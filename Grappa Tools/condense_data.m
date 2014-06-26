function [cData,sampled_rows]=condense_data(Data)

if rem(length(Data),2)
    Data(2:size(Data,1)+1,:)=Data(1:size(Data,1),:);
    Data(1,1).KSpace=[];
    Data(1,1).Times=[];
    Data(1,2).KSpace=[];
    Data(1,2).Times=[];
end


Samples=zeros(size(Data,1),1);
for iRow=1:size(Data,1)
    Samples(iRow,1)=length((Data(iRow,1).Times));
end
sampled_rows=find(Samples>1);

F=fieldnames(Data);
if length(F)==2
cData=struct('KSpace', {}, 'Times', {});
elseif length(F)==3
cData = struct('KSpace', {}, 'Times', {},'Slice',{});
end


if ~isempty(Data(1,1).Times)
    Start_Time=Data(1,1).Times(1,1);
else
    Start_Time=Data(2,1).Times(1,1);
end

for iVelocityEncode=1:size(Data,2)
    for iRow = 1:length(sampled_rows)
        cData(iRow,iVelocityEncode)=Data(sampled_rows(iRow),iVelocityEncode);
        cData(iRow,iVelocityEncode).Times=cData(iRow,iVelocityEncode).Times-Start_Time;
        cData(iRow,iVelocityEncode).Times(cData(iRow,iVelocityEncode).Times<0)=0;
    end
end
end
