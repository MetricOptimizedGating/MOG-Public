function varargout = Select_ROI_PC(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Select_ROI_PC_OpeningFcn, ...
    'gui_OutputFcn',  @Select_ROI_PC_OutputFcn, ...
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

% --- Executes just before Select_ROI_PC is made visible.
function Select_ROI_PC_OpeningFcn(hObject, dummy, handles, varargin) %#ok<INUSL>
handles.output = hObject;
handles.stop_now = 0;
handles.Images=varargin{1};
handles.Protocol=varargin{2};
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Select_ROI_PC_OutputFcn(hObject, eventdata, handles)  %#ok<*STOUT>
Images=handles.Images;
h=imshow(Images(:,:,1),[]);
title(handles.Protocol)
axis 'image'
set(h,'hittest','off')
hFig = ancestor(hObject,'figure');
set(hFig,'name','Please select a region of interest (ROI)');
hAxes = get(hFig,'currentAxes');
point=get(hAxes, 'currentpoint');
handles.last_point=[round(point(1,1)),round(point(1,2))];

guidata(hObject, handles);
while handles.stop_now~=1 && handles.stop_now~=2
    for iFrame=2:size(Images,3)
        set(h,'CData',Images(:,:,iFrame))
        pause(0.1)
        axes1_ButtonDownFcn(hObject, eventdata, handles);
        handles=guidata(hObject);
        
        if handles.point(1,1)<size(handles.Images,2)&...
                handles.point(1,2)<size(handles.Images,1)&...
                handles.point(1)>0&...
                handles.point(2)>0
            handles.current_point=[round(handles.point(1,1)),round(handles.point(1,2))];
        else
            handles.current_point=handles.last_point;
        end
        
        if handles.current_point~=handles.last_point
            h=imshow(Images(:,:,iFrame),[]);
            title(handles.Protocol)
            if handles.point(1,1)<size(Images,2)*0.5
                rectangle('Position',[handles.point(1,1)-5,handles.point(1,2)-5,11,11],'edgecolor','y')
                rectangle('Position',[size(Images,2)*0.5+handles.point(1,1)-5,+handles.point(1,2)-5,11,11],'edgecolor','y')
            else
                rectangle('Position',[handles.point(1,1)-5,handles.point(1,2)-5,11,11],'edgecolor','y')
                rectangle('Position',[-size(Images,2)*0.5+handles.point(1,1)-5,+handles.point(1,2)-5,11,11],'edgecolor','y')
            end
        end
        handles.last_point=handles.current_point;
        guidata(hObject, handles);
        if handles.stop_now==1
            if handles.point(1,1)<size(Images,2)*0.5
                coordinates=[round(handles.current_point(1,2)),round(handles.current_point(1,1))];
            else
                coordinates=[round(handles.current_point(1,2)),-size(Images,2)*0.5+round(handles.current_point(1,1))];
            end
            dimensions=[11,11];
            varargout{1}=round(coordinates(1,1)-dimensions(1,1)/2):round(coordinates(1,1)+dimensions(1,1)/2);
            varargout{2}=round(coordinates(1,2)-dimensions(1,2)/2):round(coordinates(1,2)+dimensions(1,2)/2);
            varargout{3}=0;
            break
        elseif handles.stop_now==2
            varargout{1}=[];
            varargout{2}=[];
            varargout{3}='skip';
            break
        end
    end
end
close all

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, ~, ~)
handles=guidata(hObject);
hFig = ancestor(hObject,'figure');
hAxes = get(hFig,'currentAxes');
handles.point=get(hAxes, 'currentpoint');
guidata(hObject, handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, ~, handles) %#ok<*DEFNU>
if handles.last_point(1,1)~=1 %% Prevents user from confirming ROI selection before clicking on image
    handles.stop_now = 1;
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, ~, handles)
handles.stop_now = 2;
guidata(hObject, handles);
