#include <verilated.h>          // Defines common routines
#include "Vfwft_dc_fifo.h"

#include "verilated_vcd_c.h"

#include <iostream>
#include <string>
#include <cstdlib>
#include <cstdio>

Vfwft_dc_fifo *uut;                     // Instantiation of module
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
	uut = new Vfwft_dc_fifo;   // Create instance

	uut->eval();
	uut->eval();

	int active;
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

	uut->rdclk = 0;
	uut->eval();

	active = 0;
	while (!Verilated::gotFinish())
	{
		uut->rdclk = uut->rdclk ? 0 : 1;       // Toggle clock
		uut->eval();            // Evaluate model


		 if (main_time % 4 == 0) {
			 active = !active;
		 }
		uut->wrclk = (active) ? 0 : 1 ;       // Toggle clock
		uut->eval();            // Evaluate model

		uut->wrclk_rst = (main_time > 50) ? 0 : 1;

		uut->rdclk_rst = (main_time > 50) ? 0 : 1;

		if (uut->wrclk_rst) {
			uut->wdata = 0;
			uut->wren = 0;
		}

		if (uut->rdclk_rst) {
			uut->rden = 0;
		}


		if (main_time > 51)
		{

			if (uut->wrclk){
				uut->wdata = (main_time % 4 == 0) ? uut->wdata + 1 : uut->wdata;           // increment only on posedge
				uut->wren = 1;
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
