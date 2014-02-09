function plotROC(results)

figure;
hold on;
scatter(results{1,2}(:,3),results{1,2}(:,2),'.b'); plot([1;results{1,2}(:,3);0],[1;results{1,2}(:,2);0],'b');
scatter(results{2,2}(:,3),results{2,2}(:,2),'.r'); plot([1;results{2,2}(:,3);0],[1;results{2,2}(:,2);0],'r');
scatter(results{3,2}(:,3),results{3,2}(:,2),'.g'); plot([0;results{3,2}(:,3);1],[0;results{3,2}(:,2);1],'g');
scatter(results{4,2}(:,3),results{4,2}(:,2),'.m'); plot([1;results{4,2}(:,3);0],[1;results{4,2}(:,2);0],'m');
scatter(results{5,2}(:,3),results{5,2}(:,2),'.k'); plot([1;results{5,2}(:,3);0],[1;results{5,2}(:,2);0],'k');

end