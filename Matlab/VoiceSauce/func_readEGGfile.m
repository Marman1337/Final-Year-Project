function [EGGData, FrameT] = func_readEGGfile(EGGfile, EGGheaders, EGGtimelabel)
% [EGGData, FrameT] = func_readEGGfile(EGGfile, EGGheaders, EGGtimelabel)
% Input:  EGGfile - .egg file name
%         EGGheaders - headers to look for in the .egg file
%         EGGtimelabel - label representing time
% Output: EGGData
%         FrameT - time vector
% Notes:  
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

fid = fopen(EGGfile, 'r');
tmp = textscan(fid, '%s', 1, 'delimiter', '\n');
data = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

EGGheaders = textscan(EGGheaders, '%s', 'delimiter', ',');
EGGheaders = EGGheaders{1};

% find the index of the "Entry definition and order" header
headers = textscan(tmp{1}{1}, '%s', 'delimiter', '\t');
inx = 0;
for k=1:length(headers{1})
    if (strcmp(removeExtraSpace(headers{1}{k}), 'Entry definition and order'))
        inx = k;
        break;
    end
end

% now extract the entry definition from the next data
defn = textscan(data{1}{1}, '%s', 'delimiter', '\t');
defn = defn{1}{inx};

defn_headers = textscan(defn, '%s', 'delimiter', ':,');
EGGInx = [];

for k=1:length(EGGheaders)
    for n=1:length(defn_headers{1})
        str = removeExtraSpace(defn_headers{1}{n});
        if (strcmp(EGGheaders{k}, str) == 1)
            EGGInx = [EGGInx n];
            break;
        end
        
        if (n==length(defn_headers{1}))
            EGGInx = [EGGInx -1];  % header was not found, set err code
        end
    end
end

% now extract the time data
for k=1:length(defn_headers{1})
    if (strcmp(EGGtimelabel, defn_headers{1}{k}) == 1)
        FrameInx = k;
        break;
    end
end

EGGInx = EGGInx + 1;
FrameInx = FrameInx + 1;

FrameT = zeros(1, length(data{1}));
EGGData = cell(1, length(EGGInx));
for k=1:length(EGGInx)
    EGGData{k} = zeros(1, length(data{1}));
end

for k=1:length(data{1})
    dat = textscan(data{1}{k}, '%s', 'delimiter', '\t');
    FrameT(k) = str2num(dat{1}{FrameInx});
    
    for n=1:length(EGGInx)
        if (EGGInx(n) ~= 0)
            val = str2double(dat{1}{EGGInx(n)});
            if (isnan(val))
                val = 0;
            end
            EGGData{n}(k) = val;
        end
    end
end


% removes extra spaces at the start and end of words
function str = removeExtraSpace(s)
str = s;
while (1)
    if (str(1) == ' ')
        str = str(2:end);
    else
        break;
    end
end

while(1)
    if (str(end) == ' ')
        str = str(1:end-1);
    else
        break;
    end
end