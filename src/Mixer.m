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