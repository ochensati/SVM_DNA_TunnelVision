function [clusterInfo,ClusterSeriesCalls]=ClassifyClusters(clusterInfo,peakIndexs, wholePredicted, K, uniqueS, nGroups)

afterCombineTotalRuns=0;
beforeBombineTotalRuns=0;

bins =0:nGroups;
%redo the predictions by cluster
predictedClusterGroup=zeros(size(wholePredicted));
clusterIndexs=peakIndexs(:,2)*10000 + peakIndexs(:,1);
clusterIDX= unique(clusterIndexs);

calledCorrectly=0;
nClusters=0;

ClusterSeriesCalls=[];

for L=1:length(clusterIDX)
    IDX=find(clusterIndexs==clusterIDX(L));
    if isempty(IDX)==0
        clusterCalls =wholePredicted(IDX);
        B=  histc(clusterCalls,bins);
        B(1)=0;
        [m newCall]=max(B);
        newCall=newCall-1;
        predictedClusterGroup(IDX)=newCall;
        
        nPeaks = length(IDX);
        if (nPeaks>100)
            nPeaks=100;
        end
        
        
        bestPeak=0;
        mix=zeros([1  nGroups]);
        maxRun=0;
        runCount =1;
        lPeak= clusterCalls(1);
        for peakI=2:nPeaks
            try
                mix(clusterCalls(peakI))=1;
            catch mex
              %  dispError(mex);
            end
            if clusterCalls(peakI)==lPeak
                runCount =runCount+1;
            else
                if runCount>maxRun
                    maxRun =runCount;
                    bestPeak=lPeak;
                    runCount=1;
                end
                lPeak = clusterCalls(peakI);
            end
            
        end
        
        if runCount>maxRun
            maxRun =runCount;
            bestPeak=lPeak;
        end
        
        
        if (newCall==K)
            corr=1;
            clusterInfo.goodMajority (nPeaks)=clusterInfo.goodMajority(nPeaks)+m;
            clusterInfo.goodRunLengths(nPeaks)=clusterInfo.goodRunLengths(nPeaks)+maxRun;
        else
            corr=0;
            
            clusterInfo.badRunLengths(nPeaks)=clusterInfo.badRunLengths(nPeaks)+maxRun;
            clusterInfo.badMixtures(nPeaks)=clusterInfo.badMixtures(nPeaks)+sum(mix);
            clusterInfo.badClusterPeakCount(nPeaks)=clusterInfo.badClusterPeakCount(nPeaks)+1;
        end
        
        
        if sum(B)>1
            
            ClusterSeriesCalls=[ClusterSeriesCalls newCall]; %#ok<AGROW>
            
            calledCorrectly =calledCorrectly + corr;
            clusterInfo.wholePerCluster=clusterInfo.wholePerCluster+corr;
            nClusters=nClusters+1;
            clusterInfo.whole_nPerCluster=clusterInfo.whole_nPerCluster+1;
            
            clusterInfo.clusterPeakAccuracy(nPeaks)= clusterInfo.clusterPeakAccuracy(nPeaks) + corr;
            
            if bestPeak ==K
                clusterInfo. runAccuracy(nPeaks)=clusterInfo.runAccuracy(nPeaks)+1;
                afterCombineTotalRuns=afterCombineTotalRuns+nPeaks;
                beforeBombineTotalRuns=beforeBombineTotalRuns+sum(B);
            end
            
            clusterInfo.clusterPeakCount(nPeaks)= clusterInfo.clusterPeakCount(nPeaks) +1;
            
            clusterInfo.sClusterPeakAccuracy(nPeaks,K)= clusterInfo.sClusterPeakAccuracy(nPeaks,K) + corr;
            clusterInfo.sClusterPeakCount(nPeaks,K)= clusterInfo.sClusterPeakCount(nPeaks,K) +1;
        end
    end
end



clusterInfo.perClusterAccuracy(K)=calledCorrectly/nClusters*100;
clusterInfo.predictedClusterGroups{K}=predictedClusterGroup(uniqueS);

clusterInfo.whole_cluster_correct=clusterInfo.whole_cluster_correct + length(find(predictedClusterGroup==K));
clusterInfo.whole_cluster_nPeaks=clusterInfo.whole_cluster_nPeaks + length(predictedClusterGroup);

clusterInfo.afterCombineTotalRuns=afterCombineTotalRuns/length(predictedClusterGroup)*100;
clusterInfo.beforeBombineTotalRuns=beforeBombineTotalRuns/length(uniqueS)*100;

end