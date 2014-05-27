function plotROC(white,car,spchspect,babble,opsroom,factory,whitep,carp,spchspectp,babblep,opsroomp,factoryp,snr)

subplot(3,2,1); plotLine(white,whitep); grid;
title(strcat('white',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,2); plotLine(car,carp); grid;
title(strcat('car',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,3); plotLine(spchspect,spchspectp); grid;
title(strcat('spchspect',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,4); plotLine(babble,babblep); grid;
title(strcat('babble',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,5); plotLine(opsroom,opsroomp); grid;
title(strcat('opsroom',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
subplot(3,2,6); plotLine(factory,factoryp); grid;
title(strcat('factory',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');

legend('Sohn','LTSD','Entropy','PARADE','Harmfreq','PEFAC');
subplot(3,2,1); plotScatter(white,whitep);
subplot(3,2,2); plotScatter(car,carp);
subplot(3,2,3); plotScatter(spchspect,spchspectp);
subplot(3,2,4); plotScatter(babble,babblep);
subplot(3,2,5); plotScatter(opsroom,opsroomp);
subplot(3,2,6); plotScatter(factory,factoryp);

end

function plotLine(results,resultP)

hold on;
plot([1;results{1,2}(:,3);0],[1;results{1,2}(:,2);0],'b');
plot([1;results{2,2}(:,3);0],[1;results{2,2}(:,2);0],'r');
plot([0;results{3,2}(:,3);1],[0;results{3,2}(:,2);1],'g');
plot([1;results{4,2}(:,3);0],[1;results{4,2}(:,2);0],'m');
plot([1;results{5,2}(:,3);0],[1;results{5,2}(:,2);0],'k');
plot([1;resultP{1,2}(:,3);0],[1;resultP{1,2}(:,2);0],'c');

end

function plotScatter(results,resultP)

hold on;
scatter(results{1,2}(:,3),results{1,2}(:,2),'.b');
scatter(results{2,2}(:,3),results{2,2}(:,2),'.r');
scatter(results{3,2}(:,3),results{3,2}(:,2),'.g');
scatter(results{4,2}(:,3),results{4,2}(:,2),'.m');
scatter(results{5,2}(:,3),results{5,2}(:,2),'.k');
scatter(resultP{1,2}(:,3),resultP{1,2}(:,2),'.c');

end