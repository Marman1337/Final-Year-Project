function varargout = vs_OutputToText(varargin)
% VS_OUTPUTTOTEXT M-file for vs_OutputToText.fig
%      VS_OUTPUTTOTEXT, by itself, creates a new VS_OUTPUTTOTEXT or raises
%      the existing
%      singleton*.
%
%      H = VS_OUTPUTTOTEXT returns the handle to a new VS_OUTPUTTOTEXT or the handle to
%      the existing singleton*.
%
%      VS_OUTPUTTOTEXT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VS_OUTPUTTOTEXT.M with the given input arguments.
%
%      VS_OUTPUTTOTEXT('Property','Value',...) creates a new VS_OUTPUTTOTEXT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vs_OutputToText_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vs_OutputToText_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vs_OutputToText

% Last Modified by GUIDE v2.5 08-Oct-2009 00:50:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vs_OutputToText_OpeningFcn, ...
                   'gui_OutputFcn',  @vs_OutputToText_OutputFcn, ...
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


% --- Executes just before vs_OutputToText is made visible.
function vs_OutputToText_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vs_OutputToText (see VARARGIN)

% Choose default command line output for vs_OutputToText
handles.output = hObject;

if (~isfield(handles, 'VSHandle'))
    VSHandle = VoiceSauce;
    handles.VSHandle = VSHandle;
end

% restore the variables from initialization
setGUIVariables(handles);

set(handles.uipanel_Segments,'SelectionChangeFcn',@segments_buttongroup_SelectionChangeFcn);
set(handles.uipanel_OutputOptions,'SelectionChangeFcn',@outputoptions_buttongroup_SelectionChangeFcn);
set(handles.listbox_Parameters_matfilelist, 'KeyPressFcn', @matfiles_listbox_KeyPressFcn);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vs_OutputToText wait for user response (see UIRESUME)
% uiwait(handles.figure_OutputToText);


% --- Outputs from this function are returned to the command line.
function varargout = vs_OutputToText_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function setGUIVariables(handles)
VSData = guidata(handles.VSHandle);
vars = VSData.vars;

paramlist = func_getoutputparameterlist();
set(handles.listbox_Parameters_paramlist, 'String', paramlist);

% update output file names
VSData.vars.OT_Single = [vars.OT_outputdir vars.dirdelimiter vars.OT_singleFilename];
VSData.vars.OT_F0CPPE = [vars.OT_outputdir vars.dirdelimiter vars.OT_F0CPPEfilename];
VSData.vars.OT_Formants = [vars.OT_outputdir vars.dirdelimiter vars.OT_Formantsfilename];
VSData.vars.OT_HA = [vars.OT_outputdir vars.dirdelimiter vars.OT_Hx_Axfilename];
VSData.vars.OT_HxHx = [vars.OT_outputdir vars.dirdelimiter vars.OT_HxHxfilename];
VSData.vars.OT_HxAx = [vars.OT_outputdir vars.dirdelimiter vars.OT_HxAxfilename];
VSData.vars.OT_EGG = [vars.OT_outputdir vars.dirdelimiter vars.OT_EGGfilename];
guidata(handles.VSHandle, VSData);
VSData = guidata(handles.VSHandle);
vars = VSData.vars;

% default is everything selected
if (isempty(vars.OT_selectedParams))
    vars.OT_selectedParams = 1:length(paramlist);
    VSData.vars = vars;
    guidata(handles.VSHandle, VSData);
end

set(handles.listbox_Parameters_paramlist, 'Value', vars.OT_selectedParams);
set(handles.edit_Parameters_num, 'String', num2str(sum(vars.OT_selectedParams > 0)));

set(handles.edit_Parameters_matdir, 'String', vars.OT_matdir);
set(handles.checkbox_Parameters_includesubdir, 'Value', vars.OT_includesubdir);

if (vars.OT_includesubdir == 1)
    func_setlistbox(handles.listbox_Parameters_matfilelist, vars.OT_matdir, 'recurse', vars, '*.mat');
else
    func_setlistbox(handles.listbox_Parameters_matfilelist, vars.OT_matdir, 'none', vars, '*.mat');
end

set(handles.edit_Parameters_Textgriddir, 'String', vars.OT_Textgriddir);
set(handles.checkbox_Parameters_includeEGG, 'Value', vars.OT_includeEGG);

if (vars.OT_includeEGG == 1)
    set(handles.edit_Parameters_EGGdir, 'Enable', 'On');
    set(handles.pushbutton_Parameters_outBrowse, 'Enable', 'On');
end

set(handles.edit_Parameters_EGGdir, 'String', vars.OT_EGGdir);
set(handles.edit_Parameters_outdir, 'String', vars.OT_outputdir);

set(handles.checkbox_Parameters_includeTextgrids, 'Value', vars.OT_includeTextgridLabels);
set(handles.popupmenu_Parameters_delimiter, 'Value', vars.OT_columndelimiter);

set(handles.radiobutton_noSegments, 'Value', vars.OT_noSegments);
set(handles.radiobutton_useSegments, 'Value', vars.OT_useSegments);

if (vars.OT_useSegments == 1)
    set(handles.edit_numSegments, 'String', num2str(vars.OT_numSegments));
    set(handles.edit_numSegments, 'Enable', 'On');
end

set(handles.radiobutton_Singlefile, 'Value', vars.OT_singleFile);
set(handles.radiobutton_Multiplefiles, 'value', vars.OT_multipleFiles);

set(handles.edit_OutputOptions_SingleFile, 'String', vars.OT_Single);
set(handles.edit_OutputOptions_F0CPPE, 'String', vars.OT_F0CPPE);
set(handles.edit_OutputOptions_Formants, 'String', vars.OT_Formants);
set(handles.edit_OutputOptions_Hx_Ax, 'String', vars.OT_HA);
set(handles.edit_OutputOptions_HxHx, 'String', vars.OT_HxHx);
set(handles.edit_OutputOptions_HxAx, 'String', vars.OT_HxAx);
set(handles.edit_OutputOptions_EGG, 'String', vars.OT_EGG);

if (vars.OT_multipleFiles == 1)
    set(handles.edit_OutputOptions_SingleFile, 'Enable', 'Off');
    set(handles.pushbutton_OutputOptions_SingleBrowse, 'Enable', 'Off');
    
    set(handles.edit_OutputOptions_F0CPPE, 'Enable', 'On');
    set(handles.edit_OutputOptions_Formants, 'Enable', 'On');
    set(handles.edit_OutputOptions_Hx_Ax, 'Enable', 'On');
    set(handles.edit_OutputOptions_HxHx, 'Enable', 'On');
    set(handles.edit_OutputOptions_HxAx, 'Enable', 'On');
    set(handles.edit_OutputOptions_EGG, 'Enable', 'On');
    
    set(handles.pushbutton_OO_F0CPPEBrowse, 'Enable', 'On');
    set(handles.pushbutton_OO_FormantsBrowse, 'Enable', 'On');
    set(handles.pushbutton_OO_Hx_AxBrowse, 'Enable', 'On');
    set(handles.pushbutton_OO_HxHxBrowse, 'Enable', 'On');
    set(handles.pushbutton_OO_HxAxBrowse', 'Enable', 'On');
    set(handles.pushbutton_OO_EGGBrowse', 'Enable', 'On');
end


% --- Executes on selection change in listbox_Parameters_paramlist.
function listbox_Parameters_paramlist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Parameters_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
inx = get(hObject, 'Value');

% now add the new entries and remove the old ones which are already
% selected
VSData.vars.OT_selectedParams = setxor(VSData.vars.OT_selectedParams, inx);
set(hObject, 'Value', VSData.vars.OT_selectedParams);
guidata(handles.VSHandle, VSData);
set(handles.edit_Parameters_num, 'String', num2str(sum(VSData.vars.OT_selectedParams > 0)));


% Hints: contents = get(hObject,'String') returns listbox_Parameters_paramlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Parameters_paramlist


% --- Executes during object creation, after setting all properties.
function listbox_Parameters_paramlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Parameters_paramlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Parameters_num_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Parameters_num as text
%        str2double(get(hObject,'String')) returns contents of edit_Parameters_num as a double


% --- Executes during object creation, after setting all properties.
function edit_Parameters_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Parameters_outdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_outdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Parameters_outdir as text
%        str2double(get(hObject,'String')) returns contents of edit_Parameters_outdir as a double
VSData = guidata(handles.VSHandle);
newdir = get(hObject, 'String');
if (exist(newdir, 'dir') == 7)  % new dir exists
    if (newdir(end) ~= VSData.vars.dirdelimiter)
        newdir(end + 1) = VSData.vars.dirdelimiter;
    end
    VSData.vars.OT_outputdir = newdir;
    updateOutputFiles(handles);
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.OT_outputdir);
end
guidata(handles.VSHandle, VSData);


% update the filenames in Output Options
function updateOutputFiles(handles)
VSData = guidata(handles.VSHandle);

VSData.vars.OT_Single = [VSData.vars.OT_outputdir VSData.vars.OT_singleFilename];
VSData.vars.OT_F0CPPE = [VSData.vars.OT_outputdir VSData.vars.OT_F0CPPEfilename];
VSData.vars.OT_Formants = [VSData.vars.OT_outputdir VSData.vars.OT_Formantsfilename];
VSData.vars.OT_HA = [VSData.vars.OT_outputdir VSData.vars.OT_Hx_Axfilename];
VSData.vars.OT_HxHx = [VSData.vars.OT_outputdir VSData.vars.OT_HxHxfilename];
VSData.vars.OT_HxAx = [VSData.vars.OT_outputdir VSData.vars.OT_HxAxfilename];
VSData.vars.OT_EGG = [VSData.vars.OT_outputdir VSData.vars.OT_EGGfilename];

set(handles.edit_OutputOptions_SingleFile, 'String', VSData.vars.OT_Single);
set(handles.edit_OutputOptions_F0CPPE, 'String', VSData.vars.OT_F0CPPE);
set(handles.edit_OutputOptions_Formants, 'String', VSData.vars.OT_Formants);
set(handles.edit_OutputOptions_Hx_Ax, 'String', VSData.vars.OT_HA);
set(handles.edit_OutputOptions_HxHx, 'String', VSData.vars.OT_HxHx);
set(handles.edit_OutputOptions_HxAx, 'String', VSData.vars.OT_HxAx);
set(handles.edit_OutputOptions_EGG, 'String', VSData.vars.OT_EGG);
set(handles.edit_Parameters_outdir, 'String', VSData.vars.OT_outputdir);
set(handles.edit_Parameters_EGGdir, 'String', VSData.vars.OT_EGGdir);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Parameters_outdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_outdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Parameters_outBrowse.
function pushbutton_Parameters_outBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Parameters_outBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
newdir = uigetdir(VSData.vars.OT_outputdir);
if (ischar(newdir) == 1)
    VSData.vars.OT_outputdir = [newdir VSData.vars.dirdelimiter];
    set(handles.edit_Parameters_outdir, 'String', VSData.vars.OT_outputdir);
    guidata(handles.VSHandle, VSData);
    updateOutputFiles(handles);
end


% --- Executes on selection change in popupmenu_Parameters_delimiter.
function popupmenu_Parameters_delimiter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_Parameters_delimiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_Parameters_delimiter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_Parameters_delimiter
VSData = guidata(handles.VSHandle);
VSData.vars.OT_columndelimiter = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function popupmenu_Parameters_delimiter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_Parameters_delimiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_Parameters_includeEGG.
function checkbox_Parameters_includeEGG_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Parameters_includeEGG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);

if (get(hObject, 'Value') == 1)
    set(handles.edit_Parameters_EGGdir, 'Enable', 'On');
    set(handles.pushbutton_Parameters_EGGBrowse, 'Enable', 'On');
    VSData.vars.OT_includeEGG = 1;
else
    set(handles.edit_Parameters_EGGdir, 'Enable', 'Off');
    set(handles.pushbutton_Parameters_EGGBrowse, 'Enable', 'Off');
    VSData.vars.OT_includeEGG = 0;    
end
guidata(handles.VSHandle, VSData);


function edit_Parameters_matdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_matdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Parameters_matdir as text
%        str2double(get(hObject,'String')) returns contents of edit_Parameters_matdir as a double
VSData = guidata(handles.VSHandle);
newdir = get(hObject, 'String');
if (exist(newdir, 'dir') == 7)  % new dir exists
    VSData = func_setmatdir('OT_matdir', newdir, VSData);
    set(handles.edit_Parameters_Textgriddir, 'String', newdir);
    
    if (newdir(end) ~= VSData.vars.dirdelimiter)
        newdir(end + 1) = VSData.vars.dirdelimiter;
    end
    VSData.vars.OT_outputdir = newdir;
    guidata(handles.VSHandle, VSData);
    updateOutputFiles(handles);    
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.OT_matdir);
end
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Parameters_matdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_matdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Parameters_matBrowse.
function pushbutton_Parameters_matBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Parameters_matBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
newdir = uigetdir(VSData.vars.OT_matdir);
if (ischar(newdir) == 1)
    VSData = func_setmatdir('OT_matdir', newdir, VSData);
    set(handles.edit_Parameters_matdir, 'String', newdir);
    set(handles.edit_Parameters_Textgriddir, 'String', newdir);

    if (newdir(end) ~= VSData.vars.dirdelimiter)
        newdir(end + 1) = VSData.vars.dirdelimiter;
    end
    VSData.vars.OT_outputdir = newdir;
    guidata(handles.VSHandle, VSData);
    updateOutputFiles(handles);    
    
    if (get(handles.checkbox_Parameters_includesubdir, 'Value') == 1)       
        func_setlistbox(handles.listbox_Parameters_matfilelist, VSData.vars.OT_matdir, 'recurse', VSData.vars, '*.mat');
    else
        func_setlistbox(handles.listbox_Parameters_matfilelist, VSData.vars.OT_matdir, 'none', VSData.vars, '*.mat');
    end
    guidata(handles.VSHandle, VSData);
end



function edit_Parameters_Textgriddir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_Textgriddir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Parameters_Textgriddir as text
%        str2double(get(hObject,'String')) returns contents of edit_Parameters_Textgriddir as a double
VSData = guidata(handles.VSHandle);
newdir = get(hObject, 'String');
if (exist(newdir, 'dir') == 7)  % new dir exists
    VSData.vars.OT_Textgriddir = newdir;
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.OT_Textgriddir);
end
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Parameters_Textgriddir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_Textgriddir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Parameters_TextgridBrowse.
function pushbutton_Parameters_TextgridBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Parameters_TextgridBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
newdir = uigetdir(VSData.vars.OT_Textgriddir);
if (ischar(newdir) == 1)
    VSData.vars.OT_Textgriddir = newdir;
    set(handles.edit_Parameters_Textgriddir, 'String', newdir);   
    guidata(handles.VSHandle, VSData);
end


function edit_Parameters_EGGdir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_EGGdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Parameters_EGGdir as text
%        str2double(get(hObject,'String')) returns contents of edit_Parameters_EGGdir as a double
VSData = guidata(handles.VSHandle);
newdir = get(hObject, 'String');
if (exist(newdir, 'dir') == 7)  % new dir exists
    VSData.vars.OT_EGGdir = newdir;
else
    msgbox('Error: directory not found.', 'Error', 'error', 'modal');
    set(hObject, 'String', VSData.vars.OT_EGGdir);
end
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_Parameters_EGGdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Parameters_EGGdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Parameters_EGGBrowse.
function pushbutton_Parameters_EGGBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Parameters_EGGBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
newdir = uigetdir(VSData.vars.OT_EGGdir);
if (ischar(newdir) == 1)
    set(handles.edit_Parameters_EGGdir, 'String', newdir);       
    VSData.vars.OT_EGGdir = newdir;
    guidata(handles.VSHandle, VSData);
end


function edit_numSegments_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numSegments as text
%        str2double(get(hObject,'String')) returns contents of edit_numSegments as a double

VSData = guidata(handles.VSHandle);
num = str2double(get(hObject, 'String'));

if (~isnan(num))
    num = round(num);
    if (num < 1)
        num = 1;
    elseif (num > 999)
        num = 999;
    end

    VSData.vars.OT_numSegments = num;

    set(hObject, 'String', num2str(VSData.vars.OT_numSegments));
    guidata(handles.VSHandle, VSData);
else
    set(hObject, 'String', num2str(VSData.vars.OT_numSegments));
end


% --- Executes during object creation, after setting all properties.
function edit_numSegments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numSegments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_OutputOptions_SingleFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_SingleFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_singleFilename = [filename ext];
    VSData.vars.OT_Single = [pathname VSData.vars.dirdelimiter VSData.vars.OT_singleFilename];
end

set(hObject, 'String', VSData.vars.OT_Single);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_SingleFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_SingleFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OutputOptions_SingleBrowse.
function pushbutton_OutputOptions_SingleBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OutputOptions_SingleBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_singleFilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_SingleFile, 'String', [newpath newfile]);           
    VSData.vars.OT_Single = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end


function edit_OutputOptions_F0CPPE_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_F0CPPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_F0CPPEfilename = [filename ext];
    VSData.vars.OT_F0CPPE = [pathname VSData.vars.dirdelimiter VSData.vars.OT_F0CPPEfilename];
end

set(hObject, 'String', VSData.vars.OT_F0CPPE);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_F0CPPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_F0CPPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_OutputOptions_Formants_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_Formants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_Formantsfilename = [filename ext];
    VSData.vars.OT_Formants = [pathname VSData.vars.dirdelimiter VSData.vars.OT_Formantsfilename];
end

set(hObject, 'String', VSData.vars.OT_Formants);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_Formants_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_Formants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_OutputOptions_Hx_Ax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_Hx_Ax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_Hx_Axfilename = [filename ext];
    VSData.vars.OT_HA = [pathname VSData.vars.dirdelimiter VSData.vars.OT_Hx_Axfilename];
end

set(hObject, 'String', VSData.vars.OT_HA);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_Hx_Ax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_Hx_Ax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_OutputOptions_HxHx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_HxHx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_HxHxfilename = [filename ext];
    VSData.vars.OT_HxHx = [pathname VSData.vars.dirdelimiter VSData.vars.OT_HxHxfilename];
end

set(hObject, 'String', VSData.vars.OT_HxHx);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_HxHx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_HxHx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_OutputOptions_HxAx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_HxAx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_HxAxfilename = [filename ext];
    VSData.vars.OT_HxAx = [pathname VSData.vars.dirdelimiter VSData.vars.OT_HxAxfilename];
end

set(hObject, 'String', VSData.vars.OT_HxAx);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_HxAx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_HxAx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OO_F0CPPEBrowse.
function pushbutton_OO_F0CPPEBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OO_F0CPPEBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_F0CPPEfilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_F0CPPE, 'String', [newpath newfile]);
    VSData.vars.OT_F0CPPE = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end


% --- Executes on button press in pushbutton_OO_FormantsBrowse.
function pushbutton_OO_FormantsBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OO_FormantsBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_Formantsfilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_Formants, 'String', [newpath newfile]);   
    VSData.vars.OT_Formants = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end


% --- Executes on button press in pushbutton_OO_Hx_AxBrowse.
function pushbutton_OO_Hx_AxBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OO_Hx_AxBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_Hx_Axfilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_Hx_Ax, 'String', [newpath newfile]);   
    VSData.vars.OT_HA = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end


% --- Executes on button press in pushbutton_OO_HxHxBrowse.
function pushbutton_OO_HxHxBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OO_HxHxBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_HxHxfilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_HxHx, 'String', [newpath newfile]);   
    VSData.vars.OT_HxHx = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end


% --- Executes on button press in pushbutton_OO_HxAxBrowse.
function pushbutton_OO_HxAxBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OO_HxAxBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_HxAxfilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_HxAx, 'String', [newpath newfile]);
    VSData.vars.OT_HxAx = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end


function edit_OutputOptions_EGG_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_EGG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);

str = get(hObject, 'String');
[pathname, filename, ext] = fileparts(str);

if (exist(pathname, 'dir') == 7)
    VSData.vars.OT_EGGfilename = [filename ext];
    VSData.vars.OT_EGG = [pathname VSData.vars.dirdelimiter VSData.vars.OT_EGGfilename];
end

set(hObject, 'String', VSData.vars.OT_EGG);
guidata(handles.VSHandle, VSData);


% --- Executes during object creation, after setting all properties.
function edit_OutputOptions_EGG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutputOptions_EGG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OO_EGGBrowse.
function pushbutton_OO_EGGBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OO_EGGBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VSData = guidata(handles.VSHandle);
[newfile newpath] = uiputfile({'*.txt', '*.txt'}, 'Select Output File', VSData.vars.OT_EGGfilename);
if (ischar(newfile) == 1)
    set(handles.edit_OutputOptions_EGG, 'String', [newpath newfile]);   
    VSData.vars.OT_EGG = [newpath newfile];
    guidata(handles.VSHandle, VSData);
end

% --- Executes on button press in togglebutton_Start.
function togglebutton_Start_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_Start
if (get(hObject, 'Value') == 1) % start writing output
    set(hObject, 'String', 'Processing...', 'ForegroundColor', 'red');
    
    OutputToText(handles);
    set(hObject, 'String', 'Start!', 'ForegroundColor', 'black', 'Value', 0);
    
end
    



% --- Executes on button press in checkbox_Parameters_includeTextgrids.
function checkbox_Parameters_includeTextgrids_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Parameters_includeTextgrids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
VSData.vars.OT_includeTextgridLabels = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);



function segments_buttongroup_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);
VSData = guidata(handles.VSHandle);

switch (get(eventdata.NewValue, 'Tag'))
    case 'radiobutton_noSegments'
        VSData.vars.OT_noSegments = 1;
        VSData.vars.OT_useSegments = 0;
        set(handles.edit_numSegments, 'Enable', 'Off');
    case 'radiobutton_useSegments'
        VSData.vars.OT_noSegments = 0;
        VSData.vars.OT_useSegments = 1;
        set(handles.edit_numSegments, 'Enable', 'On');
end
guidata(handles.VSHandle, VSData);


%
function outputoptions_buttongroup_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);
VSData = guidata(handles.VSHandle);

switch (get(eventdata.NewValue, 'Tag'))
    case 'radiobutton_Singlefile'
        VSData.vars.OT_singleFile = 1;
        VSData.vars.OT_multipleFiles = 0;
        
        set(handles.edit_OutputOptions_SingleFile, 'Enable', 'On');
        set(handles.pushbutton_OutputOptions_SingleBrowse, 'Enable', 'On');

        set(handles.edit_OutputOptions_F0CPPE, 'Enable', 'Off');
        set(handles.edit_OutputOptions_Formants, 'Enable', 'Off');
        set(handles.edit_OutputOptions_Hx_Ax, 'Enable', 'Off');
        set(handles.edit_OutputOptions_HxHx, 'Enable', 'Off');
        set(handles.edit_OutputOptions_HxAx, 'Enable', 'Off');
        set(handles.edit_OutputOptions_EGG, 'Enable', 'Off');

        set(handles.pushbutton_OO_F0CPPEBrowse, 'Enable', 'Off');
        set(handles.pushbutton_OO_FormantsBrowse, 'Enable', 'Off');
        set(handles.pushbutton_OO_Hx_AxBrowse, 'Enable', 'Off');
        set(handles.pushbutton_OO_HxHxBrowse, 'Enable', 'Off');
        set(handles.pushbutton_OO_HxAxBrowse, 'Enable', 'Off');
        set(handles.pushbutton_OO_EGGBrowse, 'Enable', 'Off');
        
    case 'radiobutton_Multiplefiles'
        VSData.vars.OT_singleFile = 0;
        VSData.vars.OT_multipleFiles = 1;
        
        set(handles.edit_OutputOptions_SingleFile, 'Enable', 'Off');
        set(handles.pushbutton_OutputOptions_SingleBrowse, 'Enable', 'Off');

        set(handles.edit_OutputOptions_F0CPPE, 'Enable', 'On');
        set(handles.edit_OutputOptions_Formants, 'Enable', 'On');
        set(handles.edit_OutputOptions_Hx_Ax, 'Enable', 'On');
        set(handles.edit_OutputOptions_HxHx, 'Enable', 'On');
        set(handles.edit_OutputOptions_HxAx, 'Enable', 'On');
        set(handles.edit_OutputOptions_EGG, 'Enable', 'On');

        set(handles.pushbutton_OO_F0CPPEBrowse, 'Enable', 'On');
        set(handles.pushbutton_OO_FormantsBrowse, 'Enable', 'On');
        set(handles.pushbutton_OO_Hx_AxBrowse, 'Enable', 'On');
        set(handles.pushbutton_OO_HxHxBrowse, 'Enable', 'On');
        set(handles.pushbutton_OO_HxAxBrowse, 'Enable', 'On');
        set(handles.pushbutton_OO_EGGBrowse, 'Enable', 'On');
end
guidata(handles.VSHandle, VSData);


% --- Executes on selection change in listbox_Parameters_matfilelist.
function listbox_Parameters_matfilelist_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Parameters_matfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_Parameters_matfilelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Parameters_matfilelist


% --- Executes during object creation, after setting all properties.
function listbox_Parameters_matfilelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Parameters_matfilelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_Parameters_includesubdir.
function checkbox_Parameters_includesubdir_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Parameters_includesubdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

VSData = guidata(handles.VSHandle);
VSData.vars.OT_includesubdir = get(hObject, 'Value');
guidata(handles.VSHandle, VSData);
if (VSData.vars.OT_includesubdir == 1)
    func_setlistbox(handles.listbox_Parameters_matfilelist, VSData.vars.OT_matdir, 'recurse', VSData.vars, '*.mat');
else
    func_setlistbox(handles.listbox_Parameters_matfilelist, VSData.vars.OT_matdir, 'none', VSData.vars, '*.mat');
end



% executes on key press
function matfiles_listbox_KeyPressFcn(hObject, eventdata)
handles = guidata(hObject);

key = double(get(gcbf, 'CurrentCharacter'));
if (gcbo == handles.listbox_Parameters_matfilelist)
    if (key == 127) % delete key

        inx = get(handles.listbox_Parameters_matfilelist, 'Value');
        contents = get(handles.listbox_Parameters_matfilelist, 'String');
        
        %nothing to do
        if (isempty(contents))
            return;
        end
        
        newinx = setxor(inx, [1:length(contents)]);

        newcontents = contents(newinx);
        set(handles.listbox_Parameters_matfilelist, 'String', newcontents);
        
        if (inx(end) > length(newcontents))
            set(handles.listbox_Parameters_matfilelist, 'Value', length(newcontents));
        else
            set(handles.listbox_Parameters_matfilelist, 'Value', inx(end));
        end
    end
end


% this is the function that does the actual outputting of text
function OutputToText(handles)

% check if there are any parameters and files selected
if (isempty(get(handles.listbox_Parameters_paramlist, 'Value')) && get(handles.checkbox_Parameters_includeEGG, 'Value') == 0)
    msgbox('Error: No parameters selected.', 'Error', 'warn', 'modal');
    return;
end

if (isempty(get(handles.listbox_Parameters_matfilelist, 'String')))
    msgbox('Error: No mat files to process.', 'Error', 'warn', 'modal');
    return;
end 

% get variables from the main VS window
VSData = guidata(handles.VSHandle);
matfilelist = get(handles.listbox_Parameters_matfilelist, 'String');
contents = get(handles.listbox_Parameters_paramlist, 'String');
paramlist = contents(get(handles.listbox_Parameters_paramlist, 'Value'));

% get the output delimiter
contents = get(handles.popupmenu_Parameters_delimiter, 'String');
delim = contents{VSData.vars.OT_columndelimiter};
delimiter = 9;  % ascii code for tab
switch(delim)
    case {'tab'}
        delimiter = 9;
    case {'comma'}
        delimiter = 44; %ascii for comma
    case {'space'}
        delimiter = ' '; 
end

% check output files
fids = zeros(6, 1);  % these store the fids of the open files
if (get(handles.radiobutton_Singlefile, 'Value') == 1) % single file
    fid = fopen(VSData.vars.OT_Single, 'wt');
    
    if (fid == -1)
        msgbox('Error: Unable to open file for output.', 'Error', 'error', 'modal');
        return;
    end
    
    writeFileHeaders(fid, paramlist, handles, delimiter);
    fids = [fid fid fid fid fid fid];
    
else % multiple files
    fid1 = fopen(VSData.vars.OT_F0CPPE, 'wt');
    fid2 = fopen(VSData.vars.OT_Formants, 'wt');
    fid3 = fopen(VSData.vars.OT_HA, 'wt');
    fid4 = fopen(VSData.vars.OT_HxHx, 'wt');
    fid5 = fopen(VSData.vars.OT_HxAx, 'wt');
    
    if (fid1 == -1)
        msgbox('Error: Unable to open F0/CPP/E file for output.', 'Error', 'error', 'modal');
        return;
    end
    
    if (fid2 == -1)
        msgbox('Error: Unable to open Formants file for output.', 'Error', 'error', 'modal');
        return;
    end

    if (fid3 == -1)
        msgbox('Error: Unable to open Hx/Ax file for output.', 'Error', 'error', 'modal');
        return;
    end

    if (fid4 == -1)
        msgbox('Error: Unable to open Hx-Hx file for output.', 'Error', 'error', 'modal');
        return;
    end
    
    if (fid5 == -1)
        msgbox('Error: Unable to open Hx-Ax file for output.', 'Error', 'error', 'modal');
        return;
    end
    
    fidEGG = -1;
    if (VSData.vars.OT_includeEGG == 1)
        fidEGG = fopen(VSData.vars.OT_EGG, 'wt');
        if (fidEGG == -1)
            msgbox('Error: Unable to open EGG file for output.', 'Error', 'error', 'modal');
            return;
        end
    end
    
    fids = [fid1 fid2 fid3 fid4 fid5 fidEGG];
    writeFileHeaders(fids, paramlist, handles, delimiter);
end
   
MBox = MessageBox;
MBoxHandles = guidata(MBox);
messages = cell(length(matfilelist) + 1, 1); % allocate some memory for messages
errorcnt = 0;
uniquefids = unique(fids); % store the number of unique fids

% process every file in matfilelist
for k=1:length(matfilelist)
    matfile = [VSData.vars.OT_matdir VSData.vars.dirdelimiter matfilelist{k}];
    TGfile = [VSData.vars.OT_Textgriddir VSData.vars.dirdelimiter matfilelist{k}(1:end-3) 'Textgrid'];
    messages{k} = sprintf('%d/%d. %s: ', k, length(matfilelist), matfilelist{k});
    set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
    drawnow;
    
    mdata = func_buildMData(matfile, VSData.vars.O_smoothwinsize);
    
    frameshift = VSData.vars.frameshift; % this could be wrong if the mat file has it's own frameshift
    if (isfield(mdata, 'frameshift'))
        frameshift = mdata.frameshift;
    end
    
    % find the max length of the data
    if (isfield(mdata, 'strF0'))
        maxlen = length(mdata.strF0) * frameshift;
    elseif (isfield(mdata, 'sF0'))
        maxlen = length(mdata.sF0) * frameshift;
    elseif (isfield(mdata, 'pF0'))
        maxlen = length(mdata.pF0) * frameshift;
    elseif (isfield(mdata, 'oF0'))
        maxlen = length(mdata.oF0) * frameshift;
    end
    
    % load up the textgrid data, or if it doesn't exist, use the whole file
    if (exist(TGfile, 'file') == 0) % file not found, use start and end
        messages{k} = [messages{k} 'Textgrid not found - using all data points: '];
        set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
        drawnow;
        
        start = 1;
        stop = maxlen;
        labels = {matfilelist{k}};
        
    else % use textgrid start points
        ignorelabels = textscan(VSData.vars.TextgridIgnoreList, '%s', 'delimiter', ',');
        ignorelabels = ignorelabels{1};
        
        [labels, start, stop] = func_readTextgrid(TGfile);
        labels_tmp = [];
        start_tmp = [];
        stop_tmp = [];

        for m=1:length(VSData.vars.TextgridTierNumber)
            inx = VSData.vars.TextgridTierNumber(m);
            if (inx <= length(labels))
                labels_tmp = [labels_tmp; labels{inx}];
                start_tmp = [start_tmp; start{inx}];
                stop_tmp = [stop_tmp; stop{inx}];
            end
        end

        labels = labels_tmp;
        start = start_tmp * 1000; % milliseconds
        stop = stop_tmp * 1000; % milliseconds
        
        % just pull out the start/stop of the labels that aren't
        % ignored
        inx = 1:length(labels);
        for n=1:length(labels)
            switch(labels{n})
                case ignorelabels
                    inx(n) = 0;
            end
        end
        inx = unique(inx);
        inx(inx == 0) = [];
        labels = labels(inx);
        start = start(inx);
        stop = stop(inx);
    end

    % get the EGG file if requested
    [proceedEGG, EGGfile] = checkEGGfilename(matfilelist{k}, handles);
    
    if (VSData.vars.OT_includeEGG == 1 && proceedEGG == 0)
        messages{k} = [messages{k} 'EGG file not found, '];
        set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
        drawnow;
        errorcnt = errorcnt + 1;
    end
    
    if (proceedEGG)
        [EGGData, EGGTime] = func_readEGGfile(EGGfile, VSData.vars.EGGheaders, VSData.vars.EGGtimelabel);
    end
    
    % assume each file has the parameters in the mat file
    paramlist_valid = ones(length(paramlist), 1);
    

    % no segments - complete dump
    if (VSData.vars.OT_noSegments == 1)

        % for each label, loop through and write out the selected
        % parameters
        for n=1:length(start)
            sstart = round(start(n) / frameshift);  % get the correct sample
            sstop = round(stop(n) / frameshift);
            
            sstart(sstart == 0) = 1; % special case for t = 0
            sstop(sstop > maxlen) = maxlen; % special case for t=maxlen
                        
            for s=sstart:sstop
                
                for m=1:length(uniquefids)
                    if (uniquefids(m) == -1)
                        continue;
                    end
                    
                    fprintf(uniquefids(m), '%s%c', matfilelist{k}, delimiter);
                    
                    if (VSData.vars.OT_includeTextgridLabels == 1)
                        fprintf(uniquefids(m), '%s%c', labels{n}, delimiter);
                        fprintf(uniquefids(m), '%.3f%c', start(n), delimiter);
                        fprintf(uniquefids(m), '%.3f%c', stop(n), delimiter);
                    end
                    
                    fprintf(uniquefids(m), '%.3f%c', s * frameshift, delimiter);
                end
                
                % print out the selected params
                for m=1:length(paramlist)
                    val = VSData.vars.NotANumber;  % default is the NaN label

                    C = textscan(paramlist{m}, '%s %s', 'delimiter', '(');
                    fidinx = func_getfileinx(paramlist{m});
                    param = C{2}{1}(1:end-1);
                    if (isfield(mdata, param))
                        data = mdata.(param);
                        if (length(data)==1 && isnan(data)) % guard against empty vectors
                            paramlist_valid(m) = 0;
                        else
                            if (~isnan(data(s)) && ~isinf(data(s)))
                                val = sprintf('%.3f', data(s));
                            end
                        end
                    else
                        if (paramlist_valid(m) == 1)
                            messages{k} = [messages{k} param ' not found, '];
                            set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
                            drawnow;
                            errorcnt = errorcnt + 1;
                            paramlist_valid(m) = 0;
                        end
                    end
                    
                    fprintf(fids(fidinx), '%s%c', val, delimiter);                    
                end
                    
                % for the case where EGG was requested, but no EGG file was found
                if (VSData.vars.OT_includeEGG == 1 && proceedEGG == 0)
                    fidinx = 6;
                    EGGheaders = textscan(VSData.vars.EGGheaders, '%s', 'delimiter', ',');
                    EGGheaders = EGGheaders{1};

                    for m=1:length(EGGheaders)
                        fprintf(fids(fidinx), '%s%c', VSData.vars.NotANumber, delimiter);
                    end
                end
                    
                
                % process EGG stuff
                if (proceedEGG)
                    fidinx = 6;
                    
                    % find the time segment from EGGTime, use that to index
                    % EGGData
                    t = s * frameshift; % this is the time in ms. Get the closest EGGTime to t
                    [val, s_EGG] = min(abs(EGGTime - t));
                    
                    if (abs(t - EGGTime(s_EGG)) / t > 0.05)  % if t_EGG is more than 5% away from t, it is not correct
                        for m=1:length(EGGData)
                            fprintf(fids(fidinx), '%s%c', VSData.vars.NotANumber, delimiter);
                        end
                    else
                        for m=1:length(EGGData)
                            fprintf(fids(fidinx), '%.3f%c', EGGData{m}(s_EGG), delimiter);
                        end
                    end                                                    
                end
                
                % finally, write out new line
                for m=1:length(uniquefids)
                    if (uniquefids(m) == -1)
                        continue;
                    end
                    fprintf(uniquefids(m), '\n');
                end
                                    
            end

        end
        
        
    % outputting with segments
    else
        Nseg = str2double(get(handles.edit_numSegments, 'String'));
        
        % for each segment, print out overall mean, then parts mean
        for n=1:length(start)

            % print out the header stuff
            for m=1:length(uniquefids)
                if (uniquefids(m) == -1)
                    continue;
                end

                fprintf(uniquefids(m), '%s%c', matfilelist{k}, delimiter);

                if (VSData.vars.OT_includeTextgridLabels == 1)
                    fprintf(uniquefids(m), '%s%c', labels{n}, delimiter);
                    fprintf(uniquefids(m), '%.3f%c', start(n), delimiter);
                    fprintf(uniquefids(m), '%.3f%c', stop(n), delimiter);
                end

            end            
            
            % get array of start and stop times for the segments. First one
            % is the total mean
            tsegs = linspace(start(n), stop(n), Nseg+1);
            tstart = zeros(Nseg+1, 1);
            tstop = zeros(Nseg+1, 1);
            
            tstart(1) = start(n);
            tstop(1) = stop(n);
            tstart(2:end) = tsegs(1:Nseg);
            tstop(2:end) = tsegs(2:Nseg+1);
            
            % get the sample equivalents
            sstart = round(tstart ./ frameshift);
            sstop = round(tstop ./ frameshift);
            
            % don't output segments if Nseg == 1
            if (Nseg == 1)
                sstart = sstart(1);
                sstop = sstop(1);
            end
            
            % guard against 0 and maxlen
            sstart(sstart == 0) = 1;
            sstop(sstop > maxlen) = maxlen;
                           
            for m=1:length(paramlist)
                val = VSData.vars.NotANumber;  % default value is no value
                
                fidinx = func_getfileinx(paramlist{m});
                C = textscan(paramlist{m}, '%s %s', 'delimiter', '(');
                param = C{2}{1}(1:end-1);
                if (isfield(mdata, param))
                    data = mdata.(param);
                    
                    for p=1:length(sstart)
                        if (length(data)==1 && isnan(data))
                            paramlist_valid(m) = 0;
                        else
                            dataseg = data(sstart(p):sstop(p));
                            mdataseg = mean(dataseg(~isnan(dataseg) & ~isinf(dataseg)));
                            if (~isempty(mdataseg) && ~isnan(mdataseg) && ~isinf(mdataseg))
                                val = sprintf('%.3f', mdataseg);
                            end
                        end
                        fprintf(fids(fidinx), '%s%c', val, delimiter);
                    end
                else
                    if (paramlist_valid(m) == 1)
                        messages{k} = [messages{k} param ' not found, '];
                        set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
                        drawnow;
                        errorcnt = errorcnt + 1;
                        paramlist_valid(m) = 0;
                    end
                    
                    for p=1:length(sstart)
                        fprintf(fids(fidinx), '%s%c', val, delimiter);
                    end
                end
                
            end

            
            % this case if for when the EGG was requested, but no egg file
            % was found
            if (VSData.vars.OT_includeEGG == 1 && proceedEGG == 0)
                fidinx = 6;
                EGGheaders = textscan(VSData.vars.EGGheaders, '%s', 'delimiter', ',');
                EGGheaders = EGGheaders{1};
                for m=1:length(EGGheaders)
                    for p=1:length(tstart)
                        fprintf(fids(fidinx), '%s%c', VSData.vars.NotANumber, delimiter);
                    end
                end
            end
            
            % process EGG stuff
            if (proceedEGG)
                fidinx = 6;

                for m=1:length(EGGData)
                    for p=1:length(tstart)
                        EGGInx = (EGGTime >= tstart(p)) & (EGGTime <= tstop(p));
                        meanval = mean(EGGData{m}(EGGInx));
                        if (~isempty(meanval) && ~isnan(meanval) && ~isinf(meanval))
                            val = sprintf('%.3f', meanval);
                        else
                            val = VSData.vars.NotANumber;
                        end
                        fprintf(fids(fidinx), '%s%c', val, delimiter);
                    end
                end
            end

            % finally, write out new line
            for m=1:length(uniquefids)
                if (uniquefids(m) == -1)
                    continue;
                end
                fprintf(uniquefids(m), '\n');
            end

        end
    end
end
    
for k=1:length(uniquefids)
    if (uniquefids(k) == -1)
        continue;
    end
    fclose(uniquefids(k));
end

if (errorcnt > 0)
    messages{length(matfilelist)+1} = sprintf('Completed: %d parameters not found.', errorcnt);
else
    messages{length(matfilelist)+1} = sprintf('Completed.');
end
set(MBoxHandles.listbox_messages, 'String', messages, 'Value', length(matfilelist)+1);

% allow the MBox to close
set(MBoxHandles.pushbutton_close, 'Enable', 'on');
set(MBoxHandles.pushbutton_stop, 'Enable', 'off');



% write headers to files
function writeFileHeaders(fids, paramlist, handles, delimiter)
VSData = guidata(handles.VSHandle);

% write out the filename and textgrid labels if required
for k=1:length(fids)
    if (fids(k) == -1)
        continue;
    end
    
    fprintf(fids(k), 'Filename%c', delimiter);
    
    if (VSData.vars.OT_includeTextgridLabels == 1)
        fprintf(fids(k), 'Label%c', delimiter);
        fprintf(fids(k), 'seg_Start%c', delimiter);
        fprintf(fids(k), 'seg_End%c', delimiter);
    end
    
    % only print a time stamp when doing complete dumps
    if (VSData.vars.OT_noSegments == 1)
        fprintf(fids(k), 't_ms%c', delimiter);
    end
end

% make the file ids the same length as using multiple files
if (length(fids)==1)
    if (VSData.vars.OT_includeEGG)
        fids = [fids fids fids fids fids fids];
    else
        fids = [fids fids fids fids fids -1];
    end
end

% separate case for complete data dump
if (VSData.vars.OT_noSegments == 1)
    for k=1:length(paramlist)
        fidinx = func_getfileinx(paramlist{k});
        C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
        fprintf(fids(fidinx), '%s%c', C{2}{1}(1:end-1), delimiter);
    end

    if (VSData.vars.OT_includeEGG)
        fidinx = 6;
        C = textscan(VSData.vars.EGGheaders, '%s', 'delimiter', ',');
        for n=1:length(C{1})
            fprintf(fids(fidinx), '%s%c', C{1}{n}, delimiter);
        end
    end
    
    % finally, write out new line
    fids = unique(fids);
    for k=1:length(fids)
        if (fids(k) == -1)
            continue;
        end
        fprintf(fids(k), '\n');
    end
    
% using segments
else
    Nseg = str2double(get(handles.edit_numSegments, 'String'));
    
    % for each parameter, print the mean, followed by the means of each
    % segment
    for k=1:length(paramlist)
        fidinx = func_getfileinx(paramlist{k});
        C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
        label = C{2}{1}(1:end-1);
        fprintf(fids(fidinx), '%s_mean%c', label, delimiter);
        if (Nseg > 1)
            for n=1:Nseg
                segno = sprintf('%3d', n);
                segno = strrep(segno, ' ', '0');
                fprintf(fids(fidinx), '%s_means%s%c', label, segno, delimiter);
            end
        end
    end

    if (VSData.vars.OT_includeEGG)
        fidinx = 6;
        C = textscan(VSData.vars.EGGheaders, '%s', 'delimiter', ',');
        for n=1:length(C{1})
            fprintf(fids(fidinx), '%s_mean%c', C{1}{n}, delimiter);
            
            if (Nseg > 1)
                for m=1:Nseg
                    segno = sprintf('%3d', m);
                    segno = strrep(segno, ' ', '0');
                    fprintf(fids(fidinx), '%s_means%s%c', C{1}{n}, segno, delimiter);
                end    
            end
        end
    end

    % finally, write out a new line
    fids = unique(fids);
    for k=1:length(fids)
        if (fids(k) == -1)
            continue;
        end
        fprintf(fids(k), '\n');
    end
    
    
end



function  [proceedEGG, EGGfile] = checkEGGfilename(matfile, handles)
VSData = guidata(handles.VSHandle);

if (VSData.vars.OT_includeEGG == 0)
    proceedEGG = 0;
    EGGfile = '';
    return;
end

% deal with the filename stupidity that is PCQuirer
VSData = guidata(handles.VSHandle);

EGGfile = [VSData.vars.OT_EGGdir VSData.vars.dirdelimiter matfile(1:end-3) 'egg'];  % attempt to open .egg
if (exist(EGGfile, 'file') == 0) 
    proceedEGG = 0;
            
    if (length(matfile) > 10)
        if (strcmpi(matfile(end-9:end-4), '_Audio'))  % case insensitive
            EGGfile = [VSData.vars.OT_EGGdir VSData.vars.dirdelimiter matfile(1:end-9), 'ch1.egg'];     % try with ch1 first
                    
            if (exist(EGGfile, 'file') == 0)
                EGGfile = [VSData.vars.OT_EGGdir VSData.vars.dirdelimiter matfile(1:end-10) '.egg'];  % next try with .egg w/o _Audio
                if (exist(EGGfile, 'file') == 0)
                    proceedEGG = 0;
                else
                    proceedEGG = 1;
                end
            else
                proceedEGG = 1;
            end
                    
        end
    end
else
    proceedEGG = 1;
end





