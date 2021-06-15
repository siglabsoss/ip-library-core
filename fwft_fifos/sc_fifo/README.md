fwft_sc_fifo
------------

Overview: This is a single clock first word fall through fifo which acts like a wrapper on a normal fifo with added functionality of `valid-ready` handshake.

Simulation commands:

Once you are in `sim` directory, 

first use `make` to build the c++ equivalent of verilog. 

then, use `./fwft_sc_fifo/Vfwft_sc_fifo` to create the *.vcd file which can be run using gtkwave.