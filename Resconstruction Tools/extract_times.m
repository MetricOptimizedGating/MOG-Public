function Times = extract_times(Data)
% Determine the maximum number of measured cardiac phases for each row in
% the original data structure
nRows = zeros(size(Data,1),size(Data,2),'single');
for iVelocityEncodes=1:size(Data,2);
for iRow = 1:size(Data,1);
nRows(iRow,iVelocityEncodes)=length(Data(iRow,iVelocityEncodes).Times);
end
end

% Pre-allocate the time array with nan so that time-points wherein data was
% not collected are not mistakingly recordign as time = 0 ms.
Times = nan(size(Data,1),max(nRows(:)),size(Data,2),'single');
for iVelocityEncodes=1:size(Data,2);
for iRow = 1:size(Data,1);
if nRows(iRow,iVelocityEncodes)~=0
    Times(iRow,1:nRows(iRow,iVelocityEncodes),iVelocityEncodes)=Data(iRow,iVelocityEncodes).Times;
end
end
end
if Times(end,2,1)<Times(end,1,1)
Times(end,1,1)=Times(end-1,1,1)-Times(end-2,1,1)+Times(end-1,1,1);
end
minTimes=min(min(min(Times)));
Times=Times-minTimes;
end