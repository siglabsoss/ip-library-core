/*
 * Module: udp_cmd
 * 
 * Consumes UDP Packets that have been queued by the udp_pkt_router for the port established for Ethernet UDP command and control and 
 * issues the appropriate Command Bus Command.
 * 
 * The operation of this module adheres to the details provided here: https://FIXME/wiki/SigLabs_Debug_Interface
 * 
 * TODO: Add support for memory write and read commands.
 * 
 */
 
 
`include "ethernet_support_pkg.sv"
`include "udp_cmd_pkg.sv"

`default_nettype none

module udp_cmd #(
        
    parameter bit          BIG_ENDIAN           = 0,                            // Set to 1 if Ethernet UDP data is in big endian format, 0 if it's in little endian format.
    parameter int unsigned CMD_ACK_TIMEOUT_CLKS = 64,                           // This is how many clocks to wait for a CMD ACK before concluding that no ACK will ever come (SHOULD MAKE LARGER THAN MIB MASTER ACK TIMEOUT!)
    parameter bit [31:0]   HOST_IP              = {8'd192, 8'd168, 8'd2, 8'd2}, // IP address of the host PC issuing Command and Control UDP packets (this is the IP responses will be sent to)
    parameter bit [15:0]   HOST_PORT            = 16'd50001,                    // Port on the host PC that is it listening for responses on
    parameter bit [47:0]   LOCAL_MAC            = {8'd0,   8'd1,   8'd2, 8'd4}, // MAC address of the ETH FPGA 
    parameter bit [31:0]   LOCAL_IP             = {8'd192, 8'd168, 8'd2, 8'd3}, // IP address of the ETH FPGA
    parameter bit [15:0]   LOCAL_PORT           = 16'd50000,                    // Port on the ETH FPGA that is listening for Command and Control UDP packets 
    parameter              FAMILY               = "ECP5U",                      // Specifies which Lattice FPGA family this module is being used in.
    parameter bit          GBIT_MAC_DIRECT_MODE = 0,                            // 0 = this module connects to the mac_tx_arbiter module, 1 = this module connects directly to the Lattice Gbit MAC IP. 
    parameter bit          SIM_MODE             = 0                             // Set to 1 if simulating this module
        
)(

    /* UDP_PKT_ROUTER INTERFACE */ 
    input             i_rxmac_clk,
    input             i_rxmac_srst, // synchronous to i_rxmac_clk
    output reg        o_port_fifo_rd,
    input             i_port_fifo_byte_vld,
    input             i_port_fifo_last_byte,
    input  [7:0]      i_port_fifo_byte,

    /* CMD AND CTRL INTERFACES */ 
    input             i_cmd_clk,
    input             i_cmd_srst, // synchronous to i_cmd_clk
    intf_cmd.master   cmd[2**MIB_SEL_BITS],
    
    /* MAC_TX_ARBITER INTERFACE (FOR COMMAND REPLIES) */
    input             i_txmac_clk,
    input             i_txmac_srst,      // synchronous to i_txmac_clk
    output            o_eth_avail,       // indicates a full Ethernett II Frame with UDP payload is available for downstream consumption from the output FIFO (CONNECT THIS TO tx_fifoavail and tx_fifoempty OF LATTICE GBIT MAC IN DIRECT CONNECT MODE)
    output            o_eth_eof,         // end of current Ethernet II Frame
    output            o_eth_byte_vld,    // NOT USED IN LATTICE GBIT MAC DIRECT CONNECT MODE
    output     [ 7:0] o_eth_byte, 
    input             i_eth_byte_rd,
    input      [47:0] i_host_mac,        // MAC address of the host PC (either hard coded or learned via a valid ARP request from the host PC)
    
    /* ERROR REPORTING */
    output reg        o_runt_udp_cmd // pulsed for 1 clock cycle if a UDP command message is received with only a partial sequence number
    
);
    
    // range checks
    
    initial begin
        assert (UDP_SEQ_NUM_BYTES >= 1)                      else $fatal(1, "UDP_SEQ_NUM_BYTES MUST BE >= 1!");
        assert ((8*UDP_CMD_ADDR_BYTES) >= UDP_CMD_ADDR_BITS) else $fatal(1, "NOT ENOUGH UDP_CMD_ADDR_BYTES TO FIT ALL UDP_CMD_ADDR_BITS!");
    end
    
    localparam CMD_FIFO_WIDTH       = ( 8 * (UDP_CMD_DATA_BYTES + UDP_CMD_ADDR_BYTES + UDP_SEQ_NUM_BYTES + MSG_ID_BYTES) ) + 2; // +1 unknown bad request (sequence number only), +1 for known bad request (only sequence number and message ID provided, but no address, or too much or too little data)
    localparam RESP_META_FIFO_WIDTH = ( 8 * (UDP_SEQ_NUM_BYTES  + (2*MSG_ID_BYTES) ) );                                         // 2 MSG_ID_BYTES since we have to send the MSG_ACK or MSG_NACK plus the MSG_ID of the MSG_ID of the message we're responding to.
    localparam RESP_DATA_FIFO_WIDTH = 8 * UDP_CMD_DATA_BYTES; 
    
    localparam CMD_ADDR_BITS        = UDP_CMD_ADDR_BITS - MIB_SEL_BITS; // these are the number of bits used for the address on the command bus
    
    localparam SEQ_NUM_START        = (CMD_FIFO_WIDTH - 2) - 1 ;                   // -2 for unknown bad request and known bad request flags
    localparam SEQ_NUM_END          = SEQ_NUM_START - ( (8*UDP_SEQ_NUM_BYTES) - 1 );
    localparam MSG_ID_START         = SEQ_NUM_END - 1;
    localparam MSG_ID_END           = MSG_ID_START - ( (8*MSG_ID_BYTES) - 1 );
    localparam UDP_CMD_ADDR_START   = MSG_ID_END - 1;
    localparam UDP_CMD_ADDR_END     = UDP_CMD_ADDR_START - ( (8*UDP_CMD_ADDR_BYTES) - 1 );
    localparam WDATA_START          = UDP_CMD_ADDR_END - 1;
    localparam WDATA_END            = 0; // last thing
    
    // because we currently don't use all the bits of the UDP command address bytes
    localparam MIB_SEL_START       = UDP_CMD_ADDR_BITS - 1;  
    localparam MIB_SEL_END         = MIB_SEL_START - (MIB_SEL_BITS - 1);
    localparam CMD_ADDR_START      = MIB_SEL_END - 1;
    localparam CMD_ADDR_END        = 0; // last thing
    
    // synthesis translate_off
    initial begin
        $display("SEQ_NUM_START: %d", SEQ_NUM_START);
        $display("SEQ_NUM_END: %d", SEQ_NUM_END);
        $display("MSG_ID_START: %d", MSG_ID_START);
        $display("MSG_ID_END: %d", MSG_ID_END);
        $display("UDP_CMD_ADDR_START: %d", UDP_CMD_ADDR_START);
        $display("UDP_CMD_ADDR_END: %d", UDP_CMD_ADDR_END);
        $display("WDATA_START: %d", WDATA_START);
        $display("WDATA_END: %d", WDATA_END);
        $display("MIB_SEL_START: %d", MIB_SEL_START);
        $display("MIB_SEL_END: %d", MIB_SEL_END);
    end
    // synthesis translate_on
    
    
    enum {
        WAIT_FOR_UDP_CMD,
        CAP_SEQ_NUM,
        CAP_MSG_ID,
        CAP_ADDR,
        CAP_WDATA,
        DROP_PAD_BYTES,
        QUEUE_KNOWN_BAD_CMD,
        QUEUE_UNKNOWN_BAD_CMD,
        QUEUE_GOOD_CMD
    } udp_cmd_fsm_state;
    
    logic [15:0]                       udp_byte_cntr;
    logic [(8*UDP_SEQ_NUM_BYTES)-1:0]  udp_cmd_seq_num;
    logic [(8*MSG_ID_BYTES)-1:0]       udp_cmd_msg_id;
    logic [(8*UDP_CMD_DATA_BYTES)-1:0] udp_cmd_wdata;
    logic [(8*UDP_CMD_ADDR_BYTES)-1:0] udp_cmd_addr;
    logic                              cmd_fifo_wren;
    logic [CMD_FIFO_WIDTH-1:0]         cmd_fifo_wdata;
    logic                              cmd_fifo_full;
    logic                              cmd_fifo_rden;
    logic [CMD_FIFO_WIDTH-1:0]         cmd_fifo_rdata;
    logic                              cmd_fifo_rdata_vld;

    // used as "aliases" of CMD_QUEUE_FIFO output
    logic                              cmd_udp_unknown_short;
    logic                              cmd_udp_known_short;
    logic [(8*UDP_SEQ_NUM_BYTES)-1:0]  cmd_udp_seq_num;
    logic [(8*MSG_ID_BYTES)-1:0]       cmd_udp_msg_id;
    logic [(8*UDP_CMD_DATA_BYTES)-1:0] cmd_udp_wdata;
    logic [(8*UDP_CMD_ADDR_BYTES)-1:0] cmd_udp_addr;
 
    enum {
        WAIT_FOR_CMD,
        ISSUE_CMD,
        WAIT_FOR_ACK,
        QUEUE_CMD_RESP
    } cmd_fsm_state;
    
    logic [$clog2(CMD_ACK_TIMEOUT_CLKS)-1:0] cmd_ack_timeout_cntr;

    logic                             resp_meta_fifo_rden;
    logic                             resp_meta_fifo_wren;
    logic [RESP_META_FIFO_WIDTH-1:0]  resp_meta_fifo_wdata;
    logic                             resp_meta_fifo_full;
    logic                             resp_meta_fifo_rdata_vld;
    logic [RESP_META_FIFO_WIDTH-1:0]  resp_meta_fifo_rdata;

    logic                             resp_data_fifo_rden;
    logic                             resp_data_fifo_wren;
    logic [RESP_DATA_FIFO_WIDTH-1:0]  resp_data_fifo_wdata;
    logic                             resp_data_fifo_full;
    logic                             resp_data_fifo_rdata_vld;
    logic [7:0]                       resp_data_fifo_rdata;
    

    // Command Interface Related Signals
    logic [(2**MIB_SEL_BITS)-1:0]      cmd_ack;
    logic [(2**MIB_SEL_BITS)-1:0]      cmd_sel;
    logic [(8*UDP_CMD_DATA_BYTES)-1:0] cmd_rdata[(2**MIB_SEL_BITS)-1:0];
    logic                              cmd_rd_wr_n;
    logic [CMD_ADDR_BITS-1:0]          cmd_byte_addr;
    logic [(8*UDP_CMD_DATA_BYTES)-1:0] cmd_wdata;
    
    logic [MIB_SEL_BITS-1:0]           cmd_sel_index;
    logic [MIB_SEL_BITS-1:0]           cmd_sel_index_reg;
    
    
    /*
     * 
     * Reads UDP commands from the udp_pkt_router and queues them up for downstream logic to issue the commands over the command bus.
     * 
     */
    always_ff @(posedge i_rxmac_clk) begin: UDP_CMD_FSM
      
        if (i_rxmac_srst) begin
            
            cmd_fifo_wren   <= 0;
            o_port_fifo_rd    <= 0;
            o_runt_udp_cmd    <= 0;
            udp_cmd_fsm_state <= WAIT_FOR_UDP_CMD;
            
        end else begin
            
            /* defaults */
            cmd_fifo_wren <= 0;
            o_runt_udp_cmd  <= 0;
            
            case (udp_cmd_fsm_state)
                
                WAIT_FOR_UDP_CMD: begin
                    
                    if (i_port_fifo_byte_vld & ~cmd_fifo_full) begin
                        o_port_fifo_rd    <= 1; 
                        udp_byte_cntr     <= '0;
                        udp_cmd_fsm_state <= CAP_SEQ_NUM;
                    end
                end
                
                CAP_SEQ_NUM: begin

                    if (i_port_fifo_byte_vld) begin // o_port_fifo_rd already asserted
                        udp_byte_cntr   <= udp_byte_cntr + 1;
                        udp_cmd_seq_num <= (BIG_ENDIAN) ? {udp_cmd_seq_num[(8*UDP_SEQ_NUM_BYTES)-9:0], i_port_fifo_byte} : {i_port_fifo_byte, udp_cmd_seq_num[(8*UDP_SEQ_NUM_BYTES)-1:8]}; 
                        
                        // assume there are more bytes to follow
                        if (udp_byte_cntr == (UDP_SEQ_NUM_BYTES-1)) begin 
                            udp_cmd_fsm_state <= CAP_MSG_ID;
                        end
                           
                        // correct if there are not
                        if (i_port_fifo_last_byte) begin 
                            o_port_fifo_rd <= 0;
                            if ( udp_byte_cntr == (UDP_SEQ_NUM_BYTES-1) ) begin // unknown message, but at least we got a full sequence number.  queue in cmd FIFO and let downstream logic generate a response.
                                udp_cmd_fsm_state <= QUEUE_UNKNOWN_BAD_CMD;
                            end else begin                                  // unknown message and we didn't even get a complete sequence number, disregard and raise error flag
                                o_runt_udp_cmd    <= 1;
                                udp_cmd_fsm_state <= WAIT_FOR_UDP_CMD;
                            end
                        end 
                   end
                end
                 
                CAP_MSG_ID: begin // NOTE: MSG_ID IS CURRENTLY DEFINED TO BE ONLY ONE BYTE
                    
                    if (i_port_fifo_byte_vld) begin // o_port_fifo_rd already asserted
                        
                        // assume we're good and there will be a command address next
                        udp_cmd_msg_id    <= i_port_fifo_byte;
                        udp_byte_cntr     <= udp_byte_cntr + 1;
                        udp_cmd_fsm_state <= CAP_ADDR;
                        
                        // correct if not
                        if (i_port_fifo_last_byte) begin // known short command (no address provided), queue in the cmd queue and let down stream logic generate MSG_NACK response
                            o_port_fifo_rd    <= 0;
                            udp_cmd_fsm_state <= QUEUE_KNOWN_BAD_CMD;
                        end
                    end
                end
                 
                CAP_ADDR: begin
                    
                    if (i_port_fifo_byte_vld) begin // o_port_fifo_rd already asserted
                        
                        udp_byte_cntr <= udp_byte_cntr + 1;
                        udp_cmd_addr  <= (BIG_ENDIAN) ? {udp_cmd_addr[(8*UDP_CMD_ADDR_BYTES)-9:0], i_port_fifo_byte} : {i_port_fifo_byte, udp_cmd_addr[(8*UDP_CMD_ADDR_BYTES)-1:8]}; 
                        
                        if ( udp_byte_cntr == (UDP_SEQ_NUM_BYTES + MSG_ID_BYTES + UDP_CMD_ADDR_BYTES - 1) ) begin // captured address
                            
                            // assume there's are more bytes we still need to read out
                            udp_cmd_fsm_state <= (udp_cmd_msg_id == REG_WRITE_REQ) ? CAP_WDATA : DROP_PAD_BYTES;

                            // correct if not
                            if (i_port_fifo_last_byte) begin // due to Ethernet II Frame pad bytes this probably isn't the last byte (unless an upstream module has already stripped the pad bytes and it's a REG_READ_REQ)
                                o_port_fifo_rd    <= 0;
                                udp_cmd_fsm_state <= (udp_cmd_msg_id == REG_READ_REQ) ? QUEUE_GOOD_CMD : QUEUE_KNOWN_BAD_CMD;
                            end
                        end else if (i_port_fifo_last_byte) begin // failed to get complete address
                            o_port_fifo_rd    <= 0;
                            udp_cmd_fsm_state <= QUEUE_KNOWN_BAD_CMD;
                        end

                    end
                end
                 
                CAP_WDATA: begin // NOTE: SINCE WE ONLY SUPPORT REG_WRITE_REQ MSG_ID WE'LL CAPTURE UDP_CMD_DATA_BYTES WORTH OF BYTES
                    
                    if (i_port_fifo_byte_vld) begin // o_port_fifo_rd already asserted
                        udp_byte_cntr <= udp_byte_cntr + 1;
                        udp_cmd_wdata <= (BIG_ENDIAN) ? {udp_cmd_wdata[(8*UDP_CMD_DATA_BYTES)-9:0], i_port_fifo_byte} : {i_port_fifo_byte, udp_cmd_wdata[(8*UDP_CMD_DATA_BYTES)-1:8]}; 
                        
                        if ( udp_byte_cntr == (UDP_SEQ_NUM_BYTES + MSG_ID_BYTES + UDP_CMD_ADDR_BYTES + UDP_CMD_DATA_BYTES - 1) ) begin // we should be at the last write data byte of the REG_WRITE_REQ request
                            if (i_port_fifo_last_byte) begin // this should be the last byte of the command
                                o_port_fifo_rd    <= 0;
                                udp_cmd_fsm_state <= QUEUE_GOOD_CMD; // already know it's a good command because udp_cmd_msg_id had to be equal to REG_WRITE_REQ to get here. 
                            end else begin // either one of two scenarios: 1. REG_WRITE command with padding bytes or 2. some other command with more data bytes than REG_WRITE_REQ I suppose.  Drop the remaining bytes on the floor and then take the appropriate action 
                                udp_cmd_fsm_state <= DROP_PAD_BYTES;
                            end
                        end else if (i_port_fifo_last_byte) begin // failed to get all write data bytes of whatever command this was
                            o_port_fifo_rd    <= 0;
                            udp_cmd_fsm_state <= QUEUE_KNOWN_BAD_CMD; 
                        end
                    end
                end
                
                // This state pulls the remaining pad bytes of a request or remaining bytes of an unsupported command out of the udp_packet_router's port FIFO.
                DROP_PAD_BYTES: begin
                    if (i_port_fifo_byte_vld & i_port_fifo_last_byte) begin // o_port_fifo_rd already asserted
                        o_port_fifo_rd    <= 0;
                        udp_cmd_fsm_state <= ( (udp_cmd_msg_id == REG_WRITE_REQ) || (udp_cmd_msg_id == REG_READ_REQ) ) ? QUEUE_GOOD_CMD : QUEUE_KNOWN_BAD_CMD;
                    end
                end

                QUEUE_KNOWN_BAD_CMD: begin
                    // got here because we got a UDP command with a sequence number and a MSG_ID but there was something else wrong with the rest of the data (e.g. missing address or write data)
                    cmd_fifo_wren   <= 1;
                    cmd_fifo_wdata  <= {1'b0, 1'b1, udp_cmd_seq_num, udp_cmd_msg_id, {(CMD_FIFO_WIDTH - 2 - (8*(UDP_SEQ_NUM_BYTES + MSG_ID_BYTES))){1'b0}}};
                    udp_cmd_fsm_state <= WAIT_FOR_UDP_CMD;
                end

                QUEUE_UNKNOWN_BAD_CMD: begin
                    // got here because we received a UDP command with only a complete sequence number
                    cmd_fifo_wren   <= 1;
                    cmd_fifo_wdata  <= {1'b1, 1'b0, udp_cmd_seq_num, {(CMD_FIFO_WIDTH - 2 - (8*UDP_SEQ_NUM_BYTES)){1'b0}}};
                    udp_cmd_fsm_state <= WAIT_FOR_UDP_CMD;
                end
                
                QUEUE_GOOD_CMD: begin
                    cmd_fifo_wren   <= 1;
                    cmd_fifo_wdata  <= {1'b0, 1'b0, udp_cmd_seq_num, udp_cmd_msg_id, udp_cmd_addr, udp_cmd_wdata};
                    udp_cmd_fsm_state <= WAIT_FOR_UDP_CMD;
                end
                
            endcase
        end
    end

    
    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH        (32),  // can hold 32 complete read or write requests
        .WR_DEPTH_AFULL  (31), 
        .WR_WIDTH        (CMD_FIFO_WIDTH), 
        .RD_WIDTH        (CMD_FIFO_WIDTH), 
        .FAMILY          (FAMILY), 
        .IMPLEMENTATION  ("EBR"), 
        .RESET_MODE      ("sync"), 
        .WORD_SWAP       (0), 
        .SIM_MODE        (SIM_MODE)
        ) CMD_FIFO (
        .wrclk           (i_rxmac_clk), 
        .wrclk_rst       (i_rxmac_srst), 
        .rdclk           (i_cmd_clk), 
        .rdclk_rst       (i_cmd_srst), 
        .wren            (cmd_fifo_wren           ), 
        .wdata           (cmd_fifo_wdata          ), 
        .full            (cmd_fifo_full           ), 
        .afull           (), 
        .rden            (cmd_fifo_rden           ), 
        .rdata           (cmd_fifo_rdata          ), 
        .rdata_vld       (cmd_fifo_rdata_vld      ));

    // "aliases"
    assign cmd_udp_unknown_short = cmd_fifo_rdata[CMD_FIFO_WIDTH-1];
    assign cmd_udp_known_short   = cmd_fifo_rdata[CMD_FIFO_WIDTH-2];
    assign cmd_udp_seq_num       = cmd_fifo_rdata[SEQ_NUM_START:SEQ_NUM_END];
    assign cmd_udp_msg_id        = cmd_fifo_rdata[MSG_ID_START:MSG_ID_END];
    assign cmd_udp_addr          = cmd_fifo_rdata[UDP_CMD_ADDR_START:UDP_CMD_ADDR_END];
    assign cmd_udp_wdata         = cmd_fifo_rdata[WDATA_START:WDATA_END];

    always_comb begin
        cmd_sel_index = cmd_udp_addr[MIB_SEL_START:MIB_SEL_END];    
    end
    
    /*
     *  Reads from the CMD_QUEUE_FIFO and issues them on the command bus.
     *  Once a command acknowledge is received the appropriate UDP message response is generated.
     *  
     *  Since we currently only support register write and read all of our responses will be of the following form:
     *  
     *      * Seq Number of the request we're responding to
     *      * MSG_ACK | MSG_NACK | MSG_UNKNOWN
     *      * REG_WRITE_REQUEST | REQ_READ_REQUEST | MSG_UNKNOWN (when we only receive a Sequence Number and no Message ID in the original message)
     *      * Reg Read reply data (when appropriate, otherwise no data)
     */
    always_ff @(posedge i_cmd_clk) begin: CMD_FSM
        
        if (i_cmd_srst) begin
            
            cmd_fifo_rden       <= 0;
            resp_meta_fifo_wren <= 0;
            resp_data_fifo_wren <= 0;
            
        end else begin
            
            /* defaults */
            cmd_sel             <= '0; 
            cmd_fifo_rden       <= 0;
            resp_meta_fifo_wren <= 0;
            resp_data_fifo_wren <= 0;
            
            case (cmd_fsm_state)
                
                WAIT_FOR_CMD: begin

                    cmd_ack_timeout_cntr <= '0;
                    cmd_rd_wr_n          <= (cmd_udp_msg_id == REG_READ_REQ) ? 1 : 0;
                    cmd_byte_addr        <= cmd_udp_addr[CMD_ADDR_START:CMD_ADDR_END]; 
                    cmd_wdata            <= cmd_udp_wdata;
                    cmd_sel_index_reg    <= cmd_sel_index;
                    
                    if (cmd_fifo_rdata_vld & ~resp_meta_fifo_full) begin
                        
                        if (cmd_udp_unknown_short | cmd_udp_known_short) begin 
                            cmd_fifo_rden        <= 1;
                            resp_meta_fifo_wren  <= 1;
                            // unknown = reply with MSG_UNKNOWN ID for both Message ID field and in payload, known = reply with MSG_NACK in Message ID field and the received Message ID in the payload
                            
                            if (BIG_ENDIAN) begin
                                resp_meta_fifo_wdata <= (cmd_udp_unknown_short) ? {cmd_udp_seq_num, MSG_UNKNOWN, MSG_UNKNOWN} : {cmd_udp_seq_num, MSG_NACK, cmd_udp_msg_id};
                            end else begin
                                resp_meta_fifo_wdata <= (cmd_udp_unknown_short) ? {cmd_udp_seq_num, MSG_UNKNOWN, MSG_UNKNOWN} : {cmd_udp_seq_num, cmd_udp_msg_id, MSG_NACK};
                            end

                            resp_data_fifo_wren  <= 1;
                            resp_data_fifo_wdata <= '0; // used for padding out for fixed size responses 
                            cmd_fsm_state        <= QUEUE_CMD_RESP;
                        end else begin 
                            cmd_sel[cmd_sel_index] <= 1;
                            cmd_fsm_state          <= WAIT_FOR_ACK;
                        end
                    end
                end
                
                WAIT_FOR_ACK: begin
                    
                    cmd_ack_timeout_cntr <= cmd_ack_timeout_cntr + 1;
                    
                    // ORDER OF THESE IF STATEMENTS MATTERS!
                    
                    if (cmd_ack_timeout_cntr == (CMD_ACK_TIMEOUT_CLKS-1)) begin
                        cmd_fifo_rden        <= 1;
                        resp_meta_fifo_wren  <= 1;
                        
                        if (BIG_ENDIAN) begin
                            resp_meta_fifo_wdata <= {cmd_udp_seq_num, MSG_NACK, cmd_udp_msg_id};
                        end else begin
                            resp_meta_fifo_wdata <= {cmd_udp_seq_num, cmd_udp_msg_id, MSG_NACK};
                        end
                            
                        resp_data_fifo_wren  <= 1;
                        resp_data_fifo_wdata <= '0; // used for padding out for fixed size responses 
                        cmd_fsm_state        <= QUEUE_CMD_RESP;
                    end

                    if (cmd_ack[cmd_sel_index_reg]) begin
                        cmd_fifo_rden        <= 1;
                        resp_meta_fifo_wren  <= 1;
                        
                        if (BIG_ENDIAN) begin
                            resp_meta_fifo_wdata <= {cmd_udp_seq_num, MSG_ACK, cmd_udp_msg_id};
                        end else begin
                            resp_meta_fifo_wdata <= {cmd_udp_seq_num, cmd_udp_msg_id, MSG_ACK};
                        end

                        resp_data_fifo_wren  <= 1;
                        resp_data_fifo_wdata <= cmd_rdata[cmd_sel_index_reg]; // want this here even if we're doing a Reg Write since we'll use it to pad out our ACK of the command
                        cmd_fsm_state        <= QUEUE_CMD_RESP;
                    end
                    
                end
                
                QUEUE_CMD_RESP: begin
                    // dummy state to allow for reading of CMD_QUEUE_FIFO to complete
                    cmd_fsm_state <= WAIT_FOR_CMD;
                end
                
            endcase
        end
    end
        
    /* tie all common slave signals together (and pray synthesis tools are smart enough to remove duplicate logic) */
    
    generate
        genvar i;
        for (i=0; i<(2**MIB_SEL_BITS); i++) begin
            assign cmd[i].sel       = cmd_sel[i];
            assign cmd[i].rd_wr_n   = cmd_rd_wr_n;
            assign cmd[i].byte_addr = cmd_byte_addr;
            assign cmd[i].wdata     = cmd_wdata;
            assign cmd_rdata[i]     = cmd[i].rdata;
            assign cmd_ack[i]       = cmd[i].ack;
        end
    endgenerate
     

    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH        (32), 
        .WR_DEPTH_AFULL  (31), 
        .WR_WIDTH        (RESP_META_FIFO_WIDTH), 
        .RD_WIDTH        (RESP_META_FIFO_WIDTH), 
        .FAMILY          (FAMILY), 
        .IMPLEMENTATION  ("EBR"), 
        .RESET_MODE      ("sync"), 
        .WORD_SWAP       (BIG_ENDIAN), 
        .SIM_MODE        (SIM_MODE)
        ) RESP_META_FIFO (
        .wrclk           (i_cmd_clk), 
        .wrclk_rst       (i_cmd_srst), 
        .rdclk           (i_txmac_clk), 
        .rdclk_rst       (i_txmac_srst), 
        .wren            (resp_meta_fifo_wren), 
        .wdata           (resp_meta_fifo_wdata), 
        .full            (resp_meta_fifo_full), 
        .afull           (), 
        .rden            (resp_meta_fifo_rden), 
        .rdata           (resp_meta_fifo_rdata), 
        .rdata_vld       (resp_meta_fifo_rdata_vld));

    pmi_fifo_dc_fwft_v1_0 #(
        .WR_DEPTH        (32), 
        .WR_DEPTH_AFULL  (31), 
        .WR_WIDTH        (RESP_DATA_FIFO_WIDTH), 
        .RD_WIDTH        (8), 
        .FAMILY          (FAMILY), 
        .IMPLEMENTATION  ("EBR"), 
        .RESET_MODE      ("sync"), 
        .WORD_SWAP       (BIG_ENDIAN), 
        .SIM_MODE        (SIM_MODE)
        ) RESP_DATA_FIFO (
        .wrclk           (i_cmd_clk), 
        .wrclk_rst       (i_cmd_srst), 
        .rdclk           (i_txmac_clk), 
        .rdclk_rst       (i_txmac_srst), 
        .wren            (resp_data_fifo_wren), 
        .wdata           (resp_data_fifo_wdata), 
        .full            (resp_data_fifo_full), 
        .afull           (), 
        .rden            (resp_data_fifo_rden), 
        .rdata           (resp_data_fifo_rdata), 
        .rdata_vld       (resp_data_fifo_rdata_vld));

    
    udp_packetizer #(
        .NUM_ETH_FRAME_BUFFERS    (2),  // This is the number of full size Ethernet II Frames that can be buffered.  Since we currently only support Register Read and Write requests this is plenty of buffer space.
        .SEQ_NUM_BYTES            (UDP_SEQ_NUM_BYTES), 
        .SEQ_NUM_LITTLE_ENDIAN    (~BIG_ENDIAN), 
        .META_DATA_BYTES          (2*MSG_ID_BYTES), 
        .META_DATA_LITTLE_ENDIAN  (~BIG_ENDIAN), 
        .GBIT_MAC_DIRECT_MODE     (GBIT_MAC_DIRECT_MODE),
        .SIM_MODE                 (SIM_MODE)
        ) UDP_PACKETIZER_CMD (
        .i_txmac_clk              (i_txmac_clk), 
        .i_txmac_srst             (i_txmac_srst), 
        .i_start                  (resp_meta_fifo_rdata_vld), 
        .o_start_ack              (resp_meta_fifo_rden), 
        .o_done                   (), 
        .i_data_byte_vld          (resp_data_fifo_rdata_vld), 
        .i_data_byte              (resp_data_fifo_rdata), 
        .o_data_byte_rd           (resp_data_fifo_rden), 
        .i_dest_mac               (i_host_mac), 
        .i_dest_ip                (HOST_IP), 
        .i_dest_port              (HOST_PORT), 
        .i_src_mac                (LOCAL_MAC), 
        .i_src_ip                 (LOCAL_IP), 
        .i_src_port               (LOCAL_PORT), 
        .i_udp_payload_bytes      (16'(UDP_SEQ_NUM_BYTES + (2*MSG_ID_BYTES) + UDP_CMD_DATA_BYTES)), // currently all replies get padded out to this many bytes
        .i_seq_num_prsnt          (1'b1), 
        .i_seq_num                (resp_meta_fifo_rdata[RESP_META_FIFO_WIDTH-1:(RESP_META_FIFO_WIDTH-(8*UDP_SEQ_NUM_BYTES))]), 
        .i_meta_data_prsnt        (1'b1),
        .i_meta_data              (resp_meta_fifo_rdata[(RESP_META_FIFO_WIDTH)-(8*UDP_SEQ_NUM_BYTES)-1:0]), // used for MSG_ACK, MSG_NACK, MSG_UNKNOWN message IDs and MSG_ID of request being replied to.  See: https://FIXME/wiki/SigLabs_Debug_Interface#Control_Message_Packet_Structure
        .o_eth_avail              (o_eth_avail             ), 
        .o_eth_eof                (o_eth_eof               ), 
        .o_eth_byte_vld           (o_eth_byte_vld          ), 
        .o_eth_byte               (o_eth_byte              ), 
        .i_eth_byte_rd            (i_eth_byte_rd           ));
    

endmodule


`default_nettype wire