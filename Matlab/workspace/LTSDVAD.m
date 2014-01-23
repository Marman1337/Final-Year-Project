function [ postVAD, preVAD ] = LTSDVAD(s,fs,wsec,enhance)
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
% fixed 10 ms frame shift
shiftSamples = round(0.01*fs);
% long term spectral envelope shift as defined and recommended by Ramirez
N = 6;
% enframe the signal using hanning window
frames = enframe(s,hanning(winSamples,'periodic'),shiftSamples);

% -----------------------------------------------------------
% FEATURE EXTRACTION
% -----------------------------------------------------------
% calculate the spectrum for each frame
dft = rfft(frames,winSamples,2);
% calculate the amplitude spectrum for each frame
amplitudeSpectrum = abs(dft);
% calculate the Power Spectrum of the noisy signal
signalPS = dft.*conj(dft);
% estimate the Power Spectrum of the noise
noisePS = estnoiseg(signalPS,wsec);
avgNoisePS = mean(noisePS);

noFrames = size(amplitudeSpectrum,1);
freqBins = size(amplitudeSpectrum,2);
LTSE = zeros(noFrames,freqBins);
LTSD = zeros(noFrames,1);

for i = 1:noFrames
    for j = 1:freqBins
        lowIndex = max(i-N,1);
        highIndex = min(i+N,noFrames);
        
        LTSE(i,j) = max(amplitudeSpectrum(lowIndex:highIndex,j));
    end
    
    currentLTSEsq = LTSE(i,:).^2;
    LTSEnoise = currentLTSEsq./avgNoisePS;
    LTSD(i) = 10*log10(mean(LTSEnoise));
end

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% set the threshold
thr = 8;

% preallocate for speed
framesVAD = zeros(1,noFrames);
preVAD = zeros(1,length(s));
% calculate the VAD decisions, assume first frame always noise
framesVAD(1) = 0;
preVAD(1,1:winSamples) = 0;
last = winSamples;
for i = 2:noFrames
    if(LTSD(i) > thr)
        framesVAD(i) = 1;
        preVAD(1,last:last+shiftSamples) = 1;
        last = last + shiftSamples;
    else
        framesVAD(i) = 0;
        preVAD(1,last:last+shiftSamples) = 0;
        last = last + shiftSamples;
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

% transform the VAD frames to samples with the overlap in mind
postVAD = zeros(1,length(s));
postVAD(1,1:winSamples) = 0;
last = winSamples;
for i = 2:noFrames
    if(LTSD(i) > thr)
        framesVAD(i) = 1;
        postVAD(1,last:last+shiftSamples) = 1;
        last = last + shiftSamples;
    else
        framesVAD(i) = 0;
        postVAD(1,last:last+shiftSamples) = 0;
        last = last + shiftSamples;
    end
end
end