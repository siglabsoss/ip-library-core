#include <verilated.h>          // Defines common routines
#include "Vfwft_sc_fifo.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vfwft_sc_fifo *uut;                     // Instantiation of module
vluint64_t main_time = 0;       // Current simulation time

double sc_time_stamp () {       // Called by $time in Verilog
	return main_time;           // converts to double, to match
	// what SystemC does
}

int main(int argc, char** argv)
{
	// turn on trace or not?
	bool vcdTrace = true;
	VerilatedVcdC* tfp = NULL;

	Verilated::commandArgs(argc, argv);   // Remember args
	uut = new Vfwft_sc_fifo;   // Create instance

	uut->eval();
	uut->eval();

	if (vcdTrace)
	{
		Verilated::traceEverOn(true);

		tfp = new VerilatedVcdC;
		uut->trace(tfp, 99);

		std::string vcdname = argv[0];
		vcdname += ".vcd";
		std::cout << vcdname << std::endl;
		tfp->open(vcdname.c_str());
	}

	uut->clk = 0;
	uut->eval();

	while (!Verilated::gotFinish())
	{
		uut->clk = uut->clk ? 0 : 1;       // Toggle clock
		uut->eval();            // Evaluate model

		uut->rst = (main_time > 50) ? 0 : 1;

		if (uut->rst) {
			uut->wdata = 0;
			uut->wren = 0;
		}


		if (main_time > 51)
		{
			uut->wren = 1;
			if (uut->clk){
				uut->wdata++;           // increment only on posedge
					}

		}

		if (main_time > 60) {
			uut->rden = 1;
		}

		if (tfp != NULL)
		{
			tfp->dump (main_time);
		}

		main_time++;            // Time passes...
	}

	uut->final();               // Done simulating

	if (tfp != NULL)
	{
		tfp->close();
		delete tfp;
	}

	delete uut;

	return 0;
}
