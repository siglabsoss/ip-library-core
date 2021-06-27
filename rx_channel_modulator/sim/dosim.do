vsim -c -log sim.log +access +r -lib work tb_rx_channel_modulator
trace -rec *
run -all
asdb2vcd wave.asdb wave.vcd
exit
