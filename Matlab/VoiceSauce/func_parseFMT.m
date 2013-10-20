function [F1, F2, F3] = func_parseFMT(matdata, FMTalgorithm)
% [F1, F2, F3] = func_parseFMT(matdata, FMTalgorithm)
% Input:  matdata - mat data
%         FMTalgorithm - FMT algorithm to use
% Output: F1, F2, F3 vectir
% Notes:  choose the FMT vectors depending on what is specified
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

F1 = []; F2 = []; F3 = [];

switch(FMTalgorithm)
    case {'F1, F2, F3, F4 (Snack)'}
        if (isfield(matdata, 'sF1') && isfield(matdata, 'sF2') && isfield(matdata, 'sF3'))
            F1 = matdata.sF1;
            F2 = matdata.sF2;
            F3 = matdata.sF3;
        end
        
    case {'F1, F2, F3, F4 (Praat)'}
        if (isfield(matdata, 'pF1') && isfield(matdata, 'pF2') && isfield(matdata, 'pF3'))
            F1 = matdata.pF1;
            F2 = matdata.pF2;
            F3 = matdata.pF3;
        end
        
    case {'F1, F2, F3, F4 (Other)'}
        if (isfield(matdata, 'oF1') && isfield(matdata, 'oF2') && isfield(matdata, 'oF3'))
            F1 = matdata.oF1;
            F2 = matdata.oF2;
            F3 = matdata.oF3;
        end
        
    otherwise
        F1 = [];
        F2 = [];
        F3 = [];
        
end