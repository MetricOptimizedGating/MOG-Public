%   RWaveTimes = two_para_model(ScanLength, Parameters)
%   This function takes the scan length and heart-rate-model parameters and
%   returns a list of the times at which R-waves occured
%
%   Inputs:
%   ScanLength      - The length of the scan in ms
%   Parameters      - The heart rates during the first and second halves of
%                   the scan (in BPM)
%
%   Outputs:
%   RWaveTimes      - List of the times at which R-waves occur (in ms)

function RWaveTimes = two_para_model(ScanLength, Parameters)
%% Convert heart rates into RR-interval lengths
Periods = 60000./Parameters;

%% Lay out R-waves from the middle to beginning
RWaveTimes = ScanLength/2;
while RWaveTimes(1) >= 0
    RWaveTimes = [RWaveTimes(1) - Periods(1), RWaveTimes];
end

%% Lay out R-waves from the middle to end
while RWaveTimes(end) <= ScanLength
    RWaveTimes = [RWaveTimes, RWaveTimes(end) + Periods(2)];
end

end
