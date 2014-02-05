function [ TPR, FPR ] = evaluateTIMIT(DRx,n,fs,snrr,vadfn,thr)
    TP = 0;
    TN = 0;
    FP = 0;
    FN = 0;
    
    for i = 1:length(DRx)
        % calculate the power per sample of speech when it is active
        speechPresent = logical(DRx{i}(:,2));
        psig = sum(DRx{i}(speechPresent,1).^2)/length(DRx{i}(speechPresent,1));
        % truncate the noise and calculate its power per sample
        noi = n(1:size(DRx{i},1));
        pnoi = sum(noi.^2)/length(noi);
        % calculate the scaling constant for noise
        sc = sqrt(psig/(pnoi*10^(snrr/10)));
        % scale the noise to the desired SNR
        noi = noi.*sc;
        % add noise to clean speech
        ns = DRx{i}(:,1) + noi;
        
        % run VAD
        vad = vadfn(ns,fs,0.05,0,thr);
        
        % evaluate VAD
        stats = recallPrecision(vad,DRx{i}(:,2));
        TP = TP + stats{1,2};
        TN = TN + stats{2,2};
        FP = FP + stats{3,2};
        FN = FN + stats{4,2};
    end
    
    TPR = TP/(TP+FN);
    FPR = FP/(FP+TN);
end