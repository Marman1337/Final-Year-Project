function varargout = VoiceSauce(varargin)
% VOICESAUCE M-file for VoiceSauce.fig
%      VOICESAUCE, by itself, creates a new VOICESAUCE or raises the existing
%      singleton*.
%
%      H = VOICESAUCE returns the handle to a new VOICESAUCE or the handle to
%      the existing singleton*.
%
%      VOICESAUCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOICESAUCE.M with the given input arguments.
%
%      VOICESAUCE('Property','Value',...) creates a new VOICESAUCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VoiceSauce_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VoiceSauce_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VoiceSauce

% Last Modified by GUIDE v2.5 10-Nov-2009 15:23:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VoiceSauce_OpeningFcn, ...
                   'gui_OutputFcn',  @VoiceSauce_OutputFcn, ...
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


% --- Executes just before VoiceSauce is made visible.
function VoiceSauce_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VoiceSauce (see VARARGIN)

% Choose default command line output for VoiceSauce
handles.output = hObject;

% YS: add initialization variables here
if (~isfield(handles, 'vars'))
    vars = vs_Initialize();
    handles.vars = vars;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VoiceSauce wait for user response (see UIRESUME)
% uiwait(handles.figure_VoiceSauce);


% --- Outputs from this function are returned to the command line.
function varargout = VoiceSauce_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_ParameterEstimation.
function button_ParameterEstimation_Callback(hObject, eventdata, handles)
% hObject    handle to button_ParameterEstimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vs_ParameterEstimation();



% --- Executes on button press in pushbutton_OutputtoText.
function pushbutton_OutputtoText_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OutputtoText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vs_OutputToText();

% --- Executes on button press in pushbutton_OutputtoEMU.
function pushbutton_OutputtoEMU_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OutputtoEMU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton_OutputtoEMU
vs_OutputToEMU();

% --- Executes on button press in pushbutton_ParameterDisplay.
function pushbutton_ParameterDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ParameterDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton_ParameterDisplay
vs_ParameterDisplay();

% --- Executes on button press in pushbutton_Settings.
function pushbutton_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vs_Settings();

% --- Executes on button press in pushbutton_Exit.
function pushbutton_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(get(0, 'Children'));

% --- Executes on button press in pushbutton_ManualData.
function pushbutton_ManualData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ManualData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vs_ManualData();

% --- Executes on button press in pushbutton_About.
function pushbutton_About_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vs_About();


% --- Executes when user attempts to close figure_VoiceSauce.
function figure_VoiceSauce_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_VoiceSauce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(get(0, 'Children'));


