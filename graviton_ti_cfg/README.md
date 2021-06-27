
# Graviton TI Config

## Purpose

This module is used to configure the TI parts (ADC, DAC, & LMK Clock Chips) on the Graviton Circuit Card
Assembly (CCA) from the Config FPGA on Graviton via the Serial Interface (SIF) of each part.  One instantiation
of this module should be made for each TI part and the parameters set to the correct values for that part.
Each part has a configuration ROM that is initialized from a file kept in the cfg_rom_files directory.

## Notes

* Each TI part's SIF interface is slightly different, but they're all similar enough to share a common module.
* Specify parameter P_SYSCLK_DIV large enough so as to divide the supplied SYSCLK down to 10MHz or slower
  (you probably want to shoot for 5MHz or less actually) to ensure SIF timing is met with a large amount of margin.
* This module currently only supports SIF writes.

## Warnings

* The ADC's reset is active high while the DAC's is active low for instance, so the instantiating module needs
  to compensate for these slight differences.
* The LMK04133 requires that it's select line be driven low after the config registers are written (even though it's
  active low), so the instantiating module should gate the select signal from this module after configuration is done
  to drive the select line low (this module won't do it automatically).

## TODOs

* Add in a slave command (CMD) bus interface to allow for post default configuration adjustments of TI part config registers.
* Add in SIF register readback.
