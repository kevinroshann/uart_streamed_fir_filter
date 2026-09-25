yosys -p "read_verilog uart_with_filter.v uart.v rx.v tx.v fir.v baud_generator.v; hierarchy -top uart_with_filter; synth_ice40 -top uart_with_filter -json hardware.json"
nextpnr-ice40 \
    --up5k \
    --package sg48 \
    --json hardware.json \
    --pcf icepie.pcf \
    --asc hardware.asc
icepack hardware.asc hardware.bin
iceprog hardware.bin
