lappend system "i_clk"
lappend system "i_rst_p"

set num_added [ gtkwave::addSignalsFromList $system ]
<% targets.map((t, ti) => { %>
gtkwave::/Edit/Insert_Comment "---- t${ti} ----"

lappend t${ti} "top_tb.t${ti}_data"
lappend t${ti} "top_tb.t${ti}_valid"
lappend t${ti} "top_tb.t${ti}_ready"

set num_added [ gtkwave::addSignalsFromList $t${ti} ]
<% }) %>
<% initiators.map((i, ii) => { %>
gtkwave::/Edit/Insert_Comment "---- i${ii} ----"

lappend i${ii} "top_tb.i${ii}_data"
lappend i${ii} "top_tb.i${ii}_valid"
lappend i${ii} "top_tb.i${ii}_ready"

set num_added [ gtkwave::addSignalsFromList $i${ii} ]
<% }) %>
gtkwave::setZoomFactor -4