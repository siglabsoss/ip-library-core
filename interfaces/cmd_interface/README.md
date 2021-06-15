
# Command (CMD) Interface

## Purpose

This interface provides the standard interface to be used for the purpose of register reads and writes of module blocks within
a given FPGA.  A given FPGA will have one module that implements the CMD Master interface and multiple modules that implement
the CMD Slave interface.  The CMD Master module will likely translate read and write transactions from a higher level/external
control interface (i.e. UART, Ethernet, etc.).

The CMD interface supports single cycle read and write transactions between the Master and Slave modules.  It uses parallel address
and write data buses (each with configurable widths) along with individual module select lines and slave ACK and read data buses to facilitate
register writes and reads.  The CMD master is responsible for decoding the address from the higher level/external control interface
in order to target the appropriate CMD slave module as well as mux that slave module's ACK and read data outputs for returning
read data to the higher level/external control interface.

## Examples

Within the hdl and sim folders are examples of CMD masters and slaves and can be referenced when designing a module that implements one
or the other.

In general the CMD Master module will have an array of CMD Master interfaces while each CMD Slave module will have a single CMD Slave interface.

## Timing Diagram

The doc folder contains a timing diagram showing write and read transactions on the CMD bus.  It was created using TimingAnalyzer from
http://www.timing-diagrams.com/

## Misc

The syn folder was used to test the synthesis results when using an array of systemverilog interfaces in the CMD Master module and is not
otherwise important.  It is just there for posterity.
