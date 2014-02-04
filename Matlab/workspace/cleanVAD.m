function [ postVAD, preVAD ] = cleanVAD(s,fs,wsec)
% -----------------------------------------------------------
% PRE-PROCESSING
% -----------------------------------------------------------
% number of samples per window
winSamples = round(wsec*fs);
% enframe the signal using hanning window
frames = enframe(s,winSamples,winSamples);

% -----------------------------------------------------------
% FEATURE EXTRACTION
% -----------------------------------------------------------
% calculate the energies per frame
energies = sum(frames.*frames,2);

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% assume first 100 ms is silence only to calculate the initial threshold
cleanWindows = floor(fs*0.1/winSamples);
%thr = 5*sum(energies(1:cleanWindows))/cleanWindows;
thr = 0.0003;

% preallocate for speed
framesVAD = zeros(1,length(energies));
preVAD = zeros(1,length(s));
% calculate the original VAD decisions for each frame and sample
for i = 1:length(energies)
    if(i <= cleanWindows)
        framesVAD(i) = 0;
        preVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
    else
        if(energies(i) > thr)
            framesVAD(i) = 1;
            preVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 1;
        else
            framesVAD(i) = 0;
            preVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
        end
    end
end

% -----------------------------------------------------------
% POST-PROCESSING
% -----------------------------------------------------------
% change VAD decisions whenever there is a single frame which has
% a different value from the neighbouring frames
lastFrame = framesVAD(1);
for i=2:(length(framesVAD)-1)
    currentFrame = framesVAD(i);
    if(lastFrame ~= currentFrame)
        nextFrame = framesVAD(i+1);
        if(currentFrame ~= nextFrame)
            framesVAD(i) = nextFrame;
        else
            lastFrame = currentFrame;
        end
    else
        lastFrame = currentFrame;
    end
end
% transform the VAD frames to samples
postVAD = zeros(1,length(s));
for i = 1:length(framesVAD)
    if(framesVAD(i) == 1)
        postVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 1;
    else
        postVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
    end
end
end