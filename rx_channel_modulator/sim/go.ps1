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
Compile-Verilog tb_rx_channel_modulator.sv
Compile-Verilog ../hdl/rx_chmod_dds.sv
Compile-Verilog ../hdl/rx_channel_modulator.sv

# Execute the Simulation
vsimsa -do dosim.do
