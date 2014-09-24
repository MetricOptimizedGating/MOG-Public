function Optimal_Images =  reconstruct_optimal_images(Data_Properties,RWaveTimes)
% RWaveTimes = two_para_model(Data_Properties.ScanLength,optimalrates);
KSpace = resort_data_vectorized(Data_Properties.Data, RWaveTimes, 30);
KSpace=permute(KSpace,[3 1 4 5 2]);
Images = reconstruct_images(Data_Properties,KSpace);
if strcmp(Data_Properties.DataType{1},'PC')
Optimal_Images = zeros(size(Images.Phase,1), size(Images.Magnitude, 2) + size(Images.Phase, 2), size(Images.Magnitude,3));
for iFrame=1:size(Optimal_Images,3)
    mag = Images.Magnitude(:,:,iFrame);
    pha = Images.Phase(:,:,iFrame) + pi;
    mag = mag.^0.75;
    mag = 10*mag / max(mag(:)) + 1;
    pha = 10*pha / max(pha(:)) + 1;
    Optimal_Images(:,:,iFrame) = [mag pha];
end
else
Optimal_Images = zeros(size(Images.Magnitude,1), size(Images.Magnitude, 2), size(Images.Magnitude,3));
for iFrame=1:size(Optimal_Images,3)
    mag = Images.Magnitude(:,:,iFrame);
    mag = mag.^0.55;
    mag = 10*mag / max(mag(:)) + 1;
    Optimal_Images(:,:,iFrame) = mag;
end  
end
end