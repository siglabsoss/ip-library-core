vsim -c -log sim.log +access +r -lib work tb_upconverter
trace -rec *
run -all
# asdb2vcd wave.asdb wave.vcd
exit
