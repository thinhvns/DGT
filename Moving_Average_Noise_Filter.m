
clc;
clear;
close all;

% 1. Generate the original signal
Fs = 1000;                  % Sampling frequency (Hz)
t = 0:1/Fs:2;               % Time from 0 to 2 seconds
f = 5;                      % Signal frequency (Hz)

x = sin(2*pi*f*t);          % Original sine signal

% 2. Add random noise
rng(1);                     % Make the result repeatable
noise = 0.6 * randn(size(x));
x_noisy = x + noise;

% 3. Apply Moving Average Filter
N = 31;                     % Moving average window size
b = ones(1, N) / N;         % Filter coefficients

x_filtered = filter(b, 1, x_noisy);

% 4. Plot the results
figure('Name', 'Moving Average Noise Filter');

subplot(3,1,1);
plot(t, x, 'b', 'LineWidth', 1.2);
title('Original Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,2);
plot(t, x_noisy, 'r');
title('Noisy Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot(t, x_filtered, 'k', 'LineWidth', 1.2);
title(['Filtered Signal (N = ', num2str(N), ')']);
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

sgtitle('Moving Average Noise Filter');

% 5. Compare noisy and filtered signals
figure('Name', 'Filter Comparison');
plot(t, x_noisy, 'Color', [0.7 0.7 0.7]);
hold on;
plot(t, x_filtered, 'b', 'LineWidth', 1.2);
plot(t, x, 'r--', 'LineWidth', 1.2);
title('Comparison of Original, Noisy and Filtered Signals');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Noisy Signal', 'Filtered Signal', 'Original Signal');
grid on;
