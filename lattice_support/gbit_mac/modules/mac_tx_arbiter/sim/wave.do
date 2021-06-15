onerror { resume }
transcript off
add wave -noreg -literal {/tb_mac_tx_arbiter/tb_test_str}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/i_txmac_clk}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/i_txmac_srst}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/i_src_byte}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/i_src_byte_vld}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/i_src_last_byte}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/o_src_byte_rd}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/i_tx_macread}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/o_tx_fifoavail}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/o_tx_fifoeof}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/o_tx_fifoempty}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/o_tx_fifodata}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/o_eth_frame_fifo_overflow}
add wave -noreg -color 255,0,0 -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/rr_arb_grant_mask}
add wave -noreg -color 255,128,0 -hexadecimal -literal -unsigned {/tb_mac_tx_arbiter/DUT/rr_arb_grant}
add wave -noreg -color 0,255,255 -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/rr_arb_req_raw}
add wave -noreg -color 255,0,255 -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/rr_arb_req_masked}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/rr_arb_src_index}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/eth_frame_fifo_wren}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/eth_frame_fifo_full}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/eth_frame_fifo_din}
add wave -noreg -logic {/tb_mac_tx_arbiter/DUT/eth_frame_fifo_dout_vld}
add wave -noreg -hexadecimal -literal {/tb_mac_tx_arbiter/DUT/eth_frame_fifo_frame_cntr}
add wave -noreg -hexadecimal -literal -signed2 {/tb_mac_tx_arbiter/DUT/1unnblk.i}
cursor "Cursor 1" 49524003ps  
transcript on
