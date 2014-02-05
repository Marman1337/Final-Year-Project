function [ ns ] = addNoise(s,n,fs,snrr)
    psig = activlev(s,fs);
    n = n(1:length(s));
    pnoi = sum(n.^2)/length(n);
    sc = sqrt(psig/(pnoi*10^(snrr/10)));
    n = n.*sc;
    ns = s + n;
end