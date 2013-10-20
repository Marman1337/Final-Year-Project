function corr = func_correct_iseli_z(f, Fx, Bx, Fs)
% function corr = correct_iseli_z(f, Fx, Bx, Fs)
% Inverse-filtering of vocal tract resonance (formant). Correction is in dB, and dependent on Fs
% f  [Hz]: the frequency in question, e.g. Fo for the first harmonic, 2Fo for the second harmonic, or any other frequency
% Fx [Hz]: x-th formant frequency
% Bx [Hz]: x-th formant bandwidth (if you don't know the exact value, try an estimate)
% Fs [Hz]: sampling frequency
% Usage example for correction of first two harmonics regarding first formant F1/B1:
% H1_corr = H1 - correct_iseli_z(Fo,F1,B1_c,Fs);
% H2_corr = H2 - correct_iseli_z(2*Fo,F1,B1_c,Fs);
%
% Author: Markus Iseli, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2003
% BibTex entry:
% @INPROCEEDINGS{Iseli04,
%   AUTHOR =       "M. Iseli and A. Alwan",
%   TITLE =        "AN IMPROVED CORRECTION FORMULA FOR THE ESTIMATION OF HARMONIC MAGNITUDES AND ITS APPLICATION TO OPEN QUOTIENT ESTIMATION",
%   YEAR =         "1999",
%   volume =       "",
%   pages =        "",
%   address =      "Montreal, Canada",
%   month =        "May",
% }

r = exp(-pi*Bx/Fs);
omega_x = 2*pi*Fx/Fs;
omega  = 2*pi*f/Fs;
a = r.^2 + 1 - 2*r.*cos(omega_x + omega);
b = r.^2 + 1 - 2*r.*cos(omega_x - omega);
corr = -10*(log10(a)+log10(b));   % not normalized: H(z=0)~=0

num = r.^2 + 1 - 2*r.*cos(omega_x);   % sqrt of numerator, omega=0
corr = -10*(log10(a)+log10(b)) + 20*log10(num);     % normalized: H(z=0)=1