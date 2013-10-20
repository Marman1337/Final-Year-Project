function varargout = vs_ShowWaveform(varargin)
% VS_SHOWWAVEFORM M-file for vs_ShowWaveform.fig
%      VS_SHOWWAVEFORM, by itself, creates a new VS_SHOWWAVEFORM or raises the existing
%      singleton*.
%
%      H = VS_SHOWWAVEFORM returns the handle to a new VS_SHOWWAVEFORM or the handle to
%      the existing singleton*.
%
%      VS_SHOWWAVEFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_SHOWWAVEFORM.M with the given input arguments.
%
%      VS_SHOWWAVEFORM('Property','Value',...) creates a new VS_SHOWWAVEFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_ShowWaveform_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_ShowWaveform_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_ShowWaveform

% Last Modified by GUIDE v2.5 24-Jul-2009 14:54:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_ShowWaveform_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_ShowWaveform_OutputFcn, ...
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


% --- Executes just before vs_ShowWaveform is made visible.
function vs_ShowWaveform_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_ShowWaveform (see VARARGIN)

% Choose default command line output for vs_ShowWaveform
handles.output = hObject;

PEfig = vs_ParameterEstimation;
PEhandle = guidata(PEfig);
handles.PEfig = PEfig;
handles.PEhandle = PEhandle;

if (~isfield(PEhandle, 'SWfig'))
    VSData = guidata(PEhandle.VSHandle);
    VSData.vars.PE_showwaveform = 1;
    guidata(PEhandle.VSHandle, VSData);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vs_ShowWaveform wait for user response (see UIRESUME)
% uiwait(handles.figure_ShowWaveform);


% --- Outputs from this function are returned to the command line.
function varargout = vs_ShowWaveform_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure_ShowWaveform.
function figure_ShowWaveform_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_ShowWaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.PEhandle.checkbox_showwaveform, 'Value', 0);
PEData = guidata(handles.PEfig);
if (isfield(PEData, 'SWfig'))
    PEData = rmfield(PEData, 'SWfig');
    guidata(handles.PEfig, PEData);
    VSData = guidata(PEData.VSHandle);
    VSData.vars.PE_showwaveform = 0;
    guidata(PEData.VSHandle, VSData);
end

delete(hObject);


