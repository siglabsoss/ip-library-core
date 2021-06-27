
# CREATE A LIBRARY CALLED WORK

vlib work


# COMPILE VERILOG AND SYSTEM VERILOG SOURCES 

vlog -work work ../hdl/*.sv 
vlog -work work ./*.sv


# SIMULATE LOGGING TO SIM.LOG, ALLOWING READ ACCESS TO SIGNALS, USING LIBRARY WORK, AND WITH TEST BENCH XXX

vsim -log sim.log +access +r -lib work tb_ecp5_slave_serial_programmer


# LOG ALL SIGNALS IN DESIGN

trace -rec *


# RUN UNTIL NO MORE EVENTS TO SIMULATE

run -all


# LAUNCH ACTIVE-HDL AND VIEW WAVEFORM
#
# Use -do "open -asdb wave.asdb" if you don't have a wave.do file you'd like to use.
#
# Use -do "view wave; waveconnect wave.asdb; do wave.do; wavezoom -fit" if you do.

#runexe $$ACTIVEHDLBIN\avhdl.exe -nosplash -do "open -asdb wave.asdb" "view wave; waveconnect wave.asdb" 
runexe $$ACTIVEHDLBIN\avhdl.exe -nosplash -do "view wave; waveconnect wave.asdb; do wave.do; wavezoom -fit" 


# PEACE OUT

bye
