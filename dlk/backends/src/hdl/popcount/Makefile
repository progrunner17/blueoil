MODULE := popcount
SUBMODS := 

DIR  := ..
TEST_BENCH := tb_$(MODULE).sv
SRCS :=  $(TEST_BENCH) $(MODULE).v  $(foreach SUBMOD,$(SUBMODS),$(wildcard $(DIR)/$(SUBMOD)/*.v))
TARGET := $(MODULE)


.PHONY:default
default:
	@echo "TARGET= $(TARGET)"
	@echo "USAGE: make test"
	@echo "open the .vcd file with gtkwave for watching wave form"
	@echo "TODO: test bench support for each LATENCY and enable and concurrent execution" 


test: $(TARGET)
	./$(TARGET)

$(TARGET): $(SRCS)
	iverilog -o $@ -g2005-sv $(SRCS) 


.PHONY: clean
clean:
	$(RM) $(TARGET)  

.PHONY: cleanup
cleanup: clean
	$(RM) *.vcd


