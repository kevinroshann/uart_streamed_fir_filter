import numpy as np

def signal_gen():
    fs = 10000
    t = np.arange(0, 1, 1/fs)

    # -------------------------
    # Signal: below 2000 Hz
    # -------------------------
    signal = (
        5 * np.sin(2 * np.pi * 1000 * t) +
        5 * np.sin(2 * np.pi * 1500 * t)
    )

    # -------------------------
    # Noise: above 3000 Hz
    # -------------------------
    noise = (
        5 * np.sin(2 * np.pi * 3500 * t) +
        5 * np.sin(2 * np.pi * 4000 * t)
    )

    # -------------------------
    # Add signal + noise
    # -------------------------
    y = signal + noise

    # Normalize maximum amplitude to 1
    y = y / np.max(np.abs(y))

    # Convert to signed 8-bit range [-128, 127]
    x = np.clip(np.round(y * 127), -128, 127).astype(np.int8)

    return x

# fs=1000
# t=np.arange(0,1,1/fs)
# cutoff=200/(fs/2)
# x=np.sin(2*np.pi*100*t)+np.sin(2*np.pi*300*t)

# coefficients = firwin(16, cutoff,window='rectangular',pass_zero=True)

# filt_sig=lfilter(coefficients,1,x)

# plt.plot(t,x)
# plt.show()
# plt.plot(t,filt_sig)
# plt.show()
