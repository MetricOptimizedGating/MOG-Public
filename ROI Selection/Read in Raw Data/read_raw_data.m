%   [Measurements, Data] = read_raw_data(pathname, filename)
%   Read raw Siemens data header and returns the measurement data in a
%   structure.
%   Takes in raw VB and VD header structure including multiraid files
%   Additional structure defined as 'vd2' multiraid file structure with
%   blank measurements from Bristol still under investigation.
%   
%
%   Inputs:
%   pathname        - name of the path where the target dat file is located,
%                   excluding the trailing slash
%   filename        - name of source meas.dat file, excluding the path
%
%   Outputs:
%   Measurements    - struct containing all measurements with full header
%                   information
%   Data            - struct containing echoes (that are already
%                   transformed and cropped in the FE direction), as well as the times for
%                   each measurement
% Siemens multi-raid data structure possibly include image scan, noise
% scan, phase correction scan, reference scan, phase correction scan for
% reference data, realtime feedback data, sync data and phase stabilization
% scan. Last scan in the .dat file is the image scan.
function [Measurements,Data,SiemensOS,IMAStart,NoiseScan] = read_raw_data(pathname, filename)
%% Open file
fid = fopen([pathname filesep filename], 'r','l','US-ASCII');
if (fid==-1),
    error(['Error reading ', filename,' in ', pathname,' directory']),
end
MaxCardiacPhase=0;
    fseek(fid,0,'eof');
    fileSize = ftell(fid);
    fseek(fid,0,'bof');
    hdsize  = fread(fid,1,'uint32');
    count = fread(fid,1,'uint32');
% lazy software version check (VB or VD?)
    if and(hdsize < 10000, count <= 64)
        SiemensOS = 'vd';
        % number of different scans in file stored in 2nd in
        NScans = count;
        measID = fread(fid,1,'uint32');
        fileID = fread(fid,1,'uint32');
        % measOffset: points to beginning of header, usually at 10240 bytes
        measOffset = fread(fid,1,'uint64');
        measLength = fread(fid,1,'uint64');
        fseek(fid,measOffset,'bof');
        hdrLength  = fread(fid,1,'uint32');
        cPos   = measOffset + hdrLength;
    else
        % in VB versions, the first 4 bytes indicate the beginning of the
        % raw data part of the file
        SiemensOS  = 'vb';
        cPos = hdsize;
        NScans   = 1; % VB does not support multiple scans in one file
    end
%% Advance over Header
cPos = uint32(cPos);
HeaderSize = cPos;
Status = fseek(fid, HeaderSize, 'bof');
%% Set up waitbar
    h_wait = waitbar(0,'Loading dat file...');
    tic;
    percentFinished = 0;
%% Initialize structure for index values
if (strcmp(SiemensOS, 'vd'))
 Measurements = struct('ulDMALength', {}, ...
    'ulPackBit', {}, ...
    'ulPCI_rx', {}, ...
    'ulMeasUID', {}, ...
    'ulScanCounter', {}, ...    
    'ulTimeStamp', {}, ...
    'ulPMUTimeStamp', {}, ...
    'ushSystemType', {}, ...
    'ulPTABPosDelay', {}, ...
    'lPTABPosX', {}, ...
    'lPTABPosY', {}, ...
    'lPTABPosZ', {}, ...
    'ulReserved1', {}, ...
    'aulEvalInfoMask2', {}, ...
    'ushSamplesInScan', {}, ...
    'ushUsedChannels', {}, ...
    'sLoopCounter14', {}, ...
    'sCutOff', {}, ...
    'ushKSpaceCenterColumn', {}, ...
    'ushCoilSelect', {}, ...
    'fReadOutOffCentre', {}, ...
    'ulTimeSinceLastRF', {}, ...
    'ushKSpaceCentreLineNo', {}, ...
    'ushKSpaceCentrePartitionNo', {}, ...
    'sSD', {}, ...
    'aushIceProgramPara4', {}, ...
    'aushReservedPara', {}, ...
    'ushApplicationCounter', {}, ...
    'ushApplicationMask', {}, ...
    'ulCRC', {}, ...
    'ushChannelId', {}, ...
    'ulType', {}, ...
    'ulChannelLength', {}, ...
    'ushChannelMeasUID', {}, ...
    'ulScanCounterChannel', {}, ...
    'ulReserved1Channel', {}, ...
    'ulSequenceTime', {}, ...
    'ulUnused2', {}, ...
    'ushChannelId_actual', {}, ... 
    'ushChannelId_actual2', {}, ...
    'ulUnused3', {}, ...
    'ulCRCChannel', {}, ...
    'Data', {});
else
    Measurements = struct('ulFlagsAndDMALength', {}, ...
     'lMeasUID', {}, ...
    'ulScanCounter', {}, ...
    'ulTimeStamp', {}, ...
    'ulPMUTimeStamp', {}, ...
    'aulEvalInfoMask2', {}, ...
    'ushSamplesInScan', {}, ...
    'ushUsedChannels', {}, ...
    'sLoopCounter14', {}, ...
    'sCutOff', {}, ...
    'ushKSpaceCentreColumn', {}, ...
    'ushCoilSelect', {}, ...
    'fReadOutOffcentre', {}, ...
    'ulTimeSinceLastRF', {}, ...
    'ushKSpaceCentreLineNo', {}, ...
    'ushKSpaceCentrePartitionNo', {}, ...
    'aushIceProgramPara4', {}, ...
    'aushFreePara4', {}, ...
    'sSliceData14', {}, ...
    'ushChannelId', {}, ...
    'ushPTABPosNeg', {}, ...
    'Data', {});
 NoiseScan = struct('ulFlagsAndDMALength', {}, ...
     'lMeasUID', {}, ...
    'ulScanCounter', {}, ...
    'ulTimeStamp', {}, ...
    'ulPMUTimeStamp', {}, ...
    'aulEvalInfoMask2', {}, ...
    'ushSamplesInScan', {}, ...
    'ushUsedChannels', {}, ...
    'sLoopCounter14', {}, ...
    'sCutOff', {}, ...
    'ushKSpaceCentreColumn', {}, ...
    'ushCoilSelect', {}, ...
    'fReadOutOffcentre', {}, ...
    'ulTimeSinceLastRF', {}, ...
    'ushKSpaceCentreLineNo', {}, ...
    'ushKSpaceCentrePartitionNo', {}, ...
    'aushIceProgramPara4', {}, ...
    'aushFreePara4', {}, ...
    'sSliceData14', {}, ...
    'ushChannelId', {}, ...
    'ushPTABPosNeg', {}, ...
    'Data', {});
end
Data = struct('KSpace', {}, 'Times', {});
if (strcmp(SiemensOS, 'vd'))
 % we need to differentiate between 'scan header' and 'channel header'
    % since these are used in VD versions:
    szScanHeader    = 192; % [bytes]
    szChannelHeader = 32;  % [bytes]
%% Proceed through file adding data to the structure in the appropriate spot.
n = 1; % measurement counter
s=1; % scan counter
prevLength=0;
nMeasExpected=1*10^6;
NoiseScan=0;
START_ACQ=0;
while cPos<fileSize && n<nMeasExpected% fail-safe; in case we miss MDH_ACQEND
    fseek(fid,cPos,'bof');
    Measurements(n).ulDMALength          = fread(fid,1,'ubit25');
    Measurements(n).ulPackBit            = fread(fid,1,'ubit1');
    Measurements(n).ulPCI_rx             =fread(fid,1,'ubit6');
    Measurements(n).ulMeasUID                    = fread(fid,1,'int32');
    Measurements(n).ulScanCounter                = fread(fid,1,'uint32');
    Measurements(n).ulTimeStamp                  = fread(fid,1,'uint32');
    Measurements(n).ulPMUTimeStamp               = fread(fid,1,'uint32');
    Measurements(n).ushSystemType                = fread(fid,1,'uint16');
    Measurements(n).ulPTABPosDelay               = fread(fid,1,'uint16');
    Measurements(n).ulPTABPosX                   = fread(fid,1,'int32');
    Measurements(n).ulPTABPosY                   = fread(fid,1,'int32');
    Measurements(n).ulPTABPosZ                   = fread(fid,1,'int32');
    Measurements(n).ulReserved1                  = fread(fid,1,'uint32');
    Measurements(n).aulEvalInfoMask2             = fread(fid,2,'uint32');
    Measurements(n).ushSamplesInScan             = fread(fid,1,'uint16');
    Measurements(n).ushUsedChannels              = fread(fid,1,'uint16');
    Measurements(n).sLoopCounter14               = fread(fid,14,'uint16');
    Measurements(n).sCutOff                      = fread(fid,1,'uint32');
    Measurements(n).ushKSpaceCenterColumn        = fread(fid,1,'uint16');
    Measurements(n).ushCoilSelect                = fread(fid,1,'uint16');
    Measurements(n).fReadOutOffCentre            = fread(fid,1,'float');
    Measurements(n).ulTimeSinceLastRF            = fread(fid,1,'uint32');
    Measurements(n).ushKSpaceCentreLineNo        = fread(fid,1,'uint16');
    Measurements(n).ushKSpaceCentrePartitionNo   = fread(fid,1,'uint16');
    Measurements(n).sSD                          = fread(fid,7,'float');       
    Measurements(n).aushIceProgramPara4          = fread(fid,24,'uint16');
    Measurements(n).aushReservedPara             = fread(fid,4, 'uint16');
    Measurements(n).ushApplicationCounter        = fread(fid,1,'uint16');
    Measurements(n).ushApplicationMask           = fread(fid,1,'uint16');
    Measurements(n).ulCRC                        = fread(fid,1,'uint32');  
    cPos=cPos+192;
    
    fseek(fid,cPos,'bof');   
    % inlining of evalInfoMask
    MDH_ACQEND             = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^0),1);
    MDH_RTFEEDBACK         = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^1),1);
    MDH_HPFEEDBACK         = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^2),1);
    MDH_SYNCDATA           = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^5), 1);
    MDH_RAWDATACORRECTION  = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^10),1);
    MDH_REFPHASESTABSCAN   = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^14),1);
    MDH_PHASESTABSCAN      = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^15),1);
    MDH_SIGNREV            = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^17),1);
    MDH_PHASCOR            = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^21),1);
    MDH_PATREFSCAN         = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^22),1);
    MDH_PATREFANDIMASCAN   = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^23),1);
    MDH_REFLECT            = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^24),1);
    MDH_NOISEADJSCAN       = min(bitand(Measurements(n).aulEvalInfoMask2(1), 2^25),1);
    MDH_VOP                = min(bitand(Measurements(n).aulEvalInfoMask2(2), 2^(53-32)),1);
    MDH_IMASCAN            = 1;
    
   
    if (MDH_ACQEND || MDH_RTFEEDBACK || MDH_HPFEEDBACK...
                        || MDH_PHASCOR    || MDH_NOISEADJSCAN...
                        || MDH_SYNCDATA||MDH_RAWDATACORRECTION)
        MDH_IMASCAN = 0; 
        if (MDH_NOISEADJSCAN)
        NoiseScan= NoiseScan+1;
        end
    end
    
    % otherwise the PATREFSCAN may be overwritten
    if MDH_PHASESTABSCAN || MDH_REFPHASESTABSCAN
        MDH_PATREFSCAN = 0;
        MDH_PATREFANDIMASCAN = 0;
        MDH_IMASCAN = 0; 
    end
    
    if(~START_ACQ)
    if ( MDH_PATREFSCAN && ~MDH_PATREFANDIMASCAN )
          MDH_IMASCAN = 0;
    end   
     end
   
    % Based on Philipp Eheses mapVBVD code. 
    % The pack bit indicates that multiple ADC are packed into one 
    % DMA, often in EPI scans (controlled by fRTSetReadoutPackaging in IDEA)
    % since this code assumes one adc (x NCha) per DMA, we have to correct 
    % the "DMA length"
%     if mdh.ulPackBit
    % it seems that the packbit is not always set correctly
     if ~MDH_SYNCDATA && ~MDH_ACQEND && Measurements(n).ulDMALength~=0
       Measurements(n).ulDMALength = szScanHeader + (2*4*Measurements(n).ushSamplesInScan + szChannelHeader) * Measurements(n).ushUsedChannels;
    end
    if (MDH_IMASCAN)
    if  ~MDH_SYNCDATA&&~MDH_ACQEND &&  Measurements(n).ulDMALength~=0
       START_ACQ=1;
        channel_int=1;
         %% Calculate step size in file where 128 is header size, 8 is from complex float
    AdvancedBytes = szScanHeader+(szChannelHeader+ 8*Measurements(n).ushSamplesInScan)*Measurements(n).ushUsedChannels;
         %% Initialize structure to speed up read-in
    if n == 1
        IMAStart=cPos-szScanHeader;
        nMeasExpected = floor((fileSize - IMAStart-512)/AdvancedBytes)*Measurements(n).ushUsedChannels;
        Measurements(nMeasExpected).Data = 0;
        InitialTime = Measurements(n).ulTimeStamp;
    end
  
        while  channel_int<Measurements(n).ushUsedChannels+1
        Measurements(n).ulType                      = fread(fid,1,'ubit8');
        Measurements(n).ulChannelLength             = fread(fid,1,'ubit24');
        Measurements(n).ushChannelMeasUID           = fread(fid,1,'uint32');
        Measurements(n).ulScanCounterChannel        = fread(fid,1,'uint32');
        Measurements(n).ulReserved1Channel          = fread(fid,1,'uint32');  
        Measurements(n).ulSequenceTime              = fread(fid,1,'uint32');
        Measurements(n).ulUnused2                   = fread(fid,1,'uint32');
        Measurements(n).ushChannelId_actual         = fread(fid,1,'uint16');
        Measurements(n).ushChannelId_actual2        = fread(fid,1,'uint16');
        Measurements(n).ulUnused3                   = fread(fid,1,'uint16');
        Measurements(n).ulCRC                       = fread(fid,1,'uint32');
        cPos=cPos+32;
        fseek(fid,cPos,'bof');
        Measurements(n).Data                        = fread(fid,2*Measurements(n).ushSamplesInScan,'*float32');
        cPos=cPos+2*Measurements(n).ushSamplesInScan*4;
        fseek(fid,cPos,'bof'); 
        n=n+1;
        channel_int=channel_int+1;
        if (n<nMeasExpected+1)
        Measurements(n)=Measurements(n-1);
        else
       % close(h_wait);
        position = ftell(fid);
        fclose(fid);       
        break;
        end
        end
        n=n-1;
    end
      if (n-Measurements(n).ushUsedChannels==0)
          % Store channel ids in matrix
          channel_ids = zeros(Measurements(n).ushUsedChannels,1);
          for k=1:Measurements(n).ushUsedChannels
          channel_ids(k,1)=Measurements(k).ushChannelId_actual; 
          end
     end
     cPos=cPos+ Measurements(n).ulDMALength-AdvancedBytes;           
    %% Compute data to be stored in Data structure
    % AC:  fftshift(ifft(iffshift())) is used b/c  ifft would fail for odd vectors  
    if (MDH_RAWDATACORRECTION &&MDH_IMASCAN)
    else
    for m=n-Measurements(n).ushUsedChannels+1:n
    FTEcho = fftshift(ifft(ifftshift(Measurements(m).Data(1:2:end)+ sqrt(-1)*Measurements(m).Data(2:2:end))));
    Line = Measurements(m).sLoopCounter14(1) + 1;               % +1 is becuse siemens data uses zero-initialized indices
    PhaseEncode = Measurements(m).sLoopCounter14(8) + 1;
    for k=1:Measurements(m).ushUsedChannels
    if(channel_ids(k,1)==Measurements(m).ushChannelId_actual)
        Coil =k;
        Measurements(m).ushChannelId=k-1;
        break;
    end
    end
    CardiacPhase = Measurements(m).sLoopCounter14(6) + 1;
    if (MaxCardiacPhase < CardiacPhase)
    MaxCardiacPhase=CardiacPhase;
    end
    % Store data in Data structure (cropping the echo in half)
    %% commented
    EchoLength = floor(Measurements(m).ushSamplesInScan/2);
    Data(Line, PhaseEncode).KSpace(:,Coil,CardiacPhase) = ...
        FTEcho((EchoLength-ceil(EchoLength/2)+1):(EchoLength+floor(EchoLength/2)));
    Data(Line, PhaseEncode).Times(CardiacPhase) = 2.5*(Measurements(m).ulTimeStamp - InitialTime); % 2.5 is due to siemens time stamp convention
    end
    n=n+1;
    end
            % jump to mdh of next scan
          
            elseif MDH_ACQEND || Measurements(n).ulDMALength==0
                if s<NScans 
                    cPos = cPos + Measurements(n).ulDMALength-szScanHeader;
                    % jump to next full 512 bytes
                    if mod(cPos,512)
                    cPos = cPos + 512 - mod(cPos,512);
                    end
                    fseek(fid,cPos,'bof');
                    hdrLength  = fread(fid,1,'uint32');
                    cPos = cPos + hdrLength;
                    s=s+1;
                else 
                 
                     %close(h_wait);
                    
                fclose(fid);
                
                    break;
                end
               
    elseif MDH_SYNCDATA
               % skip SYNCDATA
                cPos = cPos + Measurements(n).ulDMALength-192;      
                continue;
    else
          cPos = cPos +Measurements(n).ulDMALength-192;
    end
    if ((double(cPos)/double(fileSize))*100 > percentFinished + .1) &&(n<nMeasExpected)
                percentFinished = floor(double(cPos)/double(fileSize)*100);
              

                if ~exist('progress_str','var')
                    prevLength = 0;
                else
                    prevLength = numel(progress_str);
                end
                elapsed_time=toc;
                 time_left     = (100-((double(cPos)/double(fileSize))*100)) * (elapsed_time/((double(cPos)/double(fileSize))*100));
                progress_str = sprintf('%3.0f %% parsed in %4.0f s; estimated time left: %4.0f s \n',...
                percentFinished,elapsed_time, time_left);

                fprintf([repmat('\b',1,prevLength) '%s'],progress_str);
     waitbar(double(cPos)/double(fileSize),h_wait);
          
                
            
    end   
    
end
nMeasExpected=size(Measurements);
if(n~=nMeasExpected)
     Measurements(n+1:nMeasExpected(2))=[];
    end
elapsed_time = toc;
    progress_str = sprintf('100 %% parsed in %4.0f s; estimated time left:    0 s \n', elapsed_time);
    fprintf([repmat('\b',1,prevLength) '%s'],progress_str);
  close(h_wait);
else
    IMAStart=HeaderSize;
    CompletedBytes=HeaderSize;
    %% Proceed through file adding data to the structure in the appropriate spot.
n = 1;
m=1;
while(1)
    Measurements(n).ulFlagsAndDMALength          = fread(fid,1,'uint32');
    Measurements(n).lMeasUID                     = fread(fid,1,'int32');
    Measurements(n).ulScanCounter                = fread(fid,1,'uint32');
    Measurements(n).ulTimeStamp                  = fread(fid,1,'uint32');
    Measurements(n).ulPMUTimeStamp               = fread(fid,1,'uint32');
    Measurements(n).aulEvalInfoMask2             = fread(fid,2,'uint32');
    Measurements(n).ushSamplesInScan             = fread(fid,1,'uint16');
    Measurements(n).ushUsedChannels              = fread(fid,1,'uint16');
    Measurements(n).sLoopCounter14               = fread(fid,14,'uint16');
    Measurements(n).sCutOff                      = fread(fid,2,'int16');
    Measurements(n).ushKSpaceCentreColumn        = fread(fid,1,'uint16');
    Measurements(n).ushCoilSelect                = fread(fid,1,'uint16');
    Measurements(n).fReadOutOffcentre            = fread(fid,1,'float32');
    Measurements(n).ulTimeSinceLastRF            = fread(fid,1,'uint32');
    Measurements(n).ushKSpaceCentreLineNo        = fread(fid,1,'uint16');
    Measurements(n).ushKSpaceCentrePartitionNo   = fread(fid,1,'uint16');
    Measurements(n).aushIceProgramPara4          = fread(fid,4,'uint16');
    Measurements(n).aushFreePara4                = fread(fid,4,'uint16');
    Measurements(n).sSliceData14                 = fread(fid,14,'int16');
    Measurements(n).ushChannelId                 = fread(fid,1,'uint16');
    Measurements(n).ushPTABPosNeg                = fread(fid,1,'uint16');
    Measurements(n).Data                         = fread(fid,2*Measurements(n).ushSamplesInScan,'float32');
    %% Calculate step size in file where 128 is header size, 8 is from complex float
    AdvancedBytes = 128 + 8*Measurements(n).ushSamplesInScan;
    %% Initialize structure to speed up read-in
    if n == 1
        nMeasExpected = floor((fileSize - HeaderSize)/AdvancedBytes);
        Measurements(nMeasExpected).Data = 0;
        InitialTime = Measurements(n).ulTimeStamp;
    end
    %% Break infinite loop when the last measurement is read
    if(Measurements(n).aulEvalInfoMask2(1) == 1)
            close(h_wait);
                fclose(fid);
        break;
    end
     %% Compute data to be stored in Data structure
    % AC:  fftshift(ifft(iffshift())) is used b/c  ifft would fail for odd vectors 
  
   
    %% Advance waitbar
    CompletedBytes = CompletedBytes + AdvancedBytes;
         waitbar(double(CompletedBytes)/double(fileSize),h_wait);
    %% Advance index
    if (Measurements(n).aulEvalInfoMask2(1)==33554440 && Measurements(n).aulEvalInfoMask2(2)==0)
    NoiseScan(m)=Measurements(n);
    m=m+1;
    else
         FTEcho = fftshift(ifft(ifftshift(Measurements(n).Data(1:2:end)+ sqrt(-1)*Measurements(n).Data(2:2:end))));
    Line = Measurements(n).sLoopCounter14(1) + 1;               % +1 is becuse siemens data uses zero-initialized indices
    PhaseEncode = Measurements(n).sLoopCounter14(8) + 1;
 
    Coil = Measurements(n).ushChannelId + 1;
    CardiacPhase = Measurements(n).sLoopCounter14(6) + 1;
    if (MaxCardiacPhase < CardiacPhase)
    MaxCardiacPhase=CardiacPhase;
    end
    %% Store data in Data structure (cropping the echo in half)
    EchoLength = floor(Measurements(n).ushSamplesInScan/2);
    Data(Line, PhaseEncode).KSpace(:,Coil,CardiacPhase) = ...
    FTEcho((EchoLength-ceil(EchoLength/2)+1):(EchoLength+floor(EchoLength/2)));
    Data(Line, PhaseEncode).Times(CardiacPhase) = 2.5*(Measurements(n).ulTimeStamp - InitialTime); % 2.5 is due to siemens time stamp convention
    n = n + 1;
    end
end
nMeasExpected=length(Measurements);
if(n~=nMeasExpected)
     Measurements(n+1:nMeasExpected)=[];
end 
end
end   