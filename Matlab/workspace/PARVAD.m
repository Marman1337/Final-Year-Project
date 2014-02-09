function [ postVAD, preVAD ] = PARVAD(s,fs,wsec,enhance,thr)
% set the default threshold if none supplied
if(nargin < 5)
    thr = -50;
end

% default - no speech enhancement
if(nargin < 4)
    enhance = 0;
end

% -----------------------------------------------------------
% PARAMETERS
% -----------------------------------------------------------
B = 7; % buffer length
Sp = 2; % speech possible
Sl = 3; % speech likely
Ls = 5; % short hangover time
Lm = 8; % medium hangover time

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
pitchBin = winSamples.*(pitch./fs);
noPitches = length(pitchBin);
% for some reason PEFAC sometimes returns fewer pitch values than
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
    harm = round(pitchBin(i)+1);
    while(harm <= maxBins && harmNumber(i) < 10)
        harmPower(i) = harmPower(i) + signalPS(i,harm);
        harmNumber(i) = harmNumber(i) + 1;
        harm = round((harmNumber(i)+1)*pitchBin(i)+1);
    end
end
% calculate the periodic and aperiodic powers and their ratios
ro_a = (ro-eta.*harmPower)./(1-eta.*harmNumber);
ro_p = ro - ro_a;
mu = ro_p./ro_a;
% calculate the likelihood ratio
lr = (1./mu).*exp(mu.^2 - 1./mu.^2);
lr = lr + 1e-300.*(lr < 1e-300);
logRatio = 10*log10(lr);

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% set the threshold
% thr = -50;

% preallocate for speed
framesVAD = zeros(1,noFrames);
preVAD = zeros(1,length(s));
% calculate the VAD decisions
for i = 1:noFrames
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
% apply hang-over scheme from the original paper
T = 0;
hangoverVAD = zeros(1,noFrames);

for i = 1:(noFrames-B+1)
    M = maxConsOnes(framesVAD(i:i+B-1));
    
    if(M >= Sl)
        T = Lm;
    elseif(M >= Sp && T < Ls)
        T = Ls;
    elseif(M < Sp && T > 0)
        T = T - 1;
    end
    
    if(T > 0)
        hangoverVAD(i) = 1;
    end
end
hangoverVAD(noFrames-B+2:noFrames) = framesVAD(noFrames-B+2:noFrames);

% transform the VAD frames to samples
postVAD = zeros(1,length(s));
for i = 1:noFrames
    if(hangoverVAD(i) == 1)
        postVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 1;
    else
        postVAD(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
    end
end
end

function max = maxConsOnes(seq)
    M = 0;
    max = 0;
    
    for i = 1:length(seq)
        if(seq(i) == 1)
            M = M+1;
            if(M > max)
                max = M;
            end
        else
            M = 0;
        end
    end
end