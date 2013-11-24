function decisions = simpleVAD(s,fs,wsec)

% number of samples per window
winSamples = round(wsec*fs);

% enframe the signal using hanning window
frames = enframe(s,hanning(winSamples,'periodic'),winSamples);

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

% assume first 100 ms is noise only to calculate the initial threshold
noiseWindows = floor(fs*0.1/winSamples);
thr = sum(snr(1:noiseWindows))/noiseWindows;

% preallocate for speed
decisions = zeros(1,length(s));
% calculate the VAD decisions
for i = 1:size(signalPS,1)
    if(snr(i) > thr)
        decisions(1,(1+(i-1)*winSamples):(i*winSamples)) = 0.2;
    else
        decisions(1,(1+(i-1)*winSamples):(i*winSamples)) = 0;
    end
end

end