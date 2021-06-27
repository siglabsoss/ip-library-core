vsim  +access +r clock_shift_tb   -PL pmi_work -L ovi_ecp5u
trace /clock_shift_tb/*
trace /clock_shift_tb/master/*
trace /clock_shift_tb/slave/*
run 1100ms
asdb2vcd wave.asdb wave.vcd
exit
