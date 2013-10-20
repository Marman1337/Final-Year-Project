function [F1, F2, F3, F4, B1, B2, B3, B4, err] = func_SnackFormants(wavfile, windowlength, frameshift, preemphasis)
% [F1, F2, F3, F4, B1, B2, B3, B4, err] = func_SnackFormants(wavfile, windowlength, frameshift, preemphasis)
% Input:  wavfile - input wav file
%         windowlength - windowlength in seconds
%         frameshift - in seconds
%         preemphasis - wonder what this could be?
% Output: Fx, Bx - formant and bandwidth vectors
%         err - error flag
% Notes:  If on Windows/PC, this function will call up the Snack executable
% in the Windows folder. Otherwise, it will try to call up Snack - this
% require Snack to be installed beforehand.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

% settings 
iwantfilecleanup = 1;  %delete tcl,f0,frm files when done
tclfilename = 'tclforsnackformant.tcl'; %produce tcl file to call snack

% make the wavfile acceptable to tcl in Snack
formantfile = [wavfile(1:end-3) 'frm'];
wavfile = strrep(wavfile, '[', '\[');
wavfile = strrep(wavfile, ']', '\]');
wavfile = ['"' wavfile '"'];
%wavfile = strrep(wavfile, '\', '\\'); % for PC

if (ispc)  % pc can run snack.exe
    wavfile = strrep(wavfile, '\', '\\');
    cmds = sprintf('-windowlength %.3f -framelength %.3f -windowtype Hamming -lpctype 1 -preemphasisfactor %.3f -ds_freq 10000', windowlength, frameshift, preemphasis);
    err = system(['Windows\snack.exe formant ' wavfile ' ' cmds]);

else % for macs and possibly others
    %cmd = 'tclsh';  % this is for older macs 
    cmd = 'wish8.4';  % seems to work for OSX Snow Leopard
    %cmd = 'wish84'; % for PC

    fid = fopen(tclfilename, 'wt');
    fprintf(fid, '#!/bin/sh\n');
    fprintf(fid, '# the next line restarts with wish \\\n');
    fprintf(fid, 'exec wish8.4 "$0" "$@"\n\n');
    fprintf(fid, 'package require snack\n\n');
    fprintf(fid, 'snack::sound s\n\n');
    fprintf(fid, 's read %s\n\n', wavfile);
    fprintf(fid, 'set fd [open [file rootname %s].frm w]\n', wavfile);
    fprintf(fid, 'puts $fd [join [s formant -windowlength %.3f -framelength %.3f -windowtype 1 -lpctype 1 -preemphasisfactor %.3f -ds_freq 10000] \\n]\n', windowlength, frameshift, preemphasis);
    fprintf(fid, 'close $fd\n\n');
    fprintf(fid, 'exit');
    fclose(fid);
    
    err = system([cmd ' ' tclfilename]);
end

% change back into original file
wavfile = strrep(wavfile, '\[', '[');
wavfile = strrep(wavfile, '\]', ']');

% oops, error, exit now
if (err~=0)
    F1 = NaN; F2 = NaN; F3 = NaN; F4 = NaN;
    B1 = NaN; B2 = NaN; B3 = NaN; B4 = NaN;
    if (iwantfilecleanup)
        formantfile = strrep(formantfile, '\\', '\');
        if (exist(formantfile, 'file') ~= 0)
            delete(formantfile);
        end
        
        if (exist(tclfilename, 'file') ~= 0)
            delete(tclfilename);
        end
    end
    return;
end

% snack call was successful, read out formant values
[F1,F2,F3,F4,B1,B2,B3,B4] = textread(formantfile, '%f %f %f %f %f %f %f %f');

if (iwantfilecleanup)
    formantfile = strrep(formantfile, '\\', '\');
    if (exist(formantfile, 'file') ~= 0)
        delete(formantfile);
    end
    
    if (exist(tclfilename, 'file') ~= 0)
        delete(tclfilename);
    end
end
