module top_tb (
        input wire          i_clk,
        input wire          i_rst_p,
        input wire [31:0]   i_seed,
        input wire          rand_valid,
        input wire          rand_ready
        );

    
        logic [32-1:0]              mem0 [1500000-1:0]; // depth and width are controlled by template
        logic [$clog2(1500000)-1 : 0]   read_addr0;
        logic                               mem0_valid; // can be generated using $rand()

        logic [31:0] random_valid0;

        logic [32-1:0]                t0_data;
        logic                                 t0_valid;
        logic                                 t0_ready;
    
        logic [16-1:0]              mem1 [128-1:0]; // depth and width are controlled by template
        logic [$clog2(128)-1 : 0]   read_addr1;
        logic                               mem1_valid; // can be generated using $rand()

        logic [31:0] random_valid1;

        logic [16-1:0]                t1_data;
        logic                                 t1_valid;
        logic                                 t1_ready;
    
    
        logic [32-1:0]                i0_data;
        logic                                 i0_valid;
        logic                                 i0_ready;
        integer f0; 

        logic [31:0] random_ready0;


        assign i0_ready = (rand_ready) ? random_ready0[0] : 1;
    
        logic [16-1:0]                i1_data;
        logic                                 i1_valid;
        logic                                 i1_ready;
        integer f1; 

        logic [31:0] random_ready1;


        assign i1_ready = (rand_ready) ? random_ready1[0] : 1;
    
    
        
        assign mem0_valid = (rand_valid) ? random_valid0[0] : 1;
    
        
        assign mem1_valid = (rand_valid) ? random_valid1[0] : 1;
    
    
        initial begin
        
                $readmemh ("i_inph_data.mif", mem0);
        
                $readmemh ("i_inph_delay_data.mif", mem1);
        
        
                f0 = $fopen("ds.mif","w");
        
                f1 = $fopen("dssd.mif","w");
        
        end
    
        always_ff @(posedge i_clk) begin
        
            if (i0_ready && i0_valid) begin
                $fwrite(f0,"%h\n",i0_data);
            end
        
            if (i1_ready && i1_valid) begin
                $fwrite(f1,"%h\n",i1_data);
            end
        
        end
    
        logic [31:0] counter1;
    
    
        enum {
            IDLE0,
            TRANSFER0
        } CURR_STATE0, NEXT_STATE0;
    
        
        
        always_ff @(posedge i_clk) begin
            if (i_rst_p) begin
            
                read_addr0 <= {$clog2(128){1'b0}};
                CURR_STATE0 <= IDLE0;
            
            end else begin
            
                random_ready0 = counter1 % (5 * 32);
            
                random_ready1 = counter1 % (5 * 33);
            
            
                CURR_STATE0 <= NEXT_STATE0;
                random_valid0 = counter1 % (2 * 0 + 45);
                if (mem0_valid && t0_ready) begin
                    t0_data <= mem0[read_addr0];
                    if (read_addr0 == 1500000) begin
                        read_addr0 <= 0;
                    end else begin
                        read_addr0 <= read_addr0 + 1;
                    end
                end
            
            end
        end
        
    
        logic flag_flag0;
        logic flag0;
        always @(*) begin
            if (i_rst_p) begin
                t0_valid   = 0;
                NEXT_STATE0 = IDLE0;
                flag0 = 1;
                flag_flag0 = 0;
            end else begin
                
                case (CURR_STATE0) 
                    IDLE0: begin
                        t0_valid = 0;
                        if (mem0_valid && t0_ready && flag0) begin
                            NEXT_STATE0 = TRANSFER0;
                            t0_valid = (read_addr0 == 1);
                                    
                        end else begin
                            t0_valid = flag_flag0; 
                        end
                        if (flag_flag0) begin
                            if (read_addr0 == 1) begin
                                flag_flag0 = 0;
                            end
                        end
                    end 
                            
                    TRANSFER0: begin
                        flag0 = 0;
                        if (read_addr0 == 0) begin
                            NEXT_STATE0 = IDLE0; 
                            flag_flag0 = 1;
                        end
                                    
                        t0_valid = mem0_valid && t0_ready;
                    end
                endcase
            
            end
        end

       
        downconverter DUT (
                
                        .i_inph_data (t0_data[15:0]),
                        
                        .i_valid (t0_valid), // valid
                        
                        .i_inph_delay_data (t0_data[31:16]),
                        
                        
                
                        .o_inph_data (i0_data[15:0]),
                         
                        .o_valid (i0_valid), // valid
                        
                        .o_quad_data (i0_data[31:16])
                         
                        
                        
                
                
                    ,.i_clock  (i_clk)
                    
                
                    ,.i_reset  (i_rst_p)   
                    
            );
    assign t1_ready = 1;
    assign t0_ready = 1;
    assign i1_valid = i0_valid;
        
    typedef enum {
        ST_IDLE,         // switch from here
        PAT1_WORK		// pattern generation using a lfsr
    } genfsm_states_t;
        
    genfsm_states_t curr_state;
    genfsm_states_t next_state;
        

    // lfsr of 6 bits
    logic [5:0] lfsr_pattern;
        
    always_ff @(posedge i_clk) begin

        if (i_rst_p) begin
            curr_state <= ST_IDLE;
            next_state <= ST_IDLE;
            counter1 <= {32{1'b0}};

            lfsr_pattern <= {1'b1,{5{1'b0}}}; // initializing lfsr by 100000   			


        end else begin

            // curr_state <= ST_IDLE;

            // /* defaults */
            counter1 <= {32{1'b0}};
                

            // next_state
            curr_state <= next_state;
        
            case (curr_state)
                
                ST_IDLE: begin
                    next_state <= PAT1_WORK;
                    counter1 <= i_seed;
                end
            
                PAT1_WORK: begin
                    /*
                     * 20 bit lfsr -> x^20 + x^3 + 1 -> only 20bit output will be there. rest 12 bits won't toggle at all. 
                     * 30 bit lfsr -> x^30 + x^16 + x^15 +1
                     * I am designing using a 32 bit adder and 6 bit lfsr so that all the bits toggle eventually. -> x^6 + x + 1
                     */
                    
                    lfsr_pattern <= {lfsr_pattern[4:0],lfsr_pattern[5]}; //circular shift
                    lfsr_pattern[1] <= lfsr_pattern[0] ^ lfsr_pattern[5];
                    /* verilator lint_off WIDTH */
                    counter1 <= counter1 + lfsr_pattern;	
                    /* verilator lint_on WIDTH */
                                                    
                    
                end 
            endcase
        
        end // if i_reset
    end // always_ff i_clock
    
    
endmodule