vsim -c -log sim.log +access +r -lib work tb_cic_decimator
# trace -rec uut2/*
run -all
# asdb2vcd wave.asdb wave.vcd
exit
