import serial
import time

# Replace with your serial port (/dev/ttyUSB1 or /dev/ttyUSB0)
ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=1)
time.sleep(0.1)

# Input data list
X = [60, 70, 80, 90, 100]

# Send the bytes sequentially
ser.write(bytes(X))

# Read the 5 output bytes returned by the FIR filter
response = ser.read(len(X))

received_dec = [b for b in response]
received_hex = [hex(b) for b in response]

print(f"Sent (Dec)    : {X}")
print(f"Received (Dec): {received_dec}")
print(f"Received (Hex): {received_hex}")

ser.close()