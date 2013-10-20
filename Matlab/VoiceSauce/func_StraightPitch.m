function [F0, V] = func_StraightPitch(y, Fs, variables, textgridfile)
% [F0, V] = func_StraightPitch(y, Fs, variables, textgridfile)
% Input:  y, Fs - from wavread
%         variables - settings
%         textgridfile - this is optional
% Output: F0, V - F0 and voicing vectors
% Notes:  This function calls the Straight functions. Using textgrid
% segmentation helps to speed up the processing.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

maxF0 = variables.maxstrF0;
minF0 = variables.minstrF0;
maxdur = variables.maxstrdur;

prmF0in.DisplayPlots = 0;
prmF0in.ThresholdForVUV = 0.1;
prmF0in.ThresholdForSilence = 1;
prmF0in.F0searchLowerBound = minF0;
prmF0in.F0searchUpperBound = maxF0;
%prmF0in.VUVthresholdofAC1 = 0.9000;

warning off

% break up the file if it is too big (i.e. > 15sec)
if (nargin == 3)  % do the whole file, no textgrid data available
    L = floor(length(y)/Fs * 1000) - 1;    
    F0 = zeros(L, 1);

    if (length(y) / Fs > maxdur)
        % find suitable places to chop
        cnt = 1;
        startx = 1;
        endx = startx + floor(maxdur*Fs);
        isgood = 1;

        while(startx < length(y))
            if (startx == 1)
                yseg = y(startx : endx);  % extra millisecond
            else
                yseg = y(startx - floor(F0 / 1000) - 10 : endx);  % extra millisecond
            end
            %fprintf('Processing segment %d to %d\n', startx, endx);
            
            try    
                [F0seg, V, auxouts, prmF0out] = MulticueF0v14(yseg,Fs,prmF0in);
            catch
                isgood = 0;
                break;
            end
            
            F0(cnt:cnt+length(F0seg)-1) = F0seg;
            cnt = cnt + length(F0seg);
            startx = endx + 1;
            
            remainder = length(y) - endx - 1;
            if (remainder > maxdur*Fs)
                endx = startx + floor(maxdur*Fs);
            else
                endx = length(y);
            end
        end
        
        if (~isgood)  % multicue failed
            fprintf('Multicue failed: switching to exstraightsource\n');
            F0 = exstraightsource(y,Fs,prmF0in);
            F0 = F0(1:L)';
            V = ones(size(F0seg));
        end

    else
        try
            [F0, V, auxouts, prmF0out] = MulticueF0v14(y,Fs,prmF0in);
        catch
            fprintf('Multicue failed: switching to exstraightsource\n');
            F0 = exstraightsource(y,Fs, prmF0in);
            F0 = F0(1:L)';
            V = ones(size(F0));
        end
    end
else  % use textgrid data
    % get the labels to ignore from the settings
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
    start = start_tmp * 1000; % milliseconds
    stop = stop_tmp * 1000; % milliseconds
    
    L = floor(length(y) / Fs * 1000) - 1;
    
    F0 = zeros(L, 1) * NaN;
    V = zeros(L, 1) * NaN;
    
    for k=1:length(start)
        
        switch(labels{k})
            case ignorelabels
                continue;  % skip anything that is within the ignore list
        end
                
        tstart = start(k) - tbuffer;
        tstop = stop(k) + tbuffer;
        
        sstart = floor(tstart / 1000 * Fs);
        sstop = ceil(tstop / 1000 * Fs);
        
        sstart(sstart <= 0) = 1;
        sstop(sstop > length(y)) = length(y);
        
        yseg = y(sstart:sstop);

        try
            [F0seg, Vseg, auxouts, prmF0out] = MulticueF0v14(yseg,Fs,prmF0in);
        catch 
            fprintf('Multicue failed: switching to exstraightsource\n');
            F0seg = exstraightsource(yseg,Fs,prmF0in);
            F0seg = F0seg(2:end-1)';
            Vseg = ones(size(F0seg));
        end
        
        tstart = floor(tstart);
        tstart(tstart <= 0) = 1;
        F0(tstart:tstart+length(F0seg)-1) = F0seg;
        V(tstart:tstart+length(Vseg)-1) = Vseg;
        
        if (length(F0) > L)
            F0 = F0(1:L);
        end
        
    end
    
end

% sometimes Straight outputs 0s for F0
F0(F0 == 0) = NaN;