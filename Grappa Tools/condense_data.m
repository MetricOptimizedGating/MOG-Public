function [cData,sampled_rows,GrappaFactor,MSENSE_FLAG]=condense_data(Data)
% Check if MSense
MSENSE_FLAG=0;
grappa_m=zeros(1,size(Data,1));
for n=1:size(Data,1)
if (isempty(Data(n,1).KSpace))
else
grappa_m(1,n)=1;
end
end
for n=2:12
msense=zeros(1,size(Data,1));
msense(1:n:end)=1;
if (isequal(grappa_m,msense))
    MSENSE_FLAG=1;
    GrappaFactor=n;
end
end
%
SORT_FLAG=0;
if(MSENSE_FLAG==0)
if (isequal(grappa_m(1:9),[1,0,1,0,1,0,1,0,1]))
    GrappaFactor=2;
elseif (isequal(grappa_m(1:9),[1,0,0,1,0,0,1,0,0]))
    GrappaFactor=3;
elseif (isequal(grappa_m(1:9),[1,0,0,0,1,0,0,0,1]))
    GrappaFactor=4;
elseif (isequal(grappa_m(1:9),[1,0,0,0,0,1,0,0,0]))
    GrappaFactor=5;  
elseif (isequal(grappa_m(1:9),[1,0,0,0,0,0,1,0,0]))
    GrappaFactor=6;     
elseif (isequal(grappa_m(1:9),[1,0,0,0,0,0,0,1,0]))
    GrappaFactor=7;     
elseif (isequal(grappa_m(1:9),[1,0,0,0,0,0,0,0,1]))
    GrappaFactor=8;   
elseif (isequal(grappa_m(1:9),[0,1,0,1,0,1,0,1,0]))
    GrappaFactor=2;
    SORT_FLAG=1;
elseif(isequal(grappa_m(1:9),[0,0,1,0,0,1,0,0,1]))
    GrappaFactor=3;
    SORT_FLAG=1;
elseif(isequal(grappa_m(1:9),[0,0,1,0,0,0,1,0,0]))
    GrappaFactor=4;
    SORT_FLAG=2;
elseif(isequal(grappa_m(1:9),[0,1,0,0,1,0,0,1,0]))
    GrappaFactor=3;
    SORT_FLAG=2;
else
    error('Error unknown grappa factor, report error');
end
end
if (SORT_FLAG==0)
if rem(length(Data),GrappaFactor)
    Data(GrappaFactor:size(Data,1)+GrappaFactor-1,:)=Data(1:size(Data,1),:);
    for mm=1:GrappaFactor-1
    Data(mm,1).KSpace=[];
    Data(mm,1).Times=[];
    if (size(Data,2)==2)
    Data(mm,2).KSpace=[];
    Data(mm,2).Times=[];
    end
    end
end
end
if (SORT_FLAG==2)
if rem(length(Data),GrappaFactor)
    Data(2:size(Data,1)+1,:)=Data(1:size(Data,1),:);
    for mm=1:GrappaFactor-1
    Data(mm,1).KSpace=[];
    Data(mm,1).Times=[];
    if (size(Data,2)==2)
    Data(mm,2).KSpace=[];
    Data(mm,2).Times=[];
    end
    end
end
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
    Start_Time=Data(GrappaFactor,1).Times(1,1);
end

for iVelocityEncode=1:size(Data,2)
    for iRow = 1:length(sampled_rows)
        cData(iRow,iVelocityEncode)=Data(sampled_rows(iRow),iVelocityEncode);
        cData(iRow,iVelocityEncode).Times=cData(iRow,iVelocityEncode).Times-Start_Time;
        cData(iRow,iVelocityEncode).Times(cData(iRow,iVelocityEncode).Times<0)=0;
    end
end
end

