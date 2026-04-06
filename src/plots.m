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