//

// DESCRIPTION:
//Trying to write a simple testbench for a DUT.
//======================================================================

#include <stdlib.h>
#include <iostream>
#include <vector>
// Include common routines

#include <verilated.h>

#include <sys/stat.h>  // mkdir

// Include model header, generated from Verilating "top.v"
// #include "Vtb_higgs_top.h"
#include "Vtop_tb.h"

#include <boost/program_options.hpp>
#include <iostream>
#include <fstream>

#include "tb_helper.hpp"

using namespace boost::program_options;


// // If "verilator --trace" is used, include the tracing class
# include <verilated_vcd_c.h>

using namespace std;


typedef Vtop_tb top_t;
typedef TBHELPER<top_t> helper_t;



VerilatedVcdC* tfp = NULL;
// Construct the Verilated model, from Vtop.h generated from Verilating "top.v"
top_t* top = new top_t; // Or use a const unique_ptr, or the VL_UNIQUE_PTR wrapper
// Current simulation time (64-bit unsigned)
vluint64_t main_time = 0;
// Called by $time in Verilog
double sc_time_stamp () {
	return main_time; // Note does conversion to real, to match SystemC
}

void preReset() {
	// Initialize inputs
	top->i_rst_p = 1;
	top->i_clk = 0;
}

int main(int argc, char** argv, char** env) {


	for(int i = 0; i < 2; i++) {
		cout << "hello" << endl;
	}



	// Prevent unused variable warnings
	if (0 && argc && argv && env) {}

	// Set debug level, 0 is off, 9 is highest presently used
	Verilated::debug(0);

	// Randomization reset policy
	Verilated::randReset(2);





	Verilated::traceEverOn(true);  // Verilator must compute traced signals
	VL_PRINTF("Enabling waves into wave_dump.vcd...\n");
	tfp = new VerilatedVcdC;
	top->trace(tfp, 99);  // Trace 99 levels of hierarchy

	tfp->open("wave_dump.vcd");  // Open the dump file


	/*
	 *
	 * Adding command line options
	 *
	 */

	int verify_results;
	int number_outputs;
	int function_select;
	int enable_verbose;
	int seed_number;
	try
	{
		options_description desc{"Options"};
		desc.add_options()
	    				  ("help,h", "Help screen")
						  ("verbose,v", value<int>()->default_value(0), "Verbose output")
						  ("check", value<int>()->default_value(0), "Verify the results")
						  ("seed_value", value<int>(), "Seed value for rand() function")
						  //		  ("num_output", value<int>()->default_value(0), "Specify number of outputs")
						  ("select_function", value<int>()->default_value(0), "Select Function for the tb: 0 -> dump_output");
		//	      ("pi", value<float>()->default_value(3.14f), "Pi")
		//	      ("age", value<int>()->default_value(25), "Age");

		variables_map vm;
		store(parse_command_line(argc, argv, desc), vm);
		notify(vm);

		if (vm.count("check")) {
			verify_results = vm["check"].as<int>();
			//	    	std::cout << "Check inside: " << verify_results << '\n';
		}

		/* if (vm.count("num_output")) {
	    	number_outputs = vm["num_output"].as<int>();
	    }*/

		if (vm.count("select_function")) {
			function_select = vm["select_function"].as<int>();
		}

		if (vm.count("verbose")) {
			enable_verbose = vm["verbose"].as<int>();
		}

		if (vm.count("seed_value")) {
			seed_number = vm["seed_value"].as<int>();
		}

		if (vm.count("help"))
			std::cout << desc << '\n';
		//	    else if (vm.count("check")) {
		//	    	verify_results = vm["check"].as<int>();
		//	    	std::cout << "Check inside: " << verify_results << '\n';
		//	    }
		//	    else if (vm.count("age"))
		//	      std::cout << "Age: " << vm["age"].as<int>() << '\n';
		//	    else if (vm.count("pi"))
		//	      std::cout << "Pi: " << vm["pi"].as<float>() << '\n';
	}
	catch (const error &ex)
	{
		std::cerr << ex.what() << '\n';
	}

	TBHELPER<top_t>* t = new TBHELPER<top_t>(top,&main_time,tfp);

//	top->i_rand_const_n = function_select;
	top->i_seed = seed_number;

	//bool rand_valid, rand_ready;

	if (function_select == 0) {
		top->rand_valid = false;
		top->rand_ready = false;
	} else if (function_select == 1) {
		top->rand_valid = true;
		top->rand_ready = false;
	} else if (function_select == 2) {
		top->rand_valid = false;
		top->rand_ready = true;
	} else if (function_select == 3) {
		top->rand_valid = true;
		top->rand_ready = true;
	}

	//	if (function_select == 0) {
	//		cs20in.rand_valid = false;
	//		dac_out.rand_ready = false;
	//	} else if (function_select == 1) {
	//		cs20in.rand_valid = false;
	//		dac_out.rand_ready = true;
	//	} else if (function_select == 2) {
	//		cs20in.rand_valid = true;
	//		dac_out.rand_ready = false;
	//	} else if (function_select == 3) {
	//		cs20in.rand_valid = true;
	//		dac_out.rand_ready = true;
	//	}

	preReset();

	t->reset(40);

//	t->tick(3000000 + 10000);
	t->tick(1500000 + 10000);

	// Final model cleanup
	top->final();

	// Close trace if opened

	if (tfp) {
		tfp->close();
	}

	// Destroy model
	delete top; top = NULL;
	//print_vector(output_vector);
	// Fin
	exit(0);
}
