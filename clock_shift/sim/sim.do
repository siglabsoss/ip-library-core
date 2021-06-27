
# CREATE A LIBRARY CALLED WORK

vlib work


# COMPILE VERILOG AND SYSTEM VERILOG SOURCES 

vlog -work work ../hdl/*.v 
vlog -work work ./ddr3_fifo_tb.v
vlog -work work ../ip/lattice/ddr3_mc/inst1/ddr_p_eval/models/mem/ddr3_inst1.v
vlog -work work ../ip/lattice/ddr3_mc/inst1/ddr_p_eval/models/mem/ddr3_dimm_32_inst1.v
vlog -work work ../ip/lattice/ddr3_mc/inst1/ddr_clks_inst1.v
vlog -work work ../ip/lattice/ddr3_mc/inst1/inst1_beh.v
vlog -work work ../ip/lattice/ddr3_mc/inst1/ddr3_sdram_mem_top_wrapper_inst1.v
vlog -work work ../ip/lattice/ddr3_mc/ddr3_mc.v
vlog -work work ../ip/lattice/fifo_sc/fifo_single_clk/fifo_single_clk.v
vlog -work work ../ip/lattice/cmd_fifo_sc/cmd_fifo_sc.v
vlog -work work ../ip/lattice/data_sc/data_sc.v
vlog -work work ../ip/lattice/fifo/fifo.v
vlog -work work ../ip/lattice/out_fifo/out_fifo.v


# SIMULATE LOGGING TO SIM.LOG, ALLOWING READ ACCESS TO SIGNALS, USING LIBRARY WORK, AND WITH TEST BENCH XXX

#vsim -log sim.log +access +r -lib work ddr3_fifo_tb 
vsim  +access +r fifo_tb   -PL pmi_work -L ovi_ecp5u

# LOG ALL SIGNALS IN DESIGN

trace -rec *


# RUN UNTIL NO MORE EVENTS TO SIMULATE

run -all


# LAUNCH ACTIVE-HDL AND VIEW WAVEFORM
#
# Use -do "open -asdb wave.asdb" if you don't have a wave.do file you'd like to use.
#
# Use -do "view wave; waveconnect wave.asdb; do wave.do; wavezoom -fit" if you do.

#runexe $$ACTIVEHDLBIN\avhdl.exe -nosplash -do "open -asdb wave.asdb" "add wave *; view wave; waveconnect wave.asdb" 
runexe $$ACTIVEHDLBIN\avhdl.exe -nosplash -do "view wave; waveconnect wave.asdb; do wave.do; wavezoom -fit" 


# PEACE OUT

bye
