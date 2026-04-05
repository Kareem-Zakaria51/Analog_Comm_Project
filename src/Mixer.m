% =============================
% Mixer - RF_out & Local Oscilator
% =============================
IF = 15e3;
FLO = IF + FC1 + deltaFC * n;

% Local Oscillator Carrier
carrier_lo = cos(2 * pi * FLO * t);

% Down Convert signal to IF
IF_in = RF_out .* carrier_lo';