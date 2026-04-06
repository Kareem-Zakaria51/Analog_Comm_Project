% =============================
% Base Band Detection
% =============================
sig_BB = IF_out .* cos(2 * pi * IF * t)';       % Down Convert signal to base band

% LPF - Cutoff Frequency = Signal BW
fc = BW;        % Filter cutoff
LPF = fir1(200, fc / (Fs_new/2));    % FIR LPF

sig_BB_filtered = filter(LPF, 1, sig_BB);

sig_out= resample(sig_BB_filtered,Fs1,Fs_new);

sound(sig_out,Fs1);