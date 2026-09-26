
import serial
import time
import numpy as np

ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=1)
time.sleep(0.1)
h = [0, 5, 4, -5, -10, 0, 24, 45, 45, 24, 0, -10, -5, 4, 5, 0]
Y = np.random.randint(0, 100, size=16)
X=Y.tolist()

ser.write(bytes(X))
response = ser.read(len(X))
received_dec_unsigned = [b for b in response]
received_dec = [b - 256 if b >= 128 else b for b in received_dec_unsigned]#signed
print(f"Sent: {X}")
print(f"Received : {received_dec}")

print(len(received_dec))
print(len(X))

def trunc(a):
    trunc_op = []
    for sum_val in a:
        rounded_sum = sum_val + 64
        scaled_sum = rounded_sum >> 7
        if scaled_sum > 127:
            final_trunc = 127
        elif scaled_sum < -128:
            final_trunc = -128
        else:
            final_trunc = scaled_sum
        trunc_op.append(int(final_trunc))
    return trunc_op


numpyval=np.convolve(h, X)
print("numpy model convolution values",numpyval[:len(X)-1])

c=trunc(numpyval)

print("trunc op of convolve implementation", c[:len(X)-1])

if c[:len(X)-1] == received_dec[1:]:
    print("results matched")