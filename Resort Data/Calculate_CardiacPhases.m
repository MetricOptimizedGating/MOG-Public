function CP=Calculate_CardiacPhases(Times,RWaveTimes)
Before_Index=zeros(size(Times,1),size(Times,2),length(RWaveTimes)-1);
After_Index=zeros(size(Times,1),size(Times,2),length(RWaveTimes)-1);
% Determine which time points occur before and after each RWaveTime
% (indices)
for loop=1:(length(RWaveTimes)-1)
Before_Index(:,:,loop)=Times<=RWaveTimes(loop+1);
After_Index(:,:,loop)=Times>=RWaveTimes(loop+1);
end
Before_Index=abs(sum(Before_Index,3)-length(RWaveTimes));
After_Index=sum(After_Index,3)+1;
%Keeps track of indices where data was not collected
Before_Index(isnan(Times))=1;
After_Index(isnan(Times))=1;
% For each time point, determine which RWaves come before and after
Last_RWaves=RWaveTimes(After_Index);
Next_RWaves=RWaveTimes(Before_Index+1);
% Calculate Cardiac Phase for each time point
CP=(Times-Last_RWaves)./(Next_RWaves-Last_RWaves);
%Keeps track of indices where data was not collected
CP(isnan(Times))=nan;
end