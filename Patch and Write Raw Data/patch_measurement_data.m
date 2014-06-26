%   [Measurements] = patch_measurement_data(RWaveTimes, Measurements, SiemensOS)
%   This function patches a Measurements structure to match the heart rate
%   trace specified by RWaveTimes
%
%   Inputs:
%   Measurements    - structure containing the measurement and header data,
%                   produced by "read_raw_data.m"
%   RWaveTimes      - List of times (in ms) at which R-waves occured, using
%                   0 ms as the beginning of the scan
%   SiemensOS       - VB, VD, or VD2
%
%   Outputs:
%   Measurements    - The modified (patched) measurement data structure

function [Measurements] = patch_measurement_data(Measurements, RWaveTimes, SiemensOS)

%% Determine premilinary parameters
nMeas = length(Measurements);
InitialTimeStamp = Measurements(1).ulTimeStamp;
FinalTimeStamp = Measurements(end).ulTimeStamp;

%% Recalibrate RWaveTimes to reflect siemens timing convention and scan start time
RWaveTimes = RWaveTimes/2.5 + InitialTimeStamp;
BaseRR = mean(diff(RWaveTimes));

%% Set up waibar
h = waitbar(0,'Processing dat file...');

%% Find last R-wave before first measurement
LastRWaveIndex = find(RWaveTimes<=Measurements(1).ulTimeStamp,1,'last');
if (strcmp(SiemensOS, 'vd2'))
nMeas = nMeas-1;
end
%% Loop over measurements and overwrite struct data
for n = 1:nMeas
    %% Find index of most recent R-wave
    if Measurements(n).ulTimeStamp >= RWaveTimes(LastRWaveIndex + 1)
        LastRWaveIndex = LastRWaveIndex + 1;
    end
    
    %% Calculate new IceProgPara4(1) based on relative position between bordering R-waves
    Measurements(n).aushIceProgramPara4(1) = round(mod(...
        (Measurements(n).ulTimeStamp - RWaveTimes(LastRWaveIndex))/ ...
        (RWaveTimes(LastRWaveIndex+1) - RWaveTimes(LastRWaveIndex))*BaseRR, BaseRR));
    
    %% PMUTime is equal to IceProgPara4(1) plus 7 time units
    Measurements(n).ulPMUTimeStamp = round(mod(Measurements(n).aushIceProgramPara4(1) + 8, BaseRR));
    
    %% Set all IceProgPara4(2) to zero, some will later be changed
    Measurements(n).aushIceProgramPara4(2) = 0;
    
    %% Store the indices necessary for sorting in an array instead of a structure
    %% Line, phase encode, segment, coil, aushIceProgramPara4(1), scan number
    HeaderInfo(:,n) = [Measurements(n).sLoopCounter14([1 8 9]) + 1; ...       
        Measurements(n).ushChannelId + 1; Measurements(n).aushIceProgramPara4(1)];
    
    %% Advance waitbar
    if mod(n,100) == 0
        waitbar(n/nMeas,h);
    end
end

%% Close waitbar
close(h);

%% Calculate number of segments
nSegments = max(HeaderInfo(3,:));

%% Loop over segments
for iSegment = 1:nSegments
    
    %% Calculate "theoretical" start of current segment acquisition
    CurrentRWaveTime = (iSegment-1)*BaseRR + InitialTimeStamp;
    
    %% Find measurements that are part of current segment of interest
    CurrentSegmentIndices = find(HeaderInfo(3,:) == iSegment);
    CurrentSegment = Measurements(CurrentSegmentIndices);
    CurrentSegmentHeader = HeaderInfo(:,CurrentSegmentIndices);
    
    %% Sort according to IceProgPara(1)
    [temp, SortOrder] = sort(CurrentSegmentHeader(5,:));
    CurrentSegment = CurrentSegment(SortOrder);
    CurrentSegmentHeader = CurrentSegmentHeader(:,SortOrder);
    
    %% Find maximum values for the various indices
    nLines = max(CurrentSegmentHeader(1,:));
    nEncodes = max(CurrentSegmentHeader(2,:));
    nCoils = max(CurrentSegmentHeader(4,:));
    
    %% This array stores the values of the indices as they increment
    CardiacPhaseIndices = zeros(nLines, nEncodes, nCoils);
    
    %% Initialize the Cardiac Phase Indices storage variable
    PhaseIndices = [];
    
    %% Loop over measurements in current segment and overwrite header
    for m = 1:length(CurrentSegment)
        %% Overwrite time stamps and cardiac phase indices
        CurrentSegment(m).ulTimeStamp = CurrentRWaveTime + CurrentSegment(m).aushIceProgramPara4(1);
        CurrentSegment(m).sLoopCounter14(6) = CardiacPhaseIndices(CurrentSegment(m).sLoopCounter14(1) + 1, ...
            CurrentSegment(m).sLoopCounter14(8) + 1, CurrentSegment(m).ushChannelId + 1);

        %% Increment cardiac phase index tallies
        CardiacPhaseIndices(CurrentSegment(m).sLoopCounter14(1) + 1, ...
            CurrentSegment(m).sLoopCounter14(8) + 1, CurrentSegment(m).ushChannelId + 1) = ...
            CardiacPhaseIndices(CurrentSegment(m).sLoopCounter14(1) + 1, ...
            CurrentSegment(m).sLoopCounter14(8) + 1, CurrentSegment(m).ushChannelId + 1) + 1;
        
        %% Store Cardiac Phase Indices for sorting purposes
        PhaseIndices(m) = CurrentSegment(m).sLoopCounter14(6);
    end
    
    %% Re-sort acording to cardiac phase
    [temp, NewSortOrder] = sort(PhaseIndices);
    CurrentSegment = CurrentSegment(NewSortOrder);
    
    %% Change scan number to reflect new order
    for m = 1:length(CurrentSegment)
        CurrentSegment(m).ulScanCounter = Measurements(CurrentSegmentIndices(m)).ulScanCounter;
    end

    %% If you're on the last segment, ensure that the one measurement is at
    %% the beginning of the final cardiac cycle
    if iSegment == nSegments
        for m = 1:length(CurrentSegment)
            CurrentSegment(m).ulTimeStamp = CurrentRWaveTime;
            CurrentSegment(m).ulPMUTimeStamp = 8;
            CurrentSegment(m).aushIceProgramPara4(1) = 1;
        end
         if (strcmp(SiemensOS, 'vb'))
        nCoils = nCoils + 1;  % to account for final scan-end measurement *** don't know why????
         end
    end
    
    %% Set IceProgPara(2) ~= 0 for the first measurement of each segment
    for m = 1:nCoils
        CurrentSegment(m).aushIceProgramPara4(2) = CurrentSegment(m).aushIceProgramPara4(1) + BaseRR;
    end
    
    %Overwrite measurements
    Measurements(CurrentSegmentIndices) = CurrentSegment;
end
if (strcmp(SiemensOS, 'vd2'))
    
else

%% Set Cardiac Phase index to 0 for final scan-end measurement
Measurements(end).sLoopCounter14(6) = 0;
end
end