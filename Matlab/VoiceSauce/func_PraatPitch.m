function [F0, err] = func_PraatPitch(wavfile, frameshift, frameprecision, minF0, maxF0, ...
                                     silthres, voicethres, octavecost, ...
                                     octavejumpcost, voiunvoicost, ...
                                     killoctavejumps, smooth, smoothbw, ...
                                     interpolate, method, datalen)
% [F0, err = func_PraatPitch(wavfile, frameshift, maxF0, minF0,
% voicethres, octavecost, octavejumpcost, voiunvoicost, datalen)
% Input:  wavfile - input wav file
%         frameshift - in seconds
%         maxF0 - maximum F0
%         minF0 - minimum F0
%         silthres - Silence threshold (Praat specific)
%         voicethres - Voice threshold (Praat specific)
%         octavecost - Octave Cost (Praat specific)
%         octavejumpcost - Octave Jump Cost (Praat specific)
%         voiunvoicost - Voiced/unvoiced Cost (Praat specific)
%         killoctavejumps - Kill octave jumps? (Praat specific)
%         smooth - Smooth? (Praat specific)
%         smoothbw - Smoothing bandwidth (Hz) (Praat specific)
%         interpolate - Interpolate? (Praat specific)
%         method - autocorrelation (ac) or cross-correlation (cc)
%         datalen - output data length
% Output: F0 - F0 values
%         err - error flag
% Notes:  This currently only works on PC and Mac.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Modified by Kristine Yu 2010-10-16
% Copyright UCLA SPAPL 2010

% settings 
iwantfilecleanup = 1;  %delete files when done

% check if we need to put double quotes around wavfile
if (wavfile(1) ~= '"')
    pwavfile = ['"' wavfile '"'];
else
    pwavfile = wavfile;
end

if (ispc)  % pc can run praatcon.exe
    cmd = sprintf(['Windows\\praatcon.exe Windows\\praatF0.praat %s %.3f ' ...
    '%.3f %.3f %.3f %.3f %.3f %.3f %.3f %d %d %.3f %d %s'], pwavfile, frameshift, minF0, maxF0, silthres, ...
                  voicethres, octavecost, octavejumpcost, voiunvoicost, ...
                  killoctavejumps, smooth, smoothbw, interpolate, method);
 elseif (ismac) % mac osx can run Praat using terminal, call Praat from
                % Nix/ folder
  curr_dir = pwd;
  curr_wav = [curr_dir wavfile(2:end)];
  
  cmd = sprintf(['MacOS/Praat Windows/praatF0.praat %s %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %d %d %.3f %d %s'], curr_wav, frameshift, minF0, maxF0, silthres, voicethres, octavecost, octavejumpcost, voiunvoicost, killoctavejumps, smooth, smoothbw, interpolate, method);
  
else % otherwise  
    F0 = NaN; 
    err = -1;
    return;
end

%call up praat for pc
if (ispc)
  err = system(cmd);

  if (err ~= 0)  % oops, error, exit now
    F0 = NaN;
    if (iwantfilecleanup)
      if (exist(f0file, 'file') ~= 0)
        delete(f0file);
      end        
    end
    return;
  end
end

%call up praat for Mac OSX
if (ismac)
  err = unix(cmd);

  if (err ~= 0)  % oops, error, exit now
    F0 = NaN;
    if (iwantfilecleanup)
      if (exist(f0file, 'file') ~= 0)
        delete(f0file);
      end        
    end
    return;
  end
end


% Get f0 file
if strcmp(method, 'ac') %if autocorrelation, get .praatac file
  f0file = [wavfile '.praatac'];
else
  f0file = [wavfile '.praatcc']; % else, cross-correlation, get .praatcc file
end


% praat call was successful, return F0 values
F0 = zeros(datalen, 1) * NaN; 

fid = fopen(f0file, 'rt');

% read the rest
C = textscan(fid, '%f %f', 'delimiter', '\n', 'TreatAsEmpty', '--undefined--');
fclose(fid);

t = round(C{1} * 1000);  % time locations from praat pitch track

%KY Since Praat outputs no values in silence/if no f0 value returned, must pad with leading
% undefined values if needed, so we set start time to 0, rather than t(1)

start = 0;
finish = t(end);
increment = frameshift * 1000;

for k=start:increment:finish
    [val, inx] = min(abs(t - k)); % try to find the closest value
    if (abs(t(inx) - k) > frameprecision * frameshift * 1000)  % no valid value found
        continue;
    end
    
    n = round(k / (frameshift * 1000)) + 1; % KY I added a one since
                                            % Matlab indexing starts at 1
                                            % not 0
    if (n < 1 || n > datalen)
        continue;
    end
    
    F0(n) = C{2}(inx);
end

if (iwantfilecleanup)
    if (exist(f0file, 'file') ~= 0)
        delete(f0file);
    end    
end
