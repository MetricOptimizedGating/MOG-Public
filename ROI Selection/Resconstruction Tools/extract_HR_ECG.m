function [RRIntervals,RWaveTimes] = extract_HR_ECG(Data)
VPS=find_VPS(Data);
Times=extract_times(Data);ScanLength=max(Times(:));
seg1=1:VPS:size(Times,1);
seg2=VPS:VPS:size(Times,1);
RWaveTimes=zeros(length(seg1)+1,1);
% Put in to catch if seg1 and seg2 do not equal
if (length(seg1)==length(seg2))
RWaveTimes=zeros(length(seg1)+1,1);
for loop=1:length(seg1)
temp_t=Times(seg1(loop):seg2(loop),:);
RWaveTimes(loop+1,1)=max(temp_t(:));
end
else
RWaveTimes=zeros(length(seg2)+1,1);
for loop=1:length(seg2)
temp_t=Times(seg1(loop):seg2(loop),:);
RWaveTimes(loop+1,1)=max(temp_t(:));
end    
end
if RWaveTimes(end,1)<=ScanLength
    RWaveTimes(end,1)=RWaveTimes(end,1)+(ScanLength-RWaveTimes(end,1))+2.5;
end
RRIntervals=diff(RWaveTimes);
end