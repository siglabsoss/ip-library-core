
# FMC Slave

## Purpose

This module provides an interface between the FMC interface of the STMicro STM32F microcontroller (MCU) and the
configuration FPGA on the Copper Suicide Circuit Card Assembly (CCA) to allow for the MCU to read and write FPGA
module registers via the MIB bus.  It mimics an Asynchronous NOR flash from the FMC's perspective and uses the
FMC pause signal to pause the FMC interface while MIB/CMD bus transactions complete.

## Notes

* The module parameters need to match the MCU FMC settings.
* The module parameter FMC_CMD_ACK_TIMEOUT_CLKS needs to be set to a larger value than the MIB and CMD bus timeouts.
* The src folder contains and example STM32CubeMx project and an Eclipse software project that shows how to configure the MCU's
  FMC interface as well as issue reads and writes across it.  
* See https://FIXME/wiki/STMicro_ARM_Development_On_Windows for more info on setting up STM32CubeMx and Eclipse projects
  for STMicro MCUs.
