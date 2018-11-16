SRCS := $(wildcard *.sv) $(wildcard *.v)
TEST_BENCH := $(wildcard tb_*)
TARGET := a.out

run: $(TARGET)
	./$(TARGET)

$(TARGET): $(SRCS)
	iverilog -o $@ -g2005-sv $(SRCS) 


.PHONY: echo 
echo:
	@echo  	"TEST_BENCH: " $(TEST_BENCH)
	@echo	"SRCS: " $(SRCS)


.PHONY: clean

clean:
	$(RM) $(TARGET)

.PHONY: cleanup
cleanup: clean
	$(RM) *.vcd
