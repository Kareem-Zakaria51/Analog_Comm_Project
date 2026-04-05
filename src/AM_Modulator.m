% ===========================
% Needed Parameters
% ===========================
FC1 = 100e3;        % 1st Carrier Frequency in Hz.
FC2 = 130e3;        % 2nd Carrier Frequency in Hz.


% ===========================
% Read Audio Signals
% ===========================
[sig1_sterio, Fs1] = audioread('../assets/Short_FM9090.wav');           % 1st station
[sig2_sterio, Fs2] = audioread('../assets/Short_QuranPalestine.wav');   % 2nd station

% Mono Conversion -> as they are sterio signals
sig1_mono = sig1_sterio(:,1) + sig1_sterio(:,2);        % Single Row
sig2_mono = sig2_sterio(:,1) + sig2_sterio(:,2);        % Single Row

% Zero Padding -> in case of unequal lengthes
len1 = length(sig1_mono);
len2 = length(sig2_mono);
lens = [len1 len2];
[max_len, sig_idx] = max(lens);
if sig_idx == 1         % sig1 is the longest
    sig2_mono = [sig2_mono; zeros(len1 - len2, 1)];
else sig_idx == 2    % sig2 is the longest
    sig1_mono = [sig1_mono; zeros(len2 - len1, 1)];
end

% Upsampling by 10 -> 44.1 * 10 > 2 * (100 + 4 * 30) "Nyquest Criteria"
upsamp_factor = 10;
sig1_sampled = interp(sig1_mono, upsamp_factor);
sig2_sampled = interp(sig2_mono, upsamp_factor);
Fs_new = Fs1 * upsamp_factor;
Ts_new = 1 / Fs_new;


% ===========================
% Plot Upsampled Signals
% ===========================
N = length(sig1_mono_upsampled);
t = (0 : N-1) * Ts_new;             % time vector
f = (-N/2 : N/2-1) * (Fs_new / N);  % frequency vector

spect1 = fftshift(fft(sig1_sampled));
spect2 = fftshift(fft(sig2_sampled));

figure;
plot(f, abs(spect1));
title("Spectrum of (FM9090) - After Sampling");
xlabel("Frequency (Hz)");
ylabel("Magnitude");
grid on;

figure;
plot(f, abs(spect2));
title("Spectrum of (Quran Palestine) - After Sampling");
xlabel("Frequency (Hz)");
ylabel("Magnitude");
grid on;


% ===========================
% AM Modulation using DSB-SC
% ===========================
carrier1 = cos(2 * pi * FC1 * t);       % Carrier for sig1_sampled
carrier2 = cos(2 * pi * FC2 * t);       % Carrier for sig2_sampled

sig1_mod = sig1_sampled .* carrier1';
sig2_mod = sig2_sampled .* carrier2';

sig_FDM = sig1_mod + sig2_mod;


% ===========================
% Plot Modulated & FDM Signals
% ===========================
spect1_mod = fftshift(fft(sig1_mod));
spect2_mod = fftshift(fft(sig2_mod));
spect_FDM  = fftshift(fft(sig_FDM));

% 1st Modulated Signal
figure;
plot(f, abs(spect1_mod));
title("Spectrum of Modulated Signal 1 (FC1 = 100 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% 2nd Modulated Signal
figure;
plot(f, abs(spect2_mod));
title("Spectrum of Modulated Signal 2 (FC1 = 130 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% FDM Signals
figure;
plot(f, abs(spect_FDM));
title("Spectrum of FDM Signal");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;