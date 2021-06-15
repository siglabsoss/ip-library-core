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

$srcdir = "..\hdl"

# Compile the Verilog Files
Compile-Verilog tb_cic_decimator.sv
Compile-Verilog $srcdir\cic_decimator.sv
Compile-Verilog $srcdir\cic_decim_stages.sv
Compile-Verilog $srcdir\cic_decim_integrator.sv
Compile-Verilog $srcdir\cic_decim_comb.sv
Compile-Verilog $srcdir\cic_decim_compfir.sv

# Remove output files
Remove-Item test3.txt -force -ErrorAction silentlycontinue
Remove-Item test4.txt -force -ErrorAction silentlycontinue
Remove-Item test5.txt -force -ErrorAction silentlycontinue

# Execute the Simulation
vsimsa -do dosim.do
