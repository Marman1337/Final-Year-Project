function [ postVAD, preVAD ] = pefacVAD(s,fs,wsec,enhance,thr)
% set the default threshold if none supplied
if(nargin < 5)
    thr = 0.5;
end

% default - no speech enhancement
if(nargin < 4)
    enhance = 0;
end

% -----------------------------------------------------------
% HANG-OVER PARAMETERS
% -----------------------------------------------------------
B = 8; % buffer length
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
% -----------------------------------------------------------
% FEATURE EXTRACTION
% -----------------------------------------------------------
winSamples = round(wsec*fs);
noFrames = size(enframe(s,winSamples,winSamples),1);
[~,~,probVoiced] = fxpefac(s,fs,wsec);
pefacFrames = length(probVoiced);
if(pefacFrames < noFrames)
    for i = pefacFrames+1:noFrames
        probVoiced(i) = probVoiced(pefacFrames);
    end
end

% -----------------------------------------------------------
% CLASSIFICATION
% -----------------------------------------------------------
% preallocate for speed
framesVAD = zeros(1,noFrames);
preVAD = zeros(1,length(s));
% calculate the VAD decisions
for i = 1:noFrames
    if(probVoiced(i) > thr)
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
% apply the ETSI hang-over
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