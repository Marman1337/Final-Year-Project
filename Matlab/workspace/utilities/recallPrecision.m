function [ stats ] = recallPrecision(computed,actual)
    stats = cell(7,2);
    stats{1,1} = 'TP'; TP = 0;
    stats{2,1} = 'TN'; TN = 0;
    stats{3,1} = 'FP'; FP = 0;
    stats{4,1} = 'FN'; FN = 0;
    stats{5,1} = 'Recall'; stats{5,2} = 0;
    stats{6,1} = 'Precision'; stats{6,2} = 0;
    stats{7,1} = 'Class. rate'; stats{7,2} = 0;

    for i = 1:length(computed)
        if(computed(i) == 1 && actual(i) == 1)
            TP = TP + 1;
        elseif(computed(i) == 0 && actual(i) == 0)
            TN = TN + 1;
        elseif(computed(i) == 1 && actual(i) == 0)
            FP = FP + 1;
        elseif(computed(i) == 0 && actual(i) == 1)
            FN = FN + 1;
        end
    end
    
    stats{1,2} = TP;
    stats{2,2} = TN;
    stats{3,2} = FP;
    stats{4,2} = FN;

    % Recall
    stats{5,2} = stats{1,2}/(stats{1,2}+stats{4,2});
    % Precision
    stats{6,2} = stats{1,2}/(stats{1,2}+stats{3,2});
    % Classification rate
    stats{7,2} = (stats{1,2}+stats{2,2})/(stats{1,2}+stats{2,2}+stats{3,2}+stats{4,2});
end