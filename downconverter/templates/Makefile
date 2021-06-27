all: verilate compile run show

clean:
	rm -rf obj_dir

verilate:
	verilator \
	--trace \
	-cc \
	-O3 \
	-Ihdl \
	--top-module top_tb \
	--exe tb.cpp \
	-LDFLAGS -l:libboost_program_options.so \
	${topFile || top + '.v'} \
	top_tb.sv

compile:
	make -j -C obj_dir/ -f Vtop_tb.mk Vtop_tb

run:
	./obj_dir/Vtop_tb 

runCC:
	./obj_dir/Vtop_tb --select_function 0

runCR:
	./obj_dir/Vtop_tb --select_function 1

runRC:
	./obj_dir/Vtop_tb --select_function 2

runRR:
	./obj_dir/Vtop_tb --select_function 3
	

show:
	gtkwave wave_dump.vcd -S waves.tcl &
