function plotROC(results)

%figure;
hold on;
scatter(results{1,2}(:,3),results{1,2}(:,2),'.b'); plot(results{1,2}(:,3),results{1,2}(:,2),'b');
scatter(results{2,2}(:,3),results{2,2}(:,2),'.r'); plot(results{2,2}(:,3),results{2,2}(:,2),'r');
scatter(results{3,2}(:,3),results{3,2}(:,2),'.g'); plot(results{3,2}(:,3),results{3,2}(:,2),'g');
scatter(results{4,2}(:,3),results{4,2}(:,2),'.m'); plot(results{4,2}(:,3),results{4,2}(:,2),'m');
scatter(results{5,2}(:,3),results{5,2}(:,2),'.k'); plot(results{5,2}(:,3),results{5,2}(:,2),'k');

end