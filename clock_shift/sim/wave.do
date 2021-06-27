onerror { resume }
transcript off
#add wave -named_row "TEST BENCH" -height 36
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_clk}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_qspi_clk}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/tb_qspi_d}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/tb_qspi_d0_out}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_qspi_sel_n}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_qspi_d0_high_z}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/tb_rd_byte}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/tb_rd_byte_addr}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_rd_byte_vld}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/tb_rd_num_bytes}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_rd_pause}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_rd_start}
#add wave -noreg -logic {/tb_nor_qspi_reader/tb_srst}
#add wave -named_row "DUT" -height 36
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_clk}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_srst}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/i_rd_byte_addr}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/i_rd_num_bytes}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_rd_pause}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_rd_start}
#add wave -noreg -logic -unsigned {/tb_nor_qspi_reader/DUT/o_rd_busy}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/o_rd_byte_vld}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/o_rd_byte}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/o_qspi_clk}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/o_qspi_sel_n}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/o_qspi_d0_high_z}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/o_qspi_d0}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_qspi_d0}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_qspi_d1}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_qspi_d2}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/i_qspi_d3}
#add wave -noreg -decimal -literal {/tb_nor_qspi_reader/DUT/flash_byte_cntr}
#add wave -noreg -decimal -literal {/tb_nor_qspi_reader/DUT/flash_dout_cntr}
#add wave -noreg -decimal -literal {/tb_nor_qspi_reader/DUT/flash_dummy_cycle_cntr}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/flash_d0_out_en}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/flash_dout_next_reg}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/flash_dout_reg}
#add wave -noreg -hexadecimal -literal -signed2 {/tb_nor_qspi_reader/DUT/flash_rd_fsm_next_state}
#add wave -noreg -hexadecimal -literal -signed2 {/tb_nor_qspi_reader/DUT/flash_rd_fsm_state}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/rd_byte_addr_reg}
#add wave -noreg -hexadecimal -literal {/tb_nor_qspi_reader/DUT/rd_num_bytes_reg}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/rd_start_pulse}
#add wave -noreg -logic {/tb_nor_qspi_reader/DUT/rd_start_reg}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_addr_counter}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_address}
 add wave -noreg {/fifo_tb/DUT/main_dut/address}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_addr_counter}
 add wave -noreg {/fifo_tb/DUT/main_dut/mem_fillcount}
 add wave -noreg {/fifo_tb/DUT/main_dut/in_get_r0}
 add wave -noreg {/fifo_tb/DUT/main_dut/in_get_r1}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_addr}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_cmd}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_cmd_burst_cnt}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_cmd_valid}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_data_mask}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_data_mask_m}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_init_start}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_mem_rst_n}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_ofly_burst_len}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_rst_n}
 add wave -noreg {/fifo_tb/DUT/main_dut/in_buff_out}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_data_mask_Q}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_write_data}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_read_data}
 add wave -noreg {/fifo_tb/DUT/main_dut/mem_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/memory_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/memory_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_cmd_addr_out}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_cmd_addr_out}
 add wave -noreg {/fifo_tb/DUT/main_dut/STATE}
 add wave -noreg {/fifo_tb/DUT/main_dut/MEM_LOGIC_STATE}
 add wave -noreg {/fifo_tb/DUT/main_dut/fifo_in_wr_cmd}
 add wave -noreg {/fifo_tb/DUT/main_dut/fifo_in_rd_cmd}
 add wave -noreg {/fifo_tb/DUT/main_dut/data_mask}
 add wave -noreg {/fifo_tb/DUT/main_dut/a}
 add wave -noreg {/fifo_tb/DUT/main_dut/b}
 add wave -noreg {/fifo_tb/DUT/main_dut/c}
 add wave -noreg {/fifo_tb/DUT/main_dut/d}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_cmd_addr_put}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_cmd_addr_put}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_cmd_addr_get}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_cmd_addr_get}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_init_done}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_read_data_valid}
 add wave -noreg {/fifo_tb/DUT/main_dut/out_fifo_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_rt_err}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_sclk_out}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_wl_err}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_clocking_good}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_cmd_rdy}
 add wave -noreg {/fifo_tb/DUT/main_dut/ddr_1_datain_rdy}
 add wave -noreg {/fifo_tb/DUT/main_dut/out_buff_out}
 add wave -noreg {/fifo_tb/DUT/main_dut/in_buff_get}
 add wave -noreg {/fifo_tb/DUT/main_dut/in_buff_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/in_buff_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/out_buff_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/mem_reset_p}
 add wave -noreg {/fifo_tb/DUT/main_dut/pll_i_clk_CLKOS}
 add wave -noreg {/fifo_tb/DUT/main_dut/i}
 add wave -noreg {/fifo_tb/DUT/main_dut/count}
 add wave -noreg {/fifo_tb/DUT/main_dut/counter_reset}
 add wave -noreg {/fifo_tb/DUT/main_dut/LOCK}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_data_mask_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_cmd_addr_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/temp}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_mask_full}
 add wave -noreg {/fifo_tb/DUT/main_dut/fifo_logic_flag}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_get}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_get}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_flag}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_flag}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/write_cmd_addr_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/read_cmd_addr_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/counter}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_data}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_put}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_get}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_reset_p}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_clk}
 add wave -noreg {/fifo_tb/DUT/main_dut/fifo_clk}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_data_valid}
 add wave -noreg {/fifo_tb/DUT/main_dut/i_ready}
 add wave -noreg {/fifo_tb/DUT/main_dut/o_data}
 add wave -noreg {/fifo_tb/DUT/main_dut/o_data_valid}
 add wave -noreg {/fifo_tb/DUT/main_dut/o_ready}
 add wave -noreg {/fifo_tb/DUT/main_dut/o_empty}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_data}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_dqs}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_addr}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_ba}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_cke}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_clk}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_cs_n}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_dm}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_odt}
 add wave -noreg {/fifo_tb/DUT/main_dut/o_lock}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_cas_n}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_ras_n}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_reset_n}
 add wave -noreg {/fifo_tb/DUT/main_dut/em_ddr_we_n}
#cursor "Cursor 1" 882692ps  
transcript on
