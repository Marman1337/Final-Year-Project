function varargout = vs_Settings_Praat(varargin)
% VS_SETTINGS_PRAAT M-file for vs_Settings_Praat.fig
%      VS_SETTINGS_PRAAT, by itself, creates a new VS_SETTINGS_PRAAT or raises the existing
%      singleton*.
%
%      H = VS_SETTINGS_PRAAT returns the handle to a new VS_SETTINGS_PRAAT or the handle to
%      the existing singleton*.
%
%      VS_SETTINGS_PRAAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_SETTINGS_PRAAT.M with the given input arguments.
%
%      VS_SETTINGS_PRAAT('Property','Value',...) creates a new VS_SETTINGS_PRAAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_Settings_Praat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_Settings_Praat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_Settings_Praat

% Last Modified by GUIDE v2.5 08-Mar-2011 23:30:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_Settings_Praat_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_Settings_Praat_OutputFcn, ...
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


% --- Executes just before vs_Settings_Praat is made visible.
function vs_Settings_Praat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_Settings_Praat (see VARARGIN)

% Choose default command line output for vs_Settings_Praat
handles.output = hObject;

Setfig = vs_Settings;
Sethandle = guidata(Setfig);
handles.Setfig = Setfig;
handles.Sethandle = Sethandle;
handles.VSHandle = Sethandle.VSHandle;

setGUIVariables(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vs_Settings_Praat wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% align the variables with those in VS.vars
function setGUIVariables(handles)
VSData = guidata(handles.VSHandle);
vars = VSData.vars;

set(handles.edit_max_F0, 'String', num2str(vars.F0Praatmax));
set(handles.edit_min_F0, 'String', num2str(vars.F0Praatmin));

set(handles.edit_voice_threshold, 'String', num2str(vars.F0PraatVoiceThreshold));
set(handles.edit_silence_threshold, 'String', num2str(vars.F0PraatSilenceThreshold));
set(handles.edit_octave_cost, 'String', num2str(vars.F0PraatOctaveCost));
set(handles.edit_oct_j_cost, 'String', num2str(vars.F0PraatOctiveJumpCost));
set(handles.edit_voiced_unvoiced_cost, 'String', num2str(vars.F0PraatVoicedUnvoicedCost));
set(handles.edit_smoothing_bandwidth, 'String', num2str(vars.F0PraatSmoothingBandwidth));

set(handles.checkbox_kill_octave_jumps, 'Value', vars.F0PraatKillOctaveJumps);
set(handles.checkbox_smooth, 'Value', vars.F0PraatSmooth);
set(handles.checkbox_interpolate, 'Value', vars.F0PraatInterpolate);


% --- Outputs from this function are returned to the command line.
function varargout = vs_Settings_Praat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_min_F0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min_F0 as text
%        str2double(get(hObject,'String')) returns contents of edit_min_F0 as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0Praatmin = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0Praatmin));
end



% --- Executes during object creation, after setting all properties.
function edit_min_F0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_max_F0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_max_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_max_F0 as text
%        str2double(get(hObject,'String')) returns contents of edit_max_F0 as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0Praatmax = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0Praatmax));
end
    



% --- Executes during object creation, after setting all properties.
function edit_max_F0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_max_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_voice_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_voice_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_voice_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_voice_threshold as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0PraatVoiceThreshold = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0PraatVoiceThreshold));
end


% --- Executes during object creation, after setting all properties.
function edit_voice_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_voice_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_oct_j_cost_Callback(hObject, eventdata, handles)
% hObject    handle to edit_oct_j_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_oct_j_cost as text
%        str2double(get(hObject,'String')) returns contents of edit_oct_j_cost as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0PraatOctiveJumpCost = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0PraatOctiveJumpCost));
end


% --- Executes during object creation, after setting all properties.
function edit_oct_j_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_oct_j_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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


% --- Executes on button press in checkbox_kill_octave_jumps.
function checkbox_kill_octave_jumps_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_kill_octave_jumps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_kill_octave_jumps
VSData = guidata(handles.VSHandle);
VSData.vars.F0PraatKillOctaveJumps = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes on button press in checkbox_smooth.
function checkbox_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_smooth
VSData = guidata(handles.VSHandle);
VSData.vars.F0PraatSmooth = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes on button press in checkbox_interpolate.
function checkbox_interpolate_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_interpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_interpolate
VSData = guidata(handles.VSHandle);
VSData.vars.F0PraatInterpolate = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);



function edit_silence_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_silence_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_silence_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_silence_threshold as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0PraatSilenceThreshold = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0PraatSilenceThreshold));
end


% --- Executes during object creation, after setting all properties.
function edit_silence_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_silence_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_octave_cost_Callback(hObject, eventdata, handles)
% hObject    handle to edit_octave_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_octave_cost as text
%        str2double(get(hObject,'String')) returns contents of edit_octave_cost as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0PraatOctaveCost = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0PraatOctaveCost));
end


% --- Executes during object creation, after setting all properties.
function edit_octave_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_octave_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_voiced_unvoiced_cost_Callback(hObject, eventdata, handles)
% hObject    handle to edit_voiced_unvoiced_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_voiced_unvoiced_cost as text
%        str2double(get(hObject,'String')) returns contents of edit_voiced_unvoiced_cost as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0PraatVoicedUnvoicedCost = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0PraatVoicedUnvoicedCost));
end


% --- Executes during object creation, after setting all properties.
function edit_voiced_unvoiced_cost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_voiced_unvoiced_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_smoothing_bandwidth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_smoothing_bandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_smoothing_bandwidth as text
%        str2double(get(hObject,'String')) returns contents of edit_smoothing_bandwidth as a double
VSData = guidata(handles.VSHandle);
val = str2double(get(hObject, 'String'));

if (~isnan(val) && val >= 0)
    VSData.vars.F0PraatSmoothingBandwidth = val;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(val));
else
    set(hObject, 'String', num2str(VSData.vars.F0PraatSmoothingBandwidth));
end


% --- Executes during object creation, after setting all properties.
function edit_smoothing_bandwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smoothing_bandwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
