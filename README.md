# DGT
# Moving Average Noise Filter – MATLAB

## 1. Project Overview

This project demonstrates how to use a **Moving Average Filter** in MATLAB to reduce random noise in a signal.

A 5 Hz sine wave is generated as the original signal. Random Gaussian noise is then added to the signal. Finally, a Moving Average Filter is applied to smooth the noisy signal and reduce unwanted fluctuations.

## 2. Objectives

- Generate an original sine wave signal.
- Add random Gaussian noise to the original signal.
- Design and implement a Moving Average Filter.
- Compare the original, noisy, and filtered signals.
- Investigate how the filter window size affects noise reduction.

## 3. Theory

A Moving Average Filter is a simple digital filter that calculates the average of a fixed number of consecutive signal samples.

The output is calculated using the following equation:

\[
y[n] = \frac{1}{N}\sum_{k=0}^{N-1}x[n-k]
\]

Where:

- \(x[n]\): Input signal.
- \(y[n]\): Filtered output signal.
- \(N\): Moving average window size.
- \(n\): Current sample index.

A larger window size generally provides stronger smoothing, but it can also reduce important signal variations and increase the filter delay.

## 4. Simulation Parameters

| Parameter | Value |
|---|---:|
| Sampling Frequency (Fs) | 1000 Hz |
| Signal Frequency (f) | 5 Hz |
| Simulation Time | 2 seconds |
| Noise Type | Gaussian Random Noise |
| Noise Amplitude | 0.6 |
| Moving Average Window (N) | 15 samples |

## 5. Implementation

The MATLAB program performs the following steps:

1. Generate a 5 Hz sine wave.
2. Generate random Gaussian noise using `randn()`.
3. Add noise to the original signal.
4. Design the Moving Average Filter using `ones(1,N)/N`.
5. Apply the filter using MATLAB's `filter()` function.
6. Plot and compare the signals before and after filtering.

### Main MATLAB Code

```matlab
% Generate the original signal
Fs = 1000;
t = 0:1/Fs:2;
f = 5;

x = sin(2*pi*f*t);

% Add Gaussian noise
rng(1);
noise = 0.6 * randn(size(x));
x_noisy = x + noise;

% Apply Moving Average Filter
N = 15;
b = ones(1, N) / N;

x_filtered = filter(b, 1, x_noisy);
```

## 6. Results

The simulation produces two figures:

- **Figure 1 – Moving Average Noise Filter:** Shows the original signal, noisy signal, and filtered signal in three separate plots.
- **Figure 2 – Filter Comparison:** Compares the noisy signal, filtered signal, and original signal in one plot.

### Observations

- The original signal is a clean sine wave.
- The noisy signal contains random fluctuations caused by Gaussian noise.
- The filtered signal is smoother than the noisy input signal.
- The Moving Average Filter reduces high-frequency fluctuations while preserving the general shape of the original sine wave.

## 7. Conclusion

The simulation demonstrates that the Moving Average Filter can effectively reduce random noise in a signal.

The filtered output is smoother and closer to the original sine wave than the noisy input signal. However, selecting an appropriate window size is important because a larger window provides stronger smoothing but may also reduce signal details and introduce more delay.

Therefore, the Moving Average Filter is a simple and useful technique for basic signal smoothing and noise reduction.

## 8. Tools and Technologies

- MATLAB
- MATLAB Signal Processing Functions
- Digital Signal Processing (DSP)

## 9. How to Run

1. Download or clone this repository.
2. Open MATLAB.
3. Open the file `Moving_Average_Noise_Filter.m`.
4. Run the script.
5. View the generated figures to observe the filtering results.

---

**Project:** Moving Average Noise Filter  
**Language:** MATLAB  
**Category:** Digital Signal Processing (DSP)
