function [F1, F2, F3, F4, B1, B2, B3, B4, err] = func_PraatFormants(wavfile, ...
                                                  windowlength, frameshift, frameprecision, datalen)
% [F1, F2, F3, F4, B1, B2, B3, B4, err] = func_PraatFormants(wavfile, windowlength, frameshift, frameprecision, datalen)
% KY Time-stamp: <2010-10-16 21:47:24 amoebe>  
% Input:  wavfile - input wav file
%         windowlength - windowlength in seconds
%         frameshift - in seconds
%         frameprecision - unitless
%         datalen - output data length
% Output: Fx, Bx - formant and bandwidth vectors
%         err - error flag
% Notes:  This currently only works on a PC.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Modified by Kristine Yu, 2010-10-16 to allow for variable precision in
% matching up time alignment between data vectors.
%
% Copyright UCLA SPAPL 2010

% settings 
maxFormant = 6000;
iwantfilecleanup = 1;  %delete pfmt files when done

% check if we need to put double quotes around wavfile
if (wavfile(1) ~= '"')
    pwavfile = ['"' wavfile '"'];
else
    pwavfile = wavfile;
end

if (ispc)  % pc can run praatcon.exe
    cmd = sprintf('Windows\\praatcon.exe Windows\\praatformants.praat %s %.3f %.3f %d', pwavfile, frameshift, windowlength, maxFormant);

elseif (ismac) % mac osx can run Praat using terminal, call Praat from
                % Nix/ folder
  curr_dir = pwd;
  curr_wav = [curr_dir wavfile(2:end)];
  
  cmd = sprintf(['MacOS/Praat Windows/praatformants.praat ' ...
  '%s %.3f %.3f %d'], curr_wav, frameshift, windowlength, maxFormant);
    
else
    F1 = NaN; F2 = NaN; F3 = NaN; F4 = NaN;
    B1 = NaN; B2 = NaN; B3 = NaN; B4 = NaN;
    err = -1;
    return;
end

% Set name of formant track file
fmtfile = [wavfile '.pfmt'];

%call up praat

% for pc
if (ispc)
  err = system(cmd);
  
  if (err ~= 0)  % oops, error, exit now
    F1 = NaN; F2 = NaN; F3 = NaN; F4 = NaN;
    B1 = NaN; B2 = NaN; B3 = NaN; B4 = NaN;
    if (iwantfilecleanup)
      if (exist(fmtfile, 'file') ~= 0)
        delete(fmtfile);
      end        
    end
    return;
  end
end


% for mac
if (ismac)
  err = unix(cmd);

  if (err ~= 0)  % oops, error, exit now
    F1 = NaN; F2 = NaN; F3 = NaN; F4 = NaN;
    B1 = NaN; B2 = NaN; B3 = NaN; B4 = NaN;
    if (iwantfilecleanup)
      if (exist(fmtfile, 'file') ~= 0)
        delete(fmtfile);
      end        
    end
    return;
  end
end

% praat call was successful, return fmt values
F1 = zeros(datalen, 1) * NaN;  B1 = zeros(datalen, 1) * NaN;
F2 = zeros(datalen, 1) * NaN;  B2 = zeros(datalen, 1) * NaN;
F3 = zeros(datalen, 1) * NaN;  B3 = zeros(datalen, 1) * NaN;
F4 = zeros(datalen, 1) * NaN;  B4 = zeros(datalen, 1) * NaN;

% Get formant file

fid = fopen(fmtfile, 'rt');

% read and discard the header
C = textscan(fid, '%s', 1, 'delimiter', '\n');

% read the rest
C = textscan(fid, '%f %f %f %f %f %f %f %f %f %f', 'delimiter', '\n', 'TreatAsEmpty', '--undefined--');
fclose(fid);
t = round(C{1} * 1000);  % time locations

start = 0; % KY changed since Praat doesn't necessarily have data start
           % at time = 0
finish = t(end);
increment = frameshift * 1000;

for k=start:increment:finish
    [val, inx] = min(abs(t - k)); % try to find the closest value
    if (abs(t(inx) - k) > frameprecision * frameshift * 1000)  % no valid value found
        continue;
    end
   
    n = round(k / (frameshift * 1000)) + 1; % KY I added 1 since Matlab
                                            % index starts at 1, not 0
    if (n < 1 || n > datalen)
        continue;
    end
    
    F1(n) = C{3}(inx);
    B1(n) = C{4}(inx);
    F2(n) = C{5}(inx);
    B2(n) = C{6}(inx);
    F3(n) = C{7}(inx);
    B3(n) = C{8}(inx);
    F4(n) = C{9}(inx);
    B4(n) = C{10}(inx);
end

if (iwantfilecleanup)
    if (exist(fmtfile, 'file') ~= 0)
        delete(fmtfile);
    end    
end
