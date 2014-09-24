function [HR,Times]=RRIntervals_to_RR(RRIntervals,Times)
temp_t=reshape(Times,size(Times,1)*size(Times,2),1);
t=sort(temp_t);
i=find(t==0,1,'last');
Times=t(i:end);
RWaveTimes=zeros(length(RRIntervals)+1,1,'single');
RWaveTimes(2:end)=cumsum(RRIntervals);RR = zeros(size(Times,1),size(Times,2),'single');
RR(1,1)=RRIntervals(1,1);
for i = 2:length(RWaveTimes)   
RR(Times>RWaveTimes(i-1)&Times<=RWaveTimes(i))=RRIntervals(i-1);
end
HR=60000./RR;
Times=Times/1000;
end