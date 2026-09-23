import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

@cocotb.test()
async def test_baud_generator(dut):
    cocotb.start_soon(Clock(dut.clk, 83.33, units="ns").start())
    dut.rstn.value=0
    await RisingEdge(dut.clk)
    dut.rstn.value=1
    for i in range(3): 
        count=0
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            count=count+1
            if(dut.tick.value==1):
                break

        dut._log.info(f"tick {i} fired with count {count}")
