% =============================
% Base Band Detection
% =============================
sig_BB = IF_out .* cos(2 * pi * IF * t)';       % Down Convert signal to base band

% LPF - Cutoff Frequency = Signal BW
fc = BW;        % Filter cutoff
LPF = fir1(200, fc / (Fs_new/2));    % FIR LPF

sig_BB_filtered = filter(LPF, 1, sig_BB);

% Plot Base Band Signal (before & after LPF)
spect_BB = fftshift(fft(sig_BB));
spect_BB_filtered = fftshift(fft(sig_BB_filtered));

figure;
subplot(2, 1, 1);
plot(f, abs(spect_BB));
title('Base Band Signal - Before LPF');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;

subplot(2, 1, 2);
plot(f, abs(spect_BB_filtered));
title('Base Band Signal - After LPF');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
grid on;