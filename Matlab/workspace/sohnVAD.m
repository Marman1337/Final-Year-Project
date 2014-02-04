function [ postVAD, preVAD ] = sohnVAD(s,fs,wsec,enhance)
% default - no speech enhancement
if(nargin < 4)
    enhance = 0;
end

% -----------------------------------------------------------
% PARAMETERS
% -----------------------------------------------------------
alpha = 0.95;
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
frames = enframe(s,hanning(winSamples,'periodic'),winSamples);
noFrames = size(frames,1);

% -----------------------------------------------------------
% FEATURE EXTRACTION
% -----------------------------------------------------------
% calculate the DFT of each frame
dft = rfft(frames,winSamples,2);
% calculate the Power Spectrum of the noisy signal
signalPS = dft.*conj(dft);
% estimate the Power Spectrum of the noise
noisePS = estnoiseg(signalPS,wsec);
% calculate the a posteriori SNR
gamma = signalPS./noisePS;
% enhance for a priori SNR computation
s = ssubmmse(s,fs);
frames = enframe(s,hanning(winSamples,'periodic'),winSamples);
dft = rfft(frames,winSamples,2);
signalPS = dft.*conj(dft);

lastSNR = 1;
logRatio = zeros(noFrames,1);
for i = 1:noFrames
    xi = alpha.*lastSNR + (1-alpha).*max(gamma(i,:)-1,0);
    lambdak = (1./(1+xi)).*exp((gamma(i,:).*xi)./(1+xi));
    lglambdak = log(lambdak);
    logRatio(i) = mean(lglambdak);
    
    lastSNR = signalPS(i,:)./noisePS(i,:);
end

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
% apply hang-over scheme from the original paper
T = 5;
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