function [ postVAD, preVAD ] = PARVAD(s,fs,wsec,enhance)
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
window = hanning(winSamples,'periodic');
frames = enframe(s,window,winSamples);
noFrames = size(frames,1);
% calculate the constant for estimating the power
eta = (2*sum(window.^2))/(sum(window).^2);

% -----------------------------------------------------------
% FEATURE EXTRACTION
% -----------------------------------------------------------
% calculate the DFT of each frame
dft = rfft(frames,winSamples,2);
maxBins = size(dft,2);
% calculate the Power Spectrum of the noisy signal
signalPS = dft.*conj(dft);
% estimate the f0 of each frame using PEFAC
pitch = fxpefac(s,fs,wsec);
pitchBin = round(2*round(maxBins.*pitch)./fs);
noPitches = length(pitchBin);
% for some weird reason PEFAC sometimes returns less pitch values than
% there is frames, in that case artificially assign the last returned pitch
% to the missing frames
if(noPitches < noFrames)
    for i = noPitches+1:noFrames
        pitchBin(i) = pitchBin(noPitches);
    end
end
% calculate average power per frequency bin in each frame
ro = mean(signalPS,2);
% sum the power of the signal at multiples of f0
harmPower = zeros(noFrames,1);
harmNumber = zeros(noFrames,1);
for i = 1:noFrames
    harm = pitchBin(i)+1;
    while(harm <= maxBins)
        harmPower(i) = harmPower(i) + signalPS(i,harm);
        harmNumber(i) = harmNumber(i) + 1;
        harm = harm + pitchBin(i);
    end
end
% calculate the periodic and aperiodic powers and their ratios
ro_a = (ro-eta.*harmPower)./(1-eta.*harmNumber);
ro_p = ro - ro_a;
mu = ro_p./ro_a;
% calculate the likelihood ratio
lr = (1./mu).*exp(mu.^2 - 1./mu.^2);
lr = 10*log10(lr);

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% set the threshold (HOW TO CHOOSE AN APPROPRIATE THRESHOLD?)
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