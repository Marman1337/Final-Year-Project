function plotAllROC(white,car,spchspect,babble,opsroom,factory,snr)

subplot(3,2,1); plotLine(white); grid;
title(strcat('white',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,2); plotLine(car); grid;
title(strcat('car',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,3); plotLine(spchspect); grid;
title(strcat('spchspect',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,4); plotLine(babble); grid;
title(strcat('babble',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,5); plotLine(opsroom); grid;
title(strcat('opsroom',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,6); plotLine(factory); grid;
title(strcat('factory',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');

%legend('Sohn','LTSD','Entropy','PARADE','Harmfreq');
legend('PEFAC','LTSD');
subplot(3,2,1); plotScatter(white);
subplot(3,2,2); plotScatter(car);
subplot(3,2,3); plotScatter(spchspect);
subplot(3,2,4); plotScatter(babble);
subplot(3,2,5); plotScatter(opsroom);
subplot(3,2,6); plotScatter(factory);

end

function plotLine(results)

hold on;
plot([1;results{1,2}(:,3);0],[1;results{1,2}(:,2);0],'b');
plot([1;results{2,2}(:,3);0],[1;results{2,2}(:,2);0],'r');
%plot([0;results{3,2}(:,3);1],[0;results{3,2}(:,2);1],'g');
%plot([1;results{4,2}(:,3);0],[1;results{4,2}(:,2);0],'m');
%plot([1;results{5,2}(:,3);0],[1;results{5,2}(:,2);0],'k');

end

function plotScatter(results)

hold on;
scatter(results{1,2}(:,3),results{1,2}(:,2),'.b');
scatter(results{2,2}(:,3),results{2,2}(:,2),'.r');
%scatter(results{3,2}(:,3),results{3,2}(:,2),'.g');
%scatter(results{4,2}(:,3),results{4,2}(:,2),'.m');
%scatter(results{5,2}(:,3),results{5,2}(:,2),'.k');

end