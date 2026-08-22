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

x = np.array([1.0, 2.0, 3.0, 2.0, 1.0, 0.0, -1.0, -2.0, -1.0, 0.0])
y_numpy = np.convolve(x, coefficients, mode="full")[: len(x)]
print(y_numpy)