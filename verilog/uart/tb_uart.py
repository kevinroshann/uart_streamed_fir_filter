import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_uart_loopback(dut):
    # 1. Start 12 MHz clock
    cocotb.start_soon(Clock(dut.clk, 83.33, unit="ns").start())

    # 2. Apply reset sequence
    dut.rst.value = 1
    dut.tx_enable.value = 0
    dut.data.value = 0
    dut.read_clear.value = 0
    dut.rx.value = 1  # Standard UART idle line state
    
    await ClockCycles(dut.clk, 5)
    dut.rst.value = 0
    await ClockCycles(dut.clk, 5)

    # 3. Transmit a test byte (0xA5)
    test_byte = 0xA5
    dut.data.value = test_byte
    dut.tx_enable.value = 1
    await RisingEdge(dut.clk)
    dut.tx_enable.value = 0  # De-assert enable

    dut._log.info(f"Transmitting byte: {hex(test_byte)}")

    # 4. Loopback loop: pass TX -> RX until RX reports ready
    timeout_counter = 0
    max_cycles = 2000  # Safety timeout (1 byte takes ~1250 clock cycles)

    while int(dut.ready.value) == 0:
        await RisingEdge(dut.clk)
        
        # Connect TX output directly to RX input
        dut.rx.value = int(dut.tx.value)
        
        timeout_counter += 1
        assert timeout_counter < max_cycles, "Test timed out waiting for ready signal!"

    # 5. Verify received data
    received_data = int(dut.data_out.value)
    dut._log.info(f"Received byte: {hex(received_data)}")
    assert received_data == test_byte, f"Mismatch! Sent {hex(test_byte)}, got {hex(received_data)}"

    # 6. Clear the ready flag
    dut.read_clear.value = 1
    await RisingEdge(dut.clk)
    dut.read_clear.value = 0
    await RisingEdge(dut.clk)

    assert int(dut.ready.value) == 0, "Ready flag failed to clear after read_clear pulse!"
    dut._log.info("Loopback test passed successfully!")