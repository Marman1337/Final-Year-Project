function VSData = func_setwavdir(whoami, new_dir, VSData)
% VSData = func_setmatdir(whoami, new_dir, VSData)
% Notes: Conditionally sets the global settings for wav directories
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

if (VSData.vars.linkwavdir)
    VSData.vars.PD_wavdir = new_dir;
    VSData.vars.MD_wavdir = new_dir;
    VSData.vars.wavdir = new_dir;
else
    VSData.vars.(whoami) = new_dir;
end

