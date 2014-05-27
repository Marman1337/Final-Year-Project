function plotSNRPEFAC(results,hangover)

subplot(2,1,1); hold on; grid; set(gca,'XDir','Reverse')
axis([-15 20 0 1.01])
if(hangover == 1)
    title(strcat('Speech hit rate for the evaluated algorithms with hang-over under various SNRs'));
else
    title(strcat('Speech hit rate for the evaluated algorithms without hang-over under various SNRs'));
end
xlabel('SNR (dB)'); ylabel('Speech hit rate');
plot([20 15 10 5 0 -5 -10 -15],results{1,2}(1,:),'b','LineWidth',2);
plot([20 15 10 5 0 -5 -10 -15],results{2,2}(1,:),'r','LineWidth',2);
%plot([20 15 10 5 0 -5],results{3,2}(1,:),'g');
%plot([20 15 10 5 0 -5],results{4,2}(1,:),'m');
%plot([20 15 10 5 0 -5],results{5,2}(1,:),'k');
%legend('Sohn','LTSD','Entropy','PARADE','Harmfreq','Orientation','horizontal');
legend('PEFAC','LTSD','Orientation','horizontal');
scatter([20 15 10 5 0 -5 -10 -15],results{1,2}(1,:),200,'.b');
scatter([20 15 10 5 0 -5 -10 -15],results{2,2}(1,:),200,'.r');
%scatter([20 15 10 5 0 -5],results{3,2}(1,:),'.g');
%scatter([20 15 10 5 0 -5],results{4,2}(1,:),'.m');
%scatter([20 15 10 5 0 -5],results{5,2}(1,:),'.k');

subplot(2,1,2); hold on; grid; set(gca,'XDir','Reverse')
axis([-15 20 0 1.01])
if(hangover == 1)
    title(strcat('Non-speech hit rate for the evaluated algorithms with hang-over under various SNRs'));
else
    title(strcat('Non-speech hit rate for the evaluated algorithms without hang-over under various SNRs'));
end
xlabel('SNR (dB)'); ylabel('Non-speech hit rate');
plot([20 15 10 5 0 -5 -10 -15],results{1,2}(2,:),'b','LineWidth',2);
plot([20 15 10 5 0 -5 -10 -15],results{2,2}(2,:),'r','LineWidth',2);
%plot([20 15 10 5 0 -5],results{3,2}(2,:),'g');
%plot([20 15 10 5 0 -5],results{4,2}(2,:),'m');
%plot([20 15 10 5 0 -5],results{5,2}(2,:),'k');
scatter([20 15 10 5 0 -5 -10 -15],results{1,2}(2,:),200,'.b');
scatter([20 15 10 5 0 -5 -10 -15],results{2,2}(2,:),200,'.r');
%scatter([20 15 10 5 0 -5],results{3,2}(2,:),'.g');
%scatter([20 15 10 5 0 -5],results{4,2}(2,:),'.m');
%scatter([20 15 10 5 0 -5],results{5,2}(2,:),'.k');

end