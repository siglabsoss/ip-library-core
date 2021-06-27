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
Compile-Verilog tb_upconverter.sv
Compile-Verilog ../../hdl/duc_fixed_dds.sv
Compile-Verilog ../../hdl/duc_hb_cascade.sv
Compile-Verilog ../../hdl/duc_hb_interp_fir_h0.sv
Compile-Verilog ../../hdl/duc_skid.sv
Compile-Verilog ../../hdl/upconverter.sv

# Execute the Simulation
vsimsa -do dosim.do
