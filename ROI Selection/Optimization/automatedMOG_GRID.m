function [Optimization,Data_Properties]=automatedMOG_GRID(Data_Properties)
% tic
Optimization=Optimization_Class();
[minhr1,minhr2,minhr,maxhr,hrs0,Data_Properties.PatientType]=determine_patient_type(Data_Properties.Data);

% if strcmp(Data_Properties.DataType{2},'FULL') && Data_Properties.Trial==1;
%     Data_Properties=reduce_coils(Data_Properties);
% end

if strcmp(Data_Properties.DataType{2},'GRAPPA')
Data_Properties.DataType{2}='ZEROS';
end

% set up a wait bar so user doesn't think computer is frozen
h = waitbar(0,'Performing Search...');

% resolutions go from 10, 4, 3, 2, 1
% offsets go from 35, 8, 6, 4, 2
rs =     [10 4 3 2 1];
offset = [35 8 6 4 2];
nFrames = 10;
% initialize to some bogus value. Metric doesn't exceed 4
minmetric = 1000000;

% keep track of heart rate pairs searched and its corresponding
% image metric to generate landscape
hr1s = [];
hr2s = [];
metrix = [];
% for each hr1, hr2 pairs, the first pair will be taken as reference during
% the partial reconstruction of the KSPace
for k=1:length(rs)
    
    s1 = minhr1 - offset(k);
    e1 = minhr1 + offset(k);
    s2 = minhr2 - offset(k);
    e2 = minhr2 + offset(k);
    
    % if hr1 is bigger than hr2 by more than 20, it is likely to be off
    % from the dense region. use the average as next search point
    if abs(minhr1 - minhr2) > 15
        
        midpoint = round((minhr1 + minhr2)/2);
        s1 = midpoint - offset(k);
        e1 = midpoint + offset(k);
        s2 = s1;
        e2 = e1;
        
    end
    
    % two_para_search returns array of structs, each struct
    % containing hr1 and list of hr2s
    hrs = two_para_search(s1, e1, s2, e2, rs(k));
    
    % this part is hardcoded at the moment
    if k == 1
        hrs = hrs0;
    end
    
    % loop through struct array, and perform searches
    for i=1:length(hrs)
        
        hr1 = hrs(i).hr1;
        hr2list = hrs(i).hr2;
      
        % priming step
        % use first pair to do full reconstruction of KSPace, then
        % only bottom half of KSPace needs to be reconstructed in
        % later runs
        hr2 = hr2list(1);
        RWaveTimes = two_para_model(Data_Properties.ScanLength, [hr1 hr2]);
        ref_KSpace = resort_data_vectorized(Data_Properties.Data, RWaveTimes, nFrames);
        ref_KSpace2=permute(ref_KSpace,[3 1 4 5 2]);
        Images = reconstruct_images(Data_Properties,ref_KSpace2);
        imgmetric=imagemetric(Images.Magnitude(Data_Properties.yDimensions,Data_Properties.xDimensions,:).*Images.Phase(Data_Properties.yDimensions,Data_Properties.xDimensions,:),Data_Properties.DataType);
        % record heart rate pair and image metric
        hr1s = [hr1s hr1 - minhr + 1]; %#ok<*AGROW>
        hr2s = [hr2s maxhr - hr2 + 1];
        metrix = [metrix imgmetric];
        waitbar(length(hr1s)/101, h);
        
        % update mininum if needed
        if imgmetric < minmetric
            
            minmetric = imgmetric;
            minhr1 = hr1;
            minhr2 = hr2;
            
            
        end
        
        % partially reconstruct
        for j=2:length(hr2list)
            hr2 = hr2list(j);
            RWaveTimes = two_para_model(Data_Properties.ScanLength, [hr1 hr2]);
            KSpace = partial_resort_data_vectorized(Data_Properties.Data, ref_KSpace, (size(Data_Properties.Data,1)/2) - 2, RWaveTimes, nFrames);
            KSpace2=permute(KSpace,[3 1 4 5 2]);
            Images = reconstruct_images(Data_Properties,KSpace2);
            imgmetric=imagemetric(Images.Magnitude(Data_Properties.yDimensions,Data_Properties.xDimensions,:).*Images.Phase(Data_Properties.yDimensions,Data_Properties.xDimensions,:),Data_Properties.DataType);
            
            % record
            hr1s = [hr1s hr1 - minhr + 1];
            hr2s = [hr2s maxhr - hr2 + 1];
            metrix = [metrix imgmetric];
            waitbar(length(hr1s)/101, h);
            
            % update
            if imgmetric < minmetric
                
                minmetric = imgmetric;
                minhr1 = hr1;
                minhr2 = hr2;
                
            end
            
        end
        
    end
    
end
% toc
close(h);


Optimization.minhr1=minhr1;
Optimization.minhr2=minhr2;
Optimization.metrix=metrix;
Optimization.hr1s=hr1s;
Optimization.hr2s=hr2s;

if strcmp(Data_Properties.DataType{2},'ZEROS') && ~strcmp(Data_Properties.DataType{3},'MSENSE')
Data_Properties.DataType{2}='GRAPPA';
end



end

