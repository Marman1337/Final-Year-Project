function [ AUC ] = calculateAUC(white,car,spchspect,babble,opsroom,factory)
AUC = cell(8,6);
AUC{2,1} = 'white';
AUC{3,1} = 'car';
AUC{4,1} = 'spchspect';
AUC{5,1} = 'babble';
AUC{6,1} = 'opsroom';
AUC{7,1} = 'factory';
AUC{8,1} = 'average';
AUC{1,2} = 'Sohn';
AUC{1,3} = 'LTSD';
AUC{1,4} = 'Entropy';
AUC{1,5} = 'PARADE';
AUC{1,6} = 'Harmfreq';

auc(1,:) = singleAUC(white);
auc(2,:) = singleAUC(car);
auc(3,:) = singleAUC(spchspect);
auc(4,:) = singleAUC(babble);
auc(5,:) = singleAUC(opsroom);
auc(6,:) = singleAUC(factory);

for i = 1:6
    for j = 1:5
        AUC{i+1,j+1} = auc(i,j);
    end
end

AUC = AUC';

for i = 2:6
    AUC{i,8} = (1/6)*(AUC{i,2}+AUC{i,3}+AUC{i,4}+AUC{i,5}+AUC{i,6}+AUC{i,7});
end

end

function [ AUC ] = singleAUC(results)

AUC = zeros(1,5);
AUC(1) = trapz(flipud([1;results{1,2}(:,3);0]),flipud([1;results{1,2}(:,2);0]));
AUC(2) = trapz(flipud([1;results{2,2}(:,3);0]),flipud([1;results{2,2}(:,2);0]));
AUC(3) = trapz([0;results{3,2}(:,3);1],[0;results{3,2}(:,2);1]);
AUC(4) = trapz(flipud([1;results{4,2}(:,3);0]),flipud([1;results{4,2}(:,2);0]));
AUC(5) = trapz(flipud([1;results{5,2}(:,3);0]),flipud([1;results{5,2}(:,2);0]));

end