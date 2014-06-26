function Data_Properties=reduce_coils(Data_Properties)




% RWaveTimes = two_para_model(Data_Properties.ScanLength,[mean(extract_HR_ECG(Data_Properties.Data))*0.9 mean(extract_HR_ECG(Data_Properties.Data))*0.9]);
% KSpace = resort_data_vectorized(Data_Properties.Data, RWaveTimes, 30);
% KSpace=permute(KSpace,[3 1 4 5 2]);

tempKSpace=zeros(size(Data_Properties.Data,1),size(Data_Properties.Data(1,1).KSpace,1),1,size(Data_Properties.Data,2),size(Data_Properties.Data(1,1).KSpace,2));
for iRow = 1:size(Data_Properties.Data)
    for iVelocityEncode = 1:size(Data_Properties.Data,2)
        tempKSpace(iRow,:,1,iVelocityEncode,:) = mean(Data_Properties.Data(iRow,iVelocityEncode).KSpace,3);
    end
end



Images = fftshift(ifft(ifftshift(tempKSpace,1),[],1),1);

if strcmp(Data_Properties.DataType,'PC')
    CoilContributions=sqrt(squeeze(sum(sum(Images(Data_Properties.yDimensions,Data_Properties.xDimensions,1,2,:).*conj(Images(Data_Properties.yDimensions,Data_Properties.xDimensions,1,1,:))))));
else
    CoilContributions=sqrt(squeeze(sum(sum(Images(Data_Properties.yDimensions,Data_Properties.xDimensions,1,1,:).^2))));
end
CoilsToUse = CoilContributions > mean(CoilContributions);

for iRow = 1:size(Data_Properties.Data,1)
    for iVelocityEncode = 1:size(Data_Properties.Data,2)
        Data_Properties.Data(iRow,iVelocityEncode).KSpace = Data_Properties.Data(iRow,iVelocityEncode).KSpace(:,CoilsToUse,:);
    end
end
end


