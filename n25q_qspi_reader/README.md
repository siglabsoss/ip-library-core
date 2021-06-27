
# NOR QSPI READER

## Purpose

Simple module for reading user specified number of bytes from a Micron N25Q based NOR flash memory.
See datasheet @ https://www.micron.com/parts/nor-flash/serial-nor-flash/n25q128a13esf40g
This module will put the NOR flash in Quad-SPI Mode and then read out the specified number of bytes.

## Notes

* Set the parameter P_FLASH_BYTES to the total size of the FLASH.
* To read a specific number of bytes from a starting address you supply the starting byte address and the number of
  bytes to read while simultaneously pulsing the read start input.
* For every byte read you get a byte valid signal.
* There is a pause input to pause the reading of flash bytes.  This allows you to connect this module to a FIFO if desired.

## Warnings

* KEEP THE INPUT CLOCK AT 108MHz OR SLOWER OR RISK VIOLATING FLASH TIMING PARAMETERS.

## TODO

* ADD TIMING PARAMETERS TO ALLOW FOR FASTER CLOCKS.  THIS IS A LOW PRIORITY.
