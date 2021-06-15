Cascaded Integrator Comb Filter for Decimation
**********************************************

This IP implements a standard cascade of integrator and comb sections
for decimation filtering. The output is also compensated. The decimation
factor is 313, 5 stages are used with a delay of 2 units in each of the
comb sections.

It is a simple matter to adjust the CIC stages for a different factor,
delay, and width. However, the compensation filter coefficients are
optimized for the numbers given above. One will need to provide new
coefficients to the CIC compensation filter in order to compensate
correctly for other parameters.

Hogenauer's pruning technique is not used. The design could be made a
little smaller by adding the pruning technique while maintaining the
same magnitude of error in the output rounding stage.

Note: A gain of 2.^(5*log2(313*2)-floor(5*log2(313*2))) ~ 1.366 is
embedded in the CIC section of the filter. This could be corrected
with a multiplication at the output, but for now it is not.

Parameters
**********

The parameter *WIDTH* is provided. This scales the input and output
width of the module simultaneously.

Input
*****

The input follows the standard valid/ready handshake.

i_inph - A bit vector of length WIDTH representing the in-phase channel

i_quad - A bit vector of length WIDTH representing the quadrature channel

i_valid - The valid signal for negotiating an input sample on I/Q channels

o_ready - The ready signal for negotiating an input sample on I/Q channels

Output
******

o_inph - A bit vector of length WIDTH representing the in-phase channel

o_quad - A bit vector of length WIDTH representing the quadrature channel

o_valid - A valid signal that indicates an output is ready (no ready signal)

o_inph_pos_oflow - Indicates and overflow occurred in CIC stages

o_inph_neg_oflow - Indicates and overflow occurred in CIC stages

o_quad_pos_oflow - Indicates and overflow occurred in CIC stages

o_quad_neg_oflow - Indicates and overflow occurred in CIC stages

o_cic_inph_pos_oflow - Indicates and overflow occurred in CIC compensator

o_cic_inph_neg_oflow - Indicates and overflow occurred in CIC compensator

o_cic_quad_pos_oflow - Indicates and overflow occurred in CIC compensator

o_cic_quad_neg_oflow - Indicates and overflow occurred in CIC compensator


Control Signals
***************

i_clock - The clock, must be greater than or equal to 313 times the slower sampling rate

i_reset - The reset signal resets the chain so that no extraneous valids will appear after subsequent operation proceeds
