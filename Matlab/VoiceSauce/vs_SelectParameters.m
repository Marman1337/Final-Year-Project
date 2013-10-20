function varargout = vs_SelectParameters(varargin)
% VS_SELECTPARAMETERS M-file for vs_SelectParameters.fig
%      VS_SELECTPARAMETERS, by itself, creates a new VS_SELECTPARAMETERS or raises the existing
%      singleton*.
%
%      H = VS_SELECTPARAMETERS returns the handle to a new VS_SELECTPARAMETERS or the handle to
%      the existing singleton*.
%
%      VS_SELECTPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_SELECTPARAMETERS.M with the given input arguments.
%
%      VS_SELECTPARAMETERS('Property','Value',...) creates a new VS_SELECTPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_SelectParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_SelectParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_SelectParameters

% Last Modified by GUIDE v2.5 16-Oct-2009 14:30:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_SelectParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_SelectParameters_OutputFcn, ...
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


% --- Executes just before vs_SelectParameters is made visible.
function vs_SelectParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_SelectParameters (see VARARGIN)

% Choose default command line output for vs_SelectParameters
handles.output = hObject;

PEfig = vs_ParameterEstimation; 
PEhandle = guidata(PEfig);
handles.PEfig = PEfig; 
handles.PEhandle = PEhandle;
handles.VSHandle = PEhandle.VSHandle;

% get the list of parameters:
paramlist = func_getparameterlist();
paraminx = 1:length(paramlist);

% check to see if "Other" F0/FMT have been enabled
VSData = guidata(handles.VSHandle);
if (VSData.vars.F0OtherEnable == 0)
    paraminx(func_getparameterlist('F0 (Other)')) = 0;
end

% check to see which formant algorithm to use
if (VSData.vars.FormantsOtherEnable == 0)
    paraminx(func_getparameterlist('F1, F2, F3, F4 (Other)')) = 0;
end

paraminx(paraminx == 0) = [];
paramlist = paramlist(paraminx);

set(handles.listbox_paramlist, 'String', paramlist);

selectedparamlist = VSData.vars.PE_params;

% work out which ones to select
paraminx = zeros(length(paramlist), 1);
cnt = 1;
for k=1:length(paramlist)
    for n=1:length(selectedparamlist)
        if (strcmp(paramlist(k), selectedparamlist(n)))
            paraminx(cnt) = k;
            cnt = cnt + 1;
            break;
        end
    end
end
paraminx(paraminx==0) = [];
handles.paraminx = paraminx;

set(handles.listbox_paramlist, 'Value', handles.paraminx);

if (isempty(handles.paraminx))
    set(handles.PEhandle.edit_parameterselection, 'String', 'None');
elseif (length(handles.paraminx) == length(paramlist))
    set(handles.PEhandle.edit_parameterselection, 'String', 'All');
else
    set(handles.PEhandle.edit_parameterselection, 'String', 'Custom');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vs_SelectParameters wait for user response (see UIRESUME)
% uiwait(handles.figure_SelectParameters);


% --- Outputs from this function are returned to the command line.
function varargout = vs_SelectParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_paramlist.
function listbox_paramlist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
newinx = get(hObject, 'Value');
handles.paraminx = setxor(handles.paraminx, newinx);

paramlist = get(hObject, 'String');
VSData.vars.PE_params = paramlist(handles.paraminx);

set(handles.listbox_paramlist, 'Value', handles.paraminx);

guidata(hObject, handles);
guidata(handles.VSHandle, VSData);

if (isempty(handles.paraminx))
    set(handles.PEhandle.edit_parameterselection, 'String', 'None');
elseif (length(handles.paraminx) == length(paramlist))
    set(handles.PEhandle.edit_parameterselection, 'String', 'All');
else
    set(handles.PEhandle.edit_parameterselection, 'String', 'Custom');
end



% --- Executes during object creation, after setting all properties.
function listbox_paramlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(gcf);
