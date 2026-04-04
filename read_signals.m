Fn = 100e3 ;    % "Carriar Frequency HZ"

% =====================
% Step 1: Read signals
% =====================
[signal1, Fs1] = audioread('Short_FM9090.wav');
[signal2, Fs2] = audioread('Short_QuranPalestine.wav');

% Mono conversion
mono_signal1 = signal1(:,1) + signal1(:,2);
mono_signal2 = signal2(:,1) + signal2(:,2);

% =====================
% Step 2: Zero Padding
% =====================
length1 = length(mono_signal1);
length2 = length(mono_signal2);

if length1 > length2
    mono_signal2 = [mono_signal2; zeros(length1 - length2, 1)];
else
    mono_signal1 = [mono_signal1; zeros(length2 - length1, 1)];
end

% =====================
% Step 3: Upsample by 10 (Increase Sampling Frequency)
% =====================
upsample_factor = 10;
mono_upsampled1 = interp(mono_signal1, upsample_factor);
mono_upsampled2 = interp(mono_signal2, upsample_factor);
Fs_new = Fs1 * upsample_factor;

% =====================
% Step 4: Sampling (Build time vector)
% =====================
N = length(mono_upsampled1);
Ts_new = 1 / Fs_new;
t = (0 : N-1) * Ts_new;

sampled_signal1 = mono_upsampled1 .* ones(N, 1);
sampled_signal2 = mono_upsampled2 .* ones(N, 1);

% =====================
% Step 5: Plot spectrum using FFT
% =====================
f = (-N/2 : N/2-1) * (Fs_new / N);

spectrum1 = fftshift(fft(sampled_signal1));
spectrum2 = fftshift(fft(sampled_signal2));

figure;
plot(f, abs(spectrum1));
title('Spectrum of Short FM9090 (After Sampling)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

figure;
plot(f, abs(spectrum2));
title('Spectrum of Short Quran Palestine (After Sampling)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% =====================
% Step 6: Generate Carriers (DSB-SC)
% =====================
F0 = 100e3;        % Carrier frequency for signal 1 = 100 KHz (n=0)
F1 = 130e3;        % Carrier frequency for signal 2 = 130 KHz (n=1)

carrier1 = cos(2 * pi * F0 * t);      % Carrier for signal 1
carrier2 = cos(2 * pi * F1 * t);      % Carrier for signal 2

% =====================
% Step 7: DSB-SC Modulation (multiply signal by carrier)
% =====================
modulated_signal1 = sampled_signal1 .* carrier1';
modulated_signal2 = sampled_signal2 .* carrier2';

% =====================
% Step 8: FDM signal (sum of both modulated signals)
% =====================
FDM_signal = modulated_signal1 + modulated_signal2;

% =====================
% Step 9: Plot spectrum of modulated signals and FDM
% =====================
spectrum_mod1 = fftshift(fft(modulated_signal1));
spectrum_mod2 = fftshift(fft(modulated_signal2));
spectrum_FDM  = fftshift(fft(FDM_signal));

% Modulated signal 1
figure;
plot(f, abs(spectrum_mod1));
title('Spectrum of Modulated Signal 1 (FC = 100 KHz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% Modulated signal 2
figure;
plot(f, abs(spectrum_mod2));
title('Spectrum of Modulated Signal 2 (FC = 130 KHz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% FDM signal
figure;
plot(f, abs(spectrum_FDM));
title('Spectrum of FDM Signal (Both Stations)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% =====================
% Step 10: RF Stage - Band Pass Filter (BPF)
% =====================
% For audio signals, bandwidth is typically around 15 KHz
BW = 15e3;                  % Bandwidth = 15 KHz (estimated from spectrum plot)

% ---- BPF for Signal 1 centered at F0 = 100 KHz ----
BPF1_low  = (F0 - BW/2) / (Fs_new/2);    % Normalized lower cutoff frequency
BPF1_high = (F0 + BW/2) / (Fs_new/2);    % Normalized upper cutoff frequency

BPF1 = fir1(200, [BPF1_low, BPF1_high], 'bandpass');   % Design BPF using FIR filter

% Apply BPF to FDM signal to extract signal 1
RF_output1 = filter(BPF1, 1, FDM_signal);

% ---- BPF for Signal 2 centered at F1 = 130 KHz ----
BPF2_low  = (F1 - BW/2) / (Fs_new/2);    % Normalized lower cutoff frequency
BPF2_high = (F1 + BW/2) / (Fs_new/2);    % Normalized upper cutoff frequency

BPF2 = fir1(200, [BPF2_low, BPF2_high], 'bandpass');   % Design BPF using FIR filter

% Apply BPF to FDM signal to extract signal 2
RF_output2 = filter(BPF2, 1, FDM_signal);

% =====================
% Step 11: Plot spectrum of RF stage output
% =====================
spectrum_RF1 = fftshift(fft(RF_output1));
spectrum_RF2 = fftshift(fft(RF_output2));

figure;
subplot(2,1,1);
plot(f, abs(spectrum_RF1));
title('RF Stage Output - Signal 1 (BPF centered at 100 KHz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

subplot(2,1,2);
plot(f, abs(spectrum_RF2));
title('RF Stage Output - Signal 2 (BPF centered at 130 KHz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;