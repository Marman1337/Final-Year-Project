function [ nextCorrectAll ] = histogramErrors(DRx,Nx,fs,snrr,vadfn,dir)

    noises = length(Nx);
    signals = length(DRx);
    vadDecConcat = cell(noises,1);
    vadRefConcat = cell(noises,1);
    
    for i = 1:noises
        display(i);
        for j = 1:signals
            % calculate the power per sample of speech when it is active
            speechPresent = logical(DRx{j}(:,2));
            psig = sum(DRx{j}(speechPresent,1).^2)/length(DRx{j}(speechPresent,1));
            % truncate the noise and calculate its power per sample
            noi = Nx{i}(1:size(DRx{j},1));
            pnoi = sum(noi.^2)/length(noi);
            % calculate the scaling constant for noise
            sc = sqrt(psig/(pnoi*10^(snrr/10)));
            % scale the noise to the desired SNR
            noi = noi.*sc;
            % add noise to clean speech
            ns = DRx{j}(:,1) + noi;
            
            vadDecConcat{i} = vertcat(vadDecConcat{i},transpose(vadfn(ns,fs,0.025)));
            vadRefConcat{i} = vertcat(vadRefConcat{i},DRx{j}(:,2));
        end
        
        if(i == 1)
            nextCorrectAll = classifyError(vadDecConcat{i},vadRefConcat{i},dir);
        else
            nextCorrectAll = vertcat(nextCorrectAll,classifyError(vadDecConcat{i},vadRefConcat{i},dir));
        end
    end

end

function [ nextSpeech ] = classifyError(dec,ref,dir)
    if(strcmp(dir,'speech'))
        REF = 0;
        DEC = 1;
    elseif(strcmp(dir,'noise'))
        REF = 1;
        DEC = 0;
    else
        error('Wrong argument dir');
    end
    
    len = length(ref);
    noError = 0;
    for i = 1:len
        if(ref(i) == REF && dec(i) == DEC)
            noError = noError + 1;
        end
    end
    nextSpeech = zeros(noError,1);
    
    display(noError);
    noError = 0;
    for i = 1:len
        if(ref(i) == REF && dec(i) == DEC)
            noError = noError + 1;
            
            % check the right side
            counterRight = 1;
            index = i + 1;
            if(index <= len)
                while(ref(index) == REF)
                    counterRight = counterRight + 1;
                    index = index + 1;
                    if(index > len)
                        counterRight = inf;
                        break;
                    end
                end
            end
            
            % check the left side
            counterLeft = 1;
            index = i - 1;
            if(index > 0)
                while(ref(index) == REF)
                    counterLeft = counterLeft + 1;
                    index = index - 1;
                    if (index < 1)
                        counterLeft = inf;
                        break;
                    end
                end
            end
            if(mod(noError,10000) == 0)
                display(noError);
            end
            nextSpeech(noError) = min(counterLeft,counterRight);
        end
    end
end
