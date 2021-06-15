
# CREATE A LIBRARY CALLED WORK

vlib work


# COMPILE VERILOG AND SYSTEM VERILOG SOURCES 

vlog -work work ../../fifos/pmi_fifo_sc_fwft_v1_0/hdl/pmi_fifo_sc_fwft_v1_0.sv
vlog -work work ../../fifos/pmi_fifo_dc_fwft_v1_0/hdl/pmi_fifo_dc_fwft_v1_0.sv
vlog -incdir ../packages -work work ../modules/eth_frame_router/hdl/*.sv
vlog -incdir ../packages -work work ../modules/ipv4_pkt_router/hdl/*.sv
vlog -incdir ../packages -work work ../modules/udp_pkt_router/hdl/*.sv
vlog +define+SIM_MODE -incdir ../packages -work work ./*.sv


# SIMULATE LOGGING TO SIM.LOG, ALLOWING READ ACCESS TO SIGNALS, USING LIBRARY WORK, AND WITH TEST BENCH XXX

vsim -log sim.log +access +r -lib work -L pmi_work tb_lattice_gbit_mac_support


# LOG ALL SIGNALS IN DESIGN

trace -decl *
#trace -decl -signals DUT_RX/*
#trace -decl -signals DUT_RX/eth_frame_router/*
#trace -decl DUT_RX/ipv4_pkt_router/*
#trace -decl DUT_RX/udp_pkt_router/*
trace -decl DUT_RX/eth_dac_data_rx/*


# RUN UNTIL NO MORE EVENTS TO SIMULATE

run -all


# LAUNCH ACTIVE-HDL AND VIEW WAVEFORM
#
# Use -do "open -asdb wave.asdb" if you don't have a wave.do file you'd like to use.
#
# Use -do "view wave; waveconnect wave.asdb; do wave.do; wavezoom -fit" if you do.

runexe avhdl.exe -nosplash -do "open -asdb wave.asdb" "view wave; waveconnect wave.asdb" 
#runexe avhdl.exe -nosplash -do "view wave; waveconnect wave.asdb; do wave.do; wavezoom -fit" 


# PEACE OUT

bye
