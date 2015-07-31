clusterPeakCount=zeros([100 1]);
for K=1:length(cleanedGroups.Peaks)
    peakIndexs=cleanedGroups.Peaks{K}.Train(:,2);
    
    clusterIndexs=peakIndexs;
    clusterIDX= unique(clusterIndexs);
    
    calledCorrectly=0;
    nClusters=0;
    for L=1:length(clusterIDX)
        IDX=find(clusterIndexs==clusterIDX(L));
        
        nPeaks = length(IDX);
        if nPeaks>100
            nPeaks=100;
        end
        
        if length(IDX)>0 
          
            clusterPeakCount(nPeaks)= clusterPeakCount(nPeaks) +1;
        end
    end
end