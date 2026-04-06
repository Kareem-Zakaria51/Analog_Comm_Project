% =============================
% IF Stage - BPF
% =============================

% IF BPF - Centered at IF
IF_BPF_low = (IF - BW/2) / (Fs_new/2);    % lower cutoff frequency
IF_BPF_upp = (IF + BW/2) / (Fs_new/2);    % upper cutoff frequency
IF_BPF = fir1(300, [IF_BPF_low, IF_BPF_upp], 'bandpass');    % FIR BPF

% Pass Mixer Output to IF BPF
IF_out = filter(IF_BPF, 1,IF_in);