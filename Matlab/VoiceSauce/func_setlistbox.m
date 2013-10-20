function func_setlistbox(h_listbox, wavfiledir, mode, vars, filetype)
% func_setlistbox(h_listbox, wavfiledir, mode, vars, filetype)
% Notes: Fills a listbox with folder listings. Allows for recursive
% searches.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

if (nargin == 4)
    filetype = '*.wav';
end

fnames = dir([wavfiledir vars.dirdelimiter filetype]);
wavlist = {};

if (nargin == 2)
    mode = 'none';
end
 
if (strcmp(mode, 'none'))
    % add the files that are in the present directory
    for k=1:length(fnames)
        wavlist{k} = [wavfiledir vars.dirdelimiter fnames(k).name];
    end
end

if (strcmp(mode, 'recurse'))
    % now recurse down the directory tree
    wavlist = recurseWavSearch(wavfiledir, wavlist, filetype, vars);
end

for k=1:length(wavlist)
    wavlist{k} = wavlist{k}(length(wavfiledir)+2:end);
end

set(h_listbox, 'String', wavlist, 'Value', 1);


%-------------------------------------------------------------------------
function newfiles = recurseWavSearch(wavfiledir, files, filetype, vars)

fnames = dir([wavfiledir vars.dirdelimiter filetype]);
files_len = length(files);

for k=1:length(fnames)
    files{files_len+k} = [wavfiledir vars.dirdelimiter fnames(k).name];
end

fdir = dir([wavfiledir vars.dirdelimiter '*']);
for k=1:length(fdir)
    if (~strcmp(fdir(k).name, '.') && ~strcmp(fdir(k).name, '..') && fdir(k).isdir)
        files = recurseWavSearch([wavfiledir vars.dirdelimiter fdir(k).name], files, filetype, vars);
    end
end

newfiles = files;
