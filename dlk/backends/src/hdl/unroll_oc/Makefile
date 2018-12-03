MODULE := unroll_oc
SUBMODS := popcount ram calc_unit_parallel

DIR  := ..
RAM_GEN := generate_testdata
TEST_BENCH := tb_$(MODULE).sv
SRCS :=  $(TEST_BENCH) $(MODULE).v  $(foreach SUBMOD,$(SUBMODS),$(wildcard $(DIR)/$(SUBMOD)/*.v))
TARGET := $(MODULE)
VCD := tb_$(MODULE).vcd
GTKW := $(MODULE).gtkw


.PHONY:default
default:
	@echo "TARGET= $(TARGET)"
	@echo "USAGE: make test"
	@echo "USAGE: make waveform"
	@echo "USAGE: make update_ram"
	@echo "テストベンチでは、計算毎のチェックと、最終的なout buffer のチェックを行なっている。"




$(TARGET): $(SRCS)
	iverilog -g2005-sv -o $@  $(SRCS) 


.PHONY:update_ram
update_ram:$(RAM_GEN)
	./$(RAM_GEN)


out_check.txt:
	make update_ram


.PHONY:test
test: out_check.txt
test: $(TARGET)
	./$(TARGET)

$(VCD):$(TARGET)
	./$(TARGET)


waveform: $(VCD)
	open $(GTKW)


$(RAM_GEN): $(RAM_GEN).cpp
	$(CXX) -o $@ -std=c++11 $^


	

.PHONY: clean
clean:
	$(RM) $(TARGET)  

.PHONY: cleanup
cleanup: clean
	$(RM) *.vcd
	$(RM) *.txt
	$(RM) $(RAM_GEN)
