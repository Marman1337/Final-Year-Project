function [ postVAD, preVAD ] = simpleVAD(s,fs,wsec,enhance)
% default - no speech enhancement
if(nargin < 4)
    enhance = 0;
end

% perform speech enhancement if necessary
if(enhance == 1)
    s = specsub(s,fs);
end
if(enhance == 2)
    s = ssubmmse(s,fs);
end

% -----------------------------------------------------------
% PRE-PROCESSING
% -----------------------------------------------------------
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
% preallocate for speed
snr = zeros(size(signalPS,1),1);
% calculate the SNR for each frame
for i = 1:size(signalPS,1)
    snr(i) = (sum(signalPS(i,:))-sum(noisePS(i,:)))/sum(noisePS(i,:));
end

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% assume first 100 ms is noise only to calculate the initial threshold
noiseWindows = floor(fs*0.1/winSamples);
thr = 2*sum(snr(1:noiseWindows))/noiseWindows;

% preallocate for speed
framesVAD = zeros(1,length(snr));
preVAD = zeros(1,length(s));
% calculate the VAD decisions
for i = 1:length(snr)
    if(i <= noiseWindows)
        framesVAD(i) = 0;
        preVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
    else
        if(snr(i) > thr)
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