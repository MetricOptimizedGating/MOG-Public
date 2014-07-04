function MOG_Tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and read in raw data file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
restart='Yes';
while strcmp(restart,'Yes')
    Data_Properties=Data_Class();
    [filename,path]=uigetfile({'*.dat;*.mat','MOG Files (*.dat,*.mat)'});
    if strcmp(filename(end-3:end),'.dat');
         [Data_Properties.Measurements, Data_Properties.Data, Data_Properties.SiemensOS, Data_Properties.IMAStart] = read_raw_data(path,filename);
    % This script reads in protocol info including the target vessel and
    % patient name. Currently tested for Siemens PCMR data at SickKids only. Set variable
    % to 'off' for anonomyzed results
        Data_Properties.Protocol = read_protocol_info(path,filename,'off');
    elseif strcmp(filename(end-3:end),'.mat');
        load ([path,filename])
        Data_Properties.Data=Data;
        Data_Properties.Protocol='.mat File';
    end
    Data_Properties.Trial=0;
    Data_Properties.DataType=Determine_Data_Type(Data_Properties.Data);
    Data_Properties.ScanLength=max(max(max(extract_times(Data_Properties.Data))))+10;
    if strcmp(Data_Properties.DataType{2},'GRAPPA')
        [Data_Properties.Data,Data_Properties.Sampled_Rows]=condense_data(Data_Properties.Data);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Select Region of interest for entropy calculations
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    user_input='retry';
    while strcmp(user_input,'retry')
        
         [Data_Properties,user_input] = selectROI(Data_Properties);
%    Data_Properties.yDimensions=119:129;
 %       Data_Properties.xDimensions=80:90;
 %       Data_Properties.Trial=Data_Properties.Trial+1;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Perform two-parameter grid search
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if strcmp(user_input,'skip')
            restart=questdlg('Would you like to reconstruct a different file?','Analysis Incomplete','Yes', 'No', 'Yes');
        else
            [Optimization,Data_Properties]=automatedMOG_GRID(Data_Properties);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Display entropy landcape and optimum images
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            user_input=display_results(Data_Properties,Optimization);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Patch Raw Data File or Restart
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(user_input, 'yes') && strcmp(filename(end-3:end),'.dat');
                RWaveTimes = two_para_model(Data_Properties.ScanLength, [Optimization.minhr1, Optimization.minhr2]);
                clear Data_Properties.Data
                [Data_Properties.Measurements] = patch_measurement_data(Data_Properties.Measurements, RWaveTimes, Data_Properties.SiemensOS);
                write_raw_data(Data_Properties.Measurements, path, filename, Data_Properties.SiemensOS, Data_Properties.IMAStart);
                clear('Data_Properties.Measurements')
                restart=questdlg('Would you like to reconstruct another file?','Analysis Complete','Yes', 'No', 'Yes');
            elseif strcmp(user_input, 'yes') && strcmp(filename(end-3:end),'.mat');
                save(strcat(path,filename(1:(end-4)),'_patched',filename((end-3):end)),'Data')
                restart=questdlg('*_patched.mat file has been saved. Would you like to reconstruct another file?','Analysis Complete','Yes', 'No', 'Yes');
            elseif strcmp(user_input, 'no')
                restart=questdlg('Would you like to reconstruct another file?','Analysis Complete','Yes', 'No', 'Yes');
            end
        end
    end
end
