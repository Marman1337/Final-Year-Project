function [ speech, noise ] = separateByVAD(signal, vad)

speechlen = sum(vad);
speech = zeros(speechlen,1);
noise = zeros(length(signal)-speechlen,1);

speechIndex = 1;
noiseIndex = 1;

for i = 1:length(signal)
    if(vad(i) == 1)
        speech(speechIndex) = signal(i);
        speechIndex = speechIndex + 1;
    else
        noise(noiseIndex) = signal(i);
        noiseIndex = noiseIndex + 1;
    end
end