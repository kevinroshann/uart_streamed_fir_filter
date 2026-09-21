import cocotb
from cocotb.clock import Clock
from cocotbext.uart import UartSource, UartSink

@cocotb.test()
async def test_single_char(dut):
    # 12 MHz Clock -> ~83.33 ns period
    cocotb.start_soon(Clock(dut.clk, 83.33, unit="ns").start())

    # Attach UART interfaces matching 115200 baud
    uart_source = UartSource(dut.rx, baud=115200, bits=8)
    uart_sink   = UartSink(dut.tx, baud=115200, bits=8)

    # Send character 'A'
    await uart_source.write(b'A')

    # Read echoed response
    echoed_byte = await uart_sink.read(1)
    dut._log.info(f"Received byte: {echoed_byte}")