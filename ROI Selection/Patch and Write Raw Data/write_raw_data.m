%   [] = write_raw_data(Measurements, pathname, filename, SiemensOS, IMAStart)
%   This function takes a measurement structure and writes that data over
%   an exisiting meas.dat file
%
%   Inputs:
%   Measurements    - structure containing the measurement and header data,
%                   produced by "read_raw_data.m"
%   pathname        - name of the path where the target dat file is located,
%                   excluding the trailing slash
%   filename        - name of source meas.dat file, excluding the path
%
%   Outputs:
%

function [] = write_raw_data(Measurements, pathname, filename, SiemensOS, IMAStart, NoiseScan, Grappa)
newfilename = [filename(1:(end-4)) '_patched' filename((end-3):end)];
copyfile([pathname filesep filename],[pathname filesep newfilename],'f')

fid2 = fopen([pathname filesep newfilename], 'r+');
if (fid2==-1),  
    error(['Error reading ', newfilename,' in ', pathname,' directory'])
end

%% Advance to start of IMA file
%% Set up waitbar
f = dir([pathname filesep filename]);  
fileSize = f.bytes;  
CompletedBytes =IMAStart;
cPos=IMAStart;
n=1;
tic; 
h_wait2 = waitbar(0,'Writing dat file...');
if (strcmp(SiemensOS, 'vd') || strcmp(SiemensOS, 'vd2')||strcmp(SiemensOS,'ve'))
    szScanHeader    = 192; % [bytes]
    szChannelHeader = 32;  % [bytes]
    Status = fseek(fid2, IMAStart, 'bof');
   
%% Proceed through file overwriting appropriately
while (n<=length(Measurements))   
    fwrite(fid2, Measurements(n).ulDMALength,          'ubit25');
    fwrite(fid2, Measurements(n).ulPackBit, 'ubit1');
    fwrite(fid2, Measurements(n).ulPCI_rx, 'ubit6');
    fwrite(fid2, Measurements(n).ulMeasUID,                    'int32');
    fwrite(fid2, Measurements(n).ulScanCounter,                'uint32');
    fwrite(fid2, Measurements(n).ulTimeStamp,                  'uint32');
    fwrite(fid2, Measurements(n).ulPMUTimeStamp,               'uint32');
    fwrite(fid2, Measurements(n).ushSystemType,                'uint16');
    fwrite(fid2, Measurements(n).ulPTABPosDelay,               'uint16');
    fwrite(fid2, Measurements(n).ulPTABPosX,                    'int32');
    fwrite(fid2, Measurements(n).ulPTABPosY,                    'int32');
    fwrite(fid2, Measurements(n).ulPTABPosZ,                    'int32');
    fwrite(fid2, Measurements(n).ulReserved1,                   'uint32');
    fwrite(fid2, Measurements(n).aulEvalInfoMask2,             'uint32');
    fwrite(fid2, Measurements(n).ushSamplesInScan,             'uint16');
    fwrite(fid2, Measurements(n).ushUsedChannels,              'uint16');
    fwrite(fid2, Measurements(n).sLoopCounter14,               'uint16');
    fwrite(fid2, Measurements(n).sCutOff,                      'uint32');
    fwrite(fid2, Measurements(n).ushKSpaceCenterColumn,        'uint16');
    fwrite(fid2, Measurements(n).ushCoilSelect,                'uint16');
    fwrite(fid2, Measurements(n).fReadOutOffCentre,            'float');
    fwrite(fid2, Measurements(n).ulTimeSinceLastRF,            'uint32');
    fwrite(fid2, Measurements(n).ushKSpaceCentreLineNo,        'uint16');
    fwrite(fid2, Measurements(n).ushKSpaceCentrePartitionNo,   'uint16');
    fwrite(fid2, Measurements(n).sSD,                          'float');        
    fwrite(fid2, Measurements(n).aushIceProgramPara4,          'uint16');
    fwrite(fid2, Measurements(n).aushReservedPara,             'uint16');
    fwrite(fid2, Measurements(n).ushApplicationCounter,        'uint16');
    fwrite(fid2, Measurements(n).ushApplicationMask,           'uint16');
    fwrite(fid2, Measurements(n).ulCRC,                        'uint32');
    cPos=cPos+192;
    fseek(fid2,cPos,'bof');
  % Channel header
  channel_int=1;
   if (n<length(Measurements))%-Measurements(n).ushUsedChannels)
     while  channel_int<Measurements(1).ushUsedChannels+1
     fwrite(fid2, Measurements(n).ulType,                       'ubit8');  
     fwrite(fid2, Measurements(n).ulChannelLength,             'ubit24'); 
     fwrite(fid2, Measurements(n).ushChannelMeasUID,           'uint32');
     fwrite(fid2, Measurements(n).ulScanCounter,               'uint32');
     fwrite(fid2, Measurements(n).ulReserved1Channel,          'uint32');
     fwrite(fid2, Measurements(n).ulSequenceTime,              'uint32');
     fwrite(fid2, Measurements(n).ulUnused2,                   'uint32');             
     fwrite(fid2, Measurements(n).ushChannelId_actual,         'uint16');
     fwrite(fid2, Measurements(n).ushChannelId_actual2,        'uint16');
     fwrite(fid2, Measurements(n).ulUnused3,                   'uint16');
     fwrite(fid2, Measurements(n).ulCRC,                       'uint32');           
     cPos=cPos+32;
     fseek(fid2,cPos,'bof');   
     fwrite(fid2, Measurements(n).Data,                         'float32'); 
     channel_int=channel_int+1;
    
    
     cPos=cPos+8*Measurements(n).ushSamplesInScan;
     fseek(fid2,cPos,'bof'); 
     n=n+1;
     end
   else
       n=n+1;
   end
   CompletedBytes = CompletedBytes +szScanHeader+(szChannelHeader+ 8*Measurements(1).ushSamplesInScan)*Measurements(1).ushUsedChannels;
   waitbar(double(cPos)/double(fileSize),h_wait2);
   percentFinished = floor(double(CompletedBytes)/double(fileSize)*100);
                elapsed_time  = toc;
                time_left     = (100-((double(CompletedBytes)/double(fileSize))*100)) * (elapsed_time/((double(CompletedBytes)/double(fileSize))*100));

  progress_str = sprintf('\n %3.0f %% parsed in %4.0f s; estimated time left: %4.0f s \n',...
                percentFinished,elapsed_time, time_left);
            prevLength = numel(progress_str);
%  fprintf([repmat('\b',1,prevLength) '%s'],progress_str);
end
    
else
HeaderSize = fread(fid2,1,'int32');
Status = fseek(fid2, HeaderSize, 'bof');
CompletedBytes = HeaderSize;
cPos=HeaderSize;
 if strcmp(Grappa,'GRAPPA')
  for n = 1:length(NoiseScan)
    fwrite(fid2, NoiseScan(n).ulFlagsAndDMALength,          'uint32');
    fwrite(fid2, NoiseScan(n).lMeasUID,                     'int32');
    fwrite(fid2, NoiseScan(n).ulScanCounter,                'uint32');
    fwrite(fid2, NoiseScan(n).ulTimeStamp,                  'uint32');
    fwrite(fid2, NoiseScan(n).ulPMUTimeStamp,               'uint32');
    fwrite(fid2, NoiseScan(n).aulEvalInfoMask2,             'uint32');
    fwrite(fid2, NoiseScan(n).ushSamplesInScan,             'uint16');
    fwrite(fid2, NoiseScan(n).ushUsedChannels,              'uint16');
    fwrite(fid2, NoiseScan(n).sLoopCounter14,               'uint16');
    fwrite(fid2, NoiseScan(n).sCutOff,                      'int16');
    fwrite(fid2, NoiseScan(n).ushKSpaceCentreColumn,        'uint16');
    fwrite(fid2, NoiseScan(n).ushCoilSelect,                'uint16');
    fwrite(fid2, NoiseScan(n).fReadOutOffcentre,            'float32');
    fwrite(fid2, NoiseScan(n).ulTimeSinceLastRF,            'uint32');
    fwrite(fid2, NoiseScan(n).ushKSpaceCentreLineNo,        'uint16');
    fwrite(fid2, NoiseScan(n).ushKSpaceCentrePartitionNo,   'uint16');
    fwrite(fid2, NoiseScan(n).aushIceProgramPara4,          'uint16');
    fwrite(fid2, NoiseScan(n).aushFreePara4,                'uint16');
    fwrite(fid2, NoiseScan(n).sSliceData14,                 'int16');
    fwrite(fid2, NoiseScan(n).ushChannelId,                 'uint16');
    fwrite(fid2, NoiseScan(n).ushPTABPosNeg,                'uint16');
    fwrite(fid2, NoiseScan(n).Data,                         'float32');
    
    CompletedBytes = CompletedBytes + 128 + 8*NoiseScan(n).ushSamplesInScan;
        waitbar(CompletedBytes/fileSize,h_wait2);
    end
 end
    for n = 1:length(Measurements)
    fwrite(fid2, Measurements(n).ulFlagsAndDMALength,          'uint32');
    fwrite(fid2, Measurements(n).lMeasUID,                     'int32');
    fwrite(fid2, Measurements(n).ulScanCounter,                'uint32');
    fwrite(fid2, Measurements(n).ulTimeStamp,                  'uint32');
    fwrite(fid2, Measurements(n).ulPMUTimeStamp,               'uint32');
    fwrite(fid2, Measurements(n).aulEvalInfoMask2,             'uint32');
    fwrite(fid2, Measurements(n).ushSamplesInScan,             'uint16');
    fwrite(fid2, Measurements(n).ushUsedChannels,              'uint16');
    fwrite(fid2, Measurements(n).sLoopCounter14,               'uint16');
    fwrite(fid2, Measurements(n).sCutOff,                      'int16');
    fwrite(fid2, Measurements(n).ushKSpaceCentreColumn,        'uint16');
    fwrite(fid2, Measurements(n).ushCoilSelect,                'uint16');
    fwrite(fid2, Measurements(n).fReadOutOffcentre,            'float32');
    fwrite(fid2, Measurements(n).ulTimeSinceLastRF,            'uint32');
    fwrite(fid2, Measurements(n).ushKSpaceCentreLineNo,        'uint16');
    fwrite(fid2, Measurements(n).ushKSpaceCentrePartitionNo,   'uint16');
    fwrite(fid2, Measurements(n).aushIceProgramPara4,          'uint16');
    fwrite(fid2, Measurements(n).aushFreePara4,                'uint16');
    fwrite(fid2, Measurements(n).sSliceData14,                 'int16');
    fwrite(fid2, Measurements(n).ushChannelId,                 'uint16');
    fwrite(fid2, Measurements(n).ushPTABPosNeg,                'uint16');
    fwrite(fid2, Measurements(n).Data,                         'float32');
    CompletedBytes = CompletedBytes + 128 + 8*Measurements(n).ushSamplesInScan;
        waitbar(CompletedBytes/fileSize,h_wait2);
    end
end
%% Close file
fclose(fid2);
%% Close waitbar
close(h_wait2);
end
