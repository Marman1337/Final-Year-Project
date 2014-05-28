function investigateVAD(s,n,ref,snrr,fs,vadfn)

    ns = addNoise(s,n,fs,snrr);
    vad = vadfn(ns,fs,0.05,0);
    figure;
    plot(ns,'y'); hold on;
    plot(s,'b');
    plot(0.4*vad,'r');
    plot(-0.4*ref,'Color',[0 0.75 0])

end