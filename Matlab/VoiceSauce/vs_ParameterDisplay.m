function varargout = vs_ParameterDisplay(varargin)
% VS_PARAMETERDISPLAY M-file for vs_ParameterDisplay.fig
%      VS_PARAMETERDISPLAY, by itself, creates a new VS_PARAMETERDISPLAY or raises the existing
%      singleton*.
%
%      H = VS_PARAMETERDISPLAY returns the handle to a new VS_PARAMETERDISPLAY or the handle to
%      the existing singleton*.
%
%      VS_PARAMETERDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_PARAMETERDISPLAY.M with the given input arguments.
%
%      VS_PARAMETERDISPLAY('Property','Value',...) creates a new VS_PARAMETERDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_ParameterDisplay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_ParameterDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_ParameterDisplay

% Last Modified by GUIDE v2.5 13-Oct-2009 22:52:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_ParameterDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_ParameterDisplay_OutputFcn, ...
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


% --- Executes just before vs_ParameterDisplay is made visible.
function vs_ParameterDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_ParameterDisplay (see VARARGIN)

% Choose default command line output for vs_ParameterDisplay
handles.output = hObject;

% YS: get the settings from the main figure
if (~isfield(handles, 'VSHandle'))
    VSHandle = VoiceSauce;  
    handles.VSHandle = VSHandle;
end

VSData = guidata(handles.VSHandle);
set(handles.edit_wavdir, 'String', VSData.vars.PD_wavdir);
set(handles.edit_matdir, 'String', VSData.vars.PD_matdir);

if (VSData.vars.recursedir)
    func_setlistbox(handles.listbox_wavfilelist, VSData.vars.PD_wavdir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
else
    func_setlistbox(handles.listbox_wavfilelist, VSData.vars.PD_wavdir, 'none', VSData.vars, VSData.vars.I_searchstring);
end

set(handles.listbox_wavfilelist, 'Value', 1);

% Update handles structure
guidata(hObject, handles);

checkParameters(handles);
plotData(handles);

% UIWAIT makes vs_ParameterDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure_ParameterDisplay);


% --- Outputs from this function are returned to the command line.
function varargout = vs_ParameterDisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% displays the waveform based on the selected parameters
function plotData(handles)
VSData = guidata(handles.VSHandle);
contents = get(handles.listbox_wavfilelist, 'String');
paramlist = get(handles.listbox_paramlist, 'String');

if (isempty(contents))
    return;
end

shortwavfile = contents{get(handles.listbox_wavfilelist, 'Value')};
wavfile = [VSData.vars.PD_wavdir VSData.vars.dirdelimiter, shortwavfile];
figdata = guidata(handles.figure_ParameterDisplay);
mdata = figdata.mdata;

[y,Fs] = wavread(wavfile);

if (isempty(VSData.vars.PD_paramselection) || isempty(paramlist))
    position = [0.05 0.05 0.9 0.9];
else
    position = [0.05 0.7 0.9 0.295];
end

% top plot is always the wav
subp = subplot('Position', position, 'Parent', handles.uipanel_figure);
t = linspace(0, length(y) / Fs * 1000, length(y));
plot(subp, t, y);
axis(subp, 'tight');

if (isempty(VSData.vars.PD_paramselection) || isempty(paramlist))  % nothing else to do
    return;
end

%set(subp, 'XTick', []);
set(subp, 'XTickLabel', []);

subp2 = subplot('Position', [0.05 0.1 0.9 0.595], 'Parent', handles.uipanel_figure);
cla(subp2);

hold(subp2, 'on');
labels = cell(length(VSData.vars.PD_paramselection), 1);
for k=1:length(VSData.vars.PD_paramselection)
    C = textscan(paramlist{VSData.vars.PD_paramselection(k)}, '%s %s', 'delimiter', '(');
    param = C{2}{1}(1:end-1);
    labels{k} = param;
    t = [1:length(mdata.(param))] * mdata.frameshift;
    plot(subp2, t, mdata.(param), VSData.vars.PD_plottype{mod(k-1, VSData.vars.PD_maxplots)+1});
end

axis(subp2, 'tight');
legend(subp2, labels);
xlabel(subp2, 'Time (ms)');


% fill in the parameter listbox
function checkParameters(handles)
VSData = guidata(handles.VSHandle);
contents = get(handles.listbox_wavfilelist, 'String');

if (isempty(contents))
    return;
end

shortwavfile = contents{get(handles.listbox_wavfilelist, 'Value')};
matfile = [VSData.vars.PD_matdir VSData.vars.dirdelimiter, shortwavfile(1:end-3) 'mat'];

figdata = guidata(handles.figure_ParameterDisplay); % store it so we don't have to recreate the mat data

if (exist(matfile, 'file') == 0)
    set(handles.listbox_paramlist, 'String', []);
    mdata = [];
    paramlist = [];
else

    %load it up and check available parameters
    mdata = func_buildMData(matfile, VSData.vars.O_smoothwinsize);
        
    paramlist = func_getoutputparameterlist();
    paraminx = 1:length(paramlist);
    
    for k=1:length(paramlist)
        C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
        param = C{2}{1}(1:end-1);
        if (~isfield(mdata, param))
            paraminx(k) = 0;
        end
    end
    
    paraminx(paraminx == 0) = [];
    paramlist = paramlist(paraminx);
   
end

figdata.mdata = mdata;
guidata(handles.figure_ParameterDisplay, figdata);

set(handles.listbox_paramlist, 'String', paramlist, 'Value', VSData.vars.PD_paramselection);

            

function edit_wavdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wavdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wavdir as text
%        str2double(get(hObject,'String')) returns contents of edit_wavdir as a double
new_dir = get(hObject, 'String');

VSData = guidata(handles.VSHandle);

if (exist(new_dir, 'dir') == 7)
    VSData = func_setwavdir('PD_wavdir', new_dir, VSData);
    
    if (VSData.vars.recursedir)
        func_setlistbox(handles.listbox_wavfilelist, new_dir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
    else
        func_setlistbox(handles.listbox_wavfilelist, new_dir, 'none', VSData.vars, VSData.vars.I_searchstring);
    end
    
    if (VSData.vars.PE_savematwithwav)
        set(handles.edit_matdir, 'String', new_dir);
        VSData = func_setmatdir('PD_matdir', new_dir, VSData);
    end
    
    guidata(handles.VSHandle, VSData);
    checkParameters(handles);
    plotData(handles);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.PD_wavdir);
end

% --- Executes during object creation, after setting all properties.
function edit_wavdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wavdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_wavdir_browse.
function pushbutton_wavdir_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_wavdir_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = get(handles.edit_wavdir, 'String');
new_dir = uigetdir(current_dir);

VSData = guidata(handles.VSHandle);

if (ischar(new_dir))

    set(handles.edit_wavdir, 'String', new_dir);    
    func_setlistbox(handles.listbox_wavfilelist, new_dir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
    VSData = func_setwavdir('PD_wavdir', new_dir, VSData);
    
    if (VSData.vars.PE_savematwithwav)
        set(handles.edit_matdir, 'String', new_dir);
        VSData = func_setmatdir('PD_matdir', new_dir, VSData);
    end
    
    guidata(handles.VSHandle, VSData);
    
    checkParameters(handles);
    plotData(handles);
end



% --- Executes on selection change in listbox_wavfilelist.
function listbox_wavfilelist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_wavfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_wavfilelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_wavfilelist
checkParameters(handles);
plotData(handles);


% --- Executes during object creation, after setting all properties.
function listbox_wavfilelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_wavfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_matdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_matdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

new_dir = get(hObject, 'String');

VSData = guidata(handles.VSHandle);

if (exist(new_dir, 'dir') == 7)
    VSData = func_setmatdir('PD_matdir', newdir, VSData);
    set(handles.edit_matdir, 'String', new_dir);
        
    guidata(handles.VSHandle, VSData);
    
    checkParameters(handles);
    plotData(handles);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.PD_matdir);
end


% --- Executes during object creation, after setting all properties.
function edit_matdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_matdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_matdir_browse.
function pushbutton_matdir_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_matdir_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = get(handles.edit_matdir, 'String');
new_dir = uigetdir(current_dir);

VSData = guidata(handles.VSHandle);

if (ischar(new_dir))
    VSData = func_setmatdir('PD_matdir', new_dir, VSData);
    set(handles.edit_matdir, 'String', new_dir);
        
    guidata(handles.VSHandle, VSData);
    
    checkParameters(handles);
    plotData(handles);

end




% --- Executes on selection change in listbox_paramlist.
function listbox_paramlist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(hObject, 'String');

if (isempty(contents))
    return;
end

VSData = guidata(handles.VSHandle);
inx = get(hObject, 'Value');
VSData.vars.PD_paramselection = setxor(VSData.vars.PD_paramselection, inx);
VSData.vars.PD_paramselection(VSData.vars.PD_paramselection > length(contents)) = [];

set(hObject, 'Value', VSData.vars.PD_paramselection);
guidata(handles.VSHandle, VSData);

figdata = guidata(handles.figure_ParameterDisplay);
if (~isfield(figdata, 'mdata'))
    checkParameters(handles);
end

plotData(handles);


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
