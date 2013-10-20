function varargout = vs_Settings(varargin)
% VS_SETTINGS M-file for vs_Settings.fig
%      VS_SETTINGS, by itself, creates a new VS_SETTINGS or raises the existing
%      singleton*.
%
%      H = VS_SETTINGS returns the handle to a new VS_SETTINGS or the handle to
%      the existing singleton*.
%
%      VS_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_SETTINGS.M with the given input arguments.
%
%      VS_SETTINGS('Property','Value',...) creates a new VS_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_Settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_Settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_Settings

% Last Modified by GUIDE v2.5 09-Mar-2011 22:29:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_Settings_OutputFcn, ...
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


% --- Executes just before vs_Settings is made visible.
function vs_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_Settings (see VARARGIN)

% Choose default command line output for vs_Settings
handles.output = hObject;

% YS: get the settings from the main figure
if (~isfield(handles, 'VSHandle'))
    VSHandle = VoiceSauce;
    handles.VSHandle = VSHandle;
end

% restore the variables from initialization
setGUIVariables(handles);


% 
set(handles.uipanel_Formants,'SelectionChangeFcn',@formants_buttongroup_SelectionChangeFcn);
set(handles.uipanel_F0,'SelectionChangeFcn',@F0_buttongroup_SelectionChangeFcn);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vs_Settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vs_Settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% aligns the variables with those in VS.vars
function setGUIVariables(handles)
VSData = guidata(handles.VSHandle);
vars = VSData.vars;

%F0
switch(vars.F0algorithm)
    case {'F0 (Straight)'}
        set(handles.radiobutton_F0_Straight, 'Value', 1);
    case {'F0 (Snack)'}
        set(handles.radiobutton_F0_Snack, 'Value', 1);
    case {'F0 (Praat)'}
        set(handles.radiobutton_F0_Praat, 'Value', 1);
    case {'F0 (SHR)'}
        set(handles.radiobutton_F0_SHR, 'Value', 1);
    case {'F0 (Other)'}
        set(handles.radiobutton_F0_Other, 'Value', 1);
end

set(handles.edit_F0_Straight_maxF0, 'String', num2str(vars.maxstrF0));
set(handles.edit_F0_Straight_minF0, 'String', num2str(vars.minstrF0));
set(handles.edit_F0_Straight_maxduration, 'String', num2str(vars.maxstrdur));

set(handles.edit_F0_Snack_maxF0, 'String', num2str(vars.maxF0));
set(handles.edit_F0_Snack_minF0, 'String', num2str(vars.minF0));

set(handles.checkbox_F0_Other_Enable, 'Value', vars.F0OtherEnable);
set(handles.edit_F0_Other_Command, 'String', vars.F0OtherCommand);
set(handles.edit_F0_Other_Offset, 'String', num2str(vars.F0OtherOffset));
if (vars.F0OtherEnable == 1)
    set(handles.edit_F0_Other_Command, 'Enable', 'On');
    set(handles.edit_F0_Other_Offset, 'Enable', 'On');
    set(handles.radiobutton_F0_Other, 'Enable', 'On');
end


% Formants
switch(vars.FMTalgorithm)
    case {'F1, F2, F3, F4 (Snack)'}
        set(handles.radiobutton_Formants_Snack, 'Value', 1);
    case {'F1, F2, F3, F4 (Praat)'}
        set(handles.radiobutton_Formants_Praat, 'Value', 1);
    case {'F1, F2, F3, F4 (Other)'}
        set(handles.radiobutton_Formants_Other, 'Value', 1);
end

set(handles.edit_Formants_Snack_preemphasis, 'String', num2str(vars.preemphasis));
set(handles.checkbox_Formants_Other_Enable, 'Value', vars.FormantsOtherEnable);
set(handles.edit_Formants_Other_Command, 'String', vars.FormantsOtherCommand);
set(handles.edit_Formants_Other_Offset, 'String', num2str(vars.FormantsOtherOffset));

if (vars.FormantsOtherEnable)
    set(handles.edit_Formants_Other_Command, 'Enable', 'On');
    set(handles.edit_Formants_Other_Offset, 'Enable', 'On');
    set(handles.radiobutton_Formants_Other, 'Enable', 'On');
end

% SHR
set(handles.edit_SHR_max_F0, 'String', num2str(vars.SHRmax));
set(handles.edit_SHR_min_F0, 'String', num2str(vars.SHRmin));
set(handles.edit_SHR_threshold, 'String', num2str(vars.SHRThreshold));

% Common
set(handles.edit_Common_windowsize, 'String', num2str(vars.windowsize));
set(handles.edit_Common_frameshift, 'String', num2str(vars.frameshift));
set(handles.edit_Common_NaN, 'String', vars.NotANumber);
set(handles.checkbox_Common_linkmatdir, 'Value', vars.linkmatdir);
set(handles.checkbox_Common_linkwavdir, 'Value', vars.linkwavdir);
set(handles.checkbox_Common_recursedir, 'Value', vars.recursedir);
set(handles.edit_Common_Nperiods, 'String', num2str(vars.Nperiods));
set(handles.edit_Common_Nperiods_EC, 'String', num2str(vars.Nperiods_EC));

% Textgrid
set(handles.edit_Textgrid_ignorelist, 'String', vars.TextgridIgnoreList);
set(handles.edit_Textgrid_tiernumber, 'String', num2str(vars.TextgridTierNumber));

% EGG
set(handles.edit_EGGData_headers, 'String', vars.EGGheaders);
set(handles.edit_EGGData_timelabel, 'String' ,vars.EGGtimelabel);

% Outputs
set(handles.edit_Outputs_smoothwinsize, 'String', num2str(vars.O_smoothwinsize));

% Input (wav) files
set(handles.edit_Input_searchstring, 'String', vars.I_searchstring);


function edit_Common_windowsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Common_windowsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Common_windowsize as text
%        str2double(get(hObject,'String')) returns contents of edit_Common_windowsize as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isnan(num))
    set(hObject, 'String', num2str(vars.windowsize));
else    
    num = round(num);
    if (num > 0)
        VSData.vars.windowsize = num;
        set(hObject, 'String', num2str(num))
        guidata(handles.VSHandle, VSData);
    else
        set(hObject, 'String', num2str(num));
    end
end



% --- Executes during object creation, after setting all properties.
function edit_Common_windowsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Common_windowsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Common_frameshift_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Common_frameshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Common_frameshift as text
%        str2double(get(hObject,'String')) returns contents of edit_Common_frameshift as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isnan(num))
    set(hObject, 'String', num2str(vars.frameshift));
else
    num = round(num);
    if (num > 0)
        VSData.vars.frameshift = num(1);
        set(hObject, 'String', num2str(num))
        guidata(handles.VSHandle, VSData);
    else
        set(hObject, 'String', num2str(vars.frameshift));
    end
end


% --- Executes during object creation, after setting all properties.
function edit_Common_frameshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Common_frameshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Formants_Snack_preemphasis_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Formants_Snack_preemphasis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Formants_Snack_preemphasis as text
%        str2double(get(hObject,'String')) returns contents of edit_Formants_Snack_preemphasis as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.preemphasis));
else
    num = num(1);
    VSData.vars.preemphasis = num;
    set(hObject, 'String', num2str(num))
    guidata(handles.VSHandle, VSData);
end



% --- Executes during object creation, after setting all properties.
function edit_Formants_Snack_preemphasis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Formants_Snack_preemphasis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_F0_Straight_maxF0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Straight_maxF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Straight_maxF0 as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Straight_maxF0 as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.maxstrF0));
else
    num = num(1);
    VSData.vars.maxstrF0 = num;
    set(hObject, 'String', num2str(num))
    guidata(handles.VSHandle, VSData);
end


% --- Executes during object creation, after setting all properties.
function edit_F0_Straight_maxF0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Straight_maxF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_F0_Straight_minF0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Straight_minF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Straight_minF0 as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Straight_minF0 as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.minstrF0));
else
    num = num(1);
    VSData.vars.minstrF0 = num;
    set(hObject, 'String', num2str(num))
    guidata(handles.VSHandle, VSData);
end


% --- Executes during object creation, after setting all properties.
function edit_F0_Straight_minF0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Straight_minF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_F0_Straight.
function radiobutton_F0_Straight_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_F0_Straight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_F0_Straight


% --- Executes on button press in radiobutton_F0_Snack.
function radiobutton_F0_Snack_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_F0_Snack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_F0_Snack


% --- Executes on button press in radiobutton_F0_Other.
function radiobutton_F0_Other_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_F0_Other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_F0_Other



function edit_F0_Straight_maxduration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Straight_maxduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Straight_maxduration as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Straight_maxduration as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.maxstrdur));
else
    num = num(1);
    VSData.vars.maxstrdur = num;
    set(hObject, 'String', num2str(num))
    guidata(handles.VSHandle, VSData);
end


% --- Executes during object creation, after setting all properties.
function edit_F0_Straight_maxduration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Straight_maxduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_F0_Snack_maxF0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Snack_maxF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Snack_maxF0 as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Snack_maxF0 as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.maxF0));
else
    num = num(1);
    VSData.vars.maxF0 = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_F0_Snack_maxF0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Snack_maxF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_F0_Snack_minF0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Snack_minF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Snack_minF0 as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Snack_minF0 as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.minF0));
else
    num = num(1);
    VSData.vars.minF0 = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_F0_Snack_minF0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Snack_minF0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_F0_Other_Enable.
function checkbox_F0_Other_Enable_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_F0_Other_Enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);

if (get(hObject, 'Value') == 1)
    set(handles.edit_F0_Other_Command, 'Enable', 'on');
    set(handles.edit_F0_Other_Offset, 'Enable', 'on');
    set(handles.radiobutton_F0_Other, 'Enable', 'on');
    VSData.vars.F0OtherEnable = 1;
else
    set(handles.edit_F0_Other_Command, 'Enable', 'off');
    set(handles.edit_F0_Other_Offset, 'Enable', 'off');
    set(handles.radiobutton_F0_Other, 'Enable', 'off');
    VSData.vars.F0OtherEnable = 0;
    
    if (get(handles.radiobutton_F0_Other, 'Value') == 1) % switch back to Straight
        set(handles.radiobutton_F0_Straight, 'Value', 1);
        VSData.vars.F0algorithm = 'F0 (Straight)';
    end
end    

guidata(handles.VSHandle, VSData);
function edit_F0_Other_Command_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Other_Command (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Other_Command as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Other_Command as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
VSData.vars.F0OtherCommand = get(hObject, 'String');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_F0_Other_Command_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Other_Command (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_F0_Other_Offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_F0_Other_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_F0_Other_Offset as text
%        str2double(get(hObject,'String')) returns contents of edit_F0_Other_Offset as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.F0OtherOffset));
else
    num = num(1);
    VSData.vars.F0OtherOffset = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_F0_Other_Offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_F0_Other_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_Formants_Snack.
function radiobutton_Formants_Snack_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Formants_Snack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Formants_Snack


% --- Executes on button press in radiobutton_Formants_Other.
function radiobutton_Formants_Other_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Formants_Other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Formants_Other



function edit_Formants_Other_Offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Formants_Other_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Formants_Other_Offset as text
%        str2double(get(hObject,'String')) returns contents of edit_Formants_Other_Offset as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.FormantsOtherOffset));
else
    num = num(1);
    VSData.vars.FormantsOtherOffset = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_Formants_Other_Offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Formants_Other_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Formants_Other_Command_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Formants_Other_Command (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Formants_Other_Command as text
%        str2double(get(hObject,'String')) returns contents of edit_Formants_Other_Command as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
VSData.vars.FormantsOtherCommand = get(hObject, 'String');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Formants_Other_Command_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Formants_Other_Command (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_Formants_Other_Enable.
function checkbox_Formants_Other_Enable_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Formants_Other_Enable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);

if (get(hObject, 'Value') == 1)
    set(handles.edit_Formants_Other_Command, 'Enable', 'on');
    set(handles.edit_Formants_Other_Offset, 'Enable', 'on');
    set(handles.radiobutton_Formants_Other, 'Enable', 'on');
    VSData.vars.FormantsOtherEnable = 1;
else
    set(handles.edit_Formants_Other_Command, 'Enable', 'off');
    set(handles.edit_Formants_Other_Offset, 'Enable', 'off');
    set(handles.radiobutton_Formants_Other, 'Enable', 'off');
    VSData.vars.FormantsOtherEnable = 0;
    
    if (get(handles.radiobutton_Formants_Other, 'Value') == 1) % set back to Snack
        set(handles.radiobutton_Formants_Snack, 'Value', 1);
        VSData.vars.FMTalgorithm = 'F1, F2, F3, F4 (Snack)';
    end    
end    

guidata(handles.VSHandle, VSData);


function edit_Textgrid_ignorelist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Textgrid_ignorelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Textgrid_ignorelist as text
%        str2double(get(hObject,'String')) returns contents of edit_Textgrid_ignorelist as a double
VSData = guidata(handles.VSHandle);

if (isempty(get(hObject, 'String')))
    set(hObject, 'String', '"", " ", "SIL"');  % this is the default, edit box cannot be empty
end

VSData.vars.TextgridIgnoreList = get(hObject, 'String');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Textgrid_ignorelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Textgrid_ignorelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Textgrid_tiernumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Textgrid_tiernumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Textgrid_tiernumber as text
%        str2double(get(hObject,'String')) returns contents of edit_Textgrid_tiernumber as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2num(get(hObject, 'String'));
if (isempty(num))
    set(hObject, 'String', num2str(vars.TextgridTierNumber));
else
    VSData.vars.TextgridTierNumber = unique(num);
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(VSData.vars.TextgridTierNumber))
end


% --- Executes during object creation, after setting all properties.
function edit_Textgrid_tiernumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Textgrid_tiernumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% YS: executes on the press of a radio button in formants panel
function formants_buttongroup_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);
VSData = guidata(handles.VSHandle);

switch get(eventdata.NewValue, 'Tag')
    case 'radiobutton_Formants_Snack'
        VSData.vars.FMTalgorithm = 'F1, F2, F3, F4 (Snack)';
    case 'radiobutton_Formants_Praat'
        VSData.vars.FMTalgorithm = 'F1, F2, F3, F4 (Praat)';
    case 'radiobutton_Formants_Other'
        VSData.vars.FMTalgorithm = 'F1, F2, F3, F4 (Other)';        
    otherwise
end
guidata(handles.VSHandle, VSData);



% YS: executes on the press of a radio button in F0 panel
function F0_buttongroup_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);
VSData = guidata(handles.VSHandle);

switch get(eventdata.NewValue, 'Tag')
    case 'radiobutton_F0_Straight'
        VSData.vars.F0algorithm = 'F0 (Straight)';
    case 'radiobutton_F0_Snack'
        VSData.vars.F0algorithm = 'F0 (Snack)';
    case 'radiobutton_F0_Praat'
        VSData.vars.F0algorithm = 'F0 (Praat)';
    case 'radiobutton_F0_SHR'
        VSData.vars.F0algorithm = 'F0 (SHR)';
    case 'radiobutton_F0_Other'
        VSData.vars.F0algorithm = 'F0 (Other)';
    otherwise   
end
guidata(handles.VSHandle, VSData);



% --- Executes on button press in pushbutton_Exit.
function pushbutton_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(gcf);


% --------------------------------------------------------------------
function menu_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Settings_Load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Settings_Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
filename = uigetfile('*.mat', 'Select File to Load');

if (~ischar(filename))
    return;
end

matdata = load(filename);
VSData.vars = matdata.settings;

% set the machine specific variables
if (ispc)
    VSData.vars.dirdelimiter = '\';
else
    VSData.vars.dirdelimiter = '/';
end

if (exist(VSData.vars.wavdir, 'dir') ~= 7)
    VSData.vars.wavdir = ['.' vars.dirdelimiter];
end

if (exist(VSData.vars.matdir, 'dir') ~= 7)
    VSData.vars.matdir = ['.' vars.dirdelimiter];
end

guidata(handles.VSHandle, VSData);
setGUIVariables(handles);


% --------------------------------------------------------------------
function menu_Settings_Save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Settings_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
VSData.vars.PE_showwaveformst = 0;  % this is a special case
settings = VSData.vars;
[filename, pathname] = uiputfile('*.mat', 'Select File to Save');

if (~ischar(filename))
    return;
end

save([pathname filename], 'settings');

helpdlg('Save complete.', 'Save');



function edit_EGGData_headers_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EGGData_headers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EGGData_headers as text
%        str2double(get(hObject,'String')) returns contents of edit_EGGData_headers as a double
VSData = guidata(handles.VSHandle);

if (isempty(get(hObject, 'String')))
    set(hObject, 'String', VSData.vars.EGGheaders);  % this is the default, edit box cannot be empty
end

VSData.vars.EGGheaders = get(hObject, 'String');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_EGGData_headers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EGGData_headers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_EGGData_timelabel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EGGData_timelabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EGGData_timelabel as text
%        str2double(get(hObject,'String')) returns contents of edit_EGGData_timelabel as a double
VSData = guidata(handles.VSHandle);

if (isempty(get(hObject, 'String')))
    set(hObject, 'String', VSData.vars.EGGtimelabel);  % this is the default, edit box cannot be empty
end

VSData.vars.EGGtimelabel = get(hObject, 'String');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_EGGData_timelabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EGGData_timelabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Common_NaN_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Common_NaN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Common_NaN as text
%        str2double(get(hObject,'String')) returns contents of edit_Common_NaN as a double
VSData = guidata(handles.VSHandle);
VSData.vars.NotANumber = get(hObject, 'String');
guidata(handles.VSHandle, VSData);

% --- Executes during object creation, after setting all properties.
function edit_Common_NaN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Common_NaN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_Common_linkmatdir.
function checkbox_Common_linkmatdir_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Common_linkmatdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Common_linkmatdir
VSData = guidata(handles.VSHandle);
VSData.vars.linkmatdir = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes on button press in checkbox_Common_linkwavdir.
function checkbox_Common_linkwavdir_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Common_linkwavdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Common_linkwavdir
VSData = guidata(handles.VSHandle);
VSData.vars.linkwavdir = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes on button press in checkbox_Common_recursedir.
function checkbox_Common_recursedir_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Common_recursedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Common_recursedir
VSData = guidata(handles.VSHandle);
VSData.vars.recursedir = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);



function edit_Outputs_smoothwinsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Outputs_smoothwinsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
num = str2double(get(hObject, 'String'));

if (~isnan(num))
    num = round(num);
    if (num >= 0)  % 0 denotes no output smoothing
        set(hObject, 'String', num2str(num));
        VSData.vars.O_smoothwinsize = num;
        guidata(handles.VSHandle, VSData);
    else
        set(hObject, 'String', num2str(vars.O_smoothwinsize));
    end
else
    set(hObject, 'String', num2str(vars.O_smoothwinsize));
end



% --- Executes during object creation, after setting all properties.
function edit_Outputs_smoothwinsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Outputs_smoothwinsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Input_searchstring_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Input_searchstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
str = get(hObject, 'String');
if (isempty(str))
    set(hObject, 'String', VSData.vars.I_searchstring);
else
    VSData.vars.I_searchstring = str;
    guidata(handles.VSHandle, VSData);
end



% --- Executes during object creation, after setting all properties.
function edit_Input_searchstring_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Input_searchstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_Settings_Praat.
function pushbutton_Settings_Praat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Settings_Praat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vs_Settings_Praat();



function edit_SHR_min_F0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SHR_min_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SHR_min_F0 as text
%        str2double(get(hObject,'String')) returns contents of edit_SHR_min_F0 as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isempty(num) || num < 0)
    set(hObject, 'String', num2str(vars.SHRmin));
else
    VSData.vars.SHRmin = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_SHR_min_F0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_SHR_min_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_SHR_max_F0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SHR_max_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SHR_max_F0 as text
%        str2double(get(hObject,'String')) returns contents of edit_SHR_max_F0 as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isempty(num) || num < 0)
    set(hObject, 'String', num2str(vars.SHRmax));
else
    VSData.vars.SHRmax = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_SHR_max_F0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_SHR_max_F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_SHR_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SHR_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SHR_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_SHR_threshold as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isempty(num) || num < 0)
    set(hObject, 'String', num2str(vars.SHRThreshold));
else
    VSData.vars.SHRThreshold = num;
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(num))
end


% --- Executes during object creation, after setting all properties.
function edit_SHR_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_SHR_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Common_Nperiods_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Common_Nperiods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Common_Nperiods as text
%        str2double(get(hObject,'String')) returns contents of edit_Common_Nperiods as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isempty(num) || round(num) < 0)
    set(hObject, 'String', num2str(vars.Nperiods));
else
    VSData.vars.Nperiods = round(num);
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(round(num)))
end


% --- Executes during object creation, after setting all properties.
function edit_Common_Nperiods_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Common_Nperiods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Common_Nperiods_EC_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Common_Nperiods_EC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Common_Nperiods_EC as text
%        str2double(get(hObject,'String')) returns contents of edit_Common_Nperiods_EC as a double
VSData = guidata(handles.VSHandle);
vars = VSData.vars;
num = str2double(get(hObject, 'String'));
if (isempty(num) || round(num) < 0)
    set(hObject, 'String', num2str(vars.Nperiods_EC));
else
    VSData.vars.Nperiods_EC = round(num);
    guidata(handles.VSHandle, VSData);
    set(hObject, 'String', num2str(round(num)))
end


% --- Executes during object creation, after setting all properties.
function edit_Common_Nperiods_EC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Common_Nperiods_EC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
