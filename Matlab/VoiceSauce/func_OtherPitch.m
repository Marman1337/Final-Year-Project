function [F0, err_msg] = func_OtherPitch(wavfile, handles)
% [F0, err] = func_SnackPitch(wavfile, windowsize, frameshift, maxF0, minF0)
% Input:  wavfile - input wav file
% Output: F0 
%         err_msg - message of error
% Notes: Function attempts to call an external command to produce an F0
% output file which is read back as a vector. F0 output file format should
% be a column of F0 values for each frame
%
% Warning: experimental function
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

% get settings and commands
VSData = guidata(handles.VSHandle);
outfile = [wavfile(1:end-3) 'f0'];

C = textscan(VSData.vars.F0OtherCommand, '%s', 'delimiter', ' ');
C = C{1};

command = [];
F0 = NaN;
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
    err_msg = 'Unable to find F0 file.';
    return;
end

% if file exists, read in the vectors
fid = fopen(outfile, 'rt');
if (fid == -1)
    err_msg = 'Unable to open F0 file.';
    return;
end

C = textscan(fid, '%f');
fclose(fid);
F0 = C{1};


% clean up
delete(outfile);

