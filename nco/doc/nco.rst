Numerically Controlled Oscillator
*********************************

This module is intended to give a high-quality NCO that can be used
to build a DDS for the purpose of small or large CFO corrections. It
is based on a 32 entry look up table of sine/cosine values that are
interpolated with the Farrow FIR filter structure.

Parameters
**********

The parameter *PWIDTH* is provided. This scales the number of bits
used to represent the phase input. For the ECP5, a time-optimized
choice is 23 bits (this leads to a single 18x18 multiply used for
each of the point evaluations while using Horner's rule to evaluate
the Farrow polynomial).

The parameter *SWIDTH* is provided. This scales the number of bits
used to represent the output samples. Again, for the ECP5, a good
choice is 18-bits unless you can afford the clock rate penalty.

Input
*****

i_phase - The phase input. This number can be interpreted as a signed
          fractional input between -0.5 and 0.5 (or equivalently an
          unsigned input between 0.0 and 1.0) that spans the entire
          unit circle.

i_valid - A strobe indicating that the input to i_phase is ready to
          be read.

Output
******

o_cosine - The cosine value corresponding to the requested phase.

o_sine   - The sine value corresponding to the requested phase.

o_valid  - A strobe indicating that the output o_cosine and o_sine
           samples are ready to be read.

Control Signals
***************

The block contains a synchronous reset. The reset clears the valid
strobe pipeline so that no more valid signals will follow a reset
until the reset is deasserted and valid data is presented at the
input.

Notes
*****

This block has 10 pipeline stages (10 clock cycles of latency from
the time i_valid goes high until the corresponding o_valid is
asserted with valid sine/cosine values).

If memory usage is a concern and there are multiple clock cycles per
input sample, then a single ROM per sine/cosine output can be used to
perform the sine/cosine look ups. Right now, the block allows an input
on every clock cycle and this requires 4 separate accesses of the
sine/cosine look up table memory.
