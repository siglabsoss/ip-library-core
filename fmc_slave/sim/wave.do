onerror { resume }
transcript off
add wave -named_row "TEST BENCH" -height 36
add wave -noreg -logic {/tb_fmc_slave/tb_sys_clk}
add wave -noreg -logic {/tb_fmc_slave/tb_sys_rst}
add wave -named_row "CMD INTERFACE"
add wave -noreg -logic {/tb_fmc_slave/tb_cmd_ack}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_cmd_rdata}
add wave -noreg -logic {/tb_fmc_slave/tb_cmd_vld}
add wave -noreg -logic {/tb_fmc_slave/tb_cmd_rd_wr_n}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_cmd_addr}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_cmd_wdata}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_cmd_dummy_reg}
add wave -named_row "FMC INTERFACE"
add wave -noreg -logic {/tb_fmc_slave/tb_fmc_ne1}
add wave -noreg -logic {/tb_fmc_slave/tb_fmc_noe}
add wave -noreg -logic {/tb_fmc_slave/tb_fmc_nwe}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_fmc_a}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_fmc_d_wire}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_fmc_slave_d}
add wave -noreg -logic {/tb_fmc_slave/tb_fmc_slave_d_high_z}
add wave -noreg -logic {/tb_fmc_slave/tb_fmc_nwait}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/tb_fmc_master_d_reg}
add wave -noreg -height 32 -ascii -literal -unsigned -bold {/tb_fmc_slave/tb_test_stage_str}
add wave -named_row "DUT" -height 36
add wave -noreg -logic {/tb_fmc_slave/DUT/o_cmd_sel}
add wave -noreg -logic {/tb_fmc_slave/DUT/i_cmd_ack}
add wave -noreg -logic {/tb_fmc_slave/DUT/o_cmd_rd_wr_n}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/o_cmd_byte_addr}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/o_cmd_wdata}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/i_cmd_rdata}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/cmd_addr_reg}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/cmd_wdata_reg}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/cmd_rdata_reg}
add wave -noreg -logic {/tb_fmc_slave/DUT/cmd_rd_flag}
add wave -named_row "FMC"
add wave -noreg -logic {/tb_fmc_slave/DUT/i_fmc_ne1}
add wave -noreg -logic {/tb_fmc_slave/DUT/i_fmc_noe}
add wave -noreg -logic {/tb_fmc_slave/DUT/i_fmc_nwe}
add wave -noreg -color 255,4,255 -logic {/tb_fmc_slave/DUT/o_fmc_nwait}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/i_fmc_a}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/b_fmc_d}
add wave -noreg -hexadecimal -literal {/tb_fmc_slave/DUT/fmc_slave_fsm_state}
add wave -noreg -logic {/tb_fmc_slave/DUT/timing_cntr_en}
add wave -noreg -decimal -literal {/tb_fmc_slave/DUT/timing_cntr}
add wave -noreg -logic {/tb_fmc_slave/DUT/cs_fedge_pulse}
add wave -noreg -logic {/tb_fmc_slave/DUT/cs_redge_pulse}
add wave -noreg -logic {/tb_fmc_slave/DUT/out_en_fedge_pulse}
add wave -noreg -logic {/tb_fmc_slave/DUT/out_en_redge_pulse}
add wave -noreg -logic {/tb_fmc_slave/DUT/wr_en_fedge_pulse}
add wave -noreg -logic {/tb_fmc_slave/DUT/wr_en_redge_pulse}
transcript on
