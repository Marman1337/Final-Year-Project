function [ stats, postVAD ] = evaluateVAD(s,n,fs,snr,actualVAD)
    % truncate the noise signal to the length of the speech
    n = n(1:length(s));
    % calculate initial powers per sample
    psig = sum(s.*s)/length(s);
    pnoi = sum(n.*n)/length(n);
    % calculate the scaling constant for noise
    sc = sqrt(psig/(pnoi*10^(snr/10)));
    % scale the noise
    n = n.*sc;
    % add noise to clean speech
    ns = s + n;
    
    % run VAD
    %[ postVAD, preVAD ] = sohnVAD(ns,fs,0.05,0);
    %[ postVAD, preVAD ] = LTSDVAD(ns,fs,0.05,0);
    [ postVAD, preVAD ] = entropyVAD(ns,fs,0.05,0);
    %[ postVAD, preVAD ] = PARVAD(ns,fs,0.05,0);
    
    plot(ns); hold on;
    plot(s,'r');
    plot(1.1*max(ns).*postVAD,'g');
    plot(1.1*min(ns).*preVAD,'m');
    axis([1 length(s) 1.15*min(ns) 1.15*max(ns)]);
    
    stats = recallPrecision(postVAD,actualVAD);
end

function [ stats ] = recallPrecision(computed,actual)
    stats = cell(7,2);
    stats{1,1} = 'TP'; stats{1,2} = 0;
    stats{2,1} = 'TN'; stats{2,2} = 0;
    stats{3,1} = 'FP'; stats{3,2} = 0;
    stats{4,1} = 'FN'; stats{4,2} = 0;
    stats{5,1} = 'Recall'; stats{5,2} = 0;
    stats{6,1} = 'Precision'; stats{6,2} = 0;
    stats{7,1} = 'Class. rate'; stats{7,2} = 0;

    for i = 1:length(computed)
        if(computed(i) == 1 && actual(i) == 1)
            stats{1,2} = stats{1,2} + 1;
        elseif(computed(i) == 0 && actual(i) == 0)
            stats{2,2} = stats{2,2} + 1;
        elseif(computed(i) == 1 && actual(i) == 0)
            stats{3,2} = stats{3,2} + 1;
        elseif(computed(i) == 0 && actual(i) == 1)
            stats{4,2} = stats{4,2} + 1;
        end
    end

    % Recall
    stats{5,2} = stats{1,2}/(stats{1,2}+stats{4,2});
    % Precision
    stats{6,2} = stats{1,2}/(stats{1,2}+stats{3,2});
    % Classification rate
    stats{7,2} = (stats{1,2}+stats{2,2})/(stats{1,2}+stats{2,2}+stats{3,2}+stats{4,2});
end