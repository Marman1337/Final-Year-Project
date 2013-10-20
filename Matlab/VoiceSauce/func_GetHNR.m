function [HNR05, HNR15, HNR25, HNR35] = func_GetHNR(y, Fs, F0, variables)
% N = func_GetHNR(y, Fs, F0, variables, textgridfile
% Input:  y, Fs - from wavread
%         F0 - vector of fundamental frequencies
%         variables - global settings
%         textgridfile - this is optional
% Output: N vectors
% Notes:  Calculates the Harmonic to noise ratio based on the method
% described in de Krom, 1993 - A cepstrum-based technique for determining a
% harmonic-to-noise ratio in speech signals, JSHR.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

N_periods = variables.Nperiods_EC;
sampleshift = (Fs / 1000 * variables.frameshift);

HNR05 = zeros(length(F0), 1) * NaN;
HNR15 = zeros(length(F0), 1) * NaN;
HNR25 = zeros(length(F0), 1) * NaN;
HNR35 = zeros(length(F0), 1) * NaN;


for k=1:length(F0)
    ks = round(k * sampleshift);

    if (ks <= 0 || ks > length(y))
        continue;
    end

    F0_curr = F0(k);
    N0_curr = 1 / F0_curr * Fs;

    if (isnan(F0_curr))
        continue;
    end

    ystart = round(ks - N_periods/2*N0_curr);
    yend = round(ks + N_periods/2*N0_curr) - 1;

    if (mod(yend - ystart + 1, 2) == 0)  % length is even, make it odd
        yend = yend - 1;
    end

    if (ystart <= 0)
        continue;
    end;

    if (yend > length(y))
        continue;
    end;

    yseg = y(ystart:yend);


    hnr = getHNR(yseg, F0_curr, Fs, [500 1500 2500 3500]);

    HNR05(k) = hnr(1);
    HNR15(k) = hnr(2);
    HNR25(k) = hnr(3);
    HNR35(k) = hnr(4);

end


% main processing function
function n = getHNR(y, F0, Fs, Nfreqs)

NBins = length(y);
N0 = round(Fs / F0);
N0_delta = round(N0 * 0.1);  % search 10% either side

y = y .* hamming(length(y));
Y = fft(y, NBins);
aY = log10(abs(Y));
ay = ifft(aY);

% find possible rahmonic peaks
peakinx = zeros(floor(length(y)/ 2 / N0), 1);
for k=1:length(peakinx)
    ayseg = ay(k*N0 - N0_delta : k*N0 + N0_delta);
    [val, inx] = max(abs(ayseg));
    peakinx(k) = inx + k*N0 - N0_delta - 1;

    % lifter out each rahmonic peak
    s_ayseg = sign(diff(ayseg));
    
    % find first derivative sign change
    l_inx = inx - find((s_ayseg(inx-1:-1:1) ~= sign(inx)), 1) + 1;
    r_inx = inx + find((s_ayseg(inx+1:end) == sign(inx)), 1);
    
    l_inx = l_inx + k*N0 - N0_delta - 1;
    r_inx = r_inx + k*N0 - N0_delta - 1;
    
    % lifter out the peak
    ay(l_inx:r_inx) = 0;
   
end

% put the signal back together
midL = round(length(y) / 2) + 1;
ay(midL : end) = ay(midL - 1: -1 : midL - 1 - (length(ay) - midL));

Nap = real(fft(ay));
N = Nap;
Ha = aY - Nap;  % approximated harmonic spectrum

% calculate baseline corrections
Hdelta = F0 / Fs * length(y);
for f=Hdelta+0.0001:Hdelta:round(length(y)/2)
    fstart = ceil(f - Hdelta);
    
    Bdf = abs(min(Ha(fstart:round(f))));
    N(fstart:round(f)) = N(fstart:round(f)) - Bdf;
end

% calculate the average HNR for Nfreqs
H = aY - N;  %note that N is valid only for 1:length(N)/2
n = zeros(length(Nfreqs), 1);
for k=1:length(Nfreqs)
    Ef = round(Nfreqs(k) / Fs * length(y));  % equivalent cut off frequency
    n(k) = 20*mean(H(1:Ef)) - 20*mean(N(1:Ef));
end




