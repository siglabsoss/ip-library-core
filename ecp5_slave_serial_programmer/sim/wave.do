onerror { resume }
transcript off
add wave -named_row "TEST BENCH" -height 36
add wave -noreg -decimal -literal {/tb_ecp5_slave_serial_programmer/tb_byte}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_byte_ack}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_byte_vld}
add wave -noreg -decimal -literal -signed2 {/tb_ecp5_slave_serial_programmer/tb_bits_rx}
add wave -noreg -decimal -literal -signed2 {/tb_ecp5_slave_serial_programmer/tb_bytes_rx}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_idle}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_fpga_status_vld}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_fpga_cfg_err}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_fpga_programmed}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_clk}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_done}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_init_n}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_prog_n}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_mclk}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_mclk_reg}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_fpga_ss_mclk}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_dout_high_z}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_dout_high_z_reg}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_dout}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_dout_reg}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_fpga_ss_din}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_srst}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/tb_start}
add wave -noreg -hexadecimal -literal -signed2 {/tb_ecp5_slave_serial_programmer/tb_test_case}
add wave -noreg -hexadecimal -literal -signed2 {/tb_ecp5_slave_serial_programmer/tb_wake_up_clks_rx}
add wave -noreg -hexadecimal -literal {/tb_ecp5_slave_serial_programmer/DUT/byte_cntr}
add wave -named_row "DUT" -height 36
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/i_clk}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/i_srst}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/i_start}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/i_byte_vld}
add wave -noreg -hexadecimal -literal {/tb_ecp5_slave_serial_programmer/DUT/i_byte}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_byte_ack}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_idle}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_fpga_cfg_err}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_fpga_programmed}
add wave -named_row "FPGA SLAVE SERIAL INTERFACE"
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_mclk}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_prog_n}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_dout_high_z}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/o_dout}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/i_init_n}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/i_done}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/done_asserted}
add wave -noreg -hexadecimal -literal {/tb_ecp5_slave_serial_programmer/DUT/done_regs}
add wave -noreg -hexadecimal -literal {/tb_ecp5_slave_serial_programmer/DUT/dout_byte_reg}
add wave -noreg -hexadecimal -literal {/tb_ecp5_slave_serial_programmer/DUT/dout_shift_cntr}
add wave -noreg -hexadecimal -literal -signed2 {/tb_ecp5_slave_serial_programmer/DUT/ecp5_ss_fsm_state}
add wave -noreg -logic {/tb_ecp5_slave_serial_programmer/DUT/init_n_asserted}
add wave -noreg -hexadecimal -literal {/tb_ecp5_slave_serial_programmer/DUT/init_n_regs}
add wave -noreg -decimal -literal -unsigned {/tb_ecp5_slave_serial_programmer/DUT/timing_cntr}
transcript on
