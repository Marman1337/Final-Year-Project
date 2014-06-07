function plotHistograms(ltsd1,pefac1,ltsd2,pefac2,bins,snr1,snr2)
    figure;
    subplot(2,2,1);
    h = bar(bins,ltsd1); grid;
    set(get(h, 'Parent'), 'XTick', 0:0.250:3);
    axis([0 3 0 0.5]);
    xlabel('Time (s)');
    ylabel('Proportion of errors');
    title(strcat('LTSD at',{' '},snr1,' dB'));
    subplot(2,2,2);
    h = bar(bins,pefac1); grid;
    set(get(h, 'Parent'), 'XTick', 0:0.250:3);
    axis([0 3 0 0.5]);
    xlabel('Time (s)');
    ylabel('Proportion of errors');
    title(strcat('PEFAC at',{' '},snr1,' dB'));
    
    subplot(2,2,3);
    h = bar(bins,ltsd2); grid;
    set(get(h, 'Parent'), 'XTick', 0:0.250:3);
    axis([0 3 0 0.5]);
    xlabel('Time (s)');
    ylabel('Proportion of errors');
    title(strcat('LTSD at',{' '},snr2,' dB'));
    subplot(2,2,4);
    h = bar(bins,pefac2); grid;
    set(get(h, 'Parent'), 'XTick', 0:0.250:3);
    axis([0 3 0 0.5]);
    xlabel('Time (s)');
    ylabel('Proportion of errors');
    title(strcat('PEFAC at',{' '},snr2,' dB'));
end