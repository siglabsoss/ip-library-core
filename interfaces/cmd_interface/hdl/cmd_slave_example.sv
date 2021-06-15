module cmd_slave #(
    
    parameter int unsigned CMD_DATA_BITS = 32
        
)(

    input i_sysclk,
    input i_srst,
    intf_cmd.slave cmd
);
    
    logic [CMD_DATA_BITS-1:0] reg0;
    logic [CMD_DATA_BITS-1:0] reg1;
    
    always_ff @(posedge i_sysclk) begin
        
        if(i_srst) begin
            cmd.ack <= 0;
        end else begin
            
            /* defaults */
            cmd.ack <= 0;
            
            if (cmd.sel) begin

                cmd.ack <= 1;
                
                case (cmd.byte_addr)
                    
                    0: begin
                        
                        if (cmd.rd_wr_n) begin
                            cmd.rdata <= reg0;
                        end else begin
                            reg0 <= cmd.wdata;
                        end
                        
                    end
                    
                    4: begin

                        if (cmd.rd_wr_n) begin
                            cmd.rdata <= reg1;
                        end else begin
                            reg1 <= cmd.wdata;
                        end
                    end
                    
                    default: begin
                        // do nothing 
                    end
                    
                endcase
            end
        end
    end
        
endmodule