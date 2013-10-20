function [SHR,F0]=func_GetSHRP(y,Fs, variables, datalen)
%function [f0_time,f0_value,SHR,f0_candidates]=func_GetSHRP(y,Fs,F0MinMax,timestep,SHR_Threshold)
% Input:  y, Fs - from wavread
%         variables - settings from initialization/setting
%         datalen - output data length
% Output: F0 - F0 values
%         SHR - Subharmonic-harmonic ratio values
%         (and eventually, F0 candidates?)
% Author: Kristine Yu, Department of Linguistics, UCLA, based off code
% by Yen-Liang Shue for func_PraatPitch.m


%%%%%%%%%%% Get/set arguments to shrp.m

% TESTING
% [y,Fs]=wavread('work/beijing_f3_50_a.wav'); % for testing
% F0MinMax = [vars.SHRmin, vars.SHRmax]; % For testing
% windowsize = vars.windowsize; % Set frame_length to 25ms, the VS default, for testing
% frameshift = vars.frameshift; % Set 10 ms frameshift, for testing
% SHR_Threshold = 0.4; %
% frame_precision = 1; % fudge factor for time alignment
% ceiling = 1250;
% med_smooth = 0; CHECK_VOICING = 0; % Leave default: no smoothing, no voice detection

%%% Get settings

F0MinMax = [variables.SHRmin, variables.SHRmax]; % Set lower and
                                                       % upper bounds for
                                                       % f0 estimation
  
frameshift = variables.frameshift; % this is in ms
windowsize = variables.windowsize; % also in ms

SHR_Threshold = variables.SHRThreshold; % Set subharmonic-to-harmonic ratio

ceiling = 1250; % Leave default 1250 Hz

med_smooth = 0; CHECK_VOICING = 0; % Leave default: no smoothing, no voice detection

frame_precision = variables.frame_precision; % how many frames can
                                            % time-alignment be off by,
                                            % when outputting data vectors?

%%%%%%%%%%% Calculate subharmonic-harmonic ratios and f0 tracks
% Call Xuejing Sun's subharmonic-harmonic ratio based pitch detection
% algorithm shrp.m
% Available for download here
%http://www.mathworks.com/matlabcentral/fileexchange/1230-pitch-determination-algorithm
%http://www.speakingx.com/blog/2008/01/02/pitch-determination

[f0_time,f0_value,SHR_value,f0_candidates]=shrp(y,Fs,F0MinMax,windowsize,frameshift,SHR_Threshold,ceiling,med_smooth,CHECK_VOICING);


%%%%%%%%%%% Postprocess subharmonic-harmonic ratios and f0 tracks 

% Initialize F0 and subharmonic-harmonic ratio values  
F0 = zeros(datalen, 1) * NaN; 
SHR = zeros(datalen, 1) * NaN; 
  
t = round(f0_time);  % time locations rounded to nearest ms

start = 0; % Like timecoures from Praat, we might have missing values so pad with NaNs at
           % beginning and end if necessary.
finish = t(end);
increment = frameshift;

for k=start:increment:finish
    [val, inx] = min(abs(t - k)); % try to find the closest value
    if (abs(t(inx) - k) > frame_precision * frameshift)  % no valid value found
        continue;
    end
    
    n = round(k / frameshift) + 1; % KY I added a 1 because Matlab index starts at 1, not 0
    if (n < 1 || n > datalen)
        continue;
    end
    
    F0(n+1) = f0_value(inx); % f0 values
    SHR(n+1) = SHR_value(inx); % SHR values
    % I eventually would like to get candidates as well
end
