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
[sig1_sterio, Fs1] = audioread('../assets/Short_FM9090.wav');           % 1st station
[sig2_sterio, Fs2] = audioread('../assets/Short_QuranPalestine.wav');   % 2nd station
[sig3_sterio, Fs3] = audioread('../assets/Short_BBCArabic2.wav');   % 3rd station
[sig4_sterio, Fs4] = audioread('../assets/Short_RussianVoice.wav');   % 4th station
[sig5_sterio, Fs5] = audioread('../assets/Short_SkyNewsArabia.wav');   % 5th station


% Mono Conversion -> as they are sterio signals
sig1_mono = sig1_sterio(:,1) + sig1_sterio(:,2);        % 1st Single Row
sig2_mono = sig2_sterio(:,1) + sig2_sterio(:,2);        % 2nd Single Row
sig3_mono = sig3_sterio(:,1) + sig3_sterio(:,2);        % 3rd Single Row
sig4_mono = sig4_sterio(:,1) + sig4_sterio(:,2);        % 4th Single Row
sig5_mono = sig5_sterio(:,1) + sig5_sterio(:,2);        % 5th Single Row


% Zero Padding -> in case of unequal lengthes
len1 = length(sig1_mono);
len2 = length(sig2_mono);
len3 = length(sig3_mono);
len4 = length(sig4_mono);
len5 = length(sig5_mono);
lens = [len1 len2 len3 len4 len5];
[max_len, sig_idx] = max(lens);
if sig_idx == 1         % sig1 is the longest
    sig2_mono = [sig2_mono; zeros(len1 - len2, 1)];
    sig3_mono = [sig3_mono; zeros(len1 - len3, 1)];
    sig4_mono = [sig4_mono; zeros(len1 - len4, 1)];
    sig5_mono = [sig5_mono; zeros(len1 - len5, 1)];

elseif sig_idx==2     % sig2 is the longest
    sig1_mono = [sig1_mono; zeros(len2 - len1, 1)];
    sig3_mono = [sig3_mono; zeros(len2 - len3, 1)];
    sig4_mono = [sig4_mono; zeros(len2 - len4, 1)];
    sig5_mono = [sig5_mono; zeros(len2 - len5, 1)];

elseif sig_idx==3     % sig3 is the longest
    sig1_mono = [sig1_mono; zeros(len3 - len1, 1)];
    sig2_mono = [sig2_mono; zeros(len3 - len2, 1)];
    sig4_mono = [sig4_mono; zeros(len3 - len4, 1)];
    sig5_mono = [sig5_mono; zeros(len3 - len5, 1)];

 elseif sig_idx==4     % sig4 is the longest
    sig1_mono = [sig1_mono; zeros(len4 - len1, 1)];
    sig2_mono = [sig2_mono; zeros(len4 - len2, 1)];
    sig3_mono = [sig3_mono; zeros(len4 - len3, 1)];
    sig5_mono = [sig5_mono; zeros(len4 - len5, 1)];

 elseif sig_idx==5     % sig5 is the longest
    sig1_mono = [sig1_mono; zeros(len5 - len1, 1)];
    sig2_mono = [sig2_mono; zeros(len5 - len2, 1)];
    sig3_mono = [sig3_mono; zeros(len5 - len3, 1)];
    sig4_mono = [sig4_mono; zeros(len5 - len4, 1)];

end

% Upsampling by 11 -> 44.1 * 11 > 2 * (100 + 4 * 30) +10"Nyquest Criteria"
upsamp_factor = 11;
sig1_sampled = interp(sig1_mono, upsamp_factor);
sig2_sampled = interp(sig2_mono, upsamp_factor);
sig3_sampled = interp(sig3_mono, upsamp_factor);
sig4_sampled = interp(sig4_mono, upsamp_factor);
sig5_sampled = interp(sig5_mono, upsamp_factor);
Fs_new = Fs1 * upsamp_factor;
Ts_new = 1 / Fs_new;


% ===========================
% Plot Upsampled Signals
% ===========================
N = length(sig1_sampled);
t = (0 : N-1) * Ts_new;             % time vector
f = (-N/2 : N/2-1) * (Fs_new / N);  % frequency vector

spect1 = fftshift(fft(sig1_sampled));
spect2 = fftshift(fft(sig2_sampled));
spect3 = fftshift(fft(sig3_sampled));
spect4 = fftshift(fft(sig4_sampled));
spect5 = fftshift(fft(sig5_sampled));


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


sig_FDM = sig1_mod + sig2_mod + sig3_mod +sig4_mod + sig5_mod;