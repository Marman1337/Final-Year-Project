function plotSNR(results,hangover)

subplot(2,1,1); hold on; grid; set(gca,'XDir','Reverse')
axis([-5 20 0 1.01])
if(hangover == 1)
    title(strcat('Speech hit rate for the evaluated algorithms with hang-over under various SNRs'));
else
    title(strcat('Speech hit rate for the evaluated algorithms without hang-over under various SNRs'));
end
xlabel('SNR (dB)'); ylabel('Speech hit rate');
plot([20 15 10 5 0 -5],results{1,2}(1,:),'b','LineWidth',2);
plot([20 15 10 5 0 -5],results{2,2}(1,:),'r','LineWidth',2);
plot([20 15 10 5 0 -5],results{3,2}(1,:),'Color',[0 0.75 0],'LineWidth',2);
plot([20 15 10 5 0 -5],results{4,2}(1,:),'m','LineWidth',2);
plot([20 15 10 5 0 -5],results{5,2}(1,:),'k','LineWidth',2);
legend('Sohn','LTSD','Entropy','PARADE','Harmfreq','Orientation','horizontal');
scatter([20 15 10 5 0 -5],results{1,2}(1,:),200,'.b');
scatter([20 15 10 5 0 -5],results{2,2}(1,:),200,'.r');
scatter([20 15 10 5 0 -5],results{3,2}(1,:),200,'.','MarkerEdgeColor',[0 0.75 0]);
scatter([20 15 10 5 0 -5],results{4,2}(1,:),200,'.m');
scatter([20 15 10 5 0 -5],results{5,2}(1,:),200,'.k');

subplot(2,1,2); hold on; grid; set(gca,'XDir','Reverse')
axis([-5 20 0 1.01])
if(hangover == 1)
    title(strcat('Non-speech hit rate for the evaluated algorithms with hang-over under various SNRs'));
else
    title(strcat('Non-speech hit rate for the evaluated algorithms without hang-over under various SNRs'));
end
xlabel('SNR (dB)'); ylabel('Non-speech hit rate');
plot([20 15 10 5 0 -5],results{1,2}(2,:),'b','LineWidth',2);
plot([20 15 10 5 0 -5],results{2,2}(2,:),'r','LineWidth',2);
plot([20 15 10 5 0 -5],results{3,2}(2,:),'Color',[0 0.75 0],'LineWidth',2);
plot([20 15 10 5 0 -5],results{4,2}(2,:),'m','LineWidth',2);
plot([20 15 10 5 0 -5],results{5,2}(2,:),'k','LineWidth',2);
scatter([20 15 10 5 0 -5],results{1,2}(2,:),200,'.b');
scatter([20 15 10 5 0 -5],results{2,2}(2,:),200,'.r');
scatter([20 15 10 5 0 -5],results{3,2}(2,:),200,'.','MarkerEdgeColor',[0 0.75 0]);
scatter([20 15 10 5 0 -5],results{4,2}(2,:),200,'.m');
scatter([20 15 10 5 0 -5],results{5,2}(2,:),200,'.k');


end