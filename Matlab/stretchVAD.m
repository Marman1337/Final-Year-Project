function [ out ] = stretchVAD(vad, lengthOut)

currentVal = vad(1);
startIndexVad = 1;
endIndexVad = 1;
lengthVad = length(vad);
count = 1;

out = zeros(lengthOut,1);

for i=2:length(vad)
    if(vad(i) == currentVal)
        count = count + 1;
    else
        endIndexVad = i-1;
        startProportion = startIndexVad/lengthVad;
        endProportion = endIndexVad/lengthVad;
        
        startIndexOut = round(startProportion*lengthOut);
        endIndexOut = round(endProportion*lengthOut);
        
        out(startIndexOut:endIndexOut,1) = currentVal;
        
        startIndexVad = i;
        currentVal = vad(i);
    end
end
end