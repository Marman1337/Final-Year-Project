function [f0_time,f0_value,SHR,f0_candidates]=shrp(Y,Fs,F0MinMax,frame_length,timestep,SHR_Threshold,ceiling,med_smooth,CHECK_VOICING)
% SHRP - a pitch determination algorithm based on Subharmonic-to-Harmonic Ratio (SHR)
% [f0_time,f0_value,SHR,f0_candidates]=shrp(Y,Fs[,F0MinMax,frame_length,TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING]) 
%
%   Input parameters (There are 9):
%
%       Y:              Input data 
%       Fs:             Sampling frequency (e.g., 16000 Hz)
%       F0MinMax:       2-d array specifies the F0 range. [minf0 maxf0], default: [50 550]
%                       Quick solutions:
%                       For male speech: [50 250]
%                       For female speech: [120 400]
%       frame_length:   length of each frame in millisecond (default: 40 ms)
%       TimeStep:       Interval for updating short-term analysis in millisecond (default: 10 ms)
%       SHR_Threshold:  Subharmonic-to-harmonic ratio threshold in the range of [0,1] (default: 0.4). 
%                       If the estimated SHR is greater than the threshold, the subharmonic is regarded as F0 candidate,
%                       Otherwise, the harmonic is favored.
%       Ceiling:        Upper bound of the frequencies that are used for estimating pitch. (default: 1250 Hz)       
%       med_smooth:     the order of the median smoothing (default: 0 - no smoothing);                       
%       CHECK_VOICING:  check voicing. Current voicing determination algorithm is kind of crude.
%                       0: no voicing checking (default)
%                       1: voicing checking
%   Output parameters:
%       
%       f0_time:        an array stores the times for the F0 points
%       f0_value:       an array stores F0 values
%       SHR:            an array stores subharmonic-to-harmonic ratio for each frame
%		f0_candidates:  a matrix stores the f0 candidates for each frames, currently two f0 values generated for each frame.
%						Each row (a frame) contains two values in increasing order, i.e., [low_f0 higher_f0].
%						For SHR=0, the first f0 is 0. The purpose of this is that when you want to test different SHR
%						thresholds, you don't need to re-run the whole algorithm. You can choose to select the lower or higher
%						value based on the shr value of this frame. 	
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Permission to use, copy, modify, and distribute this software without fee is hereby granted
%	FOR RESEARCH PURPOSES only, provided that this copyright notice appears in all copies 
% 	and in all supporting documentation.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
%   
%   For details of the algorithm, please see 
%   Sun, X.,"Pitch determination and voice quality analysis using subharmonic-to-harmonic ratio" To appear in the Proc. of ICASSP2002, Orlando, Florida, May 13 -17, 2002.
%   For update information, please check http://mel.speech.nwu.edu/sunxj/pda.htm.
%
%   Copyright (c) 2001 Xuejing Sun
%   Department of Communication Sciences and Disorders
%   Northwestern University, USA
%   sunxj@northwestern.edu
%
%   Update history: 
%	Added "f0_candidates" as a return value, Dec. 21, 2001
%	Changed default median smoothing order from 5 to 0, Jan. 9, 2002
%   Modified the GetLogSpectrum function, bug fixed due to Herbert Griebel. Jan. 15, 2002
%   Several minor changes. Jan. 15,2002.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%t0 = clock;      
%------------------ Get input arguments values and set default values -------------------------
if nargin<9
    CHECK_VOICING=0;
end
if nargin<8
    med_smooth=0;
end
if nargin<7
    ceiling=1250;
end
if nargin<6
    SHR_Threshold=0.4; % subharmonic to harmonic ratio threshold
end
if nargin<5
    timestep=10;
   %timestep=6.4;
end
if nargin<4
    frame_length=40; % default 40 ms
end
if nargin<3
    minf0=50;
    maxf0=500;
else
    minf0=F0MinMax(1);
    maxf0=F0MinMax(2);
end
if nargin<2
    error('Sampling rate must be supplied!')
end
segmentduration=frame_length; 

%------------------- pre-processing input signal -------------------------
Y=Y-mean(Y); % remove DC component
Y=Y/max(abs(Y));  %normalization
total_len=length(Y);
%------------------ specify some algorithm-specific thresholds -------------------------
interpolation_depth=0.5;  % for FFT length
%--------------- derived thresholds specific to the algorithm -------------------------------
maxlogf=log2(maxf0/2);
minlogf=log2(minf0/2); % the search region to compute SHR is as low as 0.5 minf0.
N=floor(ceiling/minf0); % maximum number harmonics
m=mod(N,2);
N=N-m;
N=N*4; %In fact, in most cases we don't need to multiply N by 4 and get equally good results yet much faster.
% derive how many frames we have based on segment length and timestep.
segmentlen=round(segmentduration*(Fs/1000));
inc=round(timestep*(Fs/1000));
nf = fix((total_len-segmentlen+inc)/inc);
n=(1:nf);
f0_time=((n-1)*timestep+segmentduration/2)'; % anchor time for each frame, the middle point
%f0_time=((n-1)*timestep)'; % anchor time for each frame, starting from zero
%------------------ determine FFT length ---------------------
fftlen=1;
while (fftlen < segmentlen * (1 +interpolation_depth)) 
    fftlen =fftlen* 2;
end
%----------------- derive linear and log frequency scale ----------------
frequency=Fs*(1:fftlen/2)/fftlen; % we ignore frequency 0 here since we need to do log transformation later and won't use it anyway.
limit=find(frequency>=ceiling);
limit=limit(1); % only the first is useful
frequency=frequency(1:limit);
logf=log2(frequency);
%% clear some variables to save memory
clear frequency;
min_bin=logf(end)-logf(end-1); % the minimum distance between two points after interpolation
shift=log2(N); % shift distance
shift_units=round(shift/min_bin); %the number of unit on the log x-axis
i=(2:N);
% ------------- the followings are universal for all the frames ---------------%%
startpos=shift_units+1-round(log2(i)/min_bin);  % find out all the start position of each shift
index=find(startpos<1); % find out those positions that are less than 1
startpos(index)=1; % set them to 1 since the array index starts from 1 in matlab
interp_logf=logf(1):min_bin:logf(end);
interp_len=length(interp_logf);% new length of the amplitude spectrum after interpolation
totallen=shift_units+interp_len;
endpos=startpos+interp_len-1; %% note that : totallen=shift_units+interp_len;
index=find(endpos>totallen);
endpos(index)=totallen; % make sure all the end positions not greater than the totoal length of the shift spectrum

newfre=2.^(interp_logf); % the linear Hz scale derived from the interpolated log scale
upperbound=find(interp_logf>=maxlogf); % find out the index of upper bound of search region on the log frequency scale.
upperbound=upperbound(1);% only the first element is useful
lowerbound=find(interp_logf>=minlogf); % find out the index of lower bound of search region on the log frequency scale.
lowerbound=lowerbound(1);

%----------------- segmentation of speech ------------------------------
curpos=round(f0_time/1000*Fs);   % position for each frame in terms of index, not time
frames=toframes(Y,curpos,segmentlen,'hamm');
[nf framelen]=size(frames);
clear Y;
%----------------- initialize vectors for f0 time, f0 values, and SHR
f0_value=zeros(nf,1);
SHR=zeros(nf,1);
f0_time=f0_time(1:nf);
f0_candidates=zeros(nf,2);
%----------------- voicing determination ----------------------------
if (CHECK_VOICING)
    NoiseFloor=sum(frames(1,:).^2);   
    voicing=vda(frames,segmentduration/1000,NoiseFloor);
else
    voicing=ones(nf,1);
end
%------------------- the main loop -----------------------
curf0=0;
cur_SHR=0;
cur_cand1=0;
cur_cand2=0;
for n=1:nf
    segment=frames(n,:);
    curtime=f0_time(n);
    if voicing(n)==0
        curf0=0;
        cur_SHR=0;
    else
        [log_spectrum]=GetLogSpectrum(segment,fftlen,limit,logf,interp_logf);
        [peak_index,cur_SHR,shshift,all_peak_indices]=ComputeSHR(log_spectrum,min_bin,startpos,endpos,lowerbound,upperbound,N,shift_units,SHR_Threshold);
        if (peak_index==-1) % -1 indicates a possibly unvoiced frame, if CHECK_VOICING, set f0 to 0, otherwise uses previous value
            if (CHECK_VOICING)
                curf0=0;
                cur_cand1=0;
                cur_cand2=0;
            end
            
        else
            curf0=newfre(peak_index)*2;  
            if (curf0>maxf0)
                curf0=curf0/2;
            end
            if (length(all_peak_indices)==1)
            	cur_cand1=0;
            	cur_cand2=newfre(all_peak_indices(1))*2;
            else
            	cur_cand1=newfre(all_peak_indices(1))*2;
            	cur_cand2=newfre(all_peak_indices(2))*2;
            end	
            if (cur_cand1>maxf0)
                cur_cand1=cur_cand1/2;
            end
            if (cur_cand2>maxf0)
                cur_cand2=cur_cand2/2;
            end
            if (CHECK_VOICING)
                voicing(n)=postvda(segment,curf0,Fs);
                if (voicing(n)==0)
                    curf0=0;
                end
            end
        end
    end
    f0_value(n)=curf0;
    SHR(n)=cur_SHR;
    f0_candidates(n,1)=cur_cand1;
    f0_candidates(n,2)=cur_cand2;
    DEBUG=0;
    if DEBUG
        figure(9)
        %subplot(5,1,1),plot(segment,'*') 
        %title('windowed waveform segment')
        subplot(2,2,1),plot(interp_logf,log_spectrum,'k*')
        title('(a)')
        grid
        %('spectrum on log frequency scale')
        %grid
        shsodd=sum(shshift(1:2:N-1,:),1); 
        shseven=sum(shshift(2:2:N,:),1);
        difference=shseven-shsodd;
        subplot(2,2,2),plot(interp_logf,shseven,'k*')
        title('(b)')
        %title('even')
        grid
        subplot(2,2,3),plot(interp_logf,shsodd,'k*')
        title('(c)')
        %title('odd')
        grid
        subplot(2,2,4), plot(interp_logf,difference,'k*')
        title('(d)')
        %title('difference (even-odd)')   
        grid
        curtime
        curf0
        cur_SHR
        pause
    end
end
%-------------- post-processing -------------------------------
if (med_smooth > 0)
    f0_value=medsmooth(f0_value,med_smooth);
end
%f0=linsmooth(f0,5); % this is really optional.

%*****************************************************************************************
%-------------- do FFT and get log spectrum  ---------------------------------
%*****************************************************************************************
function [interp_amplitude]=GetLogSpectrum(segment,fftlen,limit,logf,interp_logf)
Spectra=fft(segment,fftlen);
amplitude = abs(Spectra(1:fftlen/2+1)); % fftlen is always even here. Note: change fftlen/2 to fftlen/2+1. bug fixed due to Herbert Griebel
amplitude=amplitude(2:limit+1); % ignore the zero frequency component
%amplitude=log10(amplitude+1);
interp_amplitude=interp1(logf,amplitude,interp_logf,'linear');
interp_amplitude=interp_amplitude-min(interp_amplitude);
%*****************************************************************************************
%-------------- compute subharmonic-to-harmonic ratio  ---------------------------------
%*****************************************************************************************
function [peak_index,SHR,shshift,index]=ComputeSHR(log_spectrum,min_bin,startpos,endpos,lowerbound,upperbound,N,shift_units,SHR_Threshold)
% computeshr: compute subharmonic-to-harmonic ratio for a short-term signal
len_spectrum=length(log_spectrum);
totallen=shift_units+len_spectrum;
shshift=zeros(N,totallen); %initialize the subharmonic shift matrix; each row corresponds to a shift version
shshift(1,(totallen-len_spectrum+1):totallen)=log_spectrum; % place the spectrum at the right end of the first row
% note that here startpos and endpos has N-1 rows, so we start from 2
% the first row in shshift is the original log spectrum
for i=2:N
    shshift(i,startpos(i-1):endpos(i-1))=log_spectrum(1:endpos(i-1)-startpos(i-1)+1); % store each shifted sequence
end
shshift=shshift(:,shift_units+1:totallen); % we don't need the stuff smaller than shift_units
shsodd=sum(shshift(1:2:N-1,:),1); 
shseven=sum(shshift(2:2:N,:),1);
difference=shseven-shsodd;
% peak picking process
SHR=0;
[mag,index]=twomax(difference,lowerbound,upperbound,min_bin); % only find two maxima
% first mag is always the maximum, the second, if there is, is the second max
NumPitchCandidates=length(mag);
if (NumPitchCandidates == 1) % this is possible, mainly due to we put a constraint on search region, i.e., f0 range
    if (mag <=0) % this must be an unvoiced frame
        peak_index=-1;
        return
    end
    peak_index=index;
    SHR=0;
else
    SHR=(mag(1)-mag(2))/(mag(1)+mag(2));
    if (SHR<=SHR_Threshold) 
        peak_index=index(2);  % subharmonic is weak, so favor the harmonic
    else
        peak_index=index(1); % subharmonic is strong, so favor the subharmonic as F0
    end
end
%%*****************************************************************************************
%******************    this function only finds two maximum peaks   ************************
function [mag,index]=twomax(x,lowerbound,upperbound,unitlen)
%In descending order, the magnitude and index are returned in [mag,index], respectively
lenx=length(x);
halfoct=round(1/unitlen/2); % compute the number of units of half octave. log2(2)=1; 1/unitlen
[mag,index]=max(x(lowerbound:upperbound));%find the maximum value
if (mag<=0)
    %    error('max is smaller than zero!') % return it!
    return
end
index=index+lowerbound-1;
harmonics=2;
LIMIT=0.0625; % 1/8 octave
startpos=index+round(log2(harmonics-LIMIT)/unitlen);
if (startpos<=min(lenx,upperbound))
    endpos=index+round(log2(harmonics+LIMIT)/unitlen); % for example, 100hz-200hz is one octave, 200hz-250hz is 1/4octave
    if (endpos> min(lenx,upperbound))
        endpos=min(lenx,upperbound);
    end
    [mag1,index1]=max(x(startpos:endpos));%find the maximum value at right side of last maximum 
    if (mag1>0)
        index1=index1+startpos-1;
        mag=[mag;mag1];
        index=[index;index1];
    end
end
%*****************************************************************************************
%%----------------------------------------------------------------------------------------
%%-----------------------------------voicing determination -------------------------------
function voice=vda(x,segmentdur,noisefloor,minzcr)
%voice=vda(x) determine whether the segment is voiced, unvoiced or silence
%this VDA is independent from the PDA process, and does not take advantage of the info derived from PDA
%thus, it requires more computation load.
if nargin<4
    %minzcr=2500; %unit: hertz
    minzcr=3000;
end
if nargin<3
    noisefloor=0.01;
end
[nf, len]=size(x);
voice=ones(nf,1);
engergy=sum(x.^2,2);
index=find(engergy<=noisefloor*3);
voice(index)=0;

%*****************************************************************************************
%% --------------------------------- determine the energy threshold for silence-------------------------
function thr=ethreshold(frames)
%%%%% use Rabiner and Sambur (1975) method
[nf,len]=size(frames);
lastpoint=1;
emax=0;
emin=0;
e=sum(frames.^2,2);
emax=max(e);
emin=min(e);
I1=0.03*(emax-emin)+emin;
I2=4*emin;
thr=25*min(I1,I2);

%*****************************************************************************************
%% ------------------- split signal into frames ---------------
function frames=toframes(input,curpos,segmentlen,wintype)
len=length(input);
numFrames=length(curpos);
frames=zeros(numFrames,segmentlen);
start=curpos-round(segmentlen/2);
offset=(0:segmentlen-1);
index_start=find(start<1); % find out those frames beyond the first point
start(index_start)=1; % for those, just use the first frame
endpos=start+segmentlen-1;
index=find(endpos>len);
endpos(index)=len; % duplicate the last several frames if window is over the limit.
start(index)=len+1-segmentlen;
frames(:)=input(start(:,ones(1,segmentlen))+offset(ones(numFrames,1),:));
[nf, len]=size(frames);
win=window(segmentlen,wintype);
frames = frames .* win(ones(nf,1),:);
%*****************************************************************************************
%-------------- post voicing checking ---------------------------------------------
function voicing=postvda(segment, curf0,Fs,r_threshold)
%%% check voicing again using estimated F0, which follows Hermes, SHS algorithm, JASA, 1988
if nargin<4
    r_threshold=0.2;
end
estimated_period=1/curf0;
mid_point=round(length(segment)/2);
num_points=round(estimated_period*Fs); % number of points in each period
start_point=mid_point-num_points;
end_point=mid_point+num_points;
if (start_point <1)
    start_point=1;
    mid_point=start_point+num_points;
    if (mid_point>length(segment)) % this is unreasonable, set f0 to zero
        voicing=0;
        return;
    end
end
segment1=segment(start_point:mid_point);
if (end_point>length(segment))
    end_point=length(segment);
    mid_point=end_point-num_points;
    if (mid_point<1) % this is unreasonable, set f0 to zero
        voicing=0;
        return;
    end
end
segment2=segment(mid_point:end_point);
len=min(length(segment1),length(segment2));
r=corrcoef(segment1(1:len),segment2(1:len));
r1=r(1,2);
if (r1<r_threshold) % correlation threshold
    voicing=0;
else
    voicing=1;
end
USE_ZCR=1;
if(USE_ZCR & voicing)
    zcr1=zcr(segment1,estimated_period);
    zcr2=zcr(segment2,estimated_period);
    %minzcr=2500;
    minzcr=3500;
    if (zcr1<minzcr | zcr2<minzcr)
        voicing=1;
    else
        voicing=0;
    end
end
%%*****************************************************************************************
%--------------------- Compute zero-crossing rate -------------------------------------------  
function zcr=zcr(x,dur)
% function zcr=zcr(x,dur) : compute zero-crossing rate
% x: input data
% x: duration of the input data
[nf,len]=size(x);
zcr=sum(0.5*abs(sign(x(:,2:len))-sign(x(:,1:len-1))))/dur;
%%*************************************************************************************
%--------------------- Window function -------------------------------------------  
function w = window(N,wt,beta)
%
%  w = window(N,wt)
%
%  generate a window function
%
%  N = length of desired window
%  wt = window type desired
%       'rect' = rectangular        'tria' = triangular (Bartlett)
%       'hann' = Hanning            'hamm'  = Hamming
%       'blac' = Blackman
%		  'kais' = Kaiser	
%
%  w = row vector containing samples of the desired window
% beta : used in Kaiser window

nn = N-1;
n=0:nn;
pn = 2*pi*(0:nn)/nn;
if wt(1,1:4) == 'rect',
    w = ones(1,N);
elseif wt(1,1:4) == 'tria',
    m = nn/2;
    w = (0:m)/m;
    w = [w w(ceil(m):-1:1)];
elseif wt(1,1:4) == 'hann',
    w = 0.5*(1 - cos(pn));
elseif wt(1,1:4) == 'hamm',
    w = .54 - .46*cos(pn);
elseif wt(1,1:4) == 'blac',
    w = .42 -.5*cos(pn) + .08*cos(2*pn);
elseif wt(1,1:4) == 'kais',
    if nargin<3
        error('you need provide beta!')
    end
    w =bessel1(beta*sqrt(1-((n-N/2)/(N/2)).^2))./bessel1(beta);   
else
    disp('Incorrect Window type requested')
end