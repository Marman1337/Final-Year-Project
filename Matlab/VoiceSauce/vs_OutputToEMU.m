function varargout = vs_OutputToEMU(varargin)
% VS_OUTPUTTOEMU M-file for vs_OutputToEMU.fig
%      VS_OUTPUTTOEMU, by itself, creates a new VS_OUTPUTTOEMU or raises the existing
%      singleton*.
%
%      H = VS_OUTPUTTOEMU returns the handle to a new VS_OUTPUTTOEMU or the handle to
%      the existing singleton*.
%
%      VS_OUTPUTTOEMU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_OUTPUTTOEMU.M with the given input arguments.
%
%      VS_OUTPUTTOEMU('Property','Value',...) creates a new VS_OUTPUTTOEMU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_OutputToEMU_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_OutputToEMU_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_OutputToEMU

% Last Modified by GUIDE v2.5 15-Oct-2009 12:44:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_OutputToEMU_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_OutputToEMU_OutputFcn, ...
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


% --- Executes just before vs_OutputToEMU is made visible.
function vs_OutputToEMU_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_OutputToEMU (see VARARGIN)

% Choose default command line output for vs_OutputToEMU
handles.output = hObject;

% YS: get the settings from the main figure
if (~isfield(handles, 'VSHandle'))
    VSHandle = VoiceSauce;  
    handles.VSHandle = VSHandle;
end

% Update handles structure
guidata(hObject, handles);

VSData = guidata(handles.VSHandle);
set(handles.edit_matdir, 'String', VSData.vars.OTE_matdir);
set(handles.edit_outputdir, 'String', VSData.vars.OTE_outputdir);

if (VSData.vars.recursedir)
    func_setlistbox(handles.listbox_matfilelist, VSData.vars.OTE_matdir, 'recurse', VSData.vars, '*.mat');
else
    func_setlistbox(handles.listbox_matfilelist, VSData.vars.OTE_matdir, 'none', VSData.vars, '*.mat');
end    

paramlist = func_getoutputparameterlist();

% default is everything selected
if (isempty(VSData.vars.OTE_paramselection))
    VSData.vars.OTE_paramselection = 1:length(paramlist);
    guidata(handles.VSHandle, VSData);
end

set(handles.listbox_paramlist, 'String', paramlist, 'Value', VSData.vars.OTE_paramselection);

set(handles.checkbox_saveEMUwithmat, 'Value', VSData.vars.OTE_saveEMUwithmat);

if (VSData.vars.OTE_saveEMUwithmat)
    set(handles.edit_outputdir, 'Enable', 'Off');
    set(handles.pushbutton_outputdir_browse, 'Enable', 'Off');
else
    set(handles.edit_outputdir, 'Enable', 'On');
    set(handles.pushbutton_outputdir_browse, 'Enable', 'On');
end    

set(handles.listbox_matfilelist, 'KeyPressFcn', @filelist_listbox_KeyPressFcn);



% UIWAIT makes vs_OutputToEMU wait for user response (see UIRESUME)
% uiwait(handles.figure_OutputToEMU);


% --- Outputs from this function are returned to the command line.
function varargout = vs_OutputToEMU_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_matdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_matdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = get(handles.edit_matdir, 'String');
VSData = guidata(handles.VSHandle);

if (exist(new_dir, 'dir') == 7)
    VSData = func_setmatdir('OTE_matdir', new_dir, VSData);
    set(handles.edit_matdir, 'String', new_dir);
    
    if (VSData.vars.recursedir)
        func_setlistbox(handles.listbox_matfilelist, VSData.vars.OTE_matdir, 'recurse', VSData.vars, '*.mat');
    else
        func_setlistbox(handles.listbox_matfilelist, VSData.vars.OTE_matdir, 'none', VSData.vars, '*.mat');
    end

    if (VSData.vars.OTE_saveEMUwithmat)
        set(handles.edit_outputdir, 'String', new_dir);
        VSData.vars.OTE_outputdir = new_dir;
    end
    
    guidata(handles.VSHandle, VSData);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.OTE_matdir);
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
    VSData = func_setmatdir('OTE_matdir', new_dir, VSData);
    set(handles.edit_matdir, 'String', new_dir);
    
    if (VSData.vars.recursedir)
        func_setlistbox(handles.listbox_matfilelist, VSData.vars.OTE_matdir, 'recurse', VSData.vars, '*.mat');
    else
        func_setlistbox(handles.listbox_matfilelist, VSData.vars.OTE_matdir, 'none', VSData.vars, '*.mat');
    end

    if (VSData.vars.OTE_saveEMUwithmat)
        set(handles.edit_outputdir, 'String', new_dir);
        VSData.vars.OTE_outputdir = new_dir;
    end
    
    guidata(handles.VSHandle, VSData);
end



% --- Executes on selection change in listbox_matfilelist.
function listbox_matfilelist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_matfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_matfilelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_matfilelist


% --- Executes during object creation, after setting all properties.
function listbox_matfilelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_matfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_paramlist.
function listbox_paramlist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

inx = get(hObject, 'Value');
VSData.vars.OTE_paramselection = setxor(VSData.vars.OTE_paramselection, inx);
set(hObject, 'Value', [VSData.vars.OTE_paramselection]);
guidata(handles.VSHandle, VSData);


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



function edit_outputdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_dir = get(handles.edit_outputdir, 'String');
VSData = guidata(handles.VSHandle);

if (exist(new_dir, 'dir') == 7)
    VSData.vars.OTE_outputdir = new_dir;
    set(handles.edit_outputdir, 'String', new_dir);        
    guidata(handles.VSHandle, VSData);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
end

% --- Executes during object creation, after setting all properties.
function edit_outputdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_outputdir_browse.
function pushbutton_outputdir_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outputdir_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = get(handles.edit_outputdir, 'String');
new_dir = uigetdir(current_dir);
VSData = guidata(handles.VSHandle);

if (ischar(new_dir))
    VSData.vars.OTE_outputdir = new_dir;
    set(handles.edit_outputdir, 'String', new_dir);
        
    guidata(handles.VSHandle, VSData);
end


% --- Executes on button press in togglebutton_start.
function togglebutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
matfilelist = get(handles.listbox_matfilelist, 'String');
if (isempty(matfilelist))
    msgbox('Error: no mat files found.', 'Error', 'error', 'modal');
    return;
end

if (isempty(VSData.vars.OTE_paramselection))
    msgbox('Error: no parameters selected.', 'Error', 'error', 'modal');
    return;
end

if (get(hObject, 'Value') == 1) % start the process
    set(hObject, 'String', 'Processing...', 'ForegroundColor', 'red');
    
    WriteEMUfiles(handles);
    
    set(hObject, 'String', 'Start!', 'ForegroundColor', 'black', 'Value', 0);
end




function filelist_listbox_KeyPressFcn(hObject, eventdata)
handles = guidata(hObject);

key = double(get(gcbf, 'CurrentCharacter'));
if (gcbo == handles.listbox_matfilelist)
    if (key == 127) % delete key

        inx = get(handles.listbox_matfilelist, 'Value');
        contents = get(handles.listbox_matfilelist, 'String');
        
        %nothing to do
        if (isempty(contents))
            return;
        end
        
        newinx = setxor(inx, [1:length(contents)]);

        newcontents = contents(newinx);
        set(handles.listbox_matfilelist, 'String', newcontents);
        
        if (inx(end) > length(newcontents))
            set(handles.listbox_matfilelist, 'Value', length(newcontents));
        else
            set(handles.listbox_matfilelist, 'Value', inx(end));
        end
    end
end


% --- Executes on button press in checkbox_saveEMUwithmat.
function checkbox_saveEMUwithmat_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveEMUwithmat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveEMUwithmat
VSData = guidata(handles.VSHandle);
VSData.vars.OTE_saveEMUwithmat = get(hObject, 'Value');

if (VSData.vars.OTE_saveEMUwithmat)
    set(handles.edit_outputdir, 'Enable', 'Off');
    set(handles.pushbutton_outputdir_browse, 'Enable', 'Off');

    set(handles.edit_outputdir, 'String', VSData.vars.OTE_matdir);
    VSData.vars.OTE_outputdir = VSData.vars.OTE_matdir;
    
else
    set(handles.edit_outputdir, 'Enable', 'On');
    set(handles.pushbutton_outputdir_browse, 'Enable', 'On');
end    

guidata(handles.VSHandle, VSData);


% -- main outputting function
function WriteEMUfiles(handles)

VSData = guidata(handles.VSHandle);
MBox = MessageBox;
MBoxHandles = guidata(MBox);

matfilelist = get(handles.listbox_matfilelist, 'String');
messages = cell(length(matfilelist) + 1, 1);

paramlist = get(handles.listbox_paramlist, 'String');
params = paramlist(VSData.vars.OTE_paramselection);

errcnt = 0;

for k=1:length(matfilelist)
    messages{k} = sprintf('%d/%d. %s: ', k, length(matfilelist), matfilelist{k});
    set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
    set(handles.listbox_matfilelist, 'Value', k);
    drawnow;
    
    matfile = [VSData.vars.OTE_matdir VSData.vars.dirdelimiter matfilelist{k}];
    mdata = func_buildMData(matfile, VSData.vars.O_smoothwinsize);
    
    for n=1:length(params)
        C = textscan(params{n}, '%s %s', 'delimiter', '(');
        param = C{2}{1}(1:end-1);
        
        if (~isfield(mdata, param))
            messages{k} = [messages{k} param ' not found, '];
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
            set(handles.listbox_matfilelist, 'Value', k);
            drawnow;
            errcnt = errcnt + 1;
            continue;
        end
        
        messages{k} = [messages{k} param ', '];
        set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
        set(handles.listbox_matfilelist, 'Value', k);
        drawnow;
        
        outfile = [VSData.vars.OTE_outputdir VSData.vars.dirdelimiter matfilelist{k}(1:end-3) param];
        
        % check that the outputdir exists
        pathname = fileparts(outfile);
        if (exist(pathname, 'dir') ~= 7)
            mkdir(pathname);
        end
                
        func_VS2ssff(mdata.(param), param, outfile, VSData.vars);
        
        % check if user has requested a halt
        if (get(MBoxHandles.figure_MessageBox, 'UserData') == 1)
            messages{k+1} = 'Stop button pressed.';
            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k+1);
            break;
        end
        
    end
    
    if (get(MBoxHandles.figure_MessageBox, 'UserData') == 1)
        break;
    end 
    
end

messages{length(matfilelist)+1} = sprintf('Completed. %d errors found.', errcnt);
set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
set(handles.listbox_matfilelist, 'Value', k);
drawnow;

set(MBoxHandles.pushbutton_close, 'Enable', 'On');
set(MBoxHandles.pushbutton_stop, 'Enable', 'Off');