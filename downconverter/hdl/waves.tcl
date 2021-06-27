lappend system "i_clk"
lappend system "i_rst_p"

set num_added [ gtkwave::addSignalsFromList $system ]

gtkwave::/Edit/Insert_Comment "---- t0 ----"

lappend t0 "top_tb.t0_data"
lappend t0 "top_tb.t0_valid"
lappend t0 "top_tb.t0_ready"

set num_added [ gtkwave::addSignalsFromList $t0 ]

gtkwave::/Edit/Insert_Comment "---- t1 ----"

lappend t1 "top_tb.t1_data"
lappend t1 "top_tb.t1_valid"
lappend t1 "top_tb.t1_ready"

set num_added [ gtkwave::addSignalsFromList $t1 ]


gtkwave::/Edit/Insert_Comment "---- i0 ----"

lappend i0 "top_tb.i0_data"
lappend i0 "top_tb.i0_valid"
lappend i0 "top_tb.i0_ready"

set num_added [ gtkwave::addSignalsFromList $i0 ]

gtkwave::/Edit/Insert_Comment "---- i1 ----"

lappend i1 "top_tb.i1_data"
lappend i1 "top_tb.i1_valid"
lappend i1 "top_tb.i1_ready"

set num_added [ gtkwave::addSignalsFromList $i1 ]

gtkwave::setZoomFactor -4