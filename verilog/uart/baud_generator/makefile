# Makefile
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/baud_generator.v


TOPLEVEL = baud_generator
MODULE = tb_baud_generator

include $(shell cocotb-config --makefiles)/Makefile.sim
