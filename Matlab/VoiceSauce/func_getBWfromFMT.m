function BW = func_getBWfromFMT(FMT, voiced, method)
% formant to bandwidth mapping function
%
% Author: Yen-Liang Shue and Markus Iseli, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

if (nargin == 2) % use the Mannell formula
    BW = (80 + 120 * FMT/5000) * (2 - voiced);

elseif (nargin == 3 && strcmp(method, 'hm')) % use the  Hawks and Miller formula
    F0 = voiced;
    BW = getbw_HawksMiller(FMT, F0)';
    
end


%-------------------------------------------------------------------------
function BW = getbw_HawksMiller(FMT,F0)
% Reference: Hawks, Miller, "A formant bandwidth estimation procedure for vowel
% synthesis," JASA, vol 97, no. 2, 1995

[r, c] = size(FMT);
if (r > c)
    FMT = FMT';
end

S = 1+0.25*(F0-132)/88; % bandwidth scaling factor as a function of F0

% coefficients C1 (for Fx<500 Hz) and C2 (Fx>=500Hz)
C1 = [165.327516, -6.73636734e-1, 1.80874446e-3, -4.52201682e-6, 7.49514000e-9, -4.70219241e-12];
C2 = [15.8146139, 8.10159009e-2, -9.79728215e-5, 5.28725064e-8, -1.07099364e-11, 7.91528509e-16];

F = [ones(1, length(FMT)); FMT; FMT.^2; FMT.^3; FMT.^4; FMT.^5];
mask = FMT<500; % Fx < 500 Hz
mask = repmat(mask,length(C1),1);

BW = S' .* (C1*(F .* mask) + C2*(F .* ~mask));
