function [ stats ] = plotAllVAD(cleanSpeech,noise,fs,actualVAD)
% evaluate the VADs?
if(nargin < 5)
    evaluate = 0;
else
    evaluate = 1;
end

% truncate the noise signal to the length of the speech
noise = noise(1:length(cleanSpeech));
% calculate initial powers per sample
psig = sum(cleanSpeech.*cleanSpeech)/length(cleanSpeech);
pnoi = sum(noise.*noise)/length(noise);
% calculate desired powers of noise at different SNR
pn = cell(5,2);
pn{1,1} = psig/10^2; pn{1,2} = '20 dB';
pn{2,1} = psig/10^1; pn{2,2} = '10 dB';
pn{3,1} = psig/10^(0.5); pn{3,2} = '5 dB';
pn{4,1} = psig; pn{4,2} = '0 dB';
pn{5,1} = psig/10^(-0.5); pn{5,2} = '-5 dB';

if(evaluate == 1)
    stats = cell(5,2);
end

for i=3:4
    % scale the noise to the desired power
    scaledNoise = noise.*sqrt(pn{i,1}/pnoi);
    % add the scaled noise to the signal to create a noisy speech at the
    % desired SNR
    noisySpeech = cleanSpeech + scaledNoise;
    % perform VAD on the noisy speech using
    [ postSohn, preSohn ] = sohnVAD(noisySpeech,fs,0.05);
    [ postLTSD, preLTSD ] = LTSDVAD(noisySpeech,fs,0.05);
    [ postEntropy, preEntropy ] = entropyVAD(noisySpeech,fs,0.05);
    [ postPAR, prePAR ] = PARVAD(noisySpeech,fs,0.05);
    [ postHarm, preHarm ] = harmfreqVAD(noisySpeech,fs,0.05);
    
    figure('units','normalized','outerposition',[0 0.04 1 0.96])
    subplot(5,1,1);
    plot(noisySpeech);
    hold on;
    plot(cleanSpeech,'g');
    plot(1.1*max(noisySpeech).*postSohn,'r');
    plot(1.1*min(noisySpeech).*preSohn,'m');
    axis([1 length(cleanSpeech) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'noenhance, Sohn'));
    
    subplot(5,1,2);
    plot(noisySpeech);
    hold on;
    plot(cleanSpeech,'g');
    plot(1.1*max(noisySpeech).*postLTSD,'r');
    plot(1.1*min(noisySpeech).*preLTSD,'m');
    axis([1 length(cleanSpeech) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'noenhance, LTSD'));
    
    subplot(5,1,3);
    plot(noisySpeech);
    hold on;
    plot(cleanSpeech,'g');
    plot(1.1*max(noisySpeech).*postEntropy,'r');
    plot(1.1*min(noisySpeech).*preEntropy,'m');
    axis([1 length(cleanSpeech) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'noenhance, entropy'));
    
    subplot(5,1,4);
    plot(noisySpeech);
    hold on;
    plot(cleanSpeech,'g');
    plot(1.1*max(noisySpeech).*postPAR,'r');
    plot(1.1*min(noisySpeech).*prePAR,'m');
    axis([1 length(cleanSpeech) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'noenhance, PARADE'));
    
    subplot(5,1,5);
    plot(noisySpeech);
    hold on;
    plot(cleanSpeech,'g');
    plot(1.1*max(noisySpeech).*postHarm,'r');
    plot(1.1*min(noisySpeech).*preHarm,'m');
    axis([1 length(cleanSpeech) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'noenhance, Harmfreq'));
    
    if(evaluate == 1)
        stats{i,1} = pn{i,2};
        stats{i,2} = cell(5,2);
        stats{i,2}{1,1} = 'Sohn';
        stats{i,2}{1,2} = recallPrecision(postSohn,actualVAD);
        stats{i,2}{2,1} = 'LTSD';
        stats{i,2}{2,2} = recallPrecision(postLTSD,actualVAD);
        stats{i,2}{3,1} = 'Entropy';
        stats{i,2}{3,2} = recallPrecision(postEntropy,actualVAD);
        stats{i,2}{4,1} = 'PARADE';
        stats{i,2}{4,2} = recallPrecision(postPAR,actualVAD);
        stats{i,2}{5,1} = 'Harmfreq';
        stats{i,2}{5,2} = recallPrecision(postHarm,actualVAD);
    end
end
end