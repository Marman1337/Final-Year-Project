function varargout = vs_ManualData(varargin)
% VS_MANUALDATA M-file for vs_ManualData.fig
%      VS_MANUALDATA, by itself, creates a new VS_MANUALDATA or raises the existing
%      singleton*.
%
%      H = VS_MANUALDATA returns the handle to a new VS_MANUALDATA or the handle to
%      the existing singleton*.
%
%      VS_MANUALDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_MANUALDATA.M with the given input arguments.
%
%      VS_MANUALDATA('Property','Value',...) creates a new VS_MANUALDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_ManualData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_ManualData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_ManualData

% Last Modified by GUIDE v2.5 22-Oct-2009 12:22:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_ManualData_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_ManualData_OutputFcn, ...
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


% --- Executes just before vs_ManualData is made visible.
function vs_ManualData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_ManualData (see VARARGIN)

% Choose default command line output for vs_ManualData
handles.output = hObject;

% YS: get the settings from the main figure
if (~isfield(handles, 'VSHandle'))
    VSHandle = VoiceSauce;  
    handles.VSHandle = VSHandle;
end

VSData = guidata(handles.VSHandle);

set(handles.edit_wavdir, 'String', VSData.vars.MD_wavdir);
set(handles.edit_matdir, 'String', VSData.vars.MD_matdir);

set(handles.checkbox_matwithwav, 'Value', VSData.vars.MD_matwithwav);

if (VSData.vars.MD_matwithwav)
    set(handles.edit_matdir, 'Enable', 'Off');
    set(handles.pushbutton_matfile_browse, 'Enable', 'Off');
else
    set(handles.edit_matdir, 'Enable', 'On');
    set(handles.pushbutton_matfile_browse, 'Enable', 'On');    
end
    
if (VSData.vars.recursedir)
    func_setlistbox(handles.listbox_wavfilelist, VSData.vars.MD_wavdir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
else
    func_setlistbox(handles.listbox_wavfilelist, VSData.vars.MD_wavdir, 'none', VSData.vars, VSData.vars.I_searchstring);
end

set(handles.listbox_Data_paramlist, 'String',  func_getmanualdataparameterlist());
set(handles.edit_Data_invalid, 'String', VSData.vars.MD_invalidentry);
set(handles.checkbox_resample, 'Value', VSData.vars.MD_resample);

% Update handles structure
guidata(hObject, handles);

checkParameters(handles);
plotParam(handles);

% UIWAIT makes vs_ManualData wait for user response (see UIRESUME)
% uiwait(handles.figure_ManualData);


% -- plot the current selected parameter
function plotParam(handles)
VSData = guidata(handles.VSHandle);
contents = get(handles.listbox_wavfilelist, 'String');
OF = str2double(get(handles.edit_Data_offset, 'String'));

if (isempty(contents))
    return;
end

shortwavfile = contents{get(handles.listbox_wavfilelist, 'Value')};
wavfile = [VSData.vars.MD_wavdir VSData.vars.dirdelimiter shortwavfile];

[y,Fs] = wavread(wavfile);
L = floor((length(y) / Fs * 1000) / VSData.vars.frameshift) - 1;
set(handles.edit_Data_explen, 'String', num2str(L));

% set the amount of padding needed
figdata = guidata(handles.figure_ManualData);
NL = str2double(get(handles.edit_Data_newlen, 'String'));
set(handles.edit_Data_pad, 'String', num2str(L - NL - OF));


if (isfield(figdata, 'mdata'))
    contents = get(handles.listbox_Data_paramlist, 'String');
    
    if (isempty(contents))
        return;
    end
    
    label = contents{get(handles.listbox_Data_paramlist, 'Value')};
    C = textscan(label, '%s %s', 'delimiter', '(');
    param = C{2}{1}(1:end-1);
    
    % if the parameter exists, plot it in blue
    if (isfield(figdata.mdata, param))
        plot(handles.axes_main, figdata.mdata.(param)); % plot the existing param
        L = length(figdata.mdata.(param));
        set(handles.edit_Data_explen, 'String', num2str(L));
        set(handles.edit_Data_pad, 'String', num2str(L - NL - OF));
        axis(handles.axes_main, 'tight');
    else
        cla(handles.axes_main);
    end
end

if (VSData.vars.MD_resample && isfield(figdata, 'newdata_resamp'))
    hold(handles.axes_main, 'on');
    newdata = zeros(L, 1) * NaN;
    if (OF >= 0)
        newdata(OF+1:L) = figdata.newdata_resamp;
    else
        newdata(1:length(figdata.newdata_resamp) + OF) = figdata.newdata_resamp(abs(OF)+1:end);
    end
    plot(handles.axes_main, newdata, 'r');
    hold(handles.axes_main, 'off');
    axis(handles.axes_main, 'tight');
    hold(handles.axes_main, 'off');
    
elseif (isfield(figdata, 'newdata'))
    hold(handles.axes_main, 'on');
    % create new vector
    newdata = zeros(L, 1) * NaN;
    if (length(figdata.newdata) + OF >= L)
        newdata(OF+1:L) = figdata.newdata(1:L-OF);
    else
        if (OF >=0)
            newdata(OF+1:OF+length(figdata.newdata)) = figdata.newdata;
        else
            newdata(1:length(figdata.newdata)+OF) = figdata.newdata(abs(OF)+1:end);
        end
    end
    
    plot(handles.axes_main, newdata, 'r');
    hold(handles.axes_main, 'off');
    axis(handles.axes_main, 'tight');
    %legend(handles.axes_main, {'Original', 'New'});
end


% -- build up the matfile if it exists
function checkParameters(handles)
VSData = guidata(handles.VSHandle);
contents = get(handles.listbox_wavfilelist, 'String');

if (isempty(contents))
    return;
end

shortwavfile = contents{get(handles.listbox_wavfilelist, 'Value')};
matfile = [VSData.vars.MD_matdir VSData.vars.dirdelimiter, shortwavfile(1:end-3) 'mat'];

if (exist(matfile, 'file') == 0)
    mdata = [];
else
    mdata = func_buildMData(matfile, VSData.vars.O_smoothwinsize); 
end

% store mdata so it can be accessed by plotData
figdata = guidata(handles.figure_ManualData);
figdata.mdata = mdata;
guidata(handles.figure_ManualData, figdata);



% --- Outputs from this function are returned to the command line.
function varargout = vs_ManualData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_wavdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wavdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

new_dir = get(hObject, 'String');

VSData = guidata(handles.VSHandle);

if (exist(new_dir, 'dir') == 7)
    VSData = func_setwavdir('MD_wavdir', new_dir, VSData);

    if (VSData.vars.recursedir)
        func_setlistbox(handles.listbox_wavfilelist, VSData.vars.MD_wavdir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
    else
        func_setlistbox(handles.listbox_wavfilelist, VSData.vars.MD_wavdir, 'none', VSData.vars, VSData.vars.I_searchstring);
    end
    
    if (VSData.vars.PE_savematwithwav)
        set(handles.edit_matdir, 'String', new_dir);
        VSData = func_setmatdir('MD_matdir', new_dir, VSData);
    end
    guidata(handles.VSHandle, VSData);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.MD_wavdir);
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


% --- Executes on button press in pushbutton_wavfile_browse.
function pushbutton_wavfile_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_wavfile_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = get(handles.edit_wavdir, 'String');
new_dir = uigetdir(current_dir);

VSData = guidata(handles.VSHandle);

if (ischar(new_dir))
    VSData = func_setwavdir('MD_wavdir', new_dir, VSData);
    set(handles.edit_wavdir, 'String', new_dir);
    
    if (VSData.vars.recursedir)
        func_setlistbox(handles.listbox_wavfilelist, VSData.vars.MD_wavdir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
    else
        func_setlistbox(handles.listbox_wavfilelist, VSData.vars.MD_wavdir, 'none', VSData.vars, VSData.vars.I_searchstring);
    end

    % assume that mat files are saved with wavs
    if (VSData.vars.MD_matwithwav == 1)
        set(handles.edit_matdir, 'String', new_dir);
        VSData = func_setmatdir('MD_matdir', new_dir, VSData);
    end
    
    guidata(handles.VSHandle, VSData);
    
end

checkParameters(handles);
plotParam(handles);



% --- Executes on selection change in listbox_wavfilelist.
function listbox_wavfilelist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_wavfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_wavfilelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_wavfilelist
checkParameters(handles);
plotParam(handles);


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


% --- Executes on selection change in listbox_Data_paramlist.
function listbox_Data_paramlist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Data_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_Data_paramlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Data_paramlist
%checkParameters(handles);
plotParam(handles);


% --- Executes during object creation, after setting all properties.
function listbox_Data_paramlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Data_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Data_datafile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Data_datafile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
L = str2double(get(handles.edit_Data_explen, 'String'));
OF = str2double(get(handles.edit_Data_offset, 'String'));

filename = get(hObject, 'String');

if (exist(filename,'file') == 2)
    % try to read in the file
    fid = fopen(filename, 'rt');
    set(handles.edit_Data_datafile, 'String', [pathname filename]);
    
    if (fid == -1)
        msgbox('Error: Unable to open data file', 'Error', 'error', 'modal');
        return;
    end
    
    data = textscan(fid, '%s', 'delimiter', '\n');
    fclose(fid);
    
    % get the specified labels for invalid entry
    delimiters = textscan(VSData.vars.MD_invalidentry, '%s', 'delimiter', ',');
    
    % now check each entry
    data = data{1};
    newdata = zeros(length(data), 1) * NaN;

    for k=1:length(data)
        switch(data{k})
            case delimiters
            
            otherwise
                newdata(k) = str2double(data{k});
        end        
    end
    
    figdata = guidata(handles.figure_ManualData);
    figdata.newdata = newdata;
    
    if (VSData.vars.MD_resample)
        guidata(handles.figure_ManualData, figdata);
    end
    
    guidata(handles.figure_ManualData, figdata);
    
    plotParam(handles);
    
    set(handles.edit_Data_newlen, 'String', num2str(length(newdata)));
    set(handles.edit_Data_pad, 'String', num2str(L - OF - length(newdata)));
    
end


% --- Executes during object creation, after setting all properties.
function edit_Data_datafile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Data_datafile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_datafile_browse.
function pushbutton_datafile_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_datafile_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
L = str2double(get(handles.edit_Data_explen, 'String'));
OF = str2double(get(handles.edit_Data_offset, 'String'));
current_dir = get(handles.edit_wavdir, 'String');

[filename, pathname] = uigetfile({'*.txt'; '*.*'}, 'Select data file', current_dir);

if (filename ~= 0)
    % try to read in the file
    fid = fopen([pathname filename], 'rt');
    set(handles.edit_Data_datafile, 'String', [pathname filename]);
    
    if (fid == -1)
        msgbox('Error: Unable to open data file', 'Error', 'error', 'modal');
        return;
    end
    
    data = textscan(fid, '%s', 'delimiter', '\n');
    fclose(fid);
    
    % get the specified labels for invalid entry
    delimiters = textscan(VSData.vars.MD_invalidentry, '%s', 'delimiter', ',');
    
    % now check each entry
    data = data{1};
    newdata = zeros(length(data), 1) * NaN;

    for k=1:length(data)
        switch(data{k})
            case delimiters
            
            otherwise
                newdata(k) = str2double(data{k});
        end        
    end
    
    figdata = guidata(handles.figure_ManualData);
    figdata.newdata = newdata;
    
    if (VSData.vars.MD_resample)
        figdata = resample_signal(figdata, handles);
    end
    guidata(handles.figure_ManualData, figdata);

    plotParam(handles);
    
    set(handles.edit_Data_newlen, 'String', num2str(length(newdata)));
    set(handles.edit_Data_pad, 'String', num2str(L - OF - length(newdata)));
    
end
    


function edit_Data_offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Data_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
num = str2double(str);
if (isnan(num))
    set(hObject, 'String', num2str(VSData.vars.MD_offset));
else
    VSData.vars.MD_offset = num;
    guidata(handles.VSHandle, VSData);
    
    % update the other numbers
    L = str2double(get(handles.edit_Data_explen, 'String'));
    NDL = str2double(get(handles.edit_Data_newlen, 'String'));
    set(handles.edit_Data_pad, 'String', num2str(L - num - NDL));
    
    if (VSData.vars.MD_resample)
        figdata = guidata(handles.figure_ManualData);
        figdata = resample_signal(figdata, handles);
        guidata(handles.figure_ManualData, figdata);
    end
    
    plotParam(handles);
end

% --- Executes during object creation, after setting all properties.
function edit_Data_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Data_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
    VSData = func_setmatdir('MD_matdir', new_dir, VSData);
    set(handles.edit_matdir, 'String', new_dir);
        
    guidata(handles.VSHandle, VSData);   
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.MD_matdir);
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


% --- Executes on button press in pushbutton_matfile_browse.
function pushbutton_matfile_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_matfile_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = get(handles.edit_matdir, 'String');
new_dir = uigetdir(current_dir);

VSData = guidata(handles.VSHandle);

if (ischar(new_dir))
    VSData = func_setmatdir('MD_matdir', new_dir, VSData);
    set(handles.edit_matdir, 'String', new_dir);
        
    guidata(handles.VSHandle, VSData);
end

checkParameters(handles);
plotParam(handles);


% --- Executes on button press in pushbutton_Data_save.
function pushbutton_Data_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Data_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
figdata = guidata(handles.figure_ManualData);

L = str2double(get(handles.edit_Data_explen, 'String'));
OF = VSData.vars.MD_offset;

% check we have something to save to
wavfilelist = get(handles.listbox_wavfilelist, 'String');
if (isempty(wavfilelist))
    msgbox('Error: no wav files found.', 'Error', 'error', 'modal');
    return;
end

paramlist = get(handles.listbox_Data_paramlist, 'String');
if (isempty(paramlist))
    msgbox('Error: no parameters found.', 'Error', 'error', 'modal');
    return;
end

% get the parameter
label = paramlist{get(handles.listbox_Data_paramlist, 'Value')};
C = textscan(label, '%s %s', 'delimiter', '(');
param = C{2}{1}(1:end-1);

shortwavfile = wavfilelist{get(handles.listbox_wavfilelist, 'Value')};
matfile = [VSData.vars.MD_matdir VSData.vars.dirdelimiter shortwavfile(1:end-3) 'mat'];


if (VSData.vars.MD_resample && isfield(figdata, 'newdata_resamp'))
    data = figdata.newdata_resamp;
elseif (~VSData.vars.MD_resample && isfield(figdata, 'newdata'))
    data = figdata.newdata;
else
    msgbox('Error: no new data loaded.', 'Error', 'error', 'modal');
    return;
end

newdata = zeros(L, 1) * NaN;
if (length(data) + OF >= L)
    newdata(OF+1:L) = data;
else
    if (OF >= 0)
        newdata(OF+1:OF+length(data)) = data;
    else
        newdata(1:length(data)+OF) = data(abs(OF)+1:end);
    end
end


% create the new parameter here
eval([sprintf(param) '= newdata;']);
if (exist(matfile, 'file') == 2) % mat file already exist
    save(matfile, param, '-append');
else
    save(matfile, param);
end

msgbox('Save complete.', 'Save', 'help', 'modal');
    



function edit_Data_explen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Data_explen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Data_explen as text
%        str2double(get(hObject,'String')) returns contents of edit_Data_explen as a double


% --- Executes during object creation, after setting all properties.
function edit_Data_explen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Data_explen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Data_pad_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Data_pad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Data_pad as text
%        str2double(get(hObject,'String')) returns contents of edit_Data_pad as a double


% --- Executes during object creation, after setting all properties.
function edit_Data_pad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Data_pad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Data_newlen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Data_newlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Data_newlen as text
%        str2double(get(hObject,'String')) returns contents of edit_Data_newlen as a double


% --- Executes during object creation, after setting all properties.
function edit_Data_newlen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Data_newlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Data_invalid_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Data_invalid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Data_invalid as text
%        str2double(get(hObject,'String')) returns contents of edit_Data_invalid as a double
VSData = guidata(handles.VSHandle);
VSData.vars.MD_invalidentry = get(hObject, 'String');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Data_invalid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Data_invalid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_resample.
function checkbox_resample_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_resample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
VSData.vars.MD_resample = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);

if (VSData.vars.MD_resample)
    figdata = guidata(handles.figure_ManualData);
    figdata = resample_signal(figdata, handles);
    guidata(handles.figure_ManualData, figdata);
end

plotParam(handles);




% -- resample the signal if required
function figdata = resample_signal(figdata, handles)
VSData = guidata(handles.VSHandle);

if (~isfield(figdata, 'newdata'))
    return;
end

newL = str2double(get(handles.edit_Data_explen, 'String'));

if (length(figdata.newdata)==1)
    figdata.newdata_resamp = ones(newL, 1) * figdata.newdata;
    
else
    try
        figdata.newdata_resamp = resample(figdata.newdata, newL, length(figdata.newdata));
    catch ME
        msgbox({'Error: Unable to run resample function.', '(Requires Signal Processing Toolbox)'}, 'Error', 'error', 'modal');
    end
end    


% --- Executes on button press in checkbox_matwithwav.
function checkbox_matwithwav_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_matwithwav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
VSData.vars.MD_matwithwav = get(hObject, 'Value');

if (VSData.vars.MD_matwithwav)
    set(handles.edit_matdir, 'Enable', 'Off');
    set(handles.pushbutton_matfile_browse, 'Enable', 'Off');
else
    set(handles.edit_matdir, 'Enable', 'On');
    set(handles.pushbutton_matfile_browse, 'Enable', 'On');    
end

guidata(handles.VSHandle, VSData);