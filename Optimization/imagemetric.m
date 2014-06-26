%   MetricValue = imagemetric(Images)
%   This function takes a 3D image series (xyt), or a cropped subset of a
%   series and returns a scalar value which is the time-entropy of those
%   images
%
%   Inputs:
%   Images          - 3D series of images.  The x and y dimensions are not
%                   important (ie can be collapsed) but the 3rd must be
%                   preserved)
%
%   Outputs:
%   MetricValue     - Scaler representing the metric value

function MetricValue = imagemetric(Images,DataType)
if strcmp(DataType{1},'PC')
% Check inputs
if length(size(Images)) ~= 3
    error('images is not a 3D array')
end

%% Rectify images
Images = abs(Images);

%% Calculate time-sums
PixelTotals = sqrt(sum(Images.^2,3));
PixelTotals(PixelTotals == 0) = 1;

%% Normalize Images
NormalizedImages = Images./PixelTotals(:,:,ones(size(Images,3),1));

%% Eliminate zeros from Images
NormalizedImages(NormalizedImages == 0) = 1;

%% Compute entropy
PixelEntropies = sum(NormalizedImages.*log(NormalizedImages),3);
if sum(PixelTotals(:))
    PixelWeights = PixelTotals/sum(PixelTotals(:));
else
    PixelWeights = zeros(size(PixelTotals));
end

MetricValue = -sum(sum(PixelEntropies.*PixelWeights,1),2);


else
    % Check inputs
if length(size(Images)) ~= 3
    error('images is not a 3D array')
end
% Rectify images
dImages = abs(double(Images));

% Calculate Space-sums
PixelTotals = sqrt(sum(sum(dImages.^2)));
PixelTotals(PixelTotals == 0) = 1;

% Normalize Images
NormalizedImages = dImages./PixelTotals(ones(size(dImages,1),1),ones(size(dImages,2),1),:);

% Eliminate zeros from Images
NormalizedImages(NormalizedImages == 0) = 1;

% Compute entropy
PixelEntropies = sum(sum(NormalizedImages.*log(NormalizedImages)));
if sum(PixelTotals(:))
    PixelWeights = PixelTotals/sum(PixelTotals(:));
else
    PixelWeights = zeros(size(PixelTotals));
end
MetricValue = -sum(PixelEntropies.*PixelWeights);
end

end
