TARGET=fwft_dc_fifo
.PHONY: $(TARGET)
RTLSRC=../hdl
all: $(TARGET)

LDFLAGS=
CFLAGS=-g -O3

$(TARGET):
	#verilator -Wno-fatal -I$(RTLSRC)/ --cc $(@)_top.v --trace --exe ../$(@).cpp  -Mdir $(@) -CFLAGS "$(CFLAGS)"
	verilator -Wno-fatal -I$(RTLSRC)/ --cc $(@).sv --trace --exe sim.cpp  -Mdir $(@) -CFLAGS "$(CFLAGS)"
	# make -C $(@) -f V$(@)_top.mk
	make -C $(@) -f V$(@).mk
clean:: 
	rm -rf *.o $(TARGET)
distclean:: clean
	rm -rf *~ *.txt *.vcd *.mif *.orig