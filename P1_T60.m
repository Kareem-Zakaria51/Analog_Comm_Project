% ===========================
% Needed Parameters
% ===========================
FC1 = 100e3;        % 1st Carrier Frequency in Hz.
FC2 = 130e3;        % 2nd Carrier Frequency in Hz.
FC3 = 160e3;        % 3rd Carrier Frequency in Hz.
FC4 = 190e3;        % 4th Carrier Frequency in Hz.
FC5 = 220e3;        % 5th Carrier Frequency in Hz.


% ===========================
% Read Audio Signals
% ===========================
[sig1_sterio, Fs1] = audioread('Short_FM9090.wav');           % 1st station
[sig2_sterio, Fs2] = audioread('Short_QuranPalestine.wav');   % 2nd station
[sig3_sterio, Fs3] = audioread('Short_BBCArabic2.wav');       % 2nd station
[sig4_sterio, Fs4] = audioread('Short_RussianVoice.wav');     % 2nd station
[sig5_sterio, Fs5] = audioread('Short_SkyNewsArabia.wav');    % 2nd station

% Mono Conversion -> as they are sterio signals
sig1_mono = sig1_sterio(:,1) + sig1_sterio(:,2);        % Single Row
sig2_mono = sig2_sterio(:,1) + sig2_sterio(:,2);        % Single Row
sig3_mono = sig3_sterio(:,1) + sig3_sterio(:,2);        % Single Row
sig4_mono = sig4_sterio(:,1) + sig4_sterio(:,2);        % Single Row
sig5_mono = sig5_sterio(:,1) + sig5_sterio(:,2);        % Single Row

% Zero Padding -> in case of unequal lengthes
len1 = length(sig1_mono);
len2 = length(sig2_mono);
len3 = length(sig3_mono);
len4 = length(sig4_mono);
len5 = length(sig5_mono);
lens = [len1 len2 len3 len4 len5];
[max_len, sig_idx] = max(lens);
if  sig_idx == 1        % sig1 is the longest
    sig2_mono = [sig2_mono; zeros(len1 - len2, 1)];
    sig3_mono = [sig3_mono; zeros(len1 - len3, 1)];
    sig4_mono = [sig4_mono; zeros(len1 - len4, 1)];
    sig5_mono = [sig5_mono; zeros(len1 - len5, 1)];
elseif sig_idx == 2     % sig2 is the longest
    sig1_mono = [sig1_mono; zeros(len2 - len1, 1)];
    sig3_mono = [sig3_mono; zeros(len2 - len3, 1)];
    sig4_mono = [sig4_mono; zeros(len2 - len4, 1)];
    sig5_mono = [sig5_mono; zeros(len2 - len5, 1)];
elseif sig_idx == 3     % sig3 is the longest
    sig1_mono = [sig1_mono; zeros(len3 - len1, 1)];
    sig2_mono = [sig2_mono; zeros(len3 - len2, 1)];
    sig4_mono = [sig4_mono; zeros(len3 - len4, 1)];
    sig5_mono = [sig5_mono; zeros(len3 - len5, 1)];
elseif sig_idx == 4     % sig4 is the longest
    sig1_mono = [sig1_mono; zeros(len4 - len1, 1)];
    sig2_mono = [sig2_mono; zeros(len4 - len2, 1)];
    sig3_mono = [sig3_mono; zeros(len4 - len3, 1)];
    sig5_mono = [sig5_mono; zeros(len4 - len5, 1)];
elseif sig_idx == 5     % sig5 is the longest
    sig1_mono = [sig1_mono; zeros(len5 - len1, 1)];
    sig2_mono = [sig2_mono; zeros(len5 - len2, 1)];
    sig3_mono = [sig3_mono; zeros(len5 - len3, 1)];
    sig4_mono = [sig4_mono; zeros(len5 - len4, 1)];
end

% Upsampling by 11 -> 44.1 * 11 > 2 * (100 + 4 * 30 + (BW/2 = 20/2)) "Nyquest Criteria"
upsamp_factor = 11;
sig1_sampled = interp(sig1_mono, upsamp_factor);
sig2_sampled = interp(sig2_mono, upsamp_factor);
sig3_sampled = interp(sig3_mono, upsamp_factor);
sig4_sampled = interp(sig4_mono, upsamp_factor);
sig5_sampled = interp(sig5_mono, upsamp_factor);
Fs_new = Fs1 * upsamp_factor;
Ts_new = 1 / Fs_new;


% ===========================
% Time & Frequency Vectors
% ===========================
N = length(sig1_sampled);
t = (0 : N-1) * Ts_new;             % time vector
f = (-N/2 : N/2-1) * (Fs_new / N);  % frequency vector


% ===========================
% AM Modulation using DSB-SC
% ===========================
carrier1 = cos(2 * pi * FC1 * t);       % Carrier for sig1_sampled
carrier2 = cos(2 * pi * FC2 * t);       % Carrier for sig2_sampled
carrier3 = cos(2 * pi * FC3 * t);       % Carrier for sig3_sampled
carrier4 = cos(2 * pi * FC4 * t);       % Carrier for sig4_sampled
carrier5 = cos(2 * pi * FC5 * t);       % Carrier for sig5_sampled

sig1_mod = sig1_sampled .* carrier1';
sig2_mod = sig2_sampled .* carrier2';
sig3_mod = sig3_sampled .* carrier3';
sig4_mod = sig4_sampled .* carrier4';
sig5_mod = sig5_sampled .* carrier5';

sig_FDM = sig1_mod + sig2_mod + sig3_mod + sig4_mod + sig5_mod;


% =============================
% RF Stage - BPF
% =============================
BW = 20e3;          % estimated from signal plot
n = 0;              % signal index [0, 1, 2, 3, 4 == sig1, sig2, sig3, sig4, sig5]
deltaFC = 30e3;     % each signal carrier differ by 30 kHz

% BPF for signal 1+n - centered at FC1 + 30*n kHz
BPF_low = (FC1 + deltaFC*n - BW/2) / (Fs_new/2);    % lower cutoff frequency
BPF_upp = (FC1 + deltaFC*n + BW/2) / (Fs_new/2);    % upper cutoff frequency
BPF = fir1(200, [BPF_low, BPF_upp], 'bandpass');    % FIR BPF

% Pass FDM signal to RF BPF
RF_out = filter(BPF, 1,sig_FDM);
% RF_out = sig_FDM;   % Remove RF BPF


% =============================
% Mixer - RF_out & Local Oscilator
% =============================
IF = 15e3;
FLO = IF + FC1 + deltaFC * n;
% FLO = IF + FC1 + deltaFC * n + 100;     % Frequency Offsit = 0.1 kHz
% FLO = IF + FC1 + deltaFC * n + 1000;    % Frequency Offsit = 1 kHz

% Local Oscillator Carrier
carrier_lo = cos(2 * pi * FLO * t);

% Down Convert signal to IF
IF_in = RF_out .* carrier_lo';


% =============================
% IF Stage - BPF
% =============================

% IF BPF - Centered at IF
IF_BPF_low = (IF - BW/2) / (Fs_new/2);    % lower cutoff frequency
IF_BPF_upp = (IF + BW/2) / (Fs_new/2);    % upper cutoff frequency
IF_BPF = fir1(200, [IF_BPF_low, IF_BPF_upp], 'bandpass');    % FIR BPF

% Pass Mixer Output to IF BPF
IF_out = filter(IF_BPF, 1,IF_in);


% =============================
% Base Band Detection
% =============================
sig_BB = IF_out .* cos(2 * pi * IF * t)';       % Down Convert signal to base band

% LPF - Cutoff Frequency = Signal BW
fc = BW;        % Filter cutoff
LPF = fir1(200, fc / (Fs_new/2));    % FIR LPF

sig_BB_filtered = filter(LPF, 1, sig_BB);

sig_out = resample(sig_BB_filtered,Fs1,Fs_new);
sound(sig_out, Fs1);


% ===========================
% Plot Modulated & FDM Signals
% ===========================
spect1_mod = fftshift(fft(sig1_mod));
spect2_mod = fftshift(fft(sig2_mod));
spect3_mod = fftshift(fft(sig3_mod));
spect4_mod = fftshift(fft(sig4_mod));
spect5_mod = fftshift(fft(sig5_mod));
spect_FDM  = fftshift(fft(sig_FDM));

figure;
% 1st Modulated Signal
subplot(2, 2, 1);
plot(f, abs(spect1_mod));
title("Spectrum of Modulated Signal 1 (FC1 = 100 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% 2nd Modulated Signal
subplot(2, 2, 2);
plot(f, abs(spect2_mod));
title("Spectrum of Modulated Signal 2 (FC2 = 130 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% 3rd Modulated Signals
subplot(2, 2, 3);
plot(f, abs(spect3_mod));
title("Spectrum of Modulated Signal 3 (FC3 = 160 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% 4th Modulated Signal
subplot(2, 2, 4);
plot(f, abs(spect4_mod));
title("Spectrum of Modulated Signal 4 (FC4 = 190 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

figure;
% 5th Modulated Signal
subplot(2, 1, 1);
plot(f, abs(spect5_mod));
title("Spectrum of Modulated Signal 5 (FC5 = 220 kHz)");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% FDM Signal
subplot(2, 1, 2);
plot(f, abs(spect_FDM));
title("*Spectrum of FDM Signal");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;


% ===========================
% Plot FDM Signals & RF Output
% ===========================
spect_RF = fftshift(fft(RF_out));

figure;
% FDM Signal
subplot(2, 1, 1);
plot(f, abs(spect_FDM));
title("Spectrum of FDM Signal");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% RF Output
subplot(2, 1, 2);
plot(f, abs(spect_RF));
title('RF Stage Output');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;


% ===========================
% Plot IF (Input & Output)
% ===========================
spect_IF_in = fftshift(fft(IF_in));
spect_IF = fftshift(fft(IF_out));

figure;
% IF Input - Mixer Output
subplot(2, 1, 1);
plot(f, abs(spect_IF_in));
title('Down Converted Singal - Centered at IF = 15 kHz');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

% IF Output
subplot(2, 1, 2);
plot(f, abs(spect_IF));
title('IF Stage Output');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;


% ===========================
% Base Band Signal (Before & After) LPF
% ===========================
spect_BB = fftshift(fft(sig_BB));
spect_BB_filtered = fftshift(fft(sig_BB_filtered));

figure;
% Base Band Signal Before LPF
subplot(2, 1, 1);
plot(f, abs(spect_BB));
title('Base Band Signal - Before LPF');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

% Base Band Signal After LPF
subplot(2, 1, 2);
plot(f, abs(spect_BB_filtered));
title('Base Band Signal - After LPF');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;