function VSData = func_setmatdir(whoami, new_dir, VSData)
% VSData = func_setmatdir(whoami, new_dir, VSData)
% Notes: Conditionally sets the global settings for mat directories
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

if (VSData.vars.linkmatdir)
    VSData.vars.matdir = new_dir;
    VSData.vars.PD_matdir = new_dir;
    VSData.vars.OT_matdir = new_dir;
    VSData.vars.OT_EGGdir = new_dir;
    VSData.vars.OTE_matdir = new_dir;
    VSData.vars.MD_matdir = new_dir;
    VSData.vars.OT_Textgriddir = new_dir;
    VSData.vars.OT_outputdir = new_dir;
    
    if (VSData.vars.OTE_saveEMUwithmat)
        VSData.vars.OTE_outputdir = new_dir;
    end
    
else % not linked, just update the requesting function
    VSData.vars.(whoami) = new_dir;
end


    