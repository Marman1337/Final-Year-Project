function [ymax,inx] = func_pickpeaks(y, winlen)
% [ymax,inx] = func_pickpeaks(y, winlen)
% Input:  y - from wavread
%         winlen - size of window to use
% Output: ymax - peak values
%         inx - peak positions
% Notes:  
%
% Author: Yen-Liang Shue and Markus Iseli, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

% first, get all maxima
ymin = min(y);
y = y - ymin;
dy = [y(1); transpose(diff(y))];   % diff() gives a shift by 1: insert one sample
inx1 = diff(dy < 0);    % is +1 for maxima, -1 for minima
inx1(1) = 0; % do not accept maxima at begining
inx1(end) = 0; % do not accept maxima at end
inx = inx1 > 0;         % choose maxima only
ymax= y(inx);
inx = find(inx);
%plot(y);
%hold on;
%plot(inx,ymax,'or');
%hold off;

nofmax = length(ymax);
if nofmax==1
   return;
end
% now filter maxima with window of length winlen
for cnt = 1 : nofmax
   arr = inx(1:cnt);
   cmp = inx(cnt)-winlen;
   arr2 = arr>cmp;
   %ymax(arr2)
   [m, mi] = max(ymax(arr2));
   ymax(arr2)=-60000;
   ymax(mi+length(arr2)-sum(arr2))=m;
   %ymax(arr2)
end
temp = find(ymax>0);
inx  = inx(temp);
ymax = ymax(temp);
%plot(y);
%hold on;
%plot(inx,ymax,'or');
%hold off;
ymax = ymax + ymin;
