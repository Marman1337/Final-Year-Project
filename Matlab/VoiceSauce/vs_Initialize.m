function vars = vs_Initialize()

% check if program is running on PC or a max/unix
if (ispc)
    vars.dirdelimiter = '\';
else
    vars.dirdelimiter = '/';
end

vars.wavdir = ['.' vars.dirdelimiter];
vars.matdir = ['.' vars.dirdelimiter];

vars.windowsize = 25;
vars.frameshift = 1;
vars.preemphasis = 0.96;
vars.NotANumber = '0';
vars.maxstrF0 = 500;  % straight takes longer for higher F0
vars.minstrF0 = 40;
vars.maxF0 = 500;    % snack settings
vars.minF0 = 40;
vars.maxstrdur = 10;  % 10 seconds
vars.tbuffer = 25;  % extend this amount if using textgrid segmentation
vars.F0OtherEnable = 0;
vars.F0OtherOffset = 0;
vars.F0OtherCommand = '';
vars.FormantsOtherEnable = 0;
vars.FormantsOtherOffset = 0;
vars.FormantsOtherCommand = '';
vars.TextgridIgnoreList = '"", " ", "SIL"';
vars.TextgridTierNumber = 1;
vars.frame_precision = 1;  % [KY 20101016]: how many frames can you be off by in aligning data vectors by timepoint

%F0 Praat stuff
vars.F0Praatmax = 500;  % praat F0 settings
vars.F0Praatmin = 40;
vars.F0PraatVoiceThreshold = 0.45;
vars.F0PraatOctiveJumpCost = 0.35;
vars.F0PraatSilenceThreshold = 0.03;
vars.F0PraatVoiceThreshold = 0.45;
vars.F0PraatOctaveCost = 0.01;
vars.F0PraatOctaveJumpCost = 0.35;
vars.F0PraatVoicedUnvoicedCost = 0.14;
vars.F0PraatKillOctaveJumps = 0; 
vars.F0PraatSmooth = 0;
vars.F0PraatSmoothingBandwidth = 5;
vars.F0PraatInterpolate = 0; % interpolate over missing values
vars.F0Praatmethod = 'cc'; % set cross-correlation as default for Praat f0 estimation

vars.recursedir = 0;
vars.linkmatdir = 1;
vars.linkwavdir = 1;

vars.Nperiods = 3;  % this sets out many pulses to use in the parameter estimation
vars.Nperiods_EC = 5;  % both energy, CPP  and HNR calculations use this - larger window, more averaging

% Set subharmonic-to-harmonic ratio (SHR) parameters (KY)
vars.SHRmax = 500; % upper bound for f0 candidates
vars.SHRmin = 40; % lower bound for f0 candidates
vars.SHRThreshold = 0.4; % threshold for SHR for choosing pitch halved candidate

vars.EGGheaders = 'CQ, CQ_H, CQ_PM, CQ_HT, peak_Vel, peak_Vel_Time, min_Vel, min_Vel_Time, SQ2-SQ1, SQ4-SQ3, ratio';
vars.EGGtimelabel = 'Frame';

% default parameters
vars.F0algorithm = 'F0 (Straight)';
vars.FMTalgorithm = 'F1, F2, F3, F4 (Snack)';

% Parameters from Parameter Estimation (PE)
%vars.PE_searchsubdir = 1;
vars.PE_savematwithwav = 1;
vars.PE_processwith16k = 1;
vars.PE_useTextgrid = 1;
vars.PE_showwaveforms = 0;
vars.PE_params = func_getparameterlist();

% Parameters from Parameter Display (PD)
vars.PD_wavdir = vars.wavdir;
vars.PD_matdir = vars.matdir;
vars.PD_paramselection = [];

% Parameters from Output to Text (OT)
vars.OT_selectedParams = [];
vars.OT_matdir = vars.matdir;  % default to the mat dir
vars.OT_includesubdir = 1;
vars.OT_Textgriddir = vars.matdir;
vars.OT_includeEGG = 0;
vars.OT_EGGdir = vars.matdir;
vars.OT_outputdir = vars.matdir;
vars.OT_includeTextgridLabels = 1;
vars.OT_columndelimiter = 1;  % default is tab
vars.OT_noSegments = 1;
vars.OT_useSegments = 0;
vars.OT_numSegments = 9;
vars.OT_singleFile = 1;
vars.OT_multipleFiles = 0;

vars.OT_singleFilename = 'output.txt';
vars.OT_F0CPPEfilename = 'F0_CPP_E_HNR.txt';
vars.OT_Formantsfilename = 'Formants.txt';
vars.OT_Hx_Axfilename = 'HA.txt';
vars.OT_HxHxfilename = 'HxHx.txt';
vars.OT_HxAxfilename = 'HxAx.txt';
vars.OT_EGGfilename = 'EGG.txt';

vars.OT_Single = [vars.OT_outputdir vars.OT_singleFilename];
vars.OT_F0CPPE = [vars.OT_outputdir vars.OT_F0CPPEfilename];
vars.OT_Formants = [vars.OT_outputdir vars.OT_Formantsfilename];
vars.OT_HA = [vars.OT_outputdir vars.OT_Hx_Axfilename];
vars.OT_HxHx = [vars.OT_outputdir vars.OT_HxHxfilename];
vars.OT_HxAx = [vars.OT_outputdir vars.OT_HxAxfilename];
vars.OT_EGG = [vars.OT_outputdir vars.OT_EGGfilename];

% parameters for Manual Data
vars.MD_wavdir = vars.wavdir;
vars.MD_matdir = vars.matdir;
vars.MD_offset = 0;
vars.MD_resample = 0;
vars.MD_invalidentry = '0, NaN';
vars.MD_matwithwav = 1;

% parameters for Output To EMU
vars.OTE_matdir = vars.matdir;
vars.OTE_outputdir = vars.matdir;
vars.OTE_paramselection = [];
vars.OTE_saveEMUwithmat = 1;

% parameters for Outputs
vars.O_smoothwinsize = 20;

% parameters for Input (wav) files
vars.I_searchstring = '*.wav';

% these variables are not set in the gui
vars.PD_plottype = {'b', 'r', 'g', 'k', 'c', 'b:', 'r:', 'g:', 'k:', 'c:', 'b--', 'r--', 'g--', 'k--', 'c--'};
vars.PD_maxplots = length(vars.PD_plottype);

