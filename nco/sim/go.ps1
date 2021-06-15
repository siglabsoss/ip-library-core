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
Compile-Verilog tb_nco.sv
Compile-Verilog ../hdl/nco.sv

# Execute the Simulation
vsimsa -do dosim.do
