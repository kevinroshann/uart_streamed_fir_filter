import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_uart_loopback(dut):

    cocotb.start_soon(Clock(dut.clk, 83.33, units="ns").start())

    dut.rstn.value=0
    dut.tx_enable.value=0
    dut.data.value=0
    dut.read_clear.value=0
    dut.rx.value=1

    await ClockCycles(dut.clk,5)
    dut.rstn.value=1
    await ClockCycles(dut.clk,5)

    byte=0x10
    dut.data.value=byte
    dut.tx_enable.value=1

    await RisingEdge(dut.clk)
    dut.tx_enable.value=0
    dut._log.info(f"tx byte {byte}")
    timeout_counter=0
    max_cnt=2000

    while int(dut.ready.value)==0:
        await RisingEdge(dut.clk)

        dut.rx.value = int(dut.tx.value)
        timeout_counter+=1
        assert timeout_counter<max_cnt, "timeout occured"

    recieved_data=int(dut.data_out.value)
    dut._log.info(f"recieved {recieved_data}")

