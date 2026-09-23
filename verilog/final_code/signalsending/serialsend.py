import serial
import time
from signal_gen import signal_gen
import matplotlib.pyplot as plt
import numpy as np
from scipy.io.wavfile import write
set = 100

ser = serial.Serial('/dev/ttyUSB1', 115200, timeout=1)
time.sleep(0.1)

X = signal_gen()
data = bytes(X)
datalen = len(data)

all_received = []


for i in range(0, datalen, set):
    tx_set = data[i:i + set]
    ser.write(tx_set)
    rx_bytes = ser.read(len(tx_set))
    rx_dec = list(rx_bytes)
    
    all_received.extend(rx_dec)
    
    print(f"  Sent ({len(tx_set)} bytes)     : {list(tx_set)}")
    print(f"  Received ({len(rx_dec)} bytes) : {rx_dec}\n")

print(f"Total Sent Length    : {datalen}")
print(f"Total Received Length: {len(all_received)}")
fig, ax = plt.subplots(2, 2, figsize=(12, 8))

fs=10000
t = np.arange(0, 1, 1/fs)
ax[0,0].plot(t, X, label='Transmitted Signal')




Y = np.array(all_received, dtype=np.uint8).view(np.int8)
ax[0,1].plot(t, Y, label='Received Signal', alpha=0.7)

Nt=len(X)
Xfft=np.fft.fft(X)

freqx=np.fft.fftfreq(Nt,1/fs)
amplitudex=np.abs(Xfft)/Nt
pos=freqx>0
ax[1,0].plot(freqx[pos],amplitudex[pos])


Nr=len(Y)
Yfft=np.fft.fft(Y)

freqy=np.fft.fftfreq(Nr,1/fs)
amplitudey=np.abs(Yfft)/Nr
pos=freqy>0
ax[1,1].plot(freqy[pos],amplitudey[pos])

plt.show()
write("transmitted.wav", fs, np.array(X, dtype=np.uint8))
write("received.wav", fs, np.array(Y, dtype=np.uint8))
