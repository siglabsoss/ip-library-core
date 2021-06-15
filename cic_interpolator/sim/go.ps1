function Compile-Verilog
{
	param( [string]$Filename)
	vlog +define+SIMULATION -work work -sv2k12 -dbg $Filename

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

$srcdir = "..\hdl"

# Compile the Verilog Files
Compile-Verilog err.sv
Compile-Verilog tb_cic_interpolator.sv
Compile-Verilog $srcdir\cic_interpolator.sv
Compile-Verilog $srcdir\cic_interp_stages.sv
Compile-Verilog $srcdir\cic_interp_integrator.sv
Compile-Verilog $srcdir\cic_interp_comb.sv
Compile-Verilog $srcdir\cic_interp_compfir.sv

# Execute the Simulation
vsimsa -do dosim.do
