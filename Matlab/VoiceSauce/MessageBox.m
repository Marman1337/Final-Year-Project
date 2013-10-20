function varargout = MessageBox(varargin)
% MESSAGEBOX M-file for MessageBox.fig
%      MESSAGEBOX, by itself, creates a new MESSAGEBOX or raises the existing
%      singleton*.
%
%      H = MESSAGEBOX returns the handle to a new MESSAGEBOX or the handle to
%      the existing singleton*.
%
%      MESSAGEBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MESSAGEBOX.M with the given input arguments.
%
%      MESSAGEBOX('Property','Value',...) creates a new MESSAGEBOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MessageBox_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MessageBox_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MessageBox

% Last Modified by GUIDE v2.5 02-Aug-2009 22:55:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MessageBox_OpeningFcn, ...
                   'gui_OutputFcn',  @MessageBox_OutputFcn, ...
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


% --- Executes just before MessageBox is made visible.
function MessageBox_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MessageBox (see VARARGIN)

% Choose default command line output for MessageBox
handles.output = hObject;

set(handles.figure_MessageBox, 'UserData', 0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MessageBox wait for user response (see UIRESUME)
% uiwait(handles.figure_MessageBox);


% --- Outputs from this function are returned to the command line.
function varargout = MessageBox_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_messages.
function listbox_messages_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_messages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_messages


% --- Executes during object creation, after setting all properties.
function listbox_messages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_messages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.figure_MessageBox, 'UserData', 1);
set(handles.pushbutton_close, 'Enable', 'on');
set(hObject, 'Enable', 'off');


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);


% --- Executes when user attempts to close figure_MessageBox.
function figure_MessageBox_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_MessageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(handles.figure_MessageBox, 'UserData', 1);  % signal algorithm to stop
delete(hObject);
