/*
 * Package: ethernet_support
 * 
 * Handy constants and functions related to Ethernet II Frames, UDP, TCP, and IP
 * 
 * NOTE: I DON'T SUPPORT VLAN TAGS AND I DON'T WORRY ABOUT ETHERNET FRAME CHECKSUMS.
 *       I ALSO DON'T SUPPORT IPv4 HEADER OPTIONS FIELD, JUMBO FRAMES, OR FRAGMENTATION.
 *       
 *       KEEP EVERYTHING WITHIN ONE MTU!
 * 
 * 
 */
 
`ifndef ETHERNET_SUPPORT_PKG_INCLUDED

    `define ETHERNET_SUPPORT_PKG_INCLUDED

    package ethernet_support;
    
        /*
         * 
         * ETHERNET II FRAME RELATED PARAMS/CONSTANTS
         * 
         */

        parameter                 MTU_BYTES                  = 1500;
        parameter                 IPG_BYTES                  = 12;

        parameter                 ETH_FRAME_MIN_BYTES        = 60; // 60 bytes instead of 64 because we don't currently bother with Frame CRC checksums
        parameter                 ETH_FRAME_HDR_BYTES        = 14;
        parameter                 ETH_FRAME_MAC_ADDR_BYTES   = 6; // for others to reference, hard coded else whewre in this package to 6
        parameter                 ETH_FRAME_TYPE_FIELD_BYTES = 2;
        
        parameter                 ETH_FRAME_MAX_BYTES        = MTU_BYTES + ETH_FRAME_HDR_BYTES;
        parameter                 ETH_FRAME_MAX_BYTES_BITS   = $clog2(ETH_FRAME_MAX_BYTES); 

        parameter                 ETH_TYPE_BYTES             = 2;
/* verilator lint_off LITENDIAN */ 
        parameter bit [0:1] [7:0] ETH_TYPE_ARP               = {8'h08, 8'h06};
        parameter bit [0:1] [7:0] ETH_TYPE_IPV4              = {8'h08, 8'h00};

`ifndef VERILATE_DEF
        // synthesis translate_off
        typedef struct {
            bit [0:5] [7:0] dest_mac;
            bit [0:5] [7:0] src_mac;
            bit [0:1] [7:0] eth_type;
            byte            payload [];
        } ETH_II_FRAME_T;
        // synthesis translate_on
`endif
        
        
        /*
         * 
         * ARP RELATED PARAMS/CONSTANTS (FOR IPv4 OVER ETHERNET)
         * 
         */
        
        parameter bit [0:1] [7:0] ARP_HTYPE    = {8'h00, 8'h01};
        parameter bit [0:1] [7:0] ARP_PTYPE    = {8'h08, 8'h00};
        parameter bit       [7:0] ARP_HLEN     = 8'h06;
        parameter bit       [7:0] ARP_PLEN     = 8'h04;
        parameter bit [0:1] [7:0] ARP_OPER_REQ = {8'h00, 8'h01};
        parameter bit [0:1] [7:0] ARP_OPER_REP = {8'h00, 8'h02}; 
/* verilator lint_on LITENDIAN */ 
        
        /*
         * 
         * IPv4 RELATED PARAMS/CONSTANTS
         * 
         */
        
        parameter           IPV4_HDR_BYTES          = 20;
        parameter           IPV4_IP_ADDR_BYTES      = 4; // for others to reference, hard coded else where in this package to 4 
        parameter           IPV4_PAYLOAD_MAX_BYTES  = MTU_BYTES - IPV4_HDR_BYTES;
        parameter           IPV4_HDR_PROTO_BYTE_NUM = 9;  // based on first byte of IPv4 Header being considered as byte 0
        parameter           IPV4_HDR_LAST_BYTE_NUM  = 19; // based on first byte of IPv4 Header being considered as byte 0
        
        parameter bit [7:0] IPV4_PROTO_ICMP         = 8'h01;
        parameter bit [7:0] IPV4_PROTO_UDP          = 8'h11;
        
        
        /*
         * 
         * UDP RELATED PARAMS/CONSTANTS, FUNCTIONS, AND TASKS
         * 
         */
        
        parameter UDP_HDR_BYTES              = 8;
        parameter UDP_PORT_BYTES             = 2;
        parameter UDP_LENGTH_BYTES           = 2;
        parameter UDP_PAYLOAD_MAX_BYTES      = MTU_BYTES - IPV4_HDR_BYTES - UDP_HDR_BYTES;
        // parameter UDP_PAYLOAD_MAX_BYTES_BITS = $clog2(UDP_PAYLOAD_MAX_BYTES);
        parameter UDP_RINGBUS_PAYLOAD_BYTES  = 4;

        
        // synthesis translate_off

`ifndef VERILATE_DEF
        typedef struct {
            bit [0:1] [7:0] src_port;
            bit [0:1] [7:0] dest_port;
            bit [0:1] [7:0] length;
            bit [0:1] [7:0] checksum;
        	byte            payload [];
        } UDP_PKT_T;

        /*
         * Constructs a UDP packet from the provided parameters
         */

        function automatic UDP_PKT_T create_udp_pkt ( 
            bit [0:1] [7:0] src_port, 
            bit [0:1] [7:0] dest_port,
            byte            payload []
        );
        
            UDP_PKT_T pkt;
            bit [15:0] len = 16'($size(payload) + UDP_HDR_BYTES);
            
            int unsigned pad_bytes = ($size(payload) + UDP_HDR_BYTES + IPV4_HDR_BYTES + ETH_FRAME_HDR_BYTES >= ETH_FRAME_MIN_BYTES) ? 0 : (ETH_FRAME_MIN_BYTES - $size(payload) - UDP_HDR_BYTES - IPV4_HDR_BYTES - ETH_FRAME_HDR_BYTES);

            assert ($size(payload) <= UDP_PAYLOAD_MAX_BYTES) else $fatal(0, "Error! UDP payload exceeds maximum size.  Payload bytes %d, Max Size %d", $size(payload), UDP_PAYLOAD_MAX_BYTES);
            
            pkt.src_port = src_port;
            pkt.dest_port = dest_port;
            pkt.length[0] = len[15:8];
            pkt.length[1] = len[7:0];
            pkt.checksum  = '0; // currently don't bother widh UDP checksum
            pkt.payload = new[$size(payload) + pad_bytes];
            
            for(int i=0; i<($size(payload) + pad_bytes); i++) begin
                if (i<$size(payload)) begin
                    pkt.payload[i] = payload[i];
                end else begin
                    pkt.payload[i] = '0;
                end
            end
            
            return pkt;
        
        endfunction

        
        
        // synthesis translate_on
        
        
        /*
         * 
         * HELPER TASKS
         * 
         */ 

        // synthesis translate_off

        /* 
         * Mimics the emission of a new Ethernet II frame from the Lattice Gbit MAC
         */
        task automatic emit_gbit_mac_frame (
            // used to simulate ethernet frame errors out of the mac
            input logic          vlan_tag = 0,      // used to assert rx_stat_vector[16] to indicate vlan tag detected
            input logic          crc_error = 0,     // used to assert rx_stat_vector[25] to indicate a crc error
            input logic          ipg_violation = 0, // used to assert rx_stat_vector[29] to indicate an inter packet gap time violation
            input logic          short_frame = 0,   // used to assert rx_stat_vector[30] to indicate a short frame error
            input logic          long_frame = 0,    // used to assert rx_stat_vector[31] to indicate a long frame error
            // ethernet frame and rate control
            input unsigned       ipg_clks = 12,     // controls how many clocks occur between successive packets
            input ETH_II_FRAME_T frame,
            // gbit mac rx interface signals
            const ref logic      rxmac_clk, 
            ref logic            rx_write, 
            ref logic [7:0]      rx_dbout, 
            ref logic            rx_eof, 
            ref logic            rx_error, 
            ref logic            rx_stat_en, 
            ref logic [31:0]     rx_stat_vector
        );
            int unsigned i;
            int unsigned payload_bytes = $size(frame.payload);
            
            // Range Checks
            assert (payload_bytes <= MTU_BYTES) else $fatal(0, "Error!  Ethernet frame payload exceeds MTU.  Payload bytes: %d, MTU Bytes: %d", payload_bytes, MTU_BYTES);

            // emit packet destination MAC
            for (i=0; i<ETH_FRAME_MAC_ADDR_BYTES; i++) begin
                @(posedge rxmac_clk);
                rx_write = 1;
                rx_dbout = frame.dest_mac[i];
            end
            
            // emit packet source MAC
            for (i=0; i<ETH_FRAME_MAC_ADDR_BYTES; i++) begin
                @(posedge rxmac_clk);
                rx_write = 1;
                rx_dbout = frame.src_mac[i];
            end

            // emit packet EtherType 
            for (i=0; i<ETH_FRAME_TYPE_FIELD_BYTES; i++) begin
                @(posedge rxmac_clk);
                rx_write = 1;
                rx_dbout = frame.eth_type[i];
            end
            
            // emit packet payload
            for (i=0; i<payload_bytes; i++) begin
                
                @(posedge rxmac_clk);
                
                if (i == payload_bytes/2) begin // mimic small pause in providing data from ethernet mac that was observed in Reveal Analyzer
                    rx_write = 0;
                    repeat (8) @(posedge rxmac_clk);
                end
                
                rx_write = 1;
                rx_dbout = frame.payload[i];
                
                if (i == payload_bytes-1) begin
                    rx_eof     = 1;
                    rx_stat_en = 1;
                    rx_stat_vector[16] =  (vlan_tag)      ? 1 : 0;
                    rx_stat_vector[25] =  (crc_error)     ? 1 : 0;
                    rx_stat_vector[29] =  (ipg_violation) ? 1 : 0;
                    rx_stat_vector[30] =  (short_frame)   ? 1 : 0;
                    rx_stat_vector[31] =  (long_frame)    ? 1 : 0;
                end
            end

            @(posedge rxmac_clk);
            rx_write       = 0;
            rx_eof         = 0;
            rx_stat_en     = 0;
            rx_stat_vector = 0;
            
            // inter-packet gap
            if (ipg_clks > 0) begin
                for (i=0; i<ipg_clks; i++) begin
                    @(posedge rxmac_clk);
                end
            end
        
        endtask
        
        
        /*
         *  Calculates the IPv4 Header Checksum.
         *  
         *  WARNING: IT'S UP TO THE CALLER TO ZERO OUT THE CHECKSUM FIELD WHEN APPROPRIATE (I.E. WHEN COMPUTING THE CHECKSUM FOR A NEW IPV4 PACKET)
         */
        
        function automatic bit [15:0] calc_ipv4_hdr_checksum (
            bit [0:IPV4_HDR_BYTES-1] [7:0] hdr 
        );
        
            bit [31:0] sum32 = 0;
            bit [15:0] sum16 = 0;
            int unsigned i;
            
            for(i=0; i<IPV4_HDR_BYTES; i+=2) begin
                sum32 += {hdr[i], hdr[i+1]};
            end
            
            sum16 = sum32[31:16] + sum32[15:0];
            
            return ~sum16;
        
        endfunction

        
        /*
         * Checks the validity of an IPv4 packet.  Returns 0 if all is good or -1 if an error is encountered.
         */
        
        function automatic int check_ipv4_pkt (byte pkt []);
            
            int unsigned i;
            int unsigned num_bytes = $size(pkt);
            bit [15:0] tot_len;
            bit [15:0] ident;
            bit [15:0] flags_frag;
            bit [15:0] chksum;
            bit [0:IPV4_HDR_BYTES-1] [7:0] hdr;
            
            if (num_bytes < IPV4_HDR_BYTES) begin $error ("Error! IPv4 Packet has fewer than %d bytes", IPV4_HDR_BYTES); return -1; end
            tot_len = {pkt[2], pkt[3]};
            ident = {pkt[4], pkt[5]};
            flags_frag = {pkt[6], pkt[7]};
            if (pkt[0] != 8'h45) begin $error ("Error! IPv4 Packet version and IHL = 0x%h and not 0x45", pkt[0]); return -1; end
            if (pkt[1] != 8'h00) begin $error ("Error! IPv4 Packet DSCP and ECN != 0x00"); return -1; end
            if (tot_len != num_bytes) begin $error ("Error! IPv4 Packet Total Length field specifies %d bytes, but the IPv4 Packet is actually %d bytes total", tot_len, num_bytes); return -1; end
            if ((pkt[9] != IPV4_PROTO_UDP) && (pkt[9] != IPV4_PROTO_ICMP)) begin $error ("Error! IPv4 Packet Protocol field is not set to UDP or ARP"); return -1; end
            
            for (i=0; i<IPV4_HDR_BYTES; i++) begin
                hdr[i] = pkt[i];
            end
            
            chksum = calc_ipv4_hdr_checksum(hdr);

            if (chksum) begin $error ("Error! IPv4 Packet Checksum field error.  Computed 0x%h instead of 0x0000", chksum); return -1; end
            
            return 0;
        endfunction

        /* 
         * Creates an Ethrnet II frame with the specified payload.  Adds padding bytes (zeros) to payload to meet minimum size requirements.
         */
        
        function automatic ETH_II_FRAME_T create_eth_frame (
            bit [0:5] [7:0] dest_mac,
            bit [0:5] [7:0] src_mac,
            bit [0:1] [7:0] eth_type,
            byte            payload   []
        );
            ETH_II_FRAME_T frame;
            int unsigned i;
            int unsigned payload_bytes = $size(payload);
            int unsigned num_pad_bytes = (payload_bytes + ETH_FRAME_HDR_BYTES < ETH_FRAME_MIN_BYTES) ? (ETH_FRAME_MIN_BYTES - payload_bytes - ETH_FRAME_HDR_BYTES) : 0;
        
            // Range checks
            assert (payload_bytes <= MTU_BYTES) else $fatal(0, "Error! Based on current settings the Ethernet II Frame payload must be less than or equal to %d bytes", MTU_BYTES);
            
//            $display("payload bytes %d", payload_bytes);
        
            frame.dest_mac = dest_mac;
            frame.src_mac  = src_mac;
            frame.eth_type = eth_type;
            frame.payload  = new[payload_bytes + num_pad_bytes];
            
            for (i=0; i<payload_bytes; i++) begin
                frame.payload[i] = payload[i];
            end

            if (num_pad_bytes > 0) begin
//                $display("Adding %d padding bytes (zeros) to Ethernet Frame payload", num_pad_bytes);
                for (i=0; i<num_pad_bytes; i++) begin
                    frame.payload[i+payload_bytes] = 0;
                end
            end
            
            return frame;
        
        endfunction
        
        /*
         * Creates and Ethernet frame with an ARP payload
         */
        
        function automatic ETH_II_FRAME_T create_arp_frame (
        );
        
            $fatal(0,"Error!  create_arp_frame is not implemented!");
        endfunction
            
        
        /*
         * Creates an Ethernet frame that encapsulates an IPv4 packet carrying a UDP payload
         */
        function automatic ETH_II_FRAME_T create_ipv4_udp_frame (
            bit [0:5] [7:0] dest_mac,
            bit [0:3] [7:0] dest_ip,
            bit [0:1] [7:0] dest_port,
            bit [0:5] [7:0] src_mac,
            bit [0:3] [7:0] src_ip,
            bit [0:1] [7:0] src_port,
            byte            data []
        );
            byte eth_payload []; 
            bit [0:IPV4_HDR_BYTES-1] [7:0] ipv4_hdr; 
            bit [0:UDP_HDR_BYTES-1 ] [7:0] udp_hdr;
            shortint unsigned ipv4_hdr_len;
            shortint unsigned udp_hdr_len;
            int i;
        
            // Range Checks
            assert ($size(data) <= UDP_PAYLOAD_MAX_BYTES) else $fatal(0, "Error!  UDP packet data must be less than or equal to %d bytes", UDP_PAYLOAD_MAX_BYTES);
            
            ipv4_hdr_len = IPV4_HDR_BYTES + UDP_HDR_BYTES + $size(data);
            udp_hdr_len  = UDP_HDR_BYTES + $size(data);
        
            ipv4_hdr        = {16'h4500, ipv4_hdr_len, 32'h00000000, 8'hff, IPV4_PROTO_UDP, 16'h0000, src_ip, dest_ip}; 
            ipv4_hdr[10:11] = calc_ipv4_hdr_checksum(ipv4_hdr);
            udp_hdr         = {src_port, dest_port, udp_hdr_len, 16'h0000}; // we currently don't support UDP checksums
            
            // stuff ipv4 udp packet data into ethernet payload
            eth_payload = new[ipv4_hdr_len];
            for (i=0; i<IPV4_HDR_BYTES; i++) eth_payload[i] = ipv4_hdr[i];
            for (i=0; i<UDP_HDR_BYTES; i++)  eth_payload[i+IPV4_HDR_BYTES] = udp_hdr[i];
            for (i=0; i<$size(data);i++)     eth_payload[i+(IPV4_HDR_BYTES+UDP_HDR_BYTES)] = data[i];
            
            return create_eth_frame (.dest_mac(dest_mac), .src_mac(src_mac), .eth_type(ETH_TYPE_IPV4), .payload(eth_payload));

        endfunction
        
        
        /*
         * Creates an Ethernet frame with and IPv4 payload that has an unsupported protocol.
         */
        
        function automatic ETH_II_FRAME_T create_unsupported_ethtype_frame ();
            
            byte data [1] = '{8'h00};

            return create_eth_frame (.dest_mac(48'h000000000000), .src_mac(48'h000000000000), .eth_type(16'hffff), .payload(data)); // payload will get padded out in create_eth_frame()
            
        endfunction


`endif
        
    // synthesis translate_on
    
    endpackage
    
    import ethernet_support::*;

`endif