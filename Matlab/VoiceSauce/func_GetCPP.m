function CPP = func_GetCPP(y, Fs, F0, variables)
% CPP = func_GetCPP(y, Fs, F0, variables)
% Input:  y, Fs - from wavread
%         F0 - vector of fundamental frequencies
%         variables - global settings
% Output: CPP vector
% Notes:  Calculates the CPP according to the formula from Hillenbrand, 1994.
% Currently does not use textgrid information. For very very long files this 
% may be a process-bottleneck.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

N_periods = variables.Nperiods_EC;
sampleshift = (Fs / 1000 * variables.frameshift);

CPP = zeros(length(F0), 1) * NaN;

N_ms = round(Fs / 1000); % Quefrency below 1ms are ignored as per Hillenbrand

for k=1:length(F0)
    ks = round(k * sampleshift);
    
    if (ks <= 0 || ks > length(y))
        continue;
    end
    
    F0_curr = F0(k);
    
    if (isnan(F0_curr))
        continue;
    end
    
    N0_curr = Fs / F0_curr;
  
    ystart = round(ks - N_periods/2*N0_curr);
    yend = round(ks + N_periods/2*N0_curr) - 1;
    
    if (ystart <= 0)
        continue;
    end;
    
    if (yend > length(y)) 
        continue; 
    end;
  
    yseg = y(ystart:yend);  
    yseg = yseg .* hamming(length(yseg));  %windowing
    YSEG = fft(yseg);
    yseg_c = ifft(log(abs(YSEG)));
    yseg_c_db = 10*log10(yseg_c .^ 2);
  
    yseg_c_db = yseg_c_db(1:floor(length(yseg)/2));
    [vals, inx] = func_pickpeaks(yseg_c_db(N_ms:end)', 2*N0_curr);
    [pos, pinx] = min(abs(inx - N0_curr));
    
    if (~isempty(pinx))
        inx = inx(pinx(1));
        vals = yseg_c_db(inx+N_ms-1);
        p = polyfit([N_ms:length(yseg_c_db)], yseg_c_db(N_ms:end)', 1);        
        base_val = p(1) * (inx+N_ms-1) + p(2);
        CPP(k) = vals - base_val;
        
%     figure;
%     plot(yseg_c_db); hold on;
%     plot(inx+N_ms-1, vals, 'rx');
%     plot([N_ms:length(yseg_c_db)], polyval(p,[N_ms:length(yseg_c_db)]), 'g');
    
    end
    
end

