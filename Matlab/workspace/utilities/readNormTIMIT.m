function [ normtimit ] = readNormTIMIT(file,level)

    timit = audioread(file);
    power = sum(timit.^2/length(timit));
    normtimit = timit.*sqrt(level/power);

end