% =============================
% RF Stage - BPF
% =============================
BW = 15e3;          % estimated from signal plot

% BPF1 for signal 1 - centered at FC1 = 100 kHz
BPF1_low = (FC1 - BW/2) / (Fs_new/2);       % lower cutoff frequency
BPF1_upp = (FC1 + BW/2) / (Fs_new/2);       % upper cutoff frequency
BPF1 = fir1(200, [BPF1_low, BPF1_upp], 'bandpass');     % FIR BPF

% BPF2 for signal 2 - centered at FC2 = 130 kHz
BPF2_low = (FC2 - BW/2) / (Fs_new/2);       % lower cutoff frequency
BPF2_upp = (FC2 + BW/2) / (Fs_new/2);       % upper cutoff frequency
BPF2 = fir1(200, [BPF2_low, BPF2_upp], 'bandpass');     % FIR BPF

% Apply BPFs to FDM Signal
RF_out1 = filter(BPF1, 1, sig_FDM);         % filtered signal 1
RF_out2 = filter(BPF2, 1, sig_FDM);         % filtered signal 2

% Plot Spectrum of RF Outputs
spect_RF1 = fftshift(fft(RF_out1));
spect_RF2 = fftshift(fft(RF_out2));

figure;
subplot(2, 1, 1);
plot(f, abs(spect_RF1));
title('RF Output - Signal 1 (FM9090)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

subplot(2, 1, 2);
plot(f, abs(spect_RF2));
title('RF Output - Signal 2 (Quran Palestine)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;