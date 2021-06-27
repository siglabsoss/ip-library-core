RX Channel Modulator
********************

The RX Modulator downconverts the true IF band pass signal to the
Baseband IF. This module allows the input signal prior to downconversion
to be located at multiple channels in the 32.25 MHz bandwidth centered
at multiple channels in that band. This parameter may be fixed prior
to synthesis or it may be modified during run-time.

Parameters
**********

The parameter *WIDTH* is provided. This scales the input and output
width of the in phase and quadrature channels simultaneously.

The parameter *NUM_CHANNELS* is provided and defaults to 4096. For
the time being, this parameter should not be altered. This parameter
controls the number of center frequencies that are allowed starting
at 0 and moving in equal increments of 32.25 MHz divided by NUM_CHANNELS.

Input Stream
************

1. i_inph - the in-phase component of the input IQ samples

2. i_quad - the quadrature component of the input IQ samples

3. i_valid - indicates that the values at i_inph and i_quad
are valid to be read by the downstream processing. Note that
there is no o_ready signal, so this block assumes that the
downstream block is always ready. This is due to the
real-time requirements of the blocks upstream (the ultimate
sample source being the ADC).

Chennel Selector
****************

1. i_phase_inc - This is a phase increment value, or in other words
it represents the channel number in use. It can vary from 0 to
NUM_CHANNELS - 1.

2. i_phase_inc_valid - This signal is driven by whatever is
controlling the channel (i_phase_inc) signal to indicate that the
current value is valid and should be written. When this is low,
activity on i_phase_inc is ignored.

Output Stream
*************

1. o_inph - the in-phase component of the input IQ samples

2. o_quad - the quadrature component of the input IQ samples

3. o_valid - indicates that the values at o_inph and o_quad
are valid to be read by the downstream processing. Note that
there is no i_ready signal, so this block assumes that the
downstream block is always ready. This is due to the
real-time requirements of the blocks upstream (the sample
source ultimately being the ADC).

Clock and Reset
***************

1. i_clock - The clock driving all logic in the module

2. i_reset - When active no processing occurs. It also resets the phase
counter and prevents o_ready from going high.
