onerror { resume }
transcript off
add wave -named_row "TEST BENCH" -height 36
add wave -noreg -height 12 -logic {/tb_mib_master_slave/tb_clk}
add wave -noreg -height 12 -logic {/tb_mib_master_slave/tb_srst}
add wave -noreg -height 12 -color 255,4,255 -logic {/tb_mib_master_slave/tb_m_cmd_sel}
add wave -noreg -height 12 -color 255,4,255 -logic {/tb_mib_master_slave/tb_m_cmd_rd_wr_n}
add wave -noreg -height 12 -color 255,4,255 -hexadecimal -literal {/tb_mib_master_slave/tb_m_cmd_byte_addr}
add wave -noreg -height 12 -color 255,4,255 -hexadecimal -literal {/tb_mib_master_slave/tb_m_cmd_wdata}
add wave -noreg -height 12 -color 255,4,255 -logic {/tb_mib_master_slave/tb_m_cmd_ack}
add wave -noreg -height 12 -color 255,4,255 -logic {/tb_mib_master_slave/tb_m_cmd_mib_timeout}
add wave -noreg -height 12 -color 255,4,255 -hexadecimal -literal {/tb_mib_master_slave/tb_m_cmd_rdata}
add wave -noreg -height 12 -color 255,158,0 -logic {/tb_mib_master_slave/tb_mib_start}
add wave -noreg -height 12 -color 255,158,0 -logic {/tb_mib_master_slave/tb_mib_rd_wr_n}
add wave -noreg -height 12 -color 255,158,0 -logic {/tb_mib_master_slave/tb_mib_slave_ack}
add wave -noreg -height 12 -color 255,158,0 -hexadecimal -literal {/tb_mib_master_slave/tb_mib_ad}
add wave -noreg -height 12 -color 255,158,0 -hexadecimal -literal {/tb_mib_master_slave/tb_m_mib_ad}
add wave -noreg -height 12 -color 255,158,0 -logic {/tb_mib_master_slave/tb_m_mib_ad_high_z}
add wave -named_row "SLAVE 0" -height 36
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s0_mib_ad}
add wave -noreg -logic {/tb_mib_master_slave/tb_s0_mib_ad_high_z}
add wave -noreg -logic {/tb_mib_master_slave/tb_s0_mib_slave_ack}
add wave -noreg -logic {/tb_mib_master_slave/tb_s0_mib_slave_ack_high_z}
add wave -noreg -logic {/tb_mib_master_slave/tb_s0_cmd_sel}
add wave -noreg -logic {/tb_mib_master_slave/tb_s0_cmd_rd_wr_n}
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s0_cmd_byte_addr}
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s0_cmd_wdata}
add wave -noreg -logic {/tb_mib_master_slave/tb_s0_cmd_ack}
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s0_cmd_rdata}
add wave -named_row "SLAVE 1" -height 36
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s1_mib_ad}
add wave -noreg -logic {/tb_mib_master_slave/tb_s1_mib_ad_high_z}
add wave -noreg -logic {/tb_mib_master_slave/tb_s1_mib_slave_ack}
add wave -noreg -logic {/tb_mib_master_slave/tb_s1_mib_slave_ack_high_z}
add wave -noreg -logic {/tb_mib_master_slave/tb_s1_cmd_sel}
add wave -noreg -logic {/tb_mib_master_slave/tb_s1_cmd_rd_wr_n}
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s1_cmd_byte_addr}
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s1_cmd_wdata}
add wave -noreg -logic {/tb_mib_master_slave/tb_s1_cmd_ack}
add wave -noreg -hexadecimal -literal {/tb_mib_master_slave/tb_s1_cmd_rdata}
cursor "Cursor 1" 1996ns  
transcript on
