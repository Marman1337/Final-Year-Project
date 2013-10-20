function varargout = vs_ParameterEstimation(varargin)
% VS_PARAMETERESTIMATION M-file for vs_ParameterEstimation.fig
%      VS_PARAMETERESTIMATION, by itself, creates a new VS_PARAMETERESTIMATION or raises the existing
%      singleton*.
%
%      H = VS_PARAMETERESTIMATION returns the handle to a new VS_PARAMETERESTIMATION or the handle to
%      the existing singleton*.
%
%      VS_PARAMETERESTIMATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_PARAMETERESTIMATION.M with the given input arguments.
%
%      VS_PARAMETERESTIMATION('Property','Value',...) creates a new VS_PARAMETERESTIMATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_ParameterEstimation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_ParameterEstimation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_ParameterEstimation

% Last Modified by GUIDE v2.5 19-Oct-2009 11:55:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_ParameterEstimation_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_ParameterEstimation_OutputFcn, ...
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


% --- Executes just before vs_ParameterEstimation is made visible.
function vs_ParameterEstimation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_ParameterEstimation (see VARARGIN)

% Choose default command line output for vs_ParameterEstimation
handles.output = hObject;

% YS: get the settings from the main figure
if (~isfield(handles, 'VSHandle'))
    VSHandle = VoiceSauce;  
    handles.VSHandle = VSHandle;
end

% set up the text fields with default values
setGUIVariables(handles);

set(handles.listbox_filelist, 'KeyPressFcn', @filelist_listbox_KeyPressFcn);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vs_ParameterEstimation wait for user response (see UIRESUME)
% uiwait(handles.figure_ParameterEstimation);


function setGUIVariables(handles)
VSData = guidata(handles.VSHandle);

set(handles.edit_inputdirectory, 'String', VSData.vars.wavdir);
set(handles.edit_outputdirectory, 'String', VSData.vars.matdir);

set(handles.checkbox_savematwithwav, 'Value', VSData.vars.PE_savematwithwav);
set(handles.checkbox_process16khz, 'Value', VSData.vars.PE_processwith16k);
set(handles.checkbox_useTextgrid, 'Value', VSData.vars.PE_useTextgrid);
set(handles.checkbox_showwaveform, 'Value', VSData.vars.PE_showwaveforms);  % turn this off at startup
    

if (VSData.vars.recursedir)
    func_setlistbox(handles.listbox_filelist, VSData.vars.wavdir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
else
    func_setlistbox(handles.listbox_filelist, VSData.vars.wavdir, 'none', VSData.vars, VSData.vars.I_searchstring);
end

if (VSData.vars.PE_savematwithwav == 1)
    set(handles.edit_outputdirectory, 'Enable', 'Off');
    set(handles.pushbutton_outputBrowse, 'Enable', 'Off');
else
    set(handles.edit_outputdirectory, 'Enable', 'On');
    set(handles.pushbutton_outputBrowse, 'Enable', 'On');
end    

if (length(VSData.vars.PE_params) == 0)
    set(handles.edit_parameterselection, 'String', 'None');
elseif (length(VSData.vars.PE_params) == length(func_getparameterlist()))
    set(handles.edit_parameterselection, 'String', 'All');
else
    set(handles.edit_parameterselection, 'String', 'Custom');
end



function filelist_listbox_KeyPressFcn(hObject, eventdata)
handles = guidata(hObject);

key = double(get(gcbf, 'CurrentCharacter'));
if (gcbo == handles.listbox_filelist)
    if (key == 127) % delete key

        inx = get(handles.listbox_filelist, 'Value');
        contents = get(handles.listbox_filelist, 'String');

        %nothing to do
        if (isempty(contents))
            return;
        end
        
        newinx = setxor(inx, [1:length(contents)]);

        newcontents = contents(newinx);
        set(handles.listbox_filelist, 'String', newcontents);
        
        if (inx(end) > length(newcontents))
            set(handles.listbox_filelist, 'Value', length(newcontents));
        else
            set(handles.listbox_filelist, 'Value', inx(end));
        end
    end
end



% --- Outputs from this function are returned to the command line.
function varargout = vs_ParameterEstimation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_filelist.
function listbox_filelist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(handles.checkbox_showwaveform, 'Value') == 1)
    plotCurrentWav(handles);
end


% --- Executes during object creation, after setting all properties.
function listbox_filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_inputdirectory_Callback(hObject, eventdata, handles)
% hObject    handle to edit_inputdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = get(handles.edit_inputdirectory, 'String');

VSData = guidata(handles.VSHandle);

if (exist(new_dir, 'dir') == 7) % check if new_dir exists
    VSData.vars.wavdir = new_dir;
    set(handles.edit_inputdirectory, 'String', new_dir);
    
    if (get(handles.checkbox_savematwithwav, 'Value') == 1)  % change output dir too
        set(handles.edit_outputdirectory, 'String', new_dir);
        
        VSData = func_setmatdir('matdir', new_dir, VSData);
    end
    
    % update the listbox
    if (VSData.vars.recursedir == 1)
        func_setlistbox(handles.listbox_filelist, new_dir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
    else
        func_setlistbox(handles.listbox_filelist, new_dir, 'none', VSData.vars, VSData.vars.I_searchstring);
    end

    VSData = func_setwavdir('wavdir', new_dir, VSData);
    
    % update the variables
    guidata(handles.VSHandle, VSData);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.wavdir);
end


% --- Executes during object creation, after setting all properties.
function edit_inputdirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_inputdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_inputBrowse.
function pushbutton_inputBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_inputBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = get(handles.edit_inputdirectory, 'String');
new_dir = uigetdir(current_dir);

VSData = guidata(handles.VSHandle);

if (ischar(new_dir)) % check if a new dir was returned
    VSData.vars.wavdir = new_dir;
    set(handles.edit_inputdirectory, 'String', new_dir);
    
    if (get(handles.checkbox_savematwithwav, 'Value') == 1)  % change output dir too
        set(handles.edit_outputdirectory, 'String', new_dir);
        
        VSData = func_setmatdir('matdir', new_dir, VSData);
    end
    
    % update the listbox
    if (VSData.vars.recursedir == 1)
        func_setlistbox(handles.listbox_filelist, new_dir, 'recurse', VSData.vars, VSData.vars.I_searchstring);
    else
        func_setlistbox(handles.listbox_filelist, new_dir, 'none', VSData.vars, VSData.vars.I_searchstring);
    end

    VSData = func_setwavdir('wavdir', new_dir, VSData);
    
    % update the variables
    guidata(handles.VSHandle, VSData);
end



function edit_outputdirectory_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outputdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);

if (strcmp(get(hObject, 'Enable'), 'on'))
    new_dir = get(handles.edit_outputdirectory, 'String');
    
    if (exist(new_dir, 'dir') == 7)
        set(handles.edit_outputdirectory, 'String', new_dir);
        
        VSData = func_setmatdir('matdir', new_dir, VSData);
        
        guidata(handles.VSHandle, VSData);
    else
        msgbox('Error: Directory not found.', 'Error', 'error', 'modal');
        set(hObject, 'String', VSData.vars.matdir);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_outputdirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outputdirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_outputBrowse.
function pushbutton_outputBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outputBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);

if (strcmp(get(hObject, 'Enable'), 'on'))
    curr_dir = get(handles.edit_outputdirectory, 'String');
    new_dir = uigetdir(curr_dir);
    
    if (ischar(new_dir))
        set(handles.edit_outputdirectory, 'String', new_dir);
        
        VSData = func_setmatdir('matdir', new_dir, VSData);
        
        guidata(handles.VSHandle, VSData);
    end
end
    

% --- Executes on button press in checkbox_savematwithwav.
function checkbox_savematwithwav_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_savematwithwav (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
VSData.vars.PE_savematwithwav = get(hObject, 'Value');

if (get(hObject, 'Value') == 1)  % link input with output directory
    VSData = func_setmatdir('matdir', VSData.vars.wavdir, VSData);
    
    set(handles.edit_outputdirectory, 'String', VSData.vars.matdir);
    set(handles.edit_outputdirectory, 'Enable', 'off');
    set(handles.pushbutton_outputBrowse, 'Enable', 'off');
else
    %enable user to pick output directory
    set(handles.edit_outputdirectory, 'Enable', 'on');
    set(handles.pushbutton_outputBrowse, 'Enable', 'on');
end

guidata(handles.VSHandle, VSData);





% --- Executes on button press in pushbutton_ParameterSelection.
function pushbutton_ParameterSelection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ParameterSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save the old file list
filelist = get(handles.listbox_filelist, 'String');
fileinx = get(handles.listbox_filelist, 'Value');
vs_SelectParameters();
set(handles.listbox_filelist, 'String', filelist, 'Value', fileinx);



function edit_parameterselection_Callback(hObject, eventdata, handles)
% hObject    handle to edit_parameterselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_parameterselection as text
%        str2double(get(hObject,'String')) returns contents of edit_parameterselection as a double


% --- Executes during object creation, after setting all properties.
function edit_parameterselection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_parameterselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_process16khz.
function checkbox_process16khz_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_process16khz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
VSData.vars.PE_processwith16k = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes on button press in checkbox_useTextgrid.
function checkbox_useTextgrid_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_useTextgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
VSData.vars.PE_useTextgrid = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes on button press in checkbox_showwaveform.
function checkbox_showwaveform_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_showwaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
VSData.vars.PE_showwaveforms = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);

if (get(hObject, 'Value') == 1)
    SWfig = vs_ShowWaveform;
    SWhandle = guidata(SWfig);
    
    handles.SWfig = SWfig;
    handles.SWhandle = SWhandle;
    guidata(hObject, handles);
   
    plotCurrentWav(handles);
else
    if (isfield(handles, 'SWfig'))
        delete(handles.SWfig);
        handles = rmfield(handles, 'SWfig');
        guidata(hObject, handles);
    end
end


% --- plots the current wavfile into handles.SWhandle.axes_main
function plotCurrentWav(handles)
% get the present file selected
VSData = guidata(handles.VSHandle);

contents = get(handles.listbox_filelist, 'String');
if (isempty(contents))
    return;  % do nothing
end
inx = get(handles.listbox_filelist, 'Value');
filename = contents{inx};
directory = get(handles.edit_inputdirectory, 'String');
wavfile = [directory VSData.vars.dirdelimiter filename];

[y,Fs] = wavread(wavfile);
t = linspace(0,length(y)/Fs*1000, length(y));
plot(handles.SWhandle.axes_main, t, y);
ylabel(handles.SWhandle.axes_main, 'Amplitude');
xlabel(handles.SWhandle.axes_main, 'Time (ms)');
axis(handles.SWhandle.axes_main, 'tight');
set(handles.SWhandle.figure_ShowWaveform, 'Name', filename);


% --- Executes on button press in togglebutton_start.
function togglebutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject, 'Value') == 1)  % start the process
    set(hObject, 'String', 'Processing...', 'ForegroundColor', 'red');
    
    BatchProcess(handles);
    set(hObject, 'String', 'Start!', 'ForegroundColor', 'black', 'Value', 0);

end



% this is the main parameter estimation function
function BatchProcess(handles)
VSData = guidata(handles.VSHandle);
filelist = get(handles.listbox_filelist, 'String');
paramlist = VSData.vars.PE_params;

if (isempty(filelist))
    msgbox('No input files.', 'Error', 'warn', 'modal');
    return;
end

if (isempty(paramlist))
    msgbox('No parameters selected.', 'Error', 'warn', 'modal');
    return;
end

MBox = MessageBox;
MBoxHandles = guidata(MBox);

messages = cell(length(filelist)+1, 1);  % allocate some memory for messages

% get the variables from settings
windowsize = VSData.vars.windowsize;
frameshift = VSData.vars.frameshift;
preemphasis = VSData.vars.preemphasis;
F0algorithm = VSData.vars.F0algorithm;
FMTalgorithm = VSData.vars.FMTalgorithm;
maxF0 = VSData.vars.maxF0;
minF0 = VSData.vars.minF0;
frame_precision = VSData.vars.frame_precision; % used for Praat f0/formant
                                              % estimation, SHR algorithm
                                              % to set precision for time
                                              % alignment of data
                                              % vectors, in terms of frames
                                              
inputdir = get(handles.edit_inputdirectory, 'String');
outputdir = get(handles.edit_outputdirectory, 'String');

% start the processing of each file
for k=1:length(filelist)
    % check if 'stop' button has been pressed
    if (~ishandle(MBoxHandles.figure_MessageBox) || get(MBoxHandles.figure_MessageBox, 'UserData') == 1)
        messages{k} = 'Stop button pressed by user.';
        if (ishandle(MBoxHandles.figure_MessageBox))
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
        end
        return;
    end
    
    messages{k} = sprintf('%d/%d. %s: ', k, length(filelist), filelist{k});
    set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
    set(handles.listbox_filelist, 'Value', k);
    drawnow;
    
    wavfile = [inputdir VSData.vars.dirdelimiter filelist{k}];
    matfile = [outputdir VSData.vars.dirdelimiter filelist{k}(1:end-3) 'mat'];
    textgridfile = [wavfile(1:end-3) 'Textgrid'];
    
    % strip down the matfile and check if the directory exists
    mdir = fileparts(matfile);
    if (exist(mdir, 'dir') ~= 7)
        mkdir(mdir);
    end
    
    % check if we are showing the waveforms
    if (get(handles.checkbox_showwaveform, 'Value') == 1)
        plotCurrentWav(handles);
    end
    
    % check to see if we're using textgrids
    useTextgrid = get(handles.checkbox_useTextgrid, 'Value');
    if (useTextgrid == 1)
        if (exist(textgridfile, 'file') == 0)
            useTextgrid = 0;
        end
    end
    
    % read in the wav file
    [y, Fs, nbits] = wavread(wavfile);
    
    if (size(y, 2) > 1)
        messages{k} = [messages{k} ' Multi-channel wav file - using first channel only: '];
        set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
        drawnow;
        y = y(:,1);
    end
    
    % see if we need to resample to 16 kHz (faster for Straight)
    resampled = 0;
    if (get(handles.checkbox_process16khz, 'Value') == 1)
        if (Fs ~= 16000)
            y = resample(y, 16000, Fs);
            wavfile = generateRandomFile(wavfile, handles);
            wavfile = [wavfile(1:end-4) '_16kHz.wav'];
            warning off; % stop clipping messages
            wavwrite(y, 16000, nbits, wavfile);
            warning on;
            resampled = 1;
        end
        [y, Fs] = wavread(wavfile);  % reread the resampled file
    end
    
    % calculate the length of data vectors - all measures will have this
    % length - important!!
    data_len = floor(length(y) / Fs * 1000 / frameshift);
        
    % parse the parameter list to get proper ordering
    paramlist = func_parseParameters(paramlist, handles, matfile, data_len);
    
    for n=1:length(paramlist)
        
        % check if 'stop' button has been pressed
        if (~ishandle(MBoxHandles.figure_MessageBox) || get(MBoxHandles.figure_MessageBox, 'UserData') == 1)
            break;
        end
    
        
    % F0 straight
        if (strcmp(paramlist{n}, 'F0 (Straight)'))
            messages{k} = [messages{k} 'strF0 '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            err = 0;
            
            if (useTextgrid)
                try
                    [strF0, V] = func_StraightPitch(y, Fs, VSData.vars, textgridfile);
                catch
                    err = 1;
                end
            else
                try
                    [strF0, V] = func_StraightPitch(y, Fs, VSData.vars);
                catch
                    err = 1;
                end
            end
            
            if (strcmp(VSData.vars.F0algorithm, 'F0 (Straight)') && err == 1)
                messages{k+1} = 'Error: Problem with STRAIGHT - please check settings';
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
                set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                set(MBoxHandles.pushbutton_stop, 'Enable', 'off');

                msgbox({'Error: Unable to proceed.', 'Problem with STRAIGHT - please check settings'}, 'Error', 'error', 'modal');
                if (resampled) % delete the temporary file if it exists
                    delete(wavfile);
                end
                return;
            end
            
            strF0 = strF0(1:frameshift:end);  % drop samples if necessary
            
            if (length(strF0) > data_len)
                strF0 = strF0(1:data_len);
            elseif (length(strF0) < data_len)
                strF0 = [strF0; ones(data_len - length(strF0), 1) * NaN];
            end
            
            if (exist(matfile, 'file'))
                save(matfile, 'strF0', 'Fs', '-append');
            else
                save(matfile, 'strF0', 'Fs');
            end

            
    % F0 (Snack)
        elseif (strcmp(paramlist{n}, 'F0 (Snack)'))
            messages{k} = [messages{k} 'sF0 '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            % guard case for 32-bit precision files - some version of snack
            % on a 64-bit machine causes pitch estimation to fail
            use_alt_file = 0;
            if (nbits ~= 16)
                snackwavfile = [wavfile(1:end-4) '_16b.wav'];
                use_alt_file = 1;
                wavwrite(y, Fs, 16, snackwavfile);
            else
                snackwavfile = wavfile;
            end
            
            err = 0;
            try 
                [sF0, sV, err] = func_SnackPitch(snackwavfile, windowsize/1000, frameshift/1000, maxF0, minF0);
            catch
                err = 1;
            end
            
            % check for fatal errors
            if (strcmp(VSData.vars.F0algorithm, 'F0 (Snack)') && err == 1)
                messages{k+1} = 'Error: Problem with snack - please check settings';
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
                set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                set(MBoxHandles.pushbutton_stop, 'Enable', 'off');

                msgbox({'Error: Unable to proceed.', 'Problem with snack - please check settings'}, 'Error', 'error', 'modal');
                if (resampled) % delete the temporary file if it exists
                    delete(wavfile);
                end
                if (use_alt_file)
                    delete(snackwavfile);
                end
                return;
            end
            
            sF0 = [zeros(floor(windowsize/frameshift/2),1)*NaN; sF0]; sF0 = [sF0; ones(data_len-length(sF0), 1)*NaN];
            sV = [zeros(floor(windowsize/frameshift/2),1)*NaN; sV]; sV = [sV; ones(data_len-length(sV), 1)* NaN];
            
            if (exist(matfile, 'file'))
                save(matfile, 'sF0', 'sV', 'Fs', '-append');
            else
                save(matfile, 'sF0', 'sV', 'Fs');
            end
            
            if (use_alt_file)
                delete(snackwavfile);
            end

    % F0 (Praat)
        elseif (strcmp(paramlist{n}, 'F0 (Praat)'))
            messages{k} = [messages{k} 'pF0 '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            % guard case for 32-bit precision files - some version of snack
            % on a 64-bit machine causes pitch estimation to fail            
            err = 0;
            try 
                [pF0, err] = func_PraatPitch(wavfile, frameshift/1000, frame_precision, ...
                                             VSData.vars.F0Praatmin, ...
                                             VSData.vars.F0Praatmax, ...
                                             VSData.vars.F0PraatSilenceThreshold, ...
                                             VSData.vars.F0PraatVoiceThreshold, ...
                                             VSData.vars.F0PraatOctaveCost, ...
                                             VSData.vars.F0PraatOctaveJumpCost, ...
                                             VSData.vars.F0PraatVoicedUnvoicedCost, ...
                                             VSData.vars.F0PraatKillOctaveJumps, ...
                                             VSData.vars.F0PraatSmooth, ... 
                                             VSData.vars.F0PraatSmoothingBandwidth, ...
                                             VSData.vars.F0PraatInterpolate, ... 
                                             VSData.vars.F0Praatmethod, ... 
                                             data_len);
            catch
                err = 1;
            end
            
            % check for fatal errors
            if (strcmp(VSData.vars.F0algorithm, 'F0 (Praat)') && err ~= 0)
                messages{k+1} = 'Error: Problem with Praat - please check settings';
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
                set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                set(MBoxHandles.pushbutton_stop, 'Enable', 'off');

                msgbox({'Error: Unable to proceed.', 'Problem with Praat - please check settings'}, 'Error', 'error', 'modal');
                if (resampled) % delete the temporary file if it exists
                    delete(wavfile);
                end
                
                return;
            elseif (err ~= 0)
                messages{k} = [messages{k} '(error) '];
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            end
                        
            if (exist(matfile, 'file'))
                save(matfile, 'pF0', 'Fs', '-append');
            else
                save(matfile, 'pF0', 'Fs');
            end            

    % F0 (SHR)
        elseif (strcmp(paramlist{n}, 'F0 (SHR)'))
            messages{k} = [messages{k} 'shrF0 '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
           
            [SHR, shrF0] = func_GetSHRP(y, Fs, VSData.vars, data_len);          
            save(matfile, 'shrF0', '-append');
                        
    % F0 (Other)
        elseif (strcmp(paramlist{n}, 'F0 (Other)'))
            messages{k} = [messages{k} 'oF0 '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            oF0 = zeros(data_len, 1) * NaN; % allocate some memory
            
            err = 0;
            try 
                [F0, errmsg] = func_OtherPitch(wavfile, handles);
            catch
                err = 1;
            end
           
            if ((length(F0)==1 && isnan(F0)) || isempty(F0))
                err = 1;
            end
            
            % check for fatal errors
            if (err == 1)
                messages{k} = [messages{k} '- error: ' errmsg ' '];
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
                
                if (strcmp(VSData.vars.F0algorithm, 'F0 (Other)'))
                    set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                    set(MBoxHandles.pushbutton_stop, 'Enable', 'off');
                    msgbox({['Error: ' errmsg], 'Problem with F0 estimation - please check settings'}, 'Error', 'error', 'modal');
                    if (resampled) % delete the temporary file if it exists
                        delete(wavfile);
                    end
                    return;
                end
            elseif (err ~= 0)
                messages{k} = [messages{k} '(error) '];
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            end
            

            if (VSData.vars.F0OtherOffset + length(F0) <= data_len)
                oF0(VSData.vars.F0OtherOffset+1:VSData.vars.F0OtherOffset + length(F0)) = F0;
            else  % need to trim F0
                oF0(VSData.vars.F0OtherOffset+1:end) = F0(1:data_len - VSData.vars.F0OtherOffset);
            end
                            
            if (exist(matfile, 'file'))
                save(matfile, 'oF0', 'Fs', '-append');
            else
                save(matfile, 'oF0', 'Fs');
            end
            
            
    % F1, F2, F3, F4 (Snack)
        elseif (strcmp(paramlist{n}, 'F1, F2, F3, F4 (Snack)'))
            messages{k} = [messages{k} 'FMTs '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow; 
            
            % guard case for 32-bit files - some version of snack on a
            % 64-bit machine causes formant estimation to fail
            use_alt_file = 0;
            if (nbits ~= 16)
                snackwavfile = [wavfile(1:end-4) '_16b.wav'];
                wavwrite(y, Fs, 16, snackwavfile);
                use_alt_file = 1;
            else
                snackwavfile = wavfile;
            end
            
            [sF1, sF2, sF3, sF4, sB1, sB2, sB3, sB4, err] = func_SnackFormants(snackwavfile, windowsize/1000, frameshift/1000, preemphasis);
            
            if (strcmp(VSData.vars.FMTalgorithm, 'F1, F2, F3, F4 (Snack)') && err == 1)
                messages{k+1} = 'Error: Problem with snack - please check settings';
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
                set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                set(MBoxHandles.pushbutton_stop, 'Enable', 'off');
                
                msgbox({'Error: Unable to proceed.', 'Problem with snack - please check settings'}, 'Error', 'error', 'modal');
                if (resampled) % delete the temporary file if it exists
                    delete(wavfile);
                end
                if (use_alt_file)
                    delete(snackwavfile);
                end
                
                return;
            end

            sF1 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF1]; sF1 = [sF1; ones(data_len-length(sF1), 1)*NaN];
            sF2 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF2]; sF2 = [sF2; ones(data_len-length(sF2), 1)*NaN];
            sF3 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF3]; sF3 = [sF3; ones(data_len-length(sF3), 1)*NaN];
            sF4 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF4]; sF4 = [sF4; ones(data_len-length(sF4), 1)*NaN];
            sB1 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB1]; sB1 = [sB1; ones(data_len-length(sB1), 1)*NaN];
            sB2 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB2]; sB2 = [sB2; ones(data_len-length(sB2), 1)*NaN];
            sB3 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB3]; sB3 = [sB3; ones(data_len-length(sB3), 1)*NaN];
            sB4 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB4]; sB4 = [sB4; ones(data_len-length(sB4), 1)*NaN];
            
            if (exist(matfile, 'file'))
                save(matfile, 'sF1', 'sF2', 'sF3', 'sF4', 'sB1', 'sB2', 'sB3', 'sB4', '-append');
                save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append');
            else
                save(matfile, 'sF1', 'sF2', 'sF3', 'sF4', 'sB1', 'sB2', 'sB3', 'sB4');
                save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append');
            end                
            
            if (use_alt_file)
                delete(snackwavfile);
            end
            
    % F1, F2, F3, F4 (Praat)
        elseif (strcmp(paramlist{n}, 'F1, F2, F3, F4 (Praat)'))
            messages{k} = [messages{k} 'FMTp '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow; 
                        
            [pF1, pF2, pF3, pF4, pB1, pB2, pB3, pB4, err] = ...
                func_PraatFormants(wavfile, windowsize/1000, frameshift/1000, frame_precision, data_len);
            
            if (strcmp(VSData.vars.FMTalgorithm, 'F1, F2, F3, F4 (Praat)') && err ~= 0)
                messages{k+1} = 'Error: Problem with Praat - please check settings';
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
                set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                set(MBoxHandles.pushbutton_stop, 'Enable', 'off');
                
                msgbox({'Error: Unable to proceed.', 'Problem with Praat - please check settings'}, 'Error', 'error', 'modal');
                if (resampled) % delete the temporary file if it exists
                    delete(wavfile);
                end
                
                return;
            end
            
            if (exist(matfile, 'file'))
                save(matfile, 'pF1', 'pF2', 'pF3', 'pF4', 'pB1', 'pB2', 'pB3', 'pB4', '-append');
                save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append');
            else
                save(matfile, 'pF1', 'pF2', 'pF3', 'pF4', 'pB1', 'pB2', 'pB3', 'pB4');
                save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append');
            end                
                                    
    % F1, F2, F3, F4 (Other)
        elseif (strcmp(paramlist{n}, 'F1, F2, F3, F4 (Other)'))
            messages{k} = [messages{k} 'oFMTs '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow; 
                        
            oF1 = zeros(data_len, 1) * NaN; % allocate some memory
            oF2 = zeros(data_len, 1) * NaN;
            oF3 = zeros(data_len, 1) * NaN;
            oF4 = zeros(data_len, 1) * NaN;
            oB1 = zeros(data_len, 1) * NaN; 
            oB2 = zeros(data_len, 1) * NaN;
            oB3 = zeros(data_len, 1) * NaN;
            oB4 = zeros(data_len, 1) * NaN;
            
            err = 0;
            try 
                [F1, F2, F3, F4, B1, B2, B3, B4, errmsg] = func_OtherFormants(wavfile, handles);
            catch
                err = 1;
            end
           
            if ((length(F1) == 1 && isnan(F1)) || isempty(F1))
                err = 1;
            end
                        
            if (err == 1)
                messages{k} = [messages{k} '-error: ' errmsg];
                set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
                
                if (strcmp(VSData.vars.FMTalgorithm, 'F1, F2, F3, F4 (Other)'))
                    set(MBoxHandles.pushbutton_close, 'Enable', 'on');
                    set(MBoxHandles.pushbutton_stop, 'Enable', 'off');
                
                    msgbox({'Error: Unable to proceed.', 'Problem with formant tracker - please check settings'}, 'Error', 'error', 'modal');
                    if (resampled) % delete the temporary file if it exists
                        delete(wavfile);
                    end
                
                    return;
                end
            end

            % build up the actual vector
            if (VSData.vars.FormantsOtherOffset + length(F1) <= data_len)
                oF1(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(F1)) = F1;
                oF2(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(F2)) = F2;
                oF3(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(F3)) = F3;
                oF4(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(F4)) = F4;
                oB1(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(B1)) = B1;
                oB2(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(B2)) = B2;
                oB3(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(B3)) = B3;
                oB4(VSData.vars.FormantsOtherOffset+1:VSData.vars.FormantsOtherOffset + length(B4)) = B4;
            else  % need to trim 
                oF1(VSData.vars.FormantsOtherOffset+1:end) = F1(1:data_len - VSData.vars.FormantsOtherOffset);
                oF2(VSData.vars.FormantsOtherOffset+1:end) = F2(1:data_len - VSData.vars.FormantsOtherOffset);
                oF3(VSData.vars.FormantsOtherOffset+1:end) = F3(1:data_len - VSData.vars.FormantsOtherOffset);
                oF4(VSData.vars.FormantsOtherOffset+1:end) = F4(1:data_len - VSData.vars.FormantsOtherOffset);
                oB1(VSData.vars.FormantsOtherOffset+1:end) = B1(1:data_len - VSData.vars.FormantsOtherOffset);
                oB2(VSData.vars.FormantsOtherOffset+1:end) = B2(1:data_len - VSData.vars.FormantsOtherOffset);
                oB3(VSData.vars.FormantsOtherOffset+1:end) = B3(1:data_len - VSData.vars.FormantsOtherOffset);
                oB4(VSData.vars.FormantsOtherOffset+1:end) = B4(1:data_len - VSData.vars.FormantsOtherOffset);
            end
                        
            if (exist(matfile, 'file'))
                save(matfile, 'oF1', 'oF2', 'oF3', 'oF4', 'oB1', 'oB2', 'oB3', 'oB4', '-append');
            else
                save(matfile, 'oF1', 'oF2', 'oF3', 'oF4', 'oB1', 'oB2', 'oB3', 'oB4');
            end                
            
            
            
    % H1, H2, H4    
        elseif (strcmp(paramlist{n}, 'H1, H2, H4'))
            messages{k} = [messages{k} 'Hx '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
            
            F0 = func_parseF0(matdata, F0algorithm);
            
            if (useTextgrid)
                [H1, H2, H4, isComplete] = func_GetH1_H2_H4(y, Fs, F0, MBoxHandles, VSData.vars, textgridfile);
            else
                [H1, H2, H4, isComplete] = func_GetH1_H2_H4(y, Fs, F0, MBoxHandles, VSData.vars);
            end
                    
            HF0algorithm = F0algorithm;
            
            % check if the process was completed
            if (isComplete==0)
                messages{k+1} = 'Stop button pressed by user.';
                if (ishandle(MBoxHandles.figure_MessageBox))
                    set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
                end
                if (resampled) % delete the temporary file if it exists
                    delete(wavfile);
                end

                return;
            end
                
            if (exist(matfile, 'file'))
                save(matfile, 'H1', 'H2', 'H4', 'HF0algorithm', '-append');    
            else
                save(matfile, 'H1', 'H2', 'H4', 'HF0algorithm');
            end
            
                        
                      
    % A1, A2, A3
        elseif (strcmp(paramlist{n}, 'A1, A2, A3'))
            messages{k} = [messages{k} 'Ax '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);  % file has to exist at this point - dependency checking should make sure of this
                        
            F0 = func_parseF0(matdata, F0algorithm);
            [F1, F2, F3] = func_parseFMT(matdata, FMTalgorithm);

            if (useTextgrid)
                [A1, A2, A3] = func_GetA1A2A3(y, Fs, F0, F1, F2, F3, VSData.vars, textgridfile);
            else
                [A1, A2, A3] = func_GetA1A2A3(y, Fs, F0, F1, F2, F3, VSData.vars);
            end
                        
            AFMTalgorithm = FMTalgorithm;
            
            save(matfile, 'A1', 'A2', 'A3', 'AFMTalgorithm', '-append');
            
            
    % H1*-H2* and H2*-H4*
        elseif (strcmp(paramlist{n}, 'H1*-H2*, H2*-H4*'))
            messages{k} = [messages{k} 'H1H2c H2H4c '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;

            matdata = load(matfile);
            F0 = func_parseF0(matdata, F0algorithm);
            [F1, F2, F3] = func_parseFMT(matdata, FMTalgorithm);
            
            [H1H2c, H2H4c] = func_GetH1H2_H2H4(matdata.H1, matdata.H2, matdata.H4, Fs, F0, F1, F2);            
            save(matfile, 'H1H2c', 'H2H4c', '-append');
            
            
    % H1*-A1*, H1*-A2*, and H1*-A3*
        elseif (strcmp(paramlist{n}, 'H1*-A1*, H1*-A2*, H1*-A3*'))
            messages{k} = [messages{k} 'H1A1c H1A2c H1A3c '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
            F0 = func_parseF0(matdata, F0algorithm);
            [F1, F2, F3] = func_parseFMT(matdata, FMTalgorithm);           
            
            [H1A1c, H1A2c, H1A3c] = func_GetH1A1_H1A2_H1A3(matdata.H1, matdata.A1, matdata.A2, matdata.A3, Fs, F0, F1, F2, F3);
            save(matfile, 'H1A1c', 'H1A2c', 'H1A3c', '-append');
                        
            
    % Energy
        elseif (strcmp(paramlist{n}, 'Energy'))
            messages{k} = [messages{k} 'E '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
            F0 = func_parseF0(matdata, F0algorithm);
            
            Energy = func_GetEnergy(y, F0, Fs, VSData.vars);
            save(matfile, 'Energy', '-append');
            
            
    % CPP
        elseif (strcmp(paramlist{n}, 'CPP'))
            messages{k} = [messages{k} 'CPP '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
            F0 = func_parseF0(matdata, F0algorithm);
           
            CPP = func_GetCPP(y, Fs, F0, VSData.vars);          
            save(matfile, 'CPP', '-append');
       
    
    % HNR
        elseif (strcmp(paramlist{n}, 'Harmonic to Noise Ratios - HNR'))
            messages{k} = [messages{k} 'HNR '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
            F0 = func_parseF0(matdata, F0algorithm);
           
            [HNR05, HNR15, HNR25, HNR35] = func_GetHNR(y, Fs, F0, VSData.vars);          
            save(matfile, 'HNR05', 'HNR15', 'HNR25', 'HNR35', '-append');
            
        
    % SHR
        elseif (strcmp(paramlist{n}, 'Subharmonic to Harmonic Ratio - SHR'))
            messages{k} = [messages{k} 'SHR '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            drawnow;
            
            matdata = load(matfile);
           
            [SHR, shrF0] = func_GetSHRP(y, Fs, VSData.vars, data_len);          
            save(matfile, 'SHR', '-append');
        end
        
    end
    
    if (resampled) % delete the temporary file if it exists
        delete(wavfile);
    end
    
end

messages{length(filelist)+1} = 'Processing complete.';
set(MBoxHandles.listbox_messages, 'String', messages, 'Value', length(filelist)+1);
set(MBoxHandles.pushbutton_close, 'Enable', 'on');
set(MBoxHandles.pushbutton_stop, 'Enable', 'off');


% Function to generate random file names
function filename = generateRandomFile(fname, handles)
VSData = guidata(handles.VSHandle);
N = 8;  % this many random digits/characters    
[pathstr, name, ext] = fileparts(fname);
randstr = '00000000';

isok = 0;

while(isok == 0)
    for k=1:N
        randstr(k) = floor(rand() * 25) + 65;
    end
    filename = [pathstr VSData.vars.dirdelimiter 'tmp_' name randstr ext];
    
    if (exist(filename, 'file') == 0)
        isok = 1;
    end
end


% --- Executes when user attempts to close figure_ParameterEstimation.
function figure_ParameterEstimation_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_ParameterEstimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if (isfield(handles, 'SWfig'))
    delete(handles.SWfig);
end

VSData = guidata(handles.VSHandle);
VSData.vars.PE_showwaveforms = 0;
guidata(handles.VSHandle, VSData);

delete(hObject);


