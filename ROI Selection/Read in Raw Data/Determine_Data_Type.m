function DataType=Determine_Data_Type(Data)
if size(Data,2)==1
    DataType{1}='CINE';
else
    DataType{1}='PC';
end
DataType{2}='FULL';
iRow=1;
while iRow<length(Data)
    if isempty(Data(iRow,1).KSpace)
        DataType{2}='GRAPPA';
        break;
    end
    iRow=iRow+1;
end
end