function [startIndex endIndex]=FindPeakIndexs(wholeTrace,runParameters)

startIndex=[];
endIndex=[];
delta =floor(length(wholeTrace)/10);
%aPeakIndicators =[];
for I=1:10
    StartIndexTrace=(delta*(I-1)+1);
    trace = wholeTrace(StartIndexTrace :I*delta);
    
%     disp('-------')
%     disp('60 hz noise')
%     disp('-------')
%     %Figure out the amount of 60hz noise that is in the file.  assumes
%     %50 khz sampling. this will take out the whole computer sometimes
%     %with the full data trace.  make sure to cut it down.
%     scales=520;
%     wname='cgau6';
%     %waveletCoef = cwt(trace,scales,wname);
%     %waveletCoef= downsample(abs(waveletCoef),8);
    
    disp('===============================')
    disp('PeakRangeFinder')
    %get an array of structs showing the start and end of each peak
    [allStarts allEnds] = PeakRangeFinder(trace,runParameters);
    
    startIndex =[startIndex allStarts+StartIndexTrace];
    endIndex =[endIndex allEnds+StartIndexTrace];
end

end