function [GeneralStats,perGroupStats]=RateClusterGroups(reorganizedGroups, clusterInfo)



wholeClusterTruePositive =0;
wholeClusterCount =0;


AccuracyTableColNames{ 1} ='Number of Clusters';
AccuracyTableColNames{ 2} ='All Cluster True/Positive';
AccuracyTableColNames{ 3} ='All Peaks Cluster True/Positive';
AccuracyTableColNames{4}='Run Accuracy (valid points)';
AccuracyTableColNames{5}='Run Accuracy (all points)';
%AccuracyTableColNames{ 4} ='per Cluster Peak Accuracy (cluster correct / nClusters)';

Accuracy{1}=clusterInfo.whole_nPerCluster;
Accuracy{2}=clusterInfo.wholePerCluster/clusterInfo.whole_nPerCluster*100;
Accuracy{3}=clusterInfo.whole_cluster_correct/clusterInfo.whole_cluster_nPeaks*100;
%Accuracy{4}=clusterInfo.perClusterAccuracy;
Accuracy{4}=clusterInfo.afterCombineTotalRuns;
Accuracy{5}=clusterInfo.beforeBombineTotalRuns;

title={'Accuracy per Cluster Length','Count Frequency','goodRunLengths','run accuracy','badRunLengths','badMixtures' };

for I=1:length(title)
    
    switch I
        case 2
            dataTable = clusterInfo.clusterPeakCount;
        case 1
            dataTable = clusterInfo.clusterPeakAccuracy;
        case 3
            dataTable = clusterInfo.goodRunLengths;
        case 4
            dataTable = clusterInfo.runAccuracy;
        case 5
            dataTable =clusterInfo.badRunLengths;
        case 6
            dataTable = clusterInfo.badMixtures;
    end
    
    nCols=20;
    colTitles =cell([nCols 1]);
    dataCellTable={dataTable(1:nCols)};
    for K=1:nCols
        colTitles{K}=[title{I} num2str(K)];
    end
    
    Accuracy=horzcat(Accuracy, dataCellTable{1}); %#ok<AGROW>
    Accuracy=horzcat(Accuracy,{ '    '}); %#ok<AGROW>
    AccuracyTableColNames = horzcat(AccuracyTableColNames, colTitles'); %#ok<AGROW>
    AccuracyTableColNames=horzcat(AccuracyTableColNames,{ '    '}); %#ok<AGROW>
end


perGroupStats=cell([1 length(reorganizedGroups.Peaks)]);
for K=1:length(reorganizedGroups.Peaks)
    colNames ={};
    dataTable ={};
    
    colNames{ 1} = [reorganizedGroups.Peaks{K}.GroupName ' after cluster (true/positive)'];
    colNames{ 2} = [reorganizedGroups.Peaks{K}.GroupName ' per cluster (true/positive)'];
    
    predictCluster= clusterInfo.predictedClusterGroups{K};
    
    truePositiveCluster =  length(find(predictCluster==K));
    wholeClusterTruePositive =wholeClusterTruePositive + truePositiveCluster;
    wholeClusterCount =wholeClusterCount + length(predictCluster);
    truePositiveCluster = truePositiveCluster / length(predictCluster) *100;
    
    dataTable{1}= truePositiveCluster;
    dataTable{2}= clusterInfo.perClusterAccuracy(K);
    
    
    title={[reorganizedGroups.Peaks{K}.GroupName 'group peak Frequency'] ,[reorganizedGroups.Peaks{K}.GroupName 'accuracy per peak Count']};
    
    for I=1:length(title)
        
        switch I
            case 1
                dataTableN = clusterInfo.sClusterPeakCount;
            case 2
                dataTableN = clusterInfo.sClusterPeakAccuracy;
        end
        
        colTitles =cell([40 1]);
        dataCellTable={dataTableN(1:40)};
        for M=1:40
            colTitles{M}=[title{I} num2str(M)];
        end
        
        dataTable=horzcat(dataTable, dataCellTable); %#ok<AGROW>
        colNames = horzcat(colNames, colTitles'); %#ok<AGROW>
    end
    
    perGroupStats{K}.ColNames =colNames;
    perGroupStats{K}.DataTable = dataTable;
end

ColNames=cell([length(clusterInfo.ClusterSeries) 1]);
goodFreqs=zeros([40 1]);
badFreqs=zeros([40 1]);
for K=1:length(clusterInfo.ClusterSeries)
    clusterCalls=clusterInfo.ClusterSeries{K};
    if (isempty(clusterCalls)==false)
        runCount =0;
        lPeak= clusterCalls(1);
        for peakI=1:length(clusterCalls)
            if clusterCalls(peakI)==lPeak
                runCount =runCount+1;
            else
                if (runCount>0)
                    if (runCount>39)
                        runCount = 39;
                    end
                    if (lPeak==K)
                        goodFreqs(runCount)=goodFreqs(runCount)+1;
                    else
                        badFreqs(runCount)=badFreqs(runCount)+1;
                    end
                end
                lPeak = clusterCalls(peakI);
                runCount=1;
            end
        end
        
         if (runCount>0 && runCount<size(goodFreqs,1))
                    if (lPeak==K)
                        goodFreqs(runCount)=goodFreqs(runCount)+1;
                    else
                        badFreqs(runCount)=badFreqs(runCount)+1;
                    end
         end
                
    end
   % disp(goodFreqs);
end

for K=1:length(goodFreqs)
    ColNames{K}= ['Good Frequency ' num2str(K)];
    data{K}=goodFreqs(K); %#ok<AGROW>
    
    ColNamesB{K}= ['Bad Frequency ' num2str(K)]; %#ok<AGROW>
    dataB{K}=badFreqs(K); %#ok<AGROW>
end
AccuracyTableColNames=horzcat( horzcat(AccuracyTableColNames,ColNames'),ColNamesB);
Accuracy=horzcat( horzcat(Accuracy,data),dataB);


GeneralStats.ColNames = AccuracyTableColNames;
GeneralStats.DataTable = Accuracy;
end