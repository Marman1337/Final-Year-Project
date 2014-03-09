function [ snrres ] = evaluateVsSNR(DRx,Nx,fs,vadinfo)
snrr = [20 15 10 5 0 -5 -10 -15];
% for each snr level
snrno = length(snrr);
snrres = cell(5,2);

noises = length(Nx);
vadno = size(vadinfo,1);

% initialise the output cell
for i = 1:vadno
    snrres{i,1} = vadinfo{i,1};
    snrres{i,2}(1,:) = zeros(1,snrno);
    snrres{i,2}(2,:) = zeros(1,snrno);
end

% for each snr
for i = 1:snrno
    % for each vad
    for j = 1:vadno
        display(strcat('VAD',{' '},num2str(j),{' '},'SNR',{' '},num2str(snrr(i))));
        vadfn = vadinfo{j,1};
        thr = vadinfo{j,2};
        TP = 0;
        TN = 0;
        FP = 0;
        FN = 0;
        
        for m = 1:noises
            % add noise to clean speech
            for k = 1:length(DRx)
                % calculate the power per sample of speech when it is active
                speechPresent = logical(DRx{k}(:,2));
                psig = sum(DRx{k}(speechPresent,1).^2)/length(DRx{k}(speechPresent,1));
                % truncate the noise and calculate its power per sample
                noi = Nx{m}(1:size(DRx{k},1));
                pnoi = sum(noi.^2)/length(noi);
                % calculate the scaling constant for noise
                sc = sqrt(psig/(pnoi*10^(snrr(i)/10)));
                % scale the noise to the desired SNR
                noi = noi.*sc;
                % add noise to clean speech
                ns = DRx{k}(:,1) + noi;
                
                % run VAD
                vad = vadfn(ns,fs,0.05,0,thr);
                % evaluate VAD
                stats = recallPrecision(vad,DRx{k}(:,2));
                TP = TP + stats{1,2};
                TN = TN + stats{2,2};
                FP = FP + stats{3,2};
                FN = FN + stats{4,2};
            end
        end
        
        % speech hit rate
        snrres{j,2}(1,i) = TP/(TP+FN);
        % non speech hit rate
        snrres{j,2}(2,i) = TN/(TN+FP);
    end
end
end