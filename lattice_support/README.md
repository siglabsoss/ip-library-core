

This directory is intended to house blocks that are designed specifically to help facilitate development on Lattice FPGAs and with Lattice IP.
The Lattice IP won't necessarily be held here, but rather modules that interface with Lattice IP as well as modules that instantiate a lot of Lattice specific primitives.
Basically if there's a block that is highly specific to Lattice (either architecture or IP) it should go in this folder.
Modules that are written to infer rather than instantiate DON'T belong here unless they can only infer Lattice architecture specific primitives.