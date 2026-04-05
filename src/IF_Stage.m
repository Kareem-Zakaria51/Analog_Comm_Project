% =============================
% IF Stage - BPF
% =============================

% IF BPF - Centered at IF
IF_BPF_low = (IF - BW/2) / (Fs_new/2);    % lower cutoff frequency
IF_BPF_upp = (IF + BW/2) / (Fs_new/2);    % upper cutoff frequency
IF_BPF = fir1(200, [IF_BPF_low, IF_BPF_upp], 'bandpass');    % FIR BPF

% Pass Mixer Output to IF BPF
IF_out = filter(IF_BPF, 1,IF_in);

% Plot Spectrum of IF Output
spect_IF = fftshift(fft(IF_out));

figure;
plot(f, abs(spect_IF));
title('IF Stage Output');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;