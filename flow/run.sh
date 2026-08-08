# Synthesis
yosys -p "synth_ice40 -top blink_test -json top.json" top.v
# Place and Route
nextpnr-ice40 \
    --up5k \
    --package sg48 \
    --json top.json \
    --pcf top.pcf \
    --asc top.asc

# Bitstream generation
icepack top.asc top.bin

# Program FPGA
iceprog top.bin
