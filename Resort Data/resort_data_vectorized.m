%   KSpace = resort_data(Data, RWaveTimes, nFrames)
%   This function takes raw data, the number of frames to reconstruct, and
%   information regarding the heart rate trace and re-sorts the data
%   accordingly into a 5d k-space array
%
%   Inputs:
%   Data            - Structure containing echoes (that are already
%                   transformed and cropped in the FE direction), as well as the times for
%                   each measurement
%   RWaveTimes      - List of the times at which R-waves occur (in ms)
%   nFrames         - Number of frames to reconstruct
%
%   Outputs:
%   KSpace          - 5D k-space complex-valued array (vert, hor, cardiac
%   phase, phase encode, coil)

function KSpace = resort_data_vectorized(Data, RWaveTimes, nFrames)

%% Initialize K-Space
nRows = size(Data,1);
nCols = size(Data(1).KSpace,1);
nVelocityEncodes = size(Data,2);
nCoils = size(Data(1).KSpace,2);
KSpace = zeros(nCols, nCoils, nRows, nFrames, nVelocityEncodes, 'single');

%% Loop over rows, and velocity-encodes (times for columns and coils are the same for each measurement)
for iVelocityEncodes = 1:nVelocityEncodes
    % Calculate Timing Data
    Times=extract_times(Data(:,iVelocityEncodes));
    % Calculate weights and indices for linear nearest neighboor interpolation
    [LeftIndices,RightIndices,LeftWeights,RightWeights] = CardiacPhase_Interpolation(size(Times,1),size(Times,2),Times,RWaveTimes,nFrames);

    for iFrame = 1:nFrames        
        for iRow = 1:nRows            
            KSpace(:,:,iRow,iFrame,iVelocityEncodes) = Data(iRow,iVelocityEncodes).KSpace(:,:,LeftIndices(iFrame,iRow)).*LeftWeights(iFrame,iRow)+Data(iRow,iVelocityEncodes).KSpace(:,:,RightIndices(iFrame,iRow)).*RightWeights(iFrame,iRow);
        end
    end
end

