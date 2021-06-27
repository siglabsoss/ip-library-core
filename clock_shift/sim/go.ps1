function Compile-Verilog
{
	param( [string]$Filename)
	vlog -work work -sv2k12 -dbg $Filename

	if ($LastExitCode -ne 0) {
		echo "                                                                "
		echo "    ############################################################"
		$msg = "      Compilation of " + $Filename + " failed! "
		echo $msg
		echo "    ############################################################"
		echo "                                                                "
		exit
	}
}

# Create the Work Library
vlib work

# Compile the Verilog Files
Compile-Verilog clock_shift_tb.sv
Compile-Verilog master.sv
Compile-Verilog slave.sv

Compile-Verilog ../hdl/clock_shift.sv

Compile-Verilog ../ip/lattice/sys_pll/sys_pll.v

# Execute the Simulation
vsimsa -do dosim.do
