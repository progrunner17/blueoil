MODULE := popcount
SUBMODS := 

DIR  := ..
TEST_BENCH := tb_$(MODULE).sv
SRCS :=  $(TEST_BENCH) $(MODULE).v  $(foreach SUBMOD,$(SUBMODS),$(wildcard $(DIR)/$(SUBMOD)/*.v))
TARGET := $(MODULE)
VCD := tb_$(MODULE).vcd
GTKW := $(MODULE).gtkw


.PHONY:defa
defa:
	@echo "TARGET= $(TARGET)"
	@echo "USAGE: \"make test\""
	@echo "if you want to see waveform run \"make waveform\" "
	@echo "gtkform is needed"
	@echo "open the .vcd file with gtkwave for watching wave form"
	@echo "TODO: test bench support for each LATENCY and enable and concurrent execution" 



$(TARGET): $(SRCS)
	iverilog -o $@ -g2005-sv $(SRCS) 

.PHONY:test
test: $(TARGET)
	./$(TARGET)

$(VCD):$(TARGET)
	./$(TARGET)

.PHONY:waveform
waveform: $(VCD)
	open $(GTKW)


.PHONY: clean
clean:
	$(RM) $(TARGET)  

.PHONY: cleanup
cleanup: clean
	$(RM) *.vcd


