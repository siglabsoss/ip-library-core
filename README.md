# ip-library

## Purpose

This repository should house IP. IP that has been verified
through simulation and synthesis (plus on-board testing if
possible) resides in the master branch. This is *finished*
IP that should be ready for integration into a larger system.
Other branches will be created for development purposes. The
source code here will be primarily Verilog, SystemVerilog,
and VHDL. It is up to the designer to determine if it makes
sense to include software source code (see the suggested
directory structure below).

A designer may develop IP in a branch of this repository
or elsewhere (e.g., some other repository). These branches
should not be merged into the master branch until the IP
has been verified and been deemed *finished*. Anything
under the master branch should satisfy 3 criteria.

1. The IP should have been verified through simulation
or on-board. If simulated, some basic tests that verify
the functionality of the IP should be provided.

2. The IP should have been synthesized at least once. It
is preferred that the IP has been synthesized and deployed
to an FPGA at least once, but this may not be possible for
early development. In the case that it is not possible,
efforts should be made to verify that the synthesis tool
is generating *sane* (i.e., reasonable or expected) outputs.

3. The IP should have a bare minimum of documentation. In
the documentation it should have a short description. If the
IP does not adhere to one of our standard interfaces (e.g.,
the valid/ready or bvalid/bready), then the designer should
describe the interface in detail. Timing diagrams are
appreciated (but not required).

## Suggested Directory Structure

This section suggests a directory structure for each IP
subdirectory in the repository. It is recommended to
follow this structure whenever possible. Even so, each
designer should make the call when it makes more sense
to deviate from it than to maintain it. For example, if
there are 10 individual test benches, it may be necessary
to have 10 different subdirectories in the **sim/** folder.
If a subdirectory is empty (is not needed) then leave it
off. For example, the **src/** directory will often not
be needed. If more directories are needed (for example)

- module_name/
	- hdl/ (*)
		- module_name(.v,.sv,.vhd,.vhdl)
		- (other sources)
	- sim/ (*)
		- tb_module_name(.v,.sv,.vhd,.vhdl)
		- go(.sh, .csh, .bat, .ps1, .tcl)
	- src/
		- (example code for interfacing to module from software)
	- scripts/
		- (TCL, Python, etc. scripts)
	- doc/
		- module_name(.md,.rst,.)
		- (timing diagrams and other supplemental files)
	- ip/
		- vendor_name/ (lattice, custom build, etc)
			- IP_name
	- README(.md,.rst,.txt) (*)

(*) These are required.

The **module_name** is the name of the IP. For example, the
name might be *fast_fourier_transform_1024* to indicate a
piece of IP implements a 1024 point Fast Fourier Transform.

### hdl/

This subdirectory contains the synthesizable source code. It
should be self-contained and complete. So that someone could
copy this into a subdirectory, prefix all the modules with a
name and avoid possible conflicts with modules in their local
project. It is permissible to have IP depend on other IP as a
submodule, but for now, I'm recommending we avoid that and just
make copies of the submodule with appropriate prefixes to
avoid problems if the submodule is updated, but the
instantiating module remains the same.

### sim/

This subdirectory contains the test benches and simulations
used to verify the design. It is also useful as documentation
to show how the module is intended to work. It should be easy
for another designer to grab the test bench and see how the
module is intended to be instantiated. Then, looking at the simulation waveforms, another designer can quickly get a feel
for the interfaces in of them module and how they function.

When using valid/ready handshaking or bvalid/bready bursting,
the interface should be tested as well as the functionality
of the block. For example, does the block handle push back?
Does the block gracefully handle a starvation situation?

#### Automated testing

Tests are run by the `scripts/run_tests.py` function.  This script crawls the entire repo
looking for files named `go.ps1`.  This allows for multiple tests under `sim/`, for instance:

```
ip-library\
  dds\
	  sim\
		  test_data\go.ps1
			test_enable\go.ps1
```

[More information about tester](scripts/)

### src/

This subdirectory contains example code that is intended to
aid a software developer when interfacing with the module. It
might contain a header with register offsets and a short
example program showing the intended usage of these registers.
Typically, this subdirectory will be empty.

It is recommended to include a shell script (or windows batch
file) that compiles and runs the simulation(s) assuming Active-HDL is on the path. The suggested name for this
script is **go** with the appropriate suffix for your shell
or scripting language.

### scripts/

This subdirectory is a catch all for any scripts that the
designer found useful in the development or deployment or
testing of the module. The one exception is the **go** script
that runs the testbench(es) for the module. That script resides
with the tests.

### doc/

This subdirectory should contain a file that describes the
purpose of the IP. This could be a single sentence for some
IP. It could be a paragraph for more complex IP. The document
should also explain the interfaces. For IP that follow our standard internal interfaces, just reference those.

For example, "*The input samples are accepted through a standard valid/ready handshake.*" would indicate our
internal valid/ready handshake. If it were a Wishbone
interface, then you could specify that. If it were mostly
a Wishbone interface, then you could specify that with notes
detailing the deviations from the interface.

### README

This file should contain the purpose of the IP and any
relevant information for building/maintaining the IP. If
the **doc/** subdirectory is left off, then this file should
describe the ports/interfaces as well as the purpose of the
IP.

## Notes

At the end of the day. This repository is here to make our
code easier to reuse and help us as designers. So, do what
makes the most sense in that regard.
