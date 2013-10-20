function [F1, F2, F3, F4, B1, B2, B3, B4, err_msg] = func_OtherFormants(wavfile, handles)
% [F0, err] = func_SnackPitch(wavfile, windowsize, frameshift, maxF0, minF0)
% Input:  wavfile - input wav file
% Output: F1, F2, F3, F4, B1, B2, B3, B4
%         err_msg - message of error
% Notes: Function attempts to call an external command to produce a formant
% output file which is read back as a vector. Formant output file format should
% be 8 columns of formant values for each frame
%
% Warning: experimental function
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

% get settings and commands
VSData = guidata(handles.VSHandle);
outfile = [wavfile(1:end-3) 'fmt'];

C = textscan(VSData.vars.FormantsOtherCommand, '%s', 'delimiter', ' ');
C = C{1};

command = [];
F1 = NaN; F2 = NaN; F3 = NaN; F4 = NaN;
B1 = NaN; B2 = NaN; B3 = NaN; B4 = NaN;
err_msg = [];

for k=1:length(C)
    if (strcmp(C{k}, '$wavfile'))
        command = [command wavfile ' '];
    elseif (strcmp(C{k}, '$outfile'))
        command = [command outfile ' '];
    else
        command = [command C{k} ' '];
    end
end
    
% attempt to run command
[status, results] = system(command);

% error occured, exit
if (status ~= 0)
    err_msg = 'Unable to execute command.';
    
    % try to clean up files
    if (exist(outfile, 'file') ~= 0)
        delete(outfile);
    end
    
    return;
end

% now check if outfile exists
if (exist(outfile, 'file') == 0)
    err_msg = 'Unable to find formant file.';
    return;
end

% if file exists, read in the vectors
fid = fopen(outfile, 'rt');
if (fid == -1)
    err_msg = 'Unable to open formant file.';
    return;
end

C = textscan(fid, '%f %f %f %f %f %f %f %f', 'delimiter', '\n');
fclose(fid);
F1 = C{1};
F2 = C{2};
F3 = C{3};
F4 = C{4};
B1 = C{5};
B2 = C{6};
B3 = C{7};
B4 = C{8};


% clean up
delete(outfile);

