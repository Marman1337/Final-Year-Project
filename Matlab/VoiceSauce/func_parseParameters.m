function new_paramlist = func_parseParameters(paramlist, handles, matfile, data_len)
% new_paramlist = func_parseParameters(paramlist, handles, matfile, data_len)
% sort through the parameter list and find dependencies, then output a new
% parameter list with the new param list
% also check data_len to ensure existing parameters have the same length 
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

VSData = guidata(handles.VSHandle);

% handles carries the F0 and FMT methods
F0algorithm = VSData.vars.F0algorithm;
FMTalgorithm = VSData.vars.FMTalgorithm;

% vector stores which param to enable:
%0 = disable, 1 = calculate, 2 = conditional calculate
new_param_vec = zeros(length(func_getparameterlist()), 1);  

for k=1:length(paramlist)
    if (strcmp(paramlist{k}, 'H1*-A1*, H1*-A2*, H1*-A3*'))
        new_param_vec(func_getparameterlist('H1*-A1*, H1*-A2*, H1*-A3*')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        new_param_vec(func_getparameterlist(FMTalgorithm)) = new_param_vec(func_getparameterlist(FMTalgorithm)) + 2;
        new_param_vec(func_getparameterlist('H1, H2, H4')) = new_param_vec(func_getparameterlist('H1, H2, H4')) + 2;
        new_param_vec(func_getparameterlist('A1, A2, A3')) = new_param_vec(func_getparameterlist('A1, A2, A3')) + 2;

    elseif (strcmp(paramlist{k}, 'H1*-H2*, H2*-H4*'))
        new_param_vec(func_getparameterlist('H1*-H2*, H2*-H4*')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        new_param_vec(func_getparameterlist(FMTalgorithm)) = new_param_vec(func_getparameterlist(FMTalgorithm)) + 2;    
        new_param_vec(func_getparameterlist('H1, H2, H4')) = new_param_vec(func_getparameterlist('H1, H2, H4')) + 2;
    
    elseif (strcmp(paramlist{k}, 'Energy'))
        new_param_vec(func_getparameterlist('Energy')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        
    elseif (strcmp(paramlist{k}, 'CPP'))
        new_param_vec(func_getparameterlist('CPP')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        
    elseif (strcmp(paramlist{k}, 'Harmonic to Noise Ratios - HNR'))
        new_param_vec(func_getparameterlist('Harmonic to Noise Ratios - HNR')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        
    elseif (strcmp(paramlist{k}, 'Subharmonic to Harmonic Ratio - SHR'))
        new_param_vec(func_getparameterlist('Subharmonic to Harmonic Ratio - SHR')) = 1;
        
    elseif (strcmp(paramlist{k}, 'A1, A2, A3'))
        new_param_vec(func_getparameterlist('A1, A2, A3')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        new_param_vec(func_getparameterlist(FMTalgorithm)) = new_param_vec(func_getparameterlist(FMTalgorithm)) + 2;

    elseif (strcmp(paramlist{k}, 'H1, H2, H4'))
        new_param_vec(func_getparameterlist('H1, H2, H4')) = 1;
        new_param_vec(func_getparameterlist(F0algorithm)) = new_param_vec(func_getparameterlist(F0algorithm)) + 2;
        
    elseif (strcmp(paramlist{k}, 'F1, F2, F3, F4 (Snack)'))
        new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Snack)')) = 1;

    elseif (strcmp(paramlist{k}, 'F1, F2, F3, F4 (Praat)'))
        new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Praat)')) = 1;        
        
    elseif (strcmp(paramlist{k}, 'F1, F2, F3, F4 (Other)') && VSData.vars.FormantsOtherEnable == 1)
        new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Other)')) = 1;
    
    elseif (strcmp(paramlist{k}, 'F0 (Straight)'))
        new_param_vec(func_getparameterlist('F0 (Straight)')) = 1;
        
    elseif (strcmp(paramlist{k}, 'F0 (Snack)'))
        new_param_vec(func_getparameterlist('F0 (Snack)')) = 1;
        
    elseif (strcmp(paramlist{k}, 'F0 (Praat)'))
        new_param_vec(func_getparameterlist('F0 (Praat)')) = 1;
        
    elseif (strcmp(paramlist{k}, 'F0 (SHR)'))
        new_param_vec(func_getparameterlist('F0 (SHR)')) = 1;
    
    elseif (strcmp(paramlist{k}, 'F0 (Other)') && VSData.vars.F0OtherEnable == 1)
        new_param_vec(func_getparameterlist('F0 (Other)')) = 1;
    end
    
end

% check the conditional parameters to see whether they already exist in the
% matfile
if (exist(matfile, 'file'))
    matdata = load(matfile);
    
    if (mod(new_param_vec(func_getparameterlist('F0 (Straight)')), 2) == 0 && isfield(matdata, 'strF0'))        
        if (length(matdata.strF0) == data_len)
            new_param_vec(func_getparameterlist('F0 (Straight)')) = 0;
        end
    end
    
    if (mod(new_param_vec(func_getparameterlist('F0 (Snack)')), 2) == 0 && isfield(matdata, 'sF0'))
        if (length(matdata.sF0) == data_len)
            new_param_vec(func_getparameterlist('F0 (Snack)')) = 0;
        end
    end

    if (mod(new_param_vec(func_getparameterlist('F0 (Praat)')), 2) == 0 && isfield(matdata, 'pF0'))
        if (length(matdata.pF0) == data_len)
            new_param_vec(func_getparameterlist('F0 (Praat)')) = 0;
        end
    end

    if (mod(new_param_vec(func_getparameterlist('F0 (SHR)')), 2) == 0 && isfield(matdata, 'shrF0'))
        if (length(matdata.shrF0) == data_len)
            new_param_vec(func_getparameterlist('F0 (SHR)')) = 0;
        end
    end   
    
    if (mod(new_param_vec(func_getparameterlist('F0 (Other)')), 2) == 0 && isfield(matdata, 'oF0'))
        if (length(matdata.sF0) == data_len)
            new_param_vec(func_getparameterlist('F0 (Other)')) = 0;
        end
    end
        
    if (mod(new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Snack)')), 2) == 0 && isfield(matdata, 'sF1'))
        if (length(matdata.sF1) == data_len)
            new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Snack)')) = 0;
        end
    end

    if (mod(new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Praat)')), 2) == 0 && isfield(matdata, 'pF1'))
        if (length(matdata.sF1) == data_len)
            new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Praat)')) = 0;
        end
    end    
    
    if (mod(new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Other)')), 2) == 0 && isfield(matdata, 'oF1'))
        if (length(matdata.sF1) == data_len)
            new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Other)')) = 0;
        end
    end    
    
    if (mod(new_param_vec(func_getparameterlist('A1, A2, A3')), 2) == 0 && isfield(matdata, 'A1'))
        if (length(matdata.A1) == data_len)
            new_param_vec(func_getparameterlist('A1, A2, A3')) = 0;
        end
    end
    
    if (mod(new_param_vec(func_getparameterlist('H1, H2, H4')), 2) == 0 && isfield(matdata, 'H1'))
        if (length(matdata.H1) == data_len)
            new_param_vec(func_getparameterlist('H1, H2, H4')) = 0;
        end
    end
    
end

new_param_vec(new_param_vec ~= 0) = 1;

% now build list with the proper processing order of the parameters
new_paramlist = cell(sum(new_param_vec), 1);
cnt = 1;

if (new_param_vec(func_getparameterlist('F0 (Straight)')) == 1)
    new_paramlist{cnt} = 'F0 (Straight)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F0 (Snack)')) == 1)
    new_paramlist{cnt} = 'F0 (Snack)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F0 (Praat)')) == 1)
    new_paramlist{cnt} = 'F0 (Praat)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F0 (SHR)')) == 1)
    new_paramlist{cnt} = 'F0 (SHR)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F0 (Other)')) == 1 && VSData.vars.F0OtherEnable == 1)
    new_paramlist{cnt} = 'F0 (Other)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Snack)')) == 1)
    new_paramlist{cnt} = 'F1, F2, F3, F4 (Snack)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Praat)')) == 1)
    new_paramlist{cnt} = 'F1, F2, F3, F4 (Praat)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('F1, F2, F3, F4 (Other)')) == 1 && VSData.vars.FormantsOtherEnable == 1)
    new_paramlist{cnt} = 'F1, F2, F3, F4 (Other)';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('A1, A2, A3')) == 1)
    new_paramlist{cnt} = 'A1, A2, A3';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('H1, H2, H4')) == 1)
    new_paramlist{cnt} = 'H1, H2, H4';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('Energy')) == 1)
    new_paramlist{cnt} = 'Energy';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('CPP')) == 1)
    new_paramlist{cnt} = 'CPP';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('Harmonic to Noise Ratios - HNR')) == 1)
    new_paramlist{cnt} = 'Harmonic to Noise Ratios - HNR';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('Subharmonic to Harmonic Ratio - SHR')) == 1)
    new_paramlist{cnt} = 'Subharmonic to Harmonic Ratio - SHR';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('H1*-H2*, H2*-H4*')) == 1)
    new_paramlist{cnt} = 'H1*-H2*, H2*-H4*';
    cnt = cnt + 1;
end

if (new_param_vec(func_getparameterlist('H1*-A1*, H1*-A2*, H1*-A3*')) == 1)
    new_paramlist{cnt} = 'H1*-A1*, H1*-A2*, H1*-A3*';
    cnt = cnt + 1;
end

