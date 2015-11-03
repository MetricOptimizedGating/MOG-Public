function varargout = Select_ROI_CINE(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Select_ROI_CINE_OpeningFcn, ...
    'gui_OutputFcn',  @Select_ROI_CINE_OutputFcn, ...
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

% --- Executes just before Select_ROI_CINE is made visible.
function Select_ROI_CINE_OpeningFcn(hObject, dummy, handles, varargin) %#ok<INUSL>
movegui('center')
handles.output = hObject;
handles.stop_now = 0;
handles.Images=varargin{1};
handles.Protocol=varargin{2};
handles.ROI_Width=0;
handles.ROI_Height=0;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Select_ROI_CINE_OutputFcn(hObject, eventdata, handles)  %#ok<*STOUT>
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
handles.last_width=handles.ROI_Width;
handles.last_height=handles.ROI_Height;

guidata(hObject, handles);
while handles.stop_now~=1 && handles.stop_now~=2
    for iFrame=2:size(Images,3)
        set(h,'CData',Images(:,:,iFrame))
        pause(0.05)
        axes1_ButtonDownFcn(hObject, eventdata, handles);
        handles=guidata(hObject);
        
        if handles.point(1,1)<size(handles.Images,2)&&...
                handles.point(1,2)<size(handles.Images,1)&&...
                handles.point(1)>0&&...
                handles.point(2)>0
            handles.current_point=[round(handles.point(1,1)),round(handles.point(1,2))];
        else
            handles.current_point=handles.last_point;
        end
        handles.current_width=handles.ROI_Width;
        handles.current_length=handles.ROI_Height;
        
        if       handles.current_point~=handles.last_point |...
                handles.current_width~=handles.last_width |...
                handles.current_length~=handles.last_height %#ok<*OR2>
            h=imshow(Images(:,:,iFrame),[]);
            title(handles.Protocol)
            
            
            width=11+round(handles.ROI_Width*2);
            height=11+round(handles.ROI_Height*2);
            
            posx=(width-1)/2;
            posy=(height-1)/2;
            
            rectangle('Position',[handles.current_point(1,1)-posx,handles.current_point(1,2)-posy,width,height],'edgecolor','y')
            
        end
        
        handles.last_point=handles.current_point;
        handles.last_width=handles.current_width;
        handles.last_height=handles.current_length;
        guidata(hObject, handles);
        if handles.stop_now==1
            coordinates=[round(handles.current_point(1,2)),round(handles.current_point(1,1))];
            dimensions=[11+round(handles.ROI_Height*2),11+round(handles.ROI_Width*2)];
            varargout{1}=round(coordinates(1,1)-dimensions(1,1)/2):round(coordinates(1,1)+dimensions(1,1)/2);
            varargout{2}=round(coordinates(1,2)-dimensions(1,2)/2):round(coordinates(1,2)+dimensions(1,2)/2);
            varargout{3}=0;
            break
        elseif handles.stop_now==2
            varargout{1}=[];%default output
            varargout{2}=[];%default output
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
function pushbutton5_Callback(hObject, ~, handles)
if handles.last_point(1,1)~=1 %% Prevents user from confirming ROI selection before clicking on image
    handles.stop_now = 1;
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, ~, handles) %#ok<*DEFNU>
handles.stop_now = 2;
guidata(hObject, handles);

% --- Executes on slider movement.
function slider1_Callback(hObject, ~, handles)
set(handles.slider1,'min',0,'max',round(size(handles.Images,2)/4),'SliderStep',[1/round(size(handles.Images,2)/4), 1/round(size(handles.Images,2)/4)]);
handles.ROI_Width=(round(get(handles.slider1,'Value')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function slider2_Callback(hObject, ~, handles)
set(handles.slider2,'min',0,'max',round(size(handles.Images,1)/4),'SliderStep',[1/round(size(handles.Images,1)/4), 1/round(size(handles.Images,1)/4)]);
handles.ROI_Height=(round(get(handles.slider2,'Value')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
