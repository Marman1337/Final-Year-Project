function [A1, A2, A3] = func_GetA1A2A3(y, Fs, F0, F1, F2, F3, variables, textgridfile)
% [A1, A2, A3] = func_GetA1A2A3(y, Fs, F0, F1, F2, F3, variables, textgridfile)
% Input:  y - input signal
%         Fs - sampling frequency
%         F0 - fundamental frequency (vector)
%         F1-F3 - formant frequencies (vectors)
%         variables - settings from VS
%         textgridfile - textgrid filename if available (optional)
% Output: A1, A2, A3 - uncorrected amplitudes of the spectra at the formant
% frequencies.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

N_periods = variables.Nperiods;
sampleshift = (Fs / 1000 * variables.frameshift);

A1 = zeros(length(F0), 1) * NaN;
A2 = zeros(length(F0), 1) * NaN;
A3 = zeros(length(F0), 1) * NaN;

if (nargin == 7)

    for k=1:length(F0)
        ks = round(k * sampleshift);
        
        if (ks <= 0 || ks > length(y))
            continue;
        end
        
        F0_curr = F0(k);
        
        if (isnan(F0_curr) || F0_curr == 0) 
            continue; 
        end

        N0_curr = 1 / F0_curr * Fs;
               
        ystart = round(ks - N_periods/2*N0_curr);
        yend = round(ks + N_periods/2*N0_curr) - 1;
        
        if (ystart <= 0) 
            continue; 
        end;
        
        if (yend > length(y)) 
            continue; 
        end;
        
        yseg = y(ystart:yend);
        
        % proceed if no NaNs detected
        if (~isnan(F1(k)) && ~isnan(F2(k)) && ~isnan(F3(k)) && ~isnan(N0_curr))
            [A1_, fmax] = ana_GetMagnitudeMax(yseg, F1(k), Fs, 8192);
            [A2_, fmax] = ana_GetMagnitudeMax(yseg, F2(k), Fs, 8192);
            [A3_, fmax] = ana_GetMagnitudeMax(yseg, F3(k), Fs, 8192);

            A1(k) = A1_;
            A2(k) = A2_;
            A3(k) = A3_;
        end    
    end
else
    % use textgrids - get ignore string list
    tbuffer = variables.tbuffer;
    ignorelabels = textscan(variables.TextgridIgnoreList, '%s', 'delimiter', ',');
    ignorelabels = ignorelabels{1};   
    
    [labels, start, stop] = func_readTextgrid(textgridfile);
    labels_tmp = [];
    start_tmp = [];
    stop_tmp = [];
    
    for k=1:length(variables.TextgridTierNumber)
        inx = variables.TextgridTierNumber(k);
        if (inx <= length(labels))
            labels_tmp = [labels_tmp; labels{inx}];
            start_tmp = [start_tmp; start{inx}];
            stop_tmp = [stop_tmp; stop{inx}];
        end
    end
    
    labels = labels_tmp;
    start = start_tmp;
    stop = stop_tmp; 
    
    
    for m=1:length(start)
        switch(labels{m})
            case ignorelabels
                continue;  % skip anything that is within the ignore list
        end
        
        kstart = round((start(m) * 1000 - tbuffer) / variables.frameshift);
        kstop = round((stop(m) * 1000 + tbuffer) / variables.frameshift);
        kstart(kstart <= 0) = 1;
        kstop(kstop > length(F0)) = length(F0);
        
        ystart = round(kstart * sampleshift);
        ystop = round(kstop * sampleshift);
        ystart(ystart <= 0) = 1;
        ystop(ystop > length(y)) = length(y);
        
        ysegment = y(ystart:ystop);
        F0seg = F0(kstart:kstop);
        F1seg = F1(kstart:kstop);
        F2seg = F2(kstart:kstop);
        F3seg = F3(kstart:kstop);
               
        for k=1:length(F0seg)
            ks = round(k*sampleshift);
            
            if (ks <= 0 || ks > length(ysegment))
                continue;
            end
            
            F0_curr = F0seg(k);
            if (isnan(F0_curr) || F0_curr == 0)
                continue;
            end
            
            N0_curr = Fs/F0_curr;
            ysstart = round(ks - N_periods/2 * N0_curr);
            ysend = round(ks + N_periods/2 * N0_curr) - 1;
            
            if (isnan(F1seg(k)) || isnan(F2seg(k)) || isnan(F3seg(k)))
                continue;
            end
            
            if (ysstart <= 0) 
                continue; 
            end;
            if (ysend > length(ysegment)) 
                continue; 
            end;
            
            yseg = ysegment(ysstart:ysend);
            
            [A1_, fmax] = ana_GetMagnitudeMax(yseg, F1seg(k), Fs, 8192);
            [A2_, fmax] = ana_GetMagnitudeMax(yseg, F2seg(k), Fs, 8192);
            [A3_, fmax] = ana_GetMagnitudeMax(yseg, F3seg(k), Fs, 8192);
            
            inx = kstart + k - 1;
            if (inx <= length(A1))
                A1(inx) = A1_;
                A2(inx) = A2_;
                A3(inx) = A3_;
            end                
        
        end
    
    end
end


%------------------------------------------------------------------------
function [M,fmax] = ana_GetMagnitudeMax(x, Fx, Fs, fftlen)
% Get maximal spectral magnitude of signal x around position Fx Hz in dB
% Fx can be a vector of frequency points
% Note that the bigger fftlen the better the resolution

if (isnan(Fx))
  M = NaN;
  fmax = NaN;
else

  len = length(x);
  hamlen = min(fftlen, len);
  %X = fft(hamming(hamlen).*x(1:hamlen), fftlen);
  factor = 1;  %/length(x);  % not exactly Kosher but compatible to dfs_magn()
  X = fft(x,fftlen);
  X(X==0) = 0.000000001;  % guard against log(0) warnings
  X = 20*log10(factor*abs(X(1:fftlen/2, :)));
  fstep = Fs / fftlen;
  lowf = Fx-0.1*Fx;
  if (lowf<0) lowf=0; end
  highf = Fx+0.1*Fx;
  if (highf>Fs/2-fstep) highf=Fs/2-fstep; end

  for cnt = 1:length(Fx)
      [M(cnt),pos] = max(X(1+round(lowf(cnt)/fstep):1+round(highf(cnt)/fstep), :));
      fmax(cnt) = (pos-1+round(lowf(cnt)/fstep))*fstep;
  end
  
end

% f=0:fstep:(Fs/2-fstep);
% plot(f,X); hold;
% plot(pos, M, 'rx'); hold off;
% fprintf('End get_magnitude_max()\n');
