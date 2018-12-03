MODULE := calc_unit_parallel
SUBMODS := popcount

DIR  := ..
TEST_GEN := tb_generator
TEST_BENCH := tb_$(MODULE).sv
SRCS :=  $(TEST_BENCH) $(MODULE).v  $(foreach SUBMOD,$(SUBMODS),$(wildcard $(DIR)/$(SUBMOD)/*.v))
TARGET := $(MODULE)


.PHONY:default
default:
	@echo "TARGET= $(TARGET)"
	@echo "USAGE: make run"
	@echo
	@echo "TODO: support for cuncurrent run" 
	@echo "      current testbench only support non-concurrent run"




run: $(TARGET)
	./$(TARGET)

$(TARGET): $(SRCS)
	iverilog -o $@ -g2005-sv $(SRCS) 

$(TEST_GEN): $(TEST_GEN).cpp
	$(CXX) -o $@ -std=c++11 $^

REPEAT := 10
$(TEST_BENCH):$(TEST_GEN)
	./$(TEST_GEN) $(REPEAT) > $(TEST_BENCH)

.PHONY: clean
clean:
	$(RM) $(TARGET)  

.PHONY: cleanup
cleanup: clean
	$(RM) *.vcd
	$(RM) $(TEST_GEN)
	$(RM) $(TEST_BENCH)


