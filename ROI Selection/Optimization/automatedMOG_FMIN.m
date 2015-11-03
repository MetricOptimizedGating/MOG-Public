function [Optimized_RWaveTimes,Data_Properties]=automatedMOG_FMIN(Data_Properties,Initial_RWaveTimes)

if strcmp(Data_Properties.DataType{2},'GRAPPA')
Data_Properties.DataType{2}='ZEROS';
end

% Reconstruct to total number of acquired frames rounded to 5
% nFrames=length(Data_Properties.Data(1,1).Times)+rem(length(Data_Properties.Data(1,1).Times),1.5);
nFrames = 10;

MaxIterations=5000;

% Stopping Criterion could be improved..
myoptions = optimset('MaxIter',MaxIterations,...
    'LargeScale','on',...
    'TolX', 5, ...
    'TolFun', 1e-4,...
    'OutputFcn',@myoutput);
% 'Display','iter');%
h = waitbar(0,'Performing Search...');

% tic
Optimized_RWaveTimes = fminsearch(@analyze_data, double(Initial_RWaveTimes), myoptions);


% Temporary constraints on HR model incase fminsearch produces a result
% that is outside the range of typical fetal heart rates
Optimized_RRIntervals=diff(Optimized_RWaveTimes);
Optimized_RRIntervals(Optimized_RRIntervals>545)=mean(Optimized_RRIntervals);
Optimized_RRIntervals(Optimized_RRIntervals<330)=mean(Optimized_RRIntervals);
Optimized_RWaveTimes=[0,cumsum(Optimized_RRIntervals)];

% toc
close(h);

if strcmp(Data_Properties.DataType{2},'ZEROS')
Data_Properties.DataType{2}='GRAPPA';
end

% Make sure RWaveTimes span the entire scanlength
if Optimized_RWaveTimes(1)>0
    Optimized_RWaveTimes(1)=0;
elseif Optimized_RWaveTimes(end)<Data_Properties.ScanLength
    Optimized_RWaveTimes(end)=Data_Properties.ScanLength+5;
end


%Uncomment for debugging/visualization of entropy change per iteration

% history = [];
% E=[];
    function stop = myoutput(~,dumy,state)
        stop = false;
        if strcmp(state,'iter')
                    waitbar((dumy.iteration+1)/MaxIterations, h);
%             history = [history; x'];
%             E = [E;dumy.fval];
        end
    end


    function imgmetric = analyze_data(myRWaveTimes)
        % Make sure RWaveTimes span the entire scanlength
        if myRWaveTimes(1)>0
            myRWaveTimes(1)=0;
        elseif myRWaveTimes(end)<Data_Properties.ScanLength
            myRWaveTimes(end)=Data_Properties.ScanLength+5;
        end
        ref_KSpace = resort_data_vectorized(Data_Properties.Data, myRWaveTimes, nFrames);
        ref_KSpace=permute(ref_KSpace,[3 1 4 5 2]);
        Images = reconstruct_images(Data_Properties,ref_KSpace);
        imgmetric=imagemetric(Images.Magnitude(Data_Properties.yDimensions,Data_Properties.xDimensions,:).*Images.Phase(Data_Properties.yDimensions,Data_Properties.xDimensions,:),Data_Properties.DataType);
    end
end

