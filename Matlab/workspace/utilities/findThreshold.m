function findThreshold(white,car,spchspect,babble,opsroom,factory,snr)

figure; plotScatter(white); grid;
title(strcat('white',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
hold on; plot([0 1], [1 0],'c','LineWidth',2); plotLine(white)

figure; plotScatter(car); grid;
title(strcat('car',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
hold on; plot([0 1], [1 0],'c','LineWidth',2); plotLine(car)

figure; plotScatter(spchspect); grid;
title(strcat('spchspect',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
hold on; plot([0 1], [1 0],'c','LineWidth',2); plotLine(spchspect)

figure; plotScatter(babble); grid;
title(strcat('babble',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
hold on; plot([0 1], [1 0],'c','LineWidth',2); plotLine(babble)

figure; plotScatter(opsroom); grid;
title(strcat('opsroom',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
hold on; plot([0 1], [1 0],'c','LineWidth',2); plotLine(opsroom)

figure; plotScatter(factory); grid;
title(strcat('factory',{' '},snr,{' '},'dB')); ylabel('True Positive Rate'); xlabel('False Positive Rate');
hold on; plot([0 1], [1 0],'c','LineWidth',2); plotLine(factory)

end

function plotLine(results)

hold on;
plot([1;results{1,2}(:,3);0],[1;results{1,2}(:,2);0],'b');
plot([1;results{2,2}(:,3);0],[1;results{2,2}(:,2);0],'r');
plot([0;results{3,2}(:,3);1],[0;results{3,2}(:,2);1],'g');
plot([1;results{4,2}(:,3);0],[1;results{4,2}(:,2);0],'m');
plot([1;results{5,2}(:,3);0],[1;results{5,2}(:,2);0],'k');

end

function plotScatter(results)

hold on;
scatter(results{1,2}(:,3),results{1,2}(:,2),'.b');
scatter(results{2,2}(:,3),results{2,2}(:,2),'.r');
scatter(results{3,2}(:,3),results{3,2}(:,2),'.g');
scatter(results{4,2}(:,3),results{4,2}(:,2),'.m');
scatter(results{5,2}(:,3),results{5,2}(:,2),'.k');

end