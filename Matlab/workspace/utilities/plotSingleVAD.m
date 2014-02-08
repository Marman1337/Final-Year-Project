function plotSingleVAD(s,n,fs,vadfn)

% truncate the noise signal to the length of the speech
n = n(1:length(s));
% calculate initial powers per sample
psig = activlev(s,16000);
pnoi = sum(n.*n)/length(n);
% calculate desired powers of noise at different SNR
pn = cell(4,2);
pn{1,1} = psig/10^2; pn{1,2} = '20 dB';
pn{2,1} = psig/10^1; pn{2,2} = '10 dB';
pn{3,1} = psig/10^(0.5); pn{3,2} = '5 dB';
pn{4,1} = psig; pn{4,2} = '0 dB';
pn{5,1} = psig/10^(-0.5); pn{5,2} = '-5 dB';

for i=1:5
    % scale the noise to the desired power
    scaledNoise = n.*sqrt(pn{i,1}/pnoi);
    % add the scaled noise to the signal to create a noisy speech at the
    % desired SNR
    noisySpeech = s + scaledNoise;
    % perform VAD on the noisy speech using
    % (1) no speech enhancement
    [ noEnhance, noEnhancepre ] = vadfn(noisySpeech,fs,0.05,0);
    
    % (2) spectral subtraction speech enhancement
    [ enhancesub, enhancesubpre ] = vadfn(noisySpeech,fs,0.05,1);
    
    % (3) MMSE speech enhancement
    [ enhancemmse, enhancemmsepre ] = vadfn(noisySpeech,fs,0.05,2);
    
    figure('units','normalized','outerposition',[0 0.04 1 0.96])
    subplot(3,1,1);
    plot(noisySpeech);
    hold on;
    plot(s,'g');
    plot(1.1*max(noisySpeech).*noEnhance,'r');
    plot(1.1*min(noisySpeech).*noEnhancepre,'m');
    axis([1 length(s) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'noenhance'));

    subplot(3,1,2);
    plot(noisySpeech);
    hold on;
    plot(s,'g');
    plot(1.1*max(noisySpeech).*enhancesub,'r');
    plot(1.1*min(noisySpeech).*enhancesubpre,'m');
    axis([1 length(s) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'enhance specsub'));
    
    subplot(3,1,3);
    plot(noisySpeech);
    hold on;
    plot(s,'g');
    plot(1.1*max(noisySpeech).*enhancemmse,'r');
    plot(1.1*min(noisySpeech).*enhancemmsepre,'m');
    axis([1 length(s) 1.15*min(noisySpeech) 1.15*max(noisySpeech)]);
    title(strcat(pn{i,2},{' '},'enhance ssubmmse'));
end
end