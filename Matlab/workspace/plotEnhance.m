function plotEnhance(clean,noisy,fs,label)

noEnhance = simpleVAD(noisy,fs,0.05,0);
Enhance1 = simpleVAD(noisy,fs,0.05,1);
Enhance2 = simpleVAD(noisy,fs,0.05,2);

figure;
subplot(3,1,1);
plot(noisy);
hold on;
plot(clean,'g');
plot(1.1*max(noisy).*noEnhance,'r');
title(strcat(label,{' '},'noenhance'));

subplot(3,1,2);
plot(noisy);
hold on;
plot(clean,'g');
plot(1.1*max(noisy).*Enhance1,'r');
title(strcat(label,{' '},'enhance specsub'));

subplot(3,1,3);
plot(noisy);
hold on;
plot(clean,'g');
plot(1.1*max(noisy).*Enhance2,'r');
title(strcat(label,{' '},'enhance ssubmmse'));
end