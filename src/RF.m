% =============================
% RF Stage - BPF
% =============================
BW = 15e3;          % estimated from signal plot
n = 0;              % signal index [0, 1 == sig1, sig2]
deltaFC = 30e3;     % each signal carrier differ by 30 kHz

% BPF for signal 1+n - centered at FC1 + 30*n kHz
BPF_low = (FC1 + deltaFC*n - BW/2) / (Fs_new/2);    % lower cutoff frequency
BPF_upp = (FC1 + deltaFC*n + BW/2) / (Fs_new/2);    % upper cutoff frequency
BPF = fir1(200, [BPF_low, BPF_upp], 'bandpass');    % FIR BPF

% Pass FDM signal to RF BPF
RF_out = filter(BPF, 1,sig_FDM);