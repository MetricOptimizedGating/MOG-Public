%   [Measurements] = patch_measurement_data(RWaveTimes, Measurements, SiemensOS)
%   This function patches a Measurements structure to match the heart rate
%   trace specified by RWaveTimes
%
%   Inputs:
%   Measurements    - structure containing the measurement and header data,
%                   produced by "read_raw_data.m"
%   RWaveTimes      - List of times (in ms) at which R-waves occured, using
%                   0 ms as the beginning of the scan
%   SiemensOS       - VB, VD, or VE
%
%   Outputs:
%   Measurements    - The modified (patched) measurement data structure

function [Measurements] = patch_measurement_data(Measurements, RWaveTimes, SiemensOS)

%% Save original measurements
MeasurementsOriginal=Measurements;
%% Determine premilinary parameters
InitialTimeStamp = Measurements(1).ulTimeStamp;
FinalTimeStamp = Measurements(end).ulTimeStamp;
% Remove ACQ_END
Measurements(end)=[];
nMeas = length(Measurements);
%% Recalibrate RWaveTimes to reflect siemens timing convention and scan start time
RWaveTimes = RWaveTimes/2.5 + InitialTimeStamp;
BaseRR = mean(diff(RWaveTimes));

%% Set up waibar
h = waitbar(0,'Processing dat file...');

%% Find last R-wave before first measurement
LastRWaveIndex = find(RWaveTimes<=Measurements(1).ulTimeStamp,1,'last');
%% Loop over measurements and overwrite struct data
for n = 1:nMeas
    %% Find index of most recent R-wave
    if Measurements(n).ulTimeStamp >= RWaveTimes(LastRWaveIndex + 1)
    LastRWaveIndex = LastRWaveIndex + 1;
    end
   if (LastRWaveIndex+1 >numel(RWaveTimes))
   n
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
maxEncodes=0;
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
    if (nEncodes>maxEncodes)
        maxEncodes=nEncodes;
    end
    %% This array stores the values of the indices as they increment
    CardiacPhaseIndices = zeros(nLines, nEncodes, nCoils);
    
    %% Initialize the Cardiac Phase Indices storage variable
    PhaseIndices = [];
        LineIndices=[];
        Table=[];
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
        LineIndices(m) = CurrentSegment(m).sLoopCounter14(1);
        ChannelIndices(m) = CurrentSegment(m).ushChannelId;
        SegmentIndices2(m)=CurrentSegment(m).sLoopCounter14(9);
        SetIndicies(m)=CurrentSegment(m).sLoopCounter14(8);
        Table(m,1)=CurrentSegment(m).sLoopCounter14(9);
         Table(m,2)= CurrentSegment(m).sLoopCounter14(6);
          Table(m,3)= CurrentSegment(m).sLoopCounter14(1);
         Table(m,4)=CurrentSegment(m).sLoopCounter14(8);
         Table(m,5)= CurrentSegment(m).ushChannelId;

    end
    
    %% Re-sort acording to cardiac phase
   [table2,NewSortOrder2]=sortrows(Table);
 % Original sort done by Micheal worked for VB non-grappa retained in code
 % for troubleshooting
        [temp, NewSortOrder] = sort(PhaseIndices);

   CurrentSegment = CurrentSegment(NewSortOrder2);
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
    end
    
    %% Set IceProgPara(2) ~= 0 for the first measurement of each segment
    for m = 1:nCoils
        CurrentSegment(m).aushIceProgramPara4(2) = CurrentSegment(m).aushIceProgramPara4(1) + BaseRR;
    end
    
    %Overwrite measurements
    Measurements(CurrentSegmentIndices) = CurrentSegment;
end
%Counter in incraments of ushChannels Used
nChan = 1;
NumberOfChannels=Measurements(1).ushUsedChannels;
 % Overwrite Line Index and EvalInfoMask
 for i=1:nMeas
 IceProgramPara4(i,:)=MeasurementsOriginal(i).aushIceProgramPara4;
 end
IceProgramPara4Sum=sum(sum(int16(IceProgramPara4)));
 for mm=1:nMeas
 Measurements(mm).sLoopCounter14(1)=MeasurementsOriginal(mm).sLoopCounter14(1);   
 Measurements(mm).aulEvalInfoMask2(1)=MeasurementsOriginal(mm).aulEvalInfoMask2(1);
 Measurements(mm).aulEvalInfoMask2(2)=MeasurementsOriginal(mm).aulEvalInfoMask2(2);
%if ice program para 4 is zero throughtout not sure this part is necessary
if(IceProgramPara4Sum==0)
Measurements(mm).aushIceProgramPara4=MeasurementsOriginal(mm).aushIceProgramPara4;
end
% Correction for VD/VE phase contrast scans, without this fix set 0 ulTimeScan is greater than set 1 ulTimeScan. 
% Accounts for the fact that measurement data sturucture is not always set
% 0, set 1, set 0, set 1 etc. There are individual measurements without a
% corresponding set 0 and set 1. Therefore pattern could be 0,1,0,1,1,0,1,0
% etc. 
% Check if set 0 and 1 have 
 if (maxEncodes==2 &&  mm == nChan && mm<nMeas-NumberOfChannels)
if ((Measurements(mm+NumberOfChannels).sLoopCounter14(8)-Measurements(mm).sLoopCounter14(8))~=1)
nChan=nChan+NumberOfChannels;
elseif (Measurements(mm+NumberOfChannels).ulTimeStamp<Measurements(mm).ulTimeStamp)
    Time1 = Measurements(mm).ulTimeStamp;
    PMU1 = Measurements(mm).ulPMUTimeStamp;
    Time2 = Measurements(mm+NumberOfChannels).ulTimeStamp;
    PMU2 = Measurements(mm+NumberOfChannels).ulPMUTimeStamp;
    for ll=mm:NumberOfChannels
    Measurements(ll).ulTimeStamp=Time2;
    Measurements(ll).ulPMUTimeStamp=PMU2;
    end
    for ll=mm+NumberOfChannels:mm+NumberOfChannels*2
    Measurements(ll).ulTimeStamp=Time1;
    Measurements(ll).ulPMUTimeStamp=PMU1;
    end
    nChan=nChan + 2*NumberOfChannels;
else
    nChan=nChan + 2*NumberOfChannels;
end

 end
 end
Measurements(nMeas+1)=MeasurementsOriginal(nMeas+1);
Measurements(nMeas+1).ulTimeStamp=Measurements(nMeas).ulTimeStamp;
Measurements(nMeas+1).ulPMUTimeStamp=Measurements(nMeas).ulPMUTimeStamp+1;
Measurements(nMeas+1).sLoopCounter14=MeasurementsOriginal(nMeas+1).sLoopCounter14;
end