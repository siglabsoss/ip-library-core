/*
 * Package: udp_cmd_pkg 
 * 
 * Handy constants and functions related to Ethernet UDP based command and control as layed out in
 * https://FIXME/wiki/Graviton_Ethernet_Interface
 * 
 */
 
`ifndef UDP_CMD_PKG_INCLUDED

    `define UDP_CMD_PKG_INCLUDED

    package udp_cmd_pkg;
        
        /*
         * PARAMETERS RELATED TO THE PHYSICAL ASPECTS AND USAGE OF THE COMMAND BUS.
         * THESE ARE SPECIFIED THE WAY THEY ARE BECAUSE ULTIMATELY COMMAND AND CONTROL WILL COME FROM THE ARM MICROCONTROLLER ON COPPER SUICIDE
         * VIA ITS FMC INTERFACE AND THE CFG FPGA ON COPPER SUICIDE.  THEREFORE, IN ORDER TO KEEP SOFTWARE CHANGES TO A MINIMUM, I SPECIFY THESE VALUES TO
         * MATCH WHAT THEY WILL ULTIMATELY BE.
         * 
         * Below parameters result in the Command and Control bus address being sliced as follows: 
         * 
         * ADDR[MIB_DECODE_BITS:FPGA_DECODE_BITS:MODULE_SEL_BITS:REG_SEL_BITS]
         * 
         * NOTE: MIB_DECODE_BITS + FPGA_DECODE_BITS + MODULE_SEL_BITS + REG_SEL_BITS = 26 which is the number of address bits we get of the FMC interface from the ARM MCU.
         * 
         */

        parameter int unsigned MIB_SEL_BITS       = 2;                                         // Used to determine which MIB bus is the target (matches what we're doing with the FMC bus), 2'b00 = Ethernet FPGA local cmd, 2'b01 = MIB cmd to ADC or DAC FPGAs
        parameter int unsigned FPGA_SEL_BITS      = 4;                                         // Used to determine which FPGA is the target of the Command. 
        parameter int unsigned MODULE_SEL_BITS    = 4;                                         // Used to select which module in the targeted FPGA is the target of the Command.
        parameter int unsigned REG_SEL_BITS       = 16;                                        // Used to select which register is the targeted module of the targeted FPGA is the target of the Command.
        
        parameter int unsigned MIB_ADDR_BITS = FPGA_SEL_BITS + MODULE_SEL_BITS + REG_SEL_BITS; // MIB bus address width
        
        parameter int unsigned CMD_ADDR_BITS = MIB_ADDR_BITS - FPGA_SEL_BITS;                  // CMD bus address width
        parameter int unsigned CMD_DATA_BITS = 32;                                             // CMD Bus Rd/Wr data width
 
        parameter bit          MIB_INT            = 2'b00;                                     // Bit pattern to use for accessing an internal ETH FPGA register
        parameter bit          MIB_EXT            = 2'b01;                                     // Bit pattern to use for accessing a register in either the ADC, DAC, or CFG FPGAs on Graviton

        parameter int unsigned UDP_SEQ_NUM_BYTES  = 4;                                         // Number of bytes to expect for the UDP command and control packet sequence number
        parameter int unsigned UDP_CMD_ADDR_BYTES = 4;                                         // Number of bytes to expect for the UDP command packet command address (note: not all bits are used necessarily, see below params)
        parameter int unsigned UDP_CMD_DATA_BYTES = 4;                                         // Number of bytes to expect for the UDP command packet command write data (also the number of bytes returned for a read request)
        parameter int unsigned UDP_CMD_ADDR_BITS  = MIB_ADDR_BITS + MIB_SEL_BITS;              // Number of bits of UDP_CMD_ADDR_BYTES that are actually used for commands
        
        parameter int unsigned UDP_CMD_ACK_TIMEOUT_CLKS = 512;
        parameter int unsigned MIB_MASTER_ACK_TIMEOUT_CLKS = UDP_CMD_ACK_TIMEOUT_CLKS/16;
        parameter int unsigned CMD_MASTER_ACK_TIMEOUT_CLKS = MIB_MASTER_ACK_TIMEOUT_CLKS/2;
        
        /* MESSAGE IDs */
        
        parameter MSG_ID_BYTES  = 1;

        parameter REG_WRITE_REQ = 8'h00;
        parameter REG_READ_REQ  = 8'h01;
        
        parameter MSG_ACK       = 8'hf0;
        parameter MSG_NACK      = 8'hf1;
        parameter MSG_UNKNOWN   = 8'hff;
        
    
    endpackage
    
    import udp_cmd_pkg::*;

`endif