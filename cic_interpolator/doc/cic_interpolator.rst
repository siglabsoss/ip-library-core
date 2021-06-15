Cascaded Integrator Comb Filter for Interpolation
*************************************************

This IP implements a standard cascade of integrator and comb sections
for interpolation filtering. The output is also compensated. The
interpolation factor is 313, 5 stages are used with a delay of 2
units in each of the comb sections. It is a simple matter to adjust
the CIC stages for a different factor, delay, and width. However, the
compensation filter coefficients are optimized for the numbers given
above. One will need to provide new coefficients to the CIC
compensation filter in order to compensate correctly for other
parameters.

Hogenauer's pruning technique is not used. The design could be made a
little smaller by adding the pruning technique while maintaining the
same magnitude of error in the output rounding stage.

Note: There is a gain built into the interpolation section of
2.^(log2(313.^4*2.^5)-floor(log2(313.^4*2.^5))) ~ 1.117 (linear).
This gain could be corrected by multiplying the output by 1.0/1.117
or by adjusting the input to be 1.0/1.117 times lower in amplitude
than the desired output.

Parameters
**********

The parameter *WIDTH* is provided. This scales the input and output
width of the module simultaneously.

Input
*****

The input follows the standard valid/ready handshake.

Output
******

The output follows the standard valid/ready handshake.

Control Signals
***************

The block contains an enable and a synchronous reset.
