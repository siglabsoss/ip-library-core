vsim -c -log sim.log +access +r -lib work tb_cic_interpolator
# trace -rec uut2/*
trace -rec *
run -all
# asdb2vcd wave.asdb wave.vcd
exit
