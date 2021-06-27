// transpiled from: templates

var __f0 = function (obj) {
obj || (obj = {});
var __t, __p = '';
with (obj) {
__p += 'all: verilate compile run show\n\nclean:\n	rm -rf obj_dir\n\nverilate:\n	verilator \\\n	--trace \\\n	-cc \\\n	-O3 \\\n	-Ihdl \\\n	--top-module top_tb \\\n	--exe tb.cpp \\\n	-LDFLAGS -l:libboost_program_options.so \\\n	' +
((__t = (topFile || top + '.v')) == null ? '' : __t) +
' \\\n	top_tb.sv\n\ncompile:\n	make -j -C obj_dir/ -f Vtop_tb.mk Vtop_tb\n\nrun:\n	./obj_dir/Vtop_tb \n\nrunCC:\n	./obj_dir/Vtop_tb --select_function 0\n\nrunCR:\n	./obj_dir/Vtop_tb --select_function 1\n\nrunRC:\n	./obj_dir/Vtop_tb --select_function 2\n\nrunRR:\n	./obj_dir/Vtop_tb --select_function 3\n	\n\nshow:\n	gtkwave wave_dump.vcd -S waves.tcl &\n';

}
return __p
};

var __f1 = function (obj) {
obj || (obj = {});
var __t, __p = '', __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '//\n\n// DESCRIPTION:\n//Trying to write a simple testbench for a DUT.\n//======================================================================\n\n#include <stdlib.h>\n#include <iostream>\n#include <vector>\n// Include common routines\n\n#include <verilated.h>\n\n#include <sys/stat.h>  // mkdir\n\n// Include model header, generated from Verilating "top.v"\n// #include "Vtb_higgs_top.h"\n#include "Vtop_tb.h"\n\n#include <boost/program_options.hpp>\n#include <iostream>\n#include <fstream>\n\n#include "tb_helper.hpp" \n\nusing namespace boost::program_options;\n\n\n// // If "verilator --trace" is used, include the tracing class\n# include <verilated_vcd_c.h>\n\nusing namespace std;\n\n\ntypedef Vtop_tb top_t;\ntypedef TBHELPER<top_t> helper_t;\n\n\n\nVerilatedVcdC* tfp = NULL;\n// Construct the Verilated model, from Vtop.h generated from Verilating "top.v"\ntop_t* top = new top_t; // Or use a const unique_ptr, or the VL_UNIQUE_PTR wrapper\n// Current simulation time (64-bit unsigned)\nvluint64_t main_time = 0;\n// Called by $time in Verilog\ndouble sc_time_stamp () {\n	return main_time; // Note does conversion to real, to match SystemC\n}\n\nvoid preReset() {\n	// Initialize inputs\n	top->i_rst_p = 1;\n	top->i_clk = 0;\n}\n\nint main(int argc, char** argv, char** env) {\n\n\n	for(int i = 0; i < 2; i++) {\n		cout << "hello" << endl;\n	}\n\n\n\n	// Prevent unused variable warnings\n	if (0 && argc && argv && env) {}\n\n	// Set debug level, 0 is off, 9 is highest presently used\n	Verilated::debug(0);\n\n	// Randomization reset policy\n	Verilated::randReset(2);\n\n\n\n\n\n	Verilated::traceEverOn(true);  // Verilator must compute traced signals\n	VL_PRINTF("Enabling waves into wave_dump.vcd...\\n");\n	tfp = new VerilatedVcdC;\n	top->trace(tfp, 99);  // Trace 99 levels of hierarchy\n\n	tfp->open("wave_dump.vcd");  // Open the dump file\n\n\n	/*\n	 *\n	 * Adding command line options\n	 *\n	 */\n\n	int verify_results;\n	int number_outputs;\n	int function_select;\n	int enable_verbose;\n	int seed_number;\n	try\n	{\n		options_description desc{"Options"};\n		desc.add_options()\n	    				  ("help,h", "Help screen")\n						  ("verbose,v", value<int>()->default_value(0), "Verbose output")\n						  ("check", value<int>()->default_value(0), "Verify the results")\n						  ("seed_value", value<int>(), "Seed value for rand() function")\n						  //		  ("num_output", value<int>()->default_value(0), "Specify number of outputs")\n						  ("select_function", value<int>()->default_value(0), "Select Function for the tb: 0 -> dump_output");\n		//	      ("pi", value<float>()->default_value(3.14f), "Pi")\n		//	      ("age", value<int>()->default_value(25), "Age");\n\n		variables_map vm;\n		store(parse_command_line(argc, argv, desc), vm);\n		notify(vm);\n\n		if (vm.count("check")) {\n			verify_results = vm["check"].as<int>();\n			//	    	std::cout << "Check inside: " << verify_results << \'\\n\';\n		}\n\n		/* if (vm.count("num_output")) {\n	    	number_outputs = vm["num_output"].as<int>();\n	    }*/\n\n		if (vm.count("select_function")) {\n			function_select = vm["select_function"].as<int>();\n		}\n\n		if (vm.count("verbose")) {\n			enable_verbose = vm["verbose"].as<int>();\n		}\n\n		if (vm.count("seed_value")) {\n			seed_number = vm["seed_value"].as<int>();\n		}\n\n		if (vm.count("help"))\n			std::cout << desc << \'\\n\';\n		//	    else if (vm.count("check")) {\n		//	    	verify_results = vm["check"].as<int>();\n		//	    	std::cout << "Check inside: " << verify_results << \'\\n\';\n		//	    }\n		//	    else if (vm.count("age"))\n		//	      std::cout << "Age: " << vm["age"].as<int>() << \'\\n\';\n		//	    else if (vm.count("pi"))\n		//	      std::cout << "Pi: " << vm["pi"].as<float>() << \'\\n\';\n	}\n	catch (const error &ex)\n	{\n		std::cerr << ex.what() << \'\\n\';\n	}\n\n	TBHELPER<top_t>* t = new TBHELPER<top_t>(top,&main_time,tfp);\n\n//	top->i_rand_const_n = function_select;\n	top->i_seed = seed_number;\n\n	//bool rand_valid, rand_ready;\n\n	if (function_select == 0) {\n		top->rand_valid = false;\n		top->rand_ready = false;\n	} else if (function_select == 1) {\n		top->rand_valid = true;\n		top->rand_ready = false;\n	} else if (function_select == 2) {\n		top->rand_valid = false;\n		top->rand_ready = true;\n	} else if (function_select == 3) {\n		top->rand_valid = true;\n		top->rand_ready = true;\n	}\n\n	//	if (function_select == 0) {\n	//		cs20in.rand_valid = false;\n	//		dac_out.rand_ready = false;\n	//	} else if (function_select == 1) {\n	//		cs20in.rand_valid = false;\n	//		dac_out.rand_ready = true;\n	//	} else if (function_select == 2) {\n	//		cs20in.rand_valid = true;\n	//		dac_out.rand_ready = false;\n	//	} else if (function_select == 3) {\n	//		cs20in.rand_valid = true;\n	//		dac_out.rand_ready = true;\n	//	}\n\n	preReset();\n\n	t->reset(40);\n	';
 targets.map((t, ti) => { ;
__p += '\n	t->tick(' +
((__t = (t.length)) == null ? '' : __t) +
' + 100);\n	';
 }) ;
__p += '\n	// Final model cleanup\n	top->final();\n\n	// Close trace if opened\n\n	if (tfp) {\n		tfp->close();\n	}\n\n	// Destroy model\n	delete top; top = NULL;\n	//print_vector(output_vector);\n	// Fin\n	exit(0);\n}\n\n\n\n';

}
return __p
};

var __f4 = function (obj) {
obj || (obj = {});
var __t, __p = '', __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += 'lappend system "i_clk"\r\nlappend system "i_rst_p"\r\n\r\nset num_added [ gtkwave::addSignalsFromList $system ]\r\n';
 targets.map((t, ti) => { ;
__p += '\r\ngtkwave::/Edit/Insert_Comment "---- t' +
((__t = (ti)) == null ? '' : __t) +
' ----"\r\n\r\nlappend t' +
((__t = (ti)) == null ? '' : __t) +
' "top_tb.t' +
((__t = (ti)) == null ? '' : __t) +
'_data"\r\nlappend t' +
((__t = (ti)) == null ? '' : __t) +
' "top_tb.t' +
((__t = (ti)) == null ? '' : __t) +
'_valid"\r\nlappend t' +
((__t = (ti)) == null ? '' : __t) +
' "top_tb.t' +
((__t = (ti)) == null ? '' : __t) +
'_ready"\r\n\r\nset num_added [ gtkwave::addSignalsFromList $t' +
((__t = (ti)) == null ? '' : __t) +
' ]\r\n';
 }) ;
__p += '\r\n';
 initiators.map((i, ii) => { ;
__p += '\r\ngtkwave::/Edit/Insert_Comment "---- i' +
((__t = (ii)) == null ? '' : __t) +
' ----"\r\n\r\nlappend i' +
((__t = (ii)) == null ? '' : __t) +
' "top_tb.i' +
((__t = (ii)) == null ? '' : __t) +
'_data"\r\nlappend i' +
((__t = (ii)) == null ? '' : __t) +
' "top_tb.i' +
((__t = (ii)) == null ? '' : __t) +
'_valid"\r\nlappend i' +
((__t = (ii)) == null ? '' : __t) +
' "top_tb.i' +
((__t = (ii)) == null ? '' : __t) +
'_ready"\r\n\r\nset num_added [ gtkwave::addSignalsFromList $i' +
((__t = (ii)) == null ? '' : __t) +
' ]\r\n';
 }) ;
__p += '\r\ngtkwave::setZoomFactor -4';

}
return __p
};

var __f2 = function (obj) {
obj || (obj = {});
var __t, __p = '';
with (obj) {
__p += '#ifndef __TB_HELPER__\n#define __TB_HELPER__\n\n#include <stdlib.h>\n#include <iostream>\n#include <vector>\n#include <assert.h>\n// Include common routines\n//#include <verilated.h>\n\n#include <verilated_vcd_c.h>\n\n#define VEC_R_APPEND(x,y) (x).insert((x).end(), (y).rbegin(), (y).rend())\n\ntemplate <class T>\nclass TBHELPER {\n\npublic:\n  T *top;\n  uint64_t* main_time;\n  VerilatedVcdC* tfp = NULL;\n  unsigned char *clk;\n  \n  TBHELPER(T *top, uint64_t *main_time, VerilatedVcdC *tfp) {\n    this->top=top;\n    this->main_time=main_time;\n    this->tfp=tfp;\n\n    clk = &(top->i_clk);\n\n  }\n\n  // pass number of clock cycles to reset, must be even number and greater than 4\n  void reset(unsigned count) {\n    count += count % 2; // make even number\n\n    // bound minimum\n    if(count < 4) {\n        count += 4 - count;\n    }\n\n    *clk = 0;\n    top->i_rst_p = 1;\n\n//    top->RESET = 1;\n    for(auto i = 0; i < count; i++) {\n\n        if(i+2 >= count)\n        {\n            top->i_rst_p = 0;\n        }\n\n        (*main_time)++;\n        *clk = !*clk;\n        top->eval();\n        if(tfp) {tfp->dump(*main_time);}\n    }\n\n    	top->i_rst_p = 0;\n  }\n\n  void tick(unsigned count = 1){\n    for(unsigned i = 0; i < count; i++) {\n      (*main_time)++;\n      *clk = !*clk;\n      top->eval();\n      if(tfp) {tfp->dump(*main_time);}\n//      negClock(this);\n      \n      *clk = !*clk;\n      (*main_time)++;\n      top->eval();\n      if(tfp) {tfp->dump(*main_time);}\n//      posClock(this);\n    }\n  }\n    \n};\n\n#endif\n';

}
return __p
};

var __f3 = function (obj) {
obj || (obj = {});
var __t, __p = '', __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += 'module top_tb (\n        input wire          i_clk,\n        input wire          i_rst_p,\n        input wire [31:0]   i_seed,\n        input wire          rand_valid,\n        input wire          rand_ready\n        );\n\n    ';
 targets.map((t, ti) => { ;
__p += '\n        logic [' +
((__t = (t.width)) == null ? '' : __t) +
'-1:0]              mem' +
((__t = (ti)) == null ? '' : __t) +
' [' +
((__t = (t.length)) == null ? '' : __t) +
'-1:0]; // depth and width are controlled by template\n        logic [$clog2(' +
((__t = (t.length)) == null ? '' : __t) +
')-1 : 0]   read_addr' +
((__t = (ti)) == null ? '' : __t) +
';\n        logic                               mem' +
((__t = (ti)) == null ? '' : __t) +
'_valid; // can be generated using $rand()\n\n        logic [31:0] random_valid' +
((__t = (ti)) == null ? '' : __t) +
';\n\n        logic [' +
((__t = (t.width)) == null ? '' : __t) +
'-1:0]                t' +
((__t = (ti)) == null ? '' : __t) +
'_data;\n        logic                                 t' +
((__t = (ti)) == null ? '' : __t) +
'_valid;\n        logic                                 t' +
((__t = (ti)) == null ? '' : __t) +
'_ready;\n    ';
 }) ;
__p += '\n    ';
 initiators.map((i, ii) => { ;
__p += '\n        logic [' +
((__t = (i.width)) == null ? '' : __t) +
'-1:0]                i' +
((__t = (ii)) == null ? '' : __t) +
'_data;\n        logic                                 i' +
((__t = (ii)) == null ? '' : __t) +
'_valid;\n        logic                                 i' +
((__t = (ii)) == null ? '' : __t) +
'_ready;\n        integer f' +
((__t = (ii)) == null ? '' : __t) +
'; \n\n        logic [31:0] random_ready' +
((__t = (ii)) == null ? '' : __t) +
';\n\n\n        assign i' +
((__t = (ii)) == null ? '' : __t) +
'_ready = (rand_ready) ? random_ready' +
((__t = (ii)) == null ? '' : __t) +
'[0] : 1;\n    ';
 }) ;
__p += '\n    ';
 targets.map((t, ti) => { ;
__p += '\n        \n        assign mem' +
((__t = (ti)) == null ? '' : __t) +
'_valid = (rand_valid) ? random_valid' +
((__t = (ti)) == null ? '' : __t) +
'[0] : 1;\n    ';
 }) ;
__p += '\n    \n        initial begin\n        ';
 targets.map((t, ti) => { ;
__p += '\n                $readmemh ("' +
((__t = (t.data)) == null ? '' : __t) +
'.mif", mem' +
((__t = (ti)) == null ? '' : __t) +
');\n        ';
 }) ;
__p += '\n        ';
 initiators.map((i, ii) => { ;
__p += '\n                f' +
((__t = (ii)) == null ? '' : __t) +
' = $fopen("' +
((__t = (i.data)) == null ? '' : __t) +
'.mif","w");\n        ';
 }) ;
__p += '\n        end\n    \n        always_ff @(posedge i_clk) begin\n        ';
 initiators.map((i, ii) => { ;
__p += '\n            if (i' +
((__t = (ii)) == null ? '' : __t) +
'_ready && i' +
((__t = (ii)) == null ? '' : __t) +
'_valid) begin\n                $fwrite(f' +
((__t = (ii)) == null ? '' : __t) +
',"%h\\n",i' +
((__t = (ii)) == null ? '' : __t) +
'_data);\n            end\n        ';
 }) ;
__p += '\n        end\n    \n        logic [31:0] counter1;\n    \n    ';
 targets.map((t, ti) => { ;
__p += '\n        enum {\n            IDLE' +
((__t = (ti)) == null ? '' : __t) +
',\n            TRANSFER' +
((__t = (ti)) == null ? '' : __t) +
'\n        } CURR_STATE' +
((__t = (ti)) == null ? '' : __t) +
', NEXT_STATE' +
((__t = (ti)) == null ? '' : __t) +
';\n    ';
 }) ;
__p += '   \n        \n        always_ff @(posedge i_clk) begin\n            if (i_rst_p) begin\n            ';
 targets.map((t, ti) => { ;
__p += '\n                read_addr' +
((__t = (ti)) == null ? '' : __t) +
' <= {$clog2(' +
((__t = (t.length)) == null ? '' : __t) +
'){1\'b0}};\n                CURR_STATE' +
((__t = (ti)) == null ? '' : __t) +
' <= IDLE' +
((__t = (ti)) == null ? '' : __t) +
';\n            ';
 }) ;
__p += '\n            end else begin\n            ';
 initiators.map((i, ii) => { ;
__p += '\n                random_ready' +
((__t = (ii)) == null ? '' : __t) +
' = counter1 % (5 * ' +
((__t = (ii + 32)) == null ? '' : __t) +
');\n            ';
 }) ;
__p += '\n            ';
 targets.map((t, ti) => { ;
__p += '\n                CURR_STATE' +
((__t = (ti)) == null ? '' : __t) +
' <= NEXT_STATE' +
((__t = (ti)) == null ? '' : __t) +
';\n                random_valid' +
((__t = (ti)) == null ? '' : __t) +
' = counter1 % (2 * ' +
((__t = (ti)) == null ? '' : __t) +
' + 45);\n                if (mem' +
((__t = (ti)) == null ? '' : __t) +
'_valid && t' +
((__t = (ti)) == null ? '' : __t) +
'_ready) begin\n                    t' +
((__t = (ti)) == null ? '' : __t) +
'_data <= mem' +
((__t = (ti)) == null ? '' : __t) +
'[read_addr' +
((__t = (ti)) == null ? '' : __t) +
'];\n                    read_addr' +
((__t = (ti)) == null ? '' : __t) +
' <= read_addr' +
((__t = (ti)) == null ? '' : __t) +
' + 1;\n                end\n            ';
 }) ;
__p += '\n            end\n        end\n        \n    ';
 targets.map((t, ti) => { ;
__p += '\n        logic flag_flag' +
((__t = (ti)) == null ? '' : __t) +
';\n        logic flag' +
((__t = (ti)) == null ? '' : __t) +
';\n        always @(*) begin\n            if (i_rst_p) begin\n                t' +
((__t = (ti)) == null ? '' : __t) +
'_valid   = 0;\n                NEXT_STATE' +
((__t = (ti)) == null ? '' : __t) +
' = IDLE' +
((__t = (ti)) == null ? '' : __t) +
';\n                flag' +
((__t = (ti)) == null ? '' : __t) +
' = 1;\n                flag_flag' +
((__t = (ti)) == null ? '' : __t) +
' = 0;\n            end else begin\n                \n                case (CURR_STATE' +
((__t = (ti)) == null ? '' : __t) +
') \n                    IDLE' +
((__t = (ti)) == null ? '' : __t) +
': begin\n                        t' +
((__t = (ti)) == null ? '' : __t) +
'_valid = 0;\n                        if (mem' +
((__t = (ti)) == null ? '' : __t) +
'_valid && t' +
((__t = (ti)) == null ? '' : __t) +
'_ready && flag' +
((__t = (ti)) == null ? '' : __t) +
') begin\n                            NEXT_STATE' +
((__t = (ti)) == null ? '' : __t) +
' = TRANSFER' +
((__t = (ti)) == null ? '' : __t) +
';\n                            t' +
((__t = (ti)) == null ? '' : __t) +
'_valid = (read_addr' +
((__t = (ti)) == null ? '' : __t) +
' == 1);\n                                    \n                        end else begin\n                            t' +
((__t = (ti)) == null ? '' : __t) +
'_valid = flag_flag' +
((__t = (ti)) == null ? '' : __t) +
'; \n                        end\n                        if (flag_flag' +
((__t = (ti)) == null ? '' : __t) +
') begin\n                            if (read_addr' +
((__t = (ti)) == null ? '' : __t) +
' == 1) begin\n                                flag_flag' +
((__t = (ti)) == null ? '' : __t) +
' = 0;\n                            end\n                        end\n                    end \n                            \n                    TRANSFER' +
((__t = (ti)) == null ? '' : __t) +
': begin\n                        flag' +
((__t = (ti)) == null ? '' : __t) +
' = 0;\n                        if (read_addr' +
((__t = (ti)) == null ? '' : __t) +
' == 0) begin\n                            NEXT_STATE' +
((__t = (ti)) == null ? '' : __t) +
' = IDLE' +
((__t = (ti)) == null ? '' : __t) +
'; \n                            flag_flag' +
((__t = (ti)) == null ? '' : __t) +
' = 1;\n                        end\n                                    \n                        t' +
((__t = (ti)) == null ? '' : __t) +
'_valid = mem' +
((__t = (ti)) == null ? '' : __t) +
'_valid && t' +
((__t = (ti)) == null ? '' : __t) +
'_ready;\n                    end\n                endcase\n            \n            end\n        end\n    ';
 }) ;
__p += '   \n        ' +
((__t = (top)) == null ? '' : __t) +
' DUT (\n                ';
 targets.map((t, ti) => { ;
__p += '\n                        .' +
((__t = (t.data)) == null ? '' : __t) +
' (t' +
((__t = (ti)) == null ? '' : __t) +
'_data),\n                        .' +
((__t = (t.ready)) == null ? '' : __t) +
' (t' +
((__t = (ti)) == null ? '' : __t) +
'_ready), // ready \n                        .' +
((__t = (t.valid)) == null ? '' : __t) +
' (t' +
((__t = (ti)) == null ? '' : __t) +
'_valid), // valid\n                        ';
 }) ;
__p += '\n                ';
 initiators.map((i, ii) => { ;
__p += '\n                        .' +
((__t = (i.data)) == null ? '' : __t) +
' (i' +
((__t = (ii)) == null ? '' : __t) +
'_data),\n                        .' +
((__t = (i.ready)) == null ? '' : __t) +
' (i' +
((__t = (ii)) == null ? '' : __t) +
'_ready), // ready \n                        .' +
((__t = (i.valid)) == null ? '' : __t) +
' (i' +
((__t = (ii)) == null ? '' : __t) +
'_valid) // valid\n                        ';
 }) ;
__p += '\n                \n                ';
 if (obj.clk) { ;
__p += '\n                    ,.' +
((__t = (clk)) == null ? '' : __t) +
'  (i_clk)\n                    ';
 } ;
__p += '\n                ';
 if (obj.reset) { ;
__p += '\n                    ,.' +
((__t = (reset)) == null ? '' : __t) +
'  (i_rst_p)   \n                    ';
 } ;
__p += '\n            );\n\n        \n    typedef enum {\n        ST_IDLE,         // switch from here\n        PAT1_WORK		// pattern generation using a lfsr\n    } genfsm_states_t;\n        \n    genfsm_states_t curr_state;\n    genfsm_states_t next_state;\n        \n\n    // lfsr of 6 bits\n    logic [5:0] lfsr_pattern;\n        \n    always_ff @(posedge i_clk) begin\n\n        if (i_rst_p) begin\n            curr_state <= ST_IDLE;\n            next_state <= ST_IDLE;\n            counter1 <= {32{1\'b0}};\n\n            lfsr_pattern <= {1\'b1,{5{1\'b0}}}; // initializing lfsr by 100000   			\n\n\n        end else begin\n\n            // curr_state <= ST_IDLE;\n\n            // /* defaults */\n            counter1 <= {32{1\'b0}};\n                \n\n            // next_state\n            curr_state <= next_state;\n        \n            case (curr_state)\n                \n                ST_IDLE: begin\n                    next_state <= PAT1_WORK;\n                    counter1 <= i_seed;\n                end\n            \n                PAT1_WORK: begin\n                    /*\n                     * 20 bit lfsr -> x^20 + x^3 + 1 -> only 20bit output will be there. rest 12 bits won\'t toggle at all. \n                     * 30 bit lfsr -> x^30 + x^16 + x^15 +1\n                     * I am designing using a 32 bit adder and 6 bit lfsr so that all the bits toggle eventually. -> x^6 + x + 1\n                     */\n                    \n                    lfsr_pattern <= {lfsr_pattern[4:0],lfsr_pattern[5]}; //circular shift\n                    lfsr_pattern[1] <= lfsr_pattern[0] ^ lfsr_pattern[5];\n                    /* verilator lint_off WIDTH */\n                    counter1 <= counter1 + lfsr_pattern;	\n                    /* verilator lint_on WIDTH */\n                                                    \n                    \n                end \n            endcase\n        \n        end // if i_reset\n    end // always_ff i_clock\n    \n    \nendmodule';

}
return __p
};

module.exports = {
    'Makefile' : __f0,
    'tb.cpp' : __f1,
    'tb_helper.hpp' : __f2,
    'top_tb.sv' : __f3,
    'waves.tcl' : __f4,
};
