function func_VS2ssff(data, id, outfile, variables)
% func_VS2ssff(data, id, outfile, variables)
% Notes:  Saves the contents of a matfile into an EMU compatible output.
%
% Author: Yen-Liang Shue and Henry Tehrani, UCLA
% Copyright UCLA SPAPL 2009

% ssffsize=str2mat('CHAR', 'BYTE', 'SHORT', 'LONG', 'FLOAT', 'DOUBLE');
% matsize =str2mat('uchar', 'int8', 'int16', 'int32', 'float32', 'float64');

%create ssff header
samplerate = 1000 / variables.frameshift;
starttime = 0.0;
hdr=sprintf('%s\n', 'SSFF -- (c) SHLRC');
hdr=sprintf('%s%s\n', hdr, 'Machine IBM-PC');
hdr=sprintf('%s%s %i\n', hdr, 'Record_Freq', samplerate);
hdr=sprintf('%s%s %5.2f\n', hdr, 'Start_Time',starttime);
%hdr=sprintf('%s%s %s\n', hdr, 'Comment', comment);

hdr = sprintf('%s%s %s %s %i\n', hdr, 'Column', id, 'FLOAT', 1);
hdr=sprintf('%s%s\n', hdr, '-----------------');
%done with ssff header

% added 3/17/2010 - EMU is unable to read NaN
NaNvalue = str2double(variables.NotANumber);
if (isnan(NaNvalue))
    NaNvalue = 0;  % this is the default NaN value
end

data(isnan(data)) = NaNvalue;
data(isinf(data)) = NaNvalue;

fid=fopen(outfile,'w');
%write the header
fprintf(fid, '%s', hdr);
%write the parameter
fwrite(fid,data,'float32', 0,'ieee-le');

fclose(fid);



