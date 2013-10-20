function F0 = func_parseF0(matdata, F0algorithm)
% F0 = func_parseF0(matdata, F0algorithm)
% Input:  matdata - mat data
%         F0algorithm - F0 algorithm to use
% Output: F0 vectir
% Notes:  choose the F0 depending on what is specified
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009
F0 = [];
switch(F0algorithm)
    case {'F0 (Straight)'}
        if (isfield(matdata, 'strF0'))
            F0 = matdata.strF0;
        end
    case {'F0 (Snack)'}
        if (isfield(matdata, 'sF0'))
            F0 = matdata.sF0;
        end
    case {'F0 (Praat)'}
        if (isfield(matdata, 'pF0'))
            F0 = matdata.pF0;
        end
    case {'F0 (SHR)'}
        if (isfield(matdata, 'shrF0'))
            F0 = matdata.shrF0;
        end
    case {'F0 (Other)'}
        if (isfield(matdata, 'oF0'))
            F0 = matdata.oF0;
        end
    otherwise 
        F0 = []; 
end
