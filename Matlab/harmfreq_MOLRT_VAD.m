%=========================================================================
% This is a statistical model-based speech/non-speech detection algorithm 
% in which the likelihood ratios (LRs) for voiced and unvoiced frames are
% computed differently: LR for voiced frames is calculated using only 
% the harmonic DFTs; for unvoiced frames, LR is calculated using all DFTs.
% 
% Input parameters: y - input speech samples
%                   fs - sampling freq (Hz)
%
% Output parameters: vad decisions (at rates specified by shiftTime)
%
% The VAD algorithm is described in the paper:
% L. N. Tan, B. J. Borgstrom and A. Alwan, "Voice Activity Detection using
% Harmonic Frequency Components in Likelihood Ratio Test," 
% ICASSP 2010, pp. 4466-4469.
%=========================================================================
function vad = harmfreq_MOLRT_VAD(y,fs)

% Parameters that one could tune for desired performance/application  
winTime = 0.05; % frame length (sec)
shiftTime = 0.01; % frame shift (sec)
M = 8; % No. of single-observation (SO) LRs to sum over to obtain the 
        % multiple-observation (MO) LR
thres = 20; % threshold for miss/FA trade-off
minf0 = 50; % min pitch
maxf0 = 400; % max pitch
ds_ratio = round(fs/2000); % downsample ratio is 1:ds_ratio
minpk = 0.3; % min peak magnitude for deciding whether a frame is voiced
%----------------------------------------------------------------------

winlen = round(winTime*fs);
winshft = round(shiftTime*fs);
fr_offset = floor((winlen-winshft)/winshft/2);
nfft = 2^nextpow2(winlen); % # of FFT bins
Nframes = floor((length(y)-(winlen-winshft))/winshft);
Nbins = nfft/2+1;
alp = 0.99;
minlag = floor((fs/ds_ratio)/maxf0); % min lag for acf peak
maxlag = ceil((fs/ds_ratio)/minf0); % max lag for acf peak
harm_pksep = zeros(Nframes,1);
geomLR = zeros(Nframes,1);
E = zeros(1,Nframes);
E_buf = zeros(1,10);
gamma1p5 = sqrt(pi)/2;

S = abs(spectrogram(y,winlen,winlen-winshft,nfft)).^2; % input power spectrum
noise_var = S(:,1); % initialize noise variances

for fr = 1:Nframes
    x = y((fr-1)*winshft+1:(fr-1)*winshft+winlen);
    E(fr) = x'*x;
    powspec = S(:,fr);
        
    postSNR = powspec./noise_var;
    prbY_1 = ones(Nbins,1);
    prbY_1(postSNR>=1) = postSNR(postSNR>=1);
    prbY_1 = prbY_1 - 1;
    if(fr==1)
        priorSNR = alp + (1-alp)*prbY_1;
    else
        priorSNR = alp*(A.^2)./noise_var + (1-alp)*prbY_1;
    end
    V = postSNR.*priorSNR./(1+priorSNR);
    logLR = V - log(1+priorSNR);
    Vdiv2 = V/2;
    A = gamma1p5*sqrt(V)./postSNR.*exp(-Vdiv2).*...
            ((1+V).*besseli_NOchkNum(0,Vdiv2) + V.*besseli_NOchkNum(1,Vdiv2)); 
    A(isnan(A)|isinf(A)) = 1;
    A = A.*sqrt(powspec);
    
    % Compute voicing information
    ds_x = resample(x,1,ds_ratio);
    acf = xcorr(ds_x,'coeff');
    acf = acf(length(ds_x):end);
    [pks,lags] = findpeaks(acf,'minpeakheight',minpk,'sortstr','descend');
    % Determine DFTs to use for LR computation
    if (~isempty(lags))
        lags = lags-1;
        oklags = find(lags>minlag & lags<maxlag);
        if ~isempty(oklags) % voiced frame with pitch within expected range
            harm_pksep(fr) = nfft/lags(oklags(1))/ds_ratio;
            bin_idx = zeros(floor(Nbins/(harm_pksep(fr)-1)),1);
            bin_ctr = 0;
            start_idx = round(harm_pksep(fr)-1);
            end_idx = round(harm_pksep(fr)+1);
            while(end_idx<=Nbins)
                bin_ctr = bin_ctr+1;
                [mx1, mx2] = max(powspec(start_idx:end_idx));
                bin_idx(bin_ctr) = start_idx+mx2-1;
                start_idx = round(bin_idx(bin_ctr)+harm_pksep(fr)-1);
                end_idx = round(bin_idx(bin_ctr)+harm_pksep(fr)+1);
            end
            bin_idx = bin_idx(1:bin_ctr);           
        else % unvoiced frame
            harm_pksep(fr) = 0;
            bin_idx = 1:Nbins;
        end
    else % unvoiced frame
        harm_pksep(fr) = 0;
        bin_idx = 1:Nbins;

    end  
    
    % Compute SOLR
    geomLR(fr) = mean(logLR(bin_idx));
     
    % Updating of noise variances
    if(fr==10)
        meanE = mean(E(1:10));
        stdE = std(E(1:10));
        thresE = meanE+stdE;
        E_buf = E(1:10);
        Ectr = 0;        
    end
    if(fr>10)
        if(E(fr)<thresE)
            noise_var = 0.1*powspec + 0.9*noise_var;
             Ectr = mod(Ectr,10)+1;
             E_buf(Ectr) = E(fr);
             meanE = mean(E_buf(1:10));
             stdE = std(E_buf(1:10));
             thresE = meanE+stdE;
        end
    else
        noise_var = 0.1*powspec + 0.9*noise_var;
    end
    
end
% Comput MOLR
moLR = winsum_input(geomLR,M);

% Apply threshold
vadtmp = moLR>thres;
vad = [zeros(fr_offset,1);vadtmp;zeros(fr_offset,1)];

function [w,ierr] = besseli_NOchkNum(nu,z,scale)
%BESSELI Modified Bessel function of the first kind.
%   I = BESSELI(NU,Z) is the modified Bessel function of the first kind,
%   I_nu(Z).  The order NU need not be an integer, but must be real.
%   The argument Z can be complex.  The result is real where Z is positive.
%
%   If NU and Z are arrays of the same size, the result is also that size.
%   If either input is a scalar, it is expanded to the other input's size.
%   If one input is a row vector and the other is a column vector, the
%   result is a two-dimensional table of function values.
%
%   I = BESSELI(NU,Z,0) is the same as BESSELI(NU,Z).
%
%   I = BESSELI(NU,Z,1) scales I_nu(z) by exp(-abs(real(z)))
%
%   [I,IERR] = BESSELI(NU,Z) also returns an array of error flags.
%       ierr = 1   Illegal arguments.
%       ierr = 2   Overflow.  Return Inf.
%       ierr = 3   Some loss of accuracy in argument reduction.
%       ierr = 4   Complete loss of accuracy, z or nu too large.
%       ierr = 5   No convergence.  Return NaN.
%
%   Examples:
%
%       besseli(3:9,(0:.2:10)',1) generates the entire table on page 423
%       of Abramowitz and Stegun, Handbook of Mathematical Functions.
%
%   This M-file uses a MEX interface to a Fortran library by D. E. Amos.
%
%   Class support for inputs NU and Z:
%      float: double, single
%
%   See also BESSELJ, BESSELY, BESSELK, BESSELH.

%   Reference:
%   D. E. Amos, "A subroutine package for Bessel functions of a complex
%   argument and nonnegative order", Sandia National Laboratory Report,
%   SAND85-1018, May, 1985.
%
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 5.16.4.2 $  $Date: 2005/06/21 19:37:29 $

if nargin == 2, scale = 0; end
[msg,nu,z,siz] = besschk_mod(nu,z); error(msg);
%[w,ierr] = besselmx(double('I'),nu,z,scale); % original code - does not work
%w = besselj(nu,z); % Bessel function of the 1st kind
%w = besseli(nu,z); % Modified Bessel function of the 1st kind
w = bessely(nu,z); % Bessel function of the 2nd kind
%w = besselk(nu,z); % Modified Bessel function of the 2nd kind
%w = besselh(nu,z); % Bessel function of the 3rd kind
% clean up w in case besselmx left an all-zero imaginary part
if ~isempty(w) && all(all(imag(w) == 0)), w = real(w); end
w = reshape(w,siz);

function [msg,nu,z,siz] = besschk_mod(nu,z)
%BESSCHK Check arguments to bessel functions.
%   [MSG,NU,Z,SIZ] = BESSCHK(NU,Z)

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.3 $  $Date: 2004/03/02 21:48:34 $

message = '';
siz = size(z);
% if ~isnumeric(nu) || ~isnumeric(z)
%    message = 'Arguments must be numeric.';
%    identifier = 'MATLAB:besschk:nonNumericInput';
% else
if ~isreal(nu)
   message = 'NU must be real';
   identifier = 'MATLAB:besschk:nonRealNU';
elseif length(nu) == 1
   % do nothing
elseif length(z) == 1
   z = z(ones(size(nu)));
   siz = size(z);
elseif isempty(nu) || isempty(z)
   siz = [length(z) length(nu)];
elseif automesh(nu,z)
   % If the increment in nu is 1, don't automesh since besselmx
   % will do the meshgrid and compute the result faster.
%   if all(diff(nu) == 1) & all(nu >= 0)
   if all((nu(2:end)-nu(1:end-1))== 1) && all(nu >= 0)
      siz = [length(z) length(nu)];
   else
      [nu,z] = meshgrid(nu,z);
      siz = size(z);
   end
elseif isequal(size(nu),size(z))
   % If the increment in nu is 1, then check for already meshgridded
   % inputs that can be unmeshed.  The result will still be gridded by
   % besselmx, it will just be computed faster.
%   if all(diff(nu(1,:)) == 1) & all(nu >= 0)
   if all((nu(1,2:end)-nu(1,1:end-1)) == 1) && all(nu >= 0)
      [nnu,zz] = meshgrid(nu(1,:),z(:,1));
      % If the inputs are already gridded, unmesh them.
      if isequal(nnu,nu) && isequal(zz,z),
         nu = nu(1,:);
         z = z(:,1);
         siz = [length(z) length(nu)];
      end
   end
elseif ~isequal(size(nu),size(z)), 
   message = 'NU and Z must be the same size.';
   identifier = 'MATLAB:besschk:NUAndZSizeMismatch';
end

if isempty(message)
    % Form empty Message Structure
    msg.message = '';
    msg.identifier = '';
    msg=msg(zeros(0,1));
else
    msg.message = message;
    msg.identifier = identifier;
end

% Function to compute MOLR from SOLR
function output = winsum_input(input,M)
wt_vec = ones(1,2*M+1);
L = length(wt_vec);
m = floor(L/2);
K = length(input);
new_vec = zeros(K+2*m,1);
new_vec(m+1:m+K) = input;
output = zeros(K,1);
for k = 1:K
    if(k<=m)
        wt = wt_vec;
        wt(1:m-k+1) = 0;
    elseif(K-k+1<=m)
        wt = wt_vec;
        wt(m+K-k+2:L) = 0;
    else
        wt = wt_vec;
    end
    output(k) = wt*new_vec(k:k+L-1);
end


