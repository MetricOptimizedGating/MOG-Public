function varargout = display_refined_results(varargin)
% Displays patched images

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @display_results_OpeningFcn, ...
    'gui_OutputFcn',  @display_results_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before display_results is made visible.
function display_results_OpeningFcn(hObject, dummy, handles, varargin)
movegui('center')
handles.output = hObject;
handles.stop_now = 0;
Data_Properties=varargin{1};
Optimization=varargin{2};
RWaveTimes=Optimization.RWaveTimes;
handles.Images =  reconstruct_optimal_images(Data_Properties,RWaveTimes);
handles.FigureData=Metric_Landscape(Optimization);
handles.xDimensions=Data_Properties.xDimensions;
handles.yDimensions=Data_Properties.yDimensions;
handles.Protocol=Data_Properties.Protocol;
handles.OptimalRates=[Optimization.minhr1,Optimization.minhr2];
handles.patientType=Data_Properties.PatientType;
handles.DataType=Data_Properties.DataType;
handles.yesno='yes';
handles.resize=0;
% refine functions
[handles.Two_HR,handles.t]=RRIntervals_to_RR(diff(two_para_model(Data_Properties.ScanLength, [Optimization.minhr1, Optimization.minhr2])),extract_times(Data_Properties.Data));
handles.N_HR=RRIntervals_to_RR(diff(Optimization.RWaveTimes),extract_times(Data_Properties.Data));
% Update handles structure
guidata(hObject, handles);
% --- Outputs from this function are returned to the command line.
function varargout = display_results_OutputFcn(hObject, eventdata, handles)  %#ok<*STOUT>
Images=handles.Images;
        if strcmp(handles.DataType{1},'CINE')
h=imshow(Images(:,:,1),[min(min(min((Images(handles.yDimensions,handles.xDimensions,:))))),max(max(max((Images(handles.yDimensions,handles.xDimensions,:)))))],'Parent',handles.axes1);
        else
h=imshow(Images(:,:,1),[],'Parent',handles.axes1);
        end
        ax=gca;
if ( verLessThan('matlab','8.4') )
colormap gray;    
freezeColors %freeze this plot's colormap
else
colormap (ax,'gray');
end
axis 'image'
set(h,'hittest','off')
hFig = ancestor(hObject,'figure');
set(hFig,'name','Displaying Results');
guidata(hObject, handles);
title(handles.Protocol,'FontSize',14)
axis 'square'
axes(handles.axes2)
ax2=gca;
 % won't change any frozen plots
if ( verLessThan('matlab','8.4') )
    colormap jet;
else
    colormap (ax2,'jet');
end
if strcmp(handles.patientType,'Fetal')
% xlim([110 180]);
% ylim([110 180]);
image(110:180,110:180,flipud(handles.FigureData),'CDataMapping','scaled');
set(gca,'YDir','normal')
axis 'square'
elseif strcmp(handles.patientType,'Adult')
xlim([40 110]);
ylim([40 110]);
image(40:110,40:110,flipud(handles.FigureData),'CDataMapping','scaled');
set(gca,'YDir','normal')
axis 'square'
end
xlabel('Heart Rate 1','FontSize',12)
ylabel('Heart Rate 2','FontSize',12)
box('on');
hold('all');
if ( verLessThan('matlab','8.4') )
colorbar;
cbfreeze
freezeColors;
else
h_cbar=colorbar;    
end
% mark actual minimum
hold on;
plot(handles.axes2,handles.OptimalRates(1,1), handles.OptimalRates(1,2), 'w+');
hold off;

axes(handles.axes3);
plot(handles.axes3,handles.t,handles.Two_HR)
hold on
plot(handles.axes3,handles.t,handles.N_HR,'r')
hold off
axis([0 max(handles.t) 60 180])
xlabel('Time (s)')
ylabel('HR (bpm)')
legend('Two-Parameter Heart Rate Model','Multi-Parameter Heart Rate Model','location','NW')

while handles.stop_now~=1
    for loop=2:size(Images,3)
        set(h,'CData',Images(:,:,loop))
        if ( verLessThan('matlab','8.4') )
        colormap gray
        freezeColors %freeze this plot's colormap
        else
        colormap (hFig,'gray');       
        end
        pause(0.05)
        handles=guidata(hObject);            
        if strcmp(handles.DataType{1},'CINE')
            posx=handles.xDimensions(floor(length(handles.xDimensions)/2))-(length(handles.xDimensions)-1)/2;
            posy=handles.yDimensions(floor(length(handles.yDimensions)/2))-(length(handles.yDimensions)-1)/2;
            rectangle('Position',[posx,posy,length(handles.xDimensions),length(handles.yDimensions)],'edgecolor','y','Parent',handles.axes1)
        else
            posx=handles.xDimensions(floor(length(handles.xDimensions)/2))-(length(handles.xDimensions)-1)/2;
            posy=handles.yDimensions(floor(length(handles.yDimensions)/2))-(length(handles.yDimensions)-1)/2;
            rectangle('Position',[posx,posy,length(handles.xDimensions),length(handles.yDimensions)],'edgecolor','y','Parent',handles.axes1)
            rectangle('Position',[size(Images,2)*0.5+posx,posy,length(handles.xDimensions),length(handles.yDimensions)],'edgecolor','y','Parent',handles.axes1)
        end
        title(handles.axes1,handles.Protocol,'FontSize',14)
        guidata(hObject, handles);
        if handles.stop_now==1
            varargout{1}=handles.yesno;
            break;
        end
    end
end
close all

function pushbutton6_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
handles.stop_now = 1;
handles.yesno='yes';
guidata(hObject, handles);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
handles.stop_now = 1;
handles.yesno='no';
guidata(hObject, handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
handles.stop_now = 1;
handles.yesno='retry';
guidata(hObject, handles);


% --- Executes on button press in refineButton.
function refineButton_Callback(hObject, eventdata, handles)
handles.stop_now = 1;
handles.yesno='refine';
guidata(hObject, handles);

