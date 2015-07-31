function [ slidingFreqTrace ] = makeSlidingFrequecyTrace(trace, startIndexs,endIndexs, peakFindParameters )
    halfWindow = peakFindParameters.clusterSize/2;
    maxSize =length(trace);
    sigma =  halfWindow/2;
    slidingFreqTrace = zeros([length(trace) 1]);
    
    midPeak =round( (startIndexs+endIndexs)/2);
    
    
    slidingFreqTrace(midPeak)=1;
    
    slidingFreqTrace=conv(slidingFreqTrace,exp(-1*( (-halfWindow:halfWindow) /sigma)^2));
end