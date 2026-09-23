import serial
import time
ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=1)
time.sleep(0.1)

X = [1,0,0,0,0,0,0]
ser.write(bytes(X))
response = ser.read(len(X))
received_dec = [b for b in response]
print(f"Sent: {X}")
print(f"Received : {received_dec}")

print(len(received_dec))
print(len(X))
