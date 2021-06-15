#############################
Interface/Format Descriptions
#############################

This document combines three purposes. Maybe it should be split
up later... The first purpose is to describe some basic ideas
for the codebase to ensure consistency so we can all understand
the HDL written by each other. The other purpose is to start
detailing out the interfaces for the various blocks that we will
be using. Finally, I am starting preliminary descriptions of the
blocks and the interfaces that they will support.

Before getting started, I want to clear up a few things. Most of
what is included in this document is applicable to the signal
processing sections of the design. It may not be applicable to
other sections. Always do what makes the most sense. The
suggestions here are things that I have found to be helpful.
Part of the help is simply having a consistent codebase that
everyone can understand quickly and easily.

+--------------------------------------------------------------+
| Are these hard-and-fast rules or are they flexible?          |
+==============================================================+
| Ultimately, the designer/developer has flexibility to do what|
| he or she feels is correct. Just be ready to defend the      |
| decision if someone challenges it. In the end, we want       |
| designs that make sense, so do what makes sense. Usually,    |
| following these guidelines is correct. The goal is to keep   |
| your HDL consistent, portable, flexible, and easy for others |
| to understand. If these goals are serviced better by breaking|
| some rules, then do what makes sense.                        |
+--------------------------------------------------------------+

+--------------------------------------------------------------+
| Why do we need common well-defined interfaces?               |
+==============================================================+
| We need common interfaces to ensure interoperability of our  |
| blocks. This will also aid in reordering them if required.   |
| Plus, it helps us as developers share a common language for  |
| the design. This helps us to avoid ambiguity and hand-waving |
| when we are talking about the design. Ambiguity is the enemy.|
+--------------------------------------------------------------+

Without further ado, let's get started...

******************************
Registers at Block Interfaces
******************************

It is a good idea to have registers at the interfaces of larger
blocks in the design hierarchy. This means that the input and
output signals are all tied to registers. This makes it easier
to guarantee that a design will meet timing. Unfortunately, it
may not always be possible.

If combinatorial outputs are required for some reason (i.e.,
to meet a real-time schedule at the same rate as the clock
frequency), then use them. If they are not required, then
please register your outputs.

If there is a choice between either registering inputs or
outputs, it should be preferred to register the output. If we
are all consistent about this, then it will allow us to have
much better (consistent) estimates of the clock periods that
we are able to achieve with our blocks.

Note: Combinatorial inputs/outputs are okay for submodules
that are components of a larger module. The timing of the
larger module should be verified after synthesis. Then these
submodules become a part of it (i.e., they are not necessarily
intended for reuse elsewhere in the design).

The goal here is to keep timing estimates consistent and
to keep our blocks modular so we can reuse code when possible
in different parts of the design.

**************************
Port Direction Inference
**************************

Port directions are inferred by their prefix. A prefix of *i_*
indicates that the port is an input. A prefix of *o_* indicates
that the port is an output. A prefix of *b_* indicates an inout
port.

Here is an example::

    module test (
        input wire logic          i_clock,
        input wire logic          i_reset,
        input wire logic [15:0]   i_data,
        input wire logic          i_valid,
        output     logic          o_ready,
        output     logic [31:0]   o_data,
        output     logic          o_valid,
        input wire logic          i_ready
    );

**************************
Polarity Inference
**************************

Port polarity is inferred by a suffix or a lack thereof. The suffix
*_n* indicates an active low signal. The optional suffix *_p* indicates
an active high signal. This is optional, since by default, we assume
all signals are active high.

The polarity inference suffix is applied along with the port direction
prefix. For example, if we had a module with an active low reset, we
would declare it as follows::

    module test (
        input wire logic          i_clock,
        input wire logic          i_reset_n,
        input wire logic [15:0]   i_data,
        input wire logic          i_valid,
        output     logic          o_ready,
        output     logic [31:0]   o_data,
        output     logic          o_valid,
        input wire logic          i_ready
    );

The same holds true for signals local to a module. If there is an
active low signal local to a module, use the suffix *_n* to
distinguish it from other local active high logic signals.

**************************
Default Net Type
**************************

It is preferable to use code that invokes the SystemVerilog directive
to change the default net type to nothing. This is to avoid typos that
can lead to undesired behavior when a net is inferred but has not been
defined. We also follow the idea that explicit declaration of the nets
we want is a good idea from a debugging and code maintenance
point-of-view.

An example of invoking this on an empty module is::

    `default_nettype none

    module name();
    endmodule: name

    `default_nettype wire

Be sure to set the default back to wire before the end of the file.
Otherwise, the parser/synthesizer/simulator may have unpredictable
behavior on other modules. This is because the default net type is a
global directive.

**************************
Complex-Valued Conventions
**************************

When bundling together complex-valued data, there are two fields.
In rectangular format, these are the real and imaginary parts.
In polar format, these are the magnitude and angle. The convention
that we follow for bundling under rectangular format is that the
real part should occupy the least significant word and the
imaginary part should occupy the most significant word. The
convention that we follow for polar format is that the magnitude
should occupy the least significant word and the angle should
occupy the most significant word. For example, if we had a 16-bit
real and a 16-bit imaginary part, we would use the following
representation:

+------------------------+------------------------+
| Bits 31 down to 16     | Bits 15 down to 0      |
+========================+========================+
| 16-bit imaginary part  | 16-bit real part       |
+------------------------+------------------------+

The choice of 32-bit numbers here was arbitrary. It is not a
requirement. The numbers could other lengths, and they need
not be symmetrical. For example, the following representation
still adheres to the convention:

+------------------------+------------------------+
| Bits 20 down to 16     | Bits 15 down to 0      |
+========================+========================+
| 4-bit imaginary part   | 16-bit real part       |
+------------------------+------------------------+

If we had a 24-bit magnitude and an 8-bit angle, we would
represent this as:

+------------------------+------------------------+
| Bits 31 down to 24     | Bits 23 down to 0      |
+========================+========================+
| 8-bit angle            | 24-bit magnitude       |
+------------------------+------------------------+

This convention only applies when bundling these fields together
in the HDL. It doesn't apply if they are defined as separate
fields for example::

    logic [15:0] inph;
    logic [15:0] quad;

This still follows the convention since these are individual
signals. If these were going to be concatenated, then we would
use the following to adhere to the convention::

    logic [31:0] complex_sample;
    assign complex_sample = {
        quad, inph
    };

Or equivalently::

    logic [31:0] complex_sample;
    assign complex_sample[31:16] = quad;
    assign complex_sample[15:0] = inph;

**********************
Polarity Convention
**********************

Logic signals are active high unless there is a compelling reason
to make them active low. Active low logic must be indicated with the
*_n* suffix as noted in the Polarity Inference section.

When interfacing to another chip that requires an active low signal,
the internal logic in the FPGA should be active high and then
inverted at the chip boundary unless there is a very good reason.

When exposing active low pins to software via a register interface,
the signal should be inverted in the FPGA so that the software sees
it as active high.

**********************
Reset Convention
**********************

Resets should be synchronous unless there is a compelling reason
to make them otherwise. If a reset is asserted asynchronously, it
should still be deasserted synchronously in the clock domain that
it resides in. This should be handled by the HDL in that module.
For most modules, synchronous resets are preferred.

**********************
Valid/Ready Handshake
**********************

This method of transfer allows for flow control (i.e.,
regulation of the data transfer) to occur in either
direction. It is possible and acceptable to associate
multiple data fields with a single valid/ready handshake.
For example, if there is an in_phase and quadrature field
on a complex baseband signal, then both are likely to be
associated with the same valid/ready handshake.

The basic idea of the valid/ready handshake is that data is
transferred on a clock cycle when valid and ready are both
high. Data is not transferred on a clock cycle when this is
not true. If the valid signal is asserted, it must remain
asserted until the ready signal is asserted. The ready signal
may wait for the valid signal to go high before being asserted,
but the valid signal may not wait for the ready signal to go
high before being asserted. These conditions prevent lock up
from occurring. Lock up is a state when both the upstream and
downstream blocks are waiting to hear from each other, but
neither takes the initiative. The upstream block is always
responsible to initiate transactions (although the downstream
block may advertise itself as ready or not). This handshake
is modeled after the AXI Stream standard, but we don't require
that data fields are multiples of bytes, and we have limited
the number of fields to three: data, valid, and ready.

**Note:** A valid/ready handshake indicates a single transfer may
take place. If on the next cycle, the valid or ready signal is
driven low, then a transfer does not occur on that clock cycle.
For bursting behavior see the valid/ready burst interface.

A SystemVerilog interface that exemplifies this is given next::

    interface intf_vr();

        parameter integer WIDTH = 16;

        logic [WIDTH-1:0]   data;
        logic               valid;
        logic               ready;

        modport upstream(
            output valid, data,
            input  ready
        );

        modport downstream(
            input  valid, data,
            output ready
        );

    endinterface: intf_vr

If SystemVerilog interfaces are not well supported by the tools,
then we will just mimic them by using the names with prefixes. For
example::

    module upstream_module (
        input  wire logic       i_clock,
        input  wire logic       i_reset,
        output      logic [7:0] o_sample_data,
        output      logic       o_sample_valid,
        input  wire logic       i_sample_ready
    );
    endmodule

    module downstream_module (
        input  wire logic       i_clock,
        output      logic       i_reset,
        input  wire logic [7:0] i_sample_data,
        input  wire logic       i_sample_valid,
        output      logic       o_sample_ready
    );
    endmodule

Some blocks will only support flow regulation in one direction
or the other (either upstream or downstream only). These can be
implemented by tying a ready/valid signal high or by simply leaving
it off the port map. Anything left off the port map is assumed to
be driven by a constant high value. The preferred implementation is
to leave the port off of the port map.

Do not name signals valid and ready unless they have the semantics
indicated in this section. It will just confuse us.

**********************
Valid/Ready Bursting
**********************

The Valid/Ready Bursting interface indicates that a burst transaction
is required. Using this interface creates a contractual agreement
between two blocks that the burst will occur completely without
push back or gaps in the transmission. It is also possible to
use the Valid/Ready Handshake for bursts, but the contract between
those blocks is that push back and gaps in the valid signal are
allowed. For example, the FFT output and a cyclic prefix buffer
might use this type of bursting interface.

There is a one-to-one correspondence between the signals in the
Valid/Ready Burst and the signals in the Valid/Ready Handshake
described above, but we have changed their names to indicate that
they are part of the burst interface. We prefixed their names
with a *b* to set them apart from the handshaking signals. Thus,
the signal names are bvalid, bready, and bdata. This prefix is
to help avoid developer confusion.

For this interface, when bvalid and bready are both high, a burst is
initiated. Following this, bready should go low, while bvalid remains
high until the entire burst has been transferred. The downstream block
must consume the entire burst (if bready is asserted, then the block
is advertising that it has sufficient space). The bvalid signal
remains high for the duration of the burst. If another burst is
ready, the bvalid signal will remain high after the burst is complete.
The same rules as in the Valid/Ready Handshake apply here to avoid lock
up. The bvalid signal cannot wait on the bready signal. Once bvalid is
asserted, it cannot be deasserted until the transfer has occurred
(except in the case of a reset being asserted).

A SystemVerilog interface that exemplifies this is given next::

    interface intf_burst();

        parameter integer WIDTH = 16;

        logic [WIDTH-1:0]   bdata;
        logic               bvalid;
        logic               bready;

        modport upstream(
            output bvalid, bdata,
            input  bready
        );

        modport downstream(
            input  bvalid, bdata,
            output bready
        );

    endinterface: intf_burst

And a pair of verilog modules that exemplifies this is given here::

    module upstream_module (
        input  wire logic        i_clock,
        input  wire logic        i_reset,
        output      logic [31:0] o_sample_bdata,
        output      logic        o_sample_bvalid,
        input  wire logic        i_sample_bready
    );
    endmodule

    module downstream_module (
        input  wire logic        i_clock,
        output      logic        i_reset,
        input  wire logic [31:0] i_sample_bdata,
        input  wire logic        i_sample_bvalid,
        output      logic        o_sample_bready
    );
    endmodule

Do not name signals bvalid and bready unless they have the semantics
indicated in this section. It will just confuse us.

The burst size is not part of the interface, but is an important part
of the module. It will either be a fixed number built in to the module
or a module parameter (if it can be changed when instantiated). If it
is fixed in the module, then it will typically be included in the
module name. For example, if the bursts represent frames of an FFT
and the size is fixed at 1024. Then the FFT module should be named
something like fft_1024. On the other hand, if the size is
parameterizable, then it should be added to the parameter list when
instantiating the module. This will make the burst length clear to
the uninitated, and make the code more user friendly.