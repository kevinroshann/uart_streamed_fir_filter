# Makefile
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/uart.v
VERILOG_SOURCES += $(PWD)/uart_echo.v
VERILOG_SOURCES += $(PWD)/fir.v
VERILOG_SOURCES += $(PWD)/baud_generator.v
VERILOG_SOURCES += $(PWD)/tx.v
VERILOG_SOURCES += $(PWD)/rx.v

TOPLEVEL = uart
MODULE = tb_uart

include $(shell cocotb-config --makefiles)/Makefile.sim
