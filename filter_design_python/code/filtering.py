import numpy as np
from quantise_fun import quantise
from scipy.signal import firwin, lfilter
import matplotlib.pyplot as plt


numtaps =16


cutoff_freq = 2000
fs=10000
cutoff=cutoff_freq/(fs/2)

coefficients = firwin(numtaps, cutoff,window='rectangular',pass_zero=True)
# what firwin is doing is that it is first calculate the ideal impulse reponce of what we nee
# then it woudl shift it to make it causal and then to truncate the sinc fucntion it multiply it with the window
# and then give the coefficients of the discreate signal created that are its values


print(coefficients)

quantise_value=[quantise(i) for i in coefficients]
print(quantise_value)

x = np.array([1,2,3,4,5])
y_numpy = np.convolve(x, quantise_value, mode="full")[: len(x)]

 

print(y_numpy)


h = [0, 5, 4, -5, -10, 0, 24, 45, 45, 24, 0, -10, -5, 4, 5, 0]
x = [1, 2, 3, 4, 5]

h_len = 16
x_len = 5
y_len = h_len + x_len - 1

y = []

# Outer loop iterates through each output sample index n
for n in range(y_len):
    accumulator = 0
    # Inner loop computes the dot product for the overlapping window
    for k in range(x_len):
        idx = n - k
        # Check if the coefficient index is within valid bounds
        if idx >= 0 and idx < h_len:
            accumulator = accumulator + (x[k] * h[idx])
    y.append(accumulator)

print("Output y:", y)