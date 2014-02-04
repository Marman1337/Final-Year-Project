function [ postVAD, preVAD ] = sohn1VAD(s,fs,wsec,enhance)
% default - no speech enhancement
if(nargin < 4)
    enhance = 0;
end

% -----------------------------------------------------------
% PRE-PROCESSING
% -----------------------------------------------------------
% perform speech enhancement if necessary
if(enhance == 1)
    s = specsub(s,fs);
end
if(enhance == 2)
    s = ssubmmse(s,fs);
end
% number of samples per window
winSamples = round(wsec*fs);
% enframe the signal using hanning window
frames = enframe(s,hanning(winSamples,'periodic'),winSamples);

% -----------------------------------------------------------
% FEATURE EXTRACTION
% -----------------------------------------------------------
% calculate the DFT of each frame
dft = rfft(frames,winSamples,2);
% calculate the Power Spectrum of the noisy signal
signalPS = dft.*conj(dft);
% estimate the Power Spectrum of the noise
noisePS = estnoiseg(signalPS,wsec);
% calculate the log-likelihood ratio for each frame
snr = signalPS./noisePS;
logRatio = (1/winSamples)*sum( snr-log(snr)-1 , 2);

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% set the threshold
thr = 2;

% preallocate for speed
framesVAD = zeros(1,length(logRatio));
preVAD = zeros(1,length(s));
% calculate the VAD decisions
for i = 1:length(logRatio)
    if(logRatio(i) > thr)
        framesVAD(i) = 1;
        preVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 1;
    else
        framesVAD(i) = 0;
        preVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
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