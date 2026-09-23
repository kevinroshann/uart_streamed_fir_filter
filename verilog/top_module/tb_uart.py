import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_single_char(dut):
    # 12 MHz Clock -> ~83.33 ns period
    cocotb.start_soon(Clock(dut.clk, 83.33, unit="ns").start())
    await ClockCycles(dut.clk,5)
    
    