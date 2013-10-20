function E = func_GetEnergy(y, F0, Fs, variables)
% E = func_GetEnergy(y, F0, Fs, variables)
% Input:  y, Fs - from wavread
%         F0 - vector of fundamental frequencies
%         variables - global settings
% Output: Energy vector
% Notes:  Calculates the energy, normalized for F0. This is done by using a
% variable length window consisting of 5 pitch periods, according to the F0
% at a particular point in time.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

N_periods = variables.Nperiods_EC;
sampleshift = (Fs / 1000 * variables.frameshift);

E = zeros(length(F0), 1) * NaN;

for k=1:length(F0)
  ks = round(k * sampleshift);
  
  if (ks <= 0 || ks > length(y))
      continue;
  end
 
  F0_curr = F0(k);
  
  if (isnan(F0_curr))
      continue;
  end
  
  N0_curr = Fs/F0_curr;
  
  ystart = round(ks - N_periods/2 * N0_curr);
  yend = round(ks + N_periods/2 * N0_curr) - 1;
  
  if (ystart <= 0)
    continue;
  end
  
  if (yend > length(y))
    continue;
  end
  
  yseg = y(ystart:yend);
  
  E(k) = sum(yseg .^ 2);
    
end
  
