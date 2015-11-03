function [Protocol_Info,Protocol] = read_protocol_info(pathname,filename,PatientFlag)
% %% Get File
% [filename,pathname,dummy]=uigetfile('*.dat','multiselect','on');
%%%% Open file
fid = fopen([pathname filesep filename], 'r');
if (fid==-1),
    error(['Error reading ', filename,' in ', pathname,' directory']),
end
%%% Read in each line of header text
nHeader_Lines=10000; % Arbitrary number of lines to read in past patient info, may change for different data types.
Header=cell(nHeader_Lines,1);
for loop=1:nHeader_Lines
    Header{loop,1} = fgetl(fid);
end
%%% Get the line number for each desired piece of information.
Patient_Info={'PatientName';
'ProtocolName'};
%%% Loop through and find the line number for each line of header info we
%%% are interested in.
Header_Info=cell(length(Patient_Info),3);
for pLoop=1:length(Patient_Info)
contents=strfind(Header,Patient_Info{pLoop});
Protocol_Index=5000;
for loop=1:length(contents)
    cellcontents=contents{loop};
    if ~isempty(cellcontents)&& cellcontents>length(Patient_Info{pLoop})
        Protocol_Index=loop;
    end
end
Header_Info{pLoop,1}=char(Header{Protocol_Index});
Header_Info{pLoop,2}=Protocol_Index;
Header_Info{pLoop,3}=Header(Protocol_Index+2);
end
Name=char(Header_Info{1,3});
Name(strfind(Name,'^'))=' ';
Protocol=char(Header_Info{2,3});
Protocol(strfind(Protocol,'_'))=' ';
Filename=filename(1:end-4);
Filename(strfind(Filename,'_'))=' ';
if strcmp(PatientFlag,'on')
Protocol_Info=[Name(10:end-2),', ',Protocol(10:end-2),', ',Filename];
else
Protocol_Info=[Protocol(10:end-2),', ',Filename];
end
fclose(fid);
% Protocol_Info{2}=Protocol(10:end-2);
% Protocol_Info{3}=Filename;
end
