MODULE := unroll_oc
SUBMODS := popcount ram calc_unit_parallel

DIR  := ..
RAM_GEN := generate_testdata
TEST_BENCH := tb_$(MODULE).sv
SRCS :=  $(TEST_BENCH) $(MODULE).v  $(foreach SUBMOD,$(SUBMODS),$(wildcard $(DIR)/$(SUBMOD)/*.v))
TARGET := $(MODULE)


.PHONY:default
default:
	@echo "TARGET= $(TARGET)"
	@echo "USAGE: make test"
	@echo




out_check.txt:
	make update_ram


test: out_check.txt
test: $(TARGET)
	./$(TARGET)

$(TARGET): $(SRCS)
	iverilog -g2005-sv -o $@  $(SRCS) 

$(RAM_GEN): $(RAM_GEN).cpp
	$(CXX) -o $@ -std=c++11 $^


.PHONY:update_ram
update_ram:$(RAM_GEN)
	./$(RAM_GEN)
	

.PHONY: clean
clean:
	$(RM) $(TARGET)  

.PHONY: cleanup
cleanup: clean
	$(RM) *.vcd
	$(RM) *.txt
	$(RM) $(RAM_GEN)
