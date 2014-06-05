function [ vadinfo ] = evaluateTIMIT(DRx,n,fs,snrr,vadinfo)
    % add noise to clean speech
    ns = cell(length(DRx),1);
    for k = 1:length(DRx)
        % calculate the power per sample of speech when it is active
        speechPresent = logical(DRx{k}(:,2));
        psig = sum(DRx{k}(speechPresent,1).^2)/length(DRx{k}(speechPresent,1));
        % truncate the noise and calculate its power per sample
        noi = n(1:size(DRx{k},1));
        pnoi = sum(noi.^2)/length(noi);
        % calculate the scaling constant for noise
        sc = sqrt(psig/(pnoi*10^(snrr/10)));
        % scale the noise to the desired SNR
        noi = noi.*sc;
        % add noise to clean speech
        ns{k} = DRx{k}(:,1) + noi;
    end


    vadno = size(vadinfo,1);
    % for each vad
    for i = 1:vadno
        vadfn = vadinfo{i,1};
        % for each threshold
        thrno = size(vadinfo{i,2},1);
        for j = 1:thrno
            display(strcat('VAD',{' '},num2str(i),{' '},'thr',{' '},num2str(j)));
            TP = 0;
            TN = 0;
            FP = 0;
            FN = 0;
            thr = vadinfo{i,2}(j);
            for k = 1:length(DRx)
                % run VAD
                vad = vadfn(ns{k},fs,0.05,0,thr);

                % evaluate VAD
                stats = recallPrecision(vad,DRx{k}(:,2));
                TP = TP + stats{1,2};
                TN = TN + stats{2,2};
                FP = FP + stats{3,2};
                FN = FN + stats{4,2};
            end

            % true positive rate
            vadinfo{i,2}(j,2) = TP/(TP+FN);
            % false positive rate
            vadinfo{i,2}(j,3) = FP/(FP+TN);
        end
    end
end