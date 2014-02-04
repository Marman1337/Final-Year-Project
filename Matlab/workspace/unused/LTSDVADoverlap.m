function [ postVAD, preVAD ] = LTSDVADoverlap(s,fs,wsec,enhance)
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
        startIndex = max(i-N,1);
        endIndex = min(i+N,noFrames);
        
        LTSE(i,j) = max(amplitudeSpectrum(startIndex:endIndex,j));
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
preVAD(1,1:shiftSamples) = 0;
lastSample = shiftSamples;
for i = 2:(noFrames+winSamples/shiftSamples-1)
    % the loop goes through all 10 ms chunks, at the end it will exceed the
    % number of frames, therefore guard
    if(i <= noFrames)
        if(LTSD(i) > thr)
            framesVAD(i) = 1;
        else
            framesVAD(i) = 0;
        end
    end
    % transform the decision for frame into samples taking the majority of
    % all frames' decisions which include current samples
    startIndex = max(i-4,1);
    endIndex = min(i,noFrames);
    preVAD(1,(lastSample+1):lastSample+shiftSamples) = majority(framesVAD(startIndex:endIndex));
    lastSample = lastSample + shiftSamples;
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
postVAD(1,1:shiftSamples) = 0;
lastSample = shiftSamples;
for i = 2:(noFrames+winSamples/shiftSamples-1)
    % transform the decision for frame into samples taking the majority of
    % all frames' decisions which include current samples
    startIndex = max(i-4,1);
    endIndex = min(i,noFrames);
    postVAD(1,(lastSample+1):lastSample+shiftSamples) = majority(framesVAD(startIndex:endIndex));
    lastSample = lastSample + shiftSamples;
end
end

% possibility to change this function so that if ANY frame reports speech,
% just classify the samples as speech
function mode = majority(vector)
    len = length(vector);
    ones = sum(vector);
    
    if(ones >= len/2)
        mode = 1;
    else
        mode = 0;
    end
end