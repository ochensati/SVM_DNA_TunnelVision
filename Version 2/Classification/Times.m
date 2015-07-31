function [nPlatTime, nSpikesTime, platTime,platHeights, spikeHeights]=Times(shortData,smoothData,windowSize,spikeHeightCut)

try 
remain=shortData-smoothData;
remain=remain(1:10000);

idx=  peakfinder(remain,10,100,1);

noise=std(remain);

x =( (shortData-mean(shortData))/noise );
idxP= peakfinder(x,1,1,1);
spikeHeights=mean(smoothData(idxP));
if isempty(idxP)==false
    level = 1;
    [c,l] = wavedec(x,level,'haar');
    
    wCoefP=zeros([level,length(idxP)]);
    for I=1:level
        d1 =( detcoef(c,l,I));
        d1=interpft(d1,round(length(x)/length(d1))*length(d1));
        d1P=d1(idxP);
        wCoefP(I,:)=abs(d1P);
    end
    
    s1=wCoefP(1,:);
    idxSpike1 = find(s1>spikeHeightCut);
    nSpikesTime=length(idxSpike1 );
else
    nSpikesTime=0;
end

smoothed =find( abs(smoothData- smooth(smoothData,windowSize))<noise) ;

didx=smoothed(2:end)-smoothed(1:end-1);
idx=find(didx~=1);

platHeights =mean(smoothData( smoothed(idx)));

platTime = mean( idx(2:end)-idx(1:end-1));
nPlatTime = length(idx);% length(smoothed)/length(smoothData);

catch mex
    nPlatTime=0;
    nSpikesTime=0;
    platTime=0;
   platHeights=0; 
   spikeHeights=0;
end

end
