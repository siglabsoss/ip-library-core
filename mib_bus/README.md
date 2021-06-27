# MIB BUS 

## Purpose

This pair of modules provides a means for performing FPGA register reads and writes over the MIB bus found on the Graviton and Copper Suicide Circuit Cards.
The MIB master implements and internal FPGA command (cmd) slave interface while the MIB slave implements an internal FPGA cmd master interface. The MIB bus 
is a multi-drop shared bus that connects the configuration FPGA on Copper Suicide to the 4x4 array of FPGAs on Copper Suicide along with the four FPGAs on Graviton.

The configuration FPGA will instantiate two MIB Master modules, one for Copper Suicide array and one for Graviton, while the remaining FPGAs will instantiate
MIB Slave modules.  The MIB slave in each FPGA will decode the most significant nibble of the MIB address/data bus during the address phase to determine 
if it is the target of the current bus transaction.  Since the MIB bus is a multi-drop shared bus each slave must tri-state its outputs unless it is the target
of the transaction.

The address and data of an MIB transaction are multiplexed onto a single address/data bus that is 16-bits wides, so it takes two Address cycles and two Data cycles
to complete an MIB transaction.  The current address width of the MIB address is 20-bits, which is due to the address width limitation of the FMC interface between
the configuration FPGA on Copper Suicide and the Microcontroller that is also on Copper Suicide.  The MIB bus can easily have the address expanded to 32-bits if
necessary in the future.

For Copper Suicide/Graviton the MIB master is intended to be connected to the FMC Slave modules which translates Microcontroller FMC reads and writes into internal
FPGA command bus reads and writes, which in turn get translated to MIB bus reads and writes if the address targets a non-Copper Suicide configuration FPGA register.

+-----+               +----------------+               +-----------------+
| MCU | <--- FMC ---> | Copper Suicide | <--- MIB ---> | Copper Suicide  |
|     |               | Config FPGA    |               | & Graviton FPGAs|
+-----+               +----------------+               +-----------------+

## Notes

* Set the parameter P_SLAVE_MIB_ADDR_MSN to a unique value for each MIB slave. 
* Set the parameter P_MIB_ACK_TIMEOUT_CLKS in the MIB master to the desired number of system clocks to wait for an MIB slave ack.  THIS SHOULD BE A SMALLER VALUE THAN THE FMC TIMEOUT.
* Set the parameter P_CMD_ACK_TIMEOUT_CLKS to the desired number of system clocks to wait for a command bus timeout in each slave FPGA.  THIS SHOULD BE A SMALLER VALUE THAN P_MIB_ACK_TIMEOUT_CLKS.

## Warnings

* The FMC, MIB, and CMD timeouts should get successively smaller (FMC, MIB, CMD timeouts = 64, 32, 16 seem reasonable)

## TODO

* Add parameter to allow for changing the number of address bits.
* Add parameter to allow for Slave FPGAs to decode more address bits than just the Most-Significant-Nibble (will need when multiple Copper Suicide boards are connected together).
* Change *_cmd_* ports of Master and Slave to slave and master cmd systemverilog interfaces respectively.
