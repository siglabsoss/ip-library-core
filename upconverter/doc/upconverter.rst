Upconverter Module
******************

This module implements the upconverter. The upconverter takes the samples
at a rate of 31.25 MS/s and upconverts by 4 to an intermediate frequency
of 125 MS/s, then it modulates this to the IF frequency (at the time of
writing this is 35 MHz).

Parameters
**********

The parameter *WIDTH* is provided. This scales the input and output
widths for the in phase and quadrature components. The filtering inside
the module is carried out with widths that match the FPGA technology
(i.e., 52-bit accumulators, etc). This width value controls the widths
of the interface modules.

Input Stream Signals
********************

i_inph_data

    The next in-phase sample to be read when the ready signal goes high.

i_quad_data

    The next quadrature sample to be read when the ready signal does high.

o_ready

    A strobe signal that indicates when a new sample is read from the in-phase
    and quadrature input channels respectively. This signal is sent from the
    upconverter to the upstream module that provides the samples. In a typical
    application, it is pulsed for one clock cycle that is 4 times slower than
    the output frequency.

The input follows the standard valid/ready handshake but all valid signals
are taken to be an implied '1' (so data should always be ready at the input
ports).

Output Stream Signals
*********************

o_inph_data

    The next in-phase sample of the filtered and upconvertered stream. This
    output sample will be read the next time the downstream ready signal goes
    high.

o_quad_data

    The next quadrature sample of the filtered and upconvertered stream. This
    output sample will be read the next time the downstream ready signal goes
    high.

i_ready

    A strobe signal that indicates when a new sample is read from the in-phase
    and quadrature channel outputs. Data must always be available.

The output follows the standard valid/ready handshake but all valid signals
are taken to be an implied '1' (so data should always be ready at the input
ports).

Control Signals
***************

i_clock

    The primary clock for the synchronous logic in the module.

i_reset

    Synchronous reset to clear the module state.
