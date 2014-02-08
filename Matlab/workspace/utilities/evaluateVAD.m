function [ stats, postVAD ] = evaluateVAD(s,n,fs,vadfn,snrr,actualVAD,plt)
    if(nargin < 7)
        plt = 0;
    end

    % truncate the noise signal to the length of the speech
    n = n(1:length(s));
    % calculate initial powers per sample
    psig = activlev(s,16000);
    pnoi = sum(n.*n)/length(n);
    % calculate the scaling constant for noise
    sc = sqrt(psig/(pnoi*10^(snrr/10)));
    % scale the noise
    n = n.*sc;
    % add noise to clean speech
    ns = s + n;
    
    % run VAD
    [ postVAD, preVAD ] = vadfn(ns,fs,0.05,0);
    
    if(plt == 1)
        plot(ns); hold on;
        plot(s,'r');
        plot(1.1*max(ns).*postVAD,'g');
        plot(1.1*min(ns).*preVAD,'m');
        axis([1 length(s) 1.15*min(ns) 1.15*max(ns)]);
    end
    
    stats = recallPrecision(postVAD,actualVAD);
end