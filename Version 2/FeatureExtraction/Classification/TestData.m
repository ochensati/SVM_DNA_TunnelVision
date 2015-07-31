function [extraInfo,GeneralStats,perGroupStats,wholeTruePositive,Singlefilled,allCalls]=TestData(reorganizedGroups,runParams, colNumbers, commonSVM ,anomolySVM, allPeaksSVM,extraInfo)

disp('initialize Training');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%cluster Preps%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clusterInfo.bins =0:length(reorganizedGroups.Peaks);
clusterInfo.clusterPeakAccuracy=zeros([100 1]);
clusterInfo.clusterPeakCount =zeros([100 1]);

clusterInfo.sClusterPeakAccuracy=zeros([100 length(reorganizedGroups.Peaks)]);
clusterInfo.sClusterPeakCount =zeros([100 length(reorganizedGroups.Peaks)]);
clusterInfo.badRunLengths = zeros([100 1]);
clusterInfo.goodRunLengths = zeros([100 1]);
clusterInfo.badMixtures =  zeros([100 1]);
clusterInfo.goodMajority = zeros([100 1]);

clusterInfo.badClusterPeakCount =  zeros([100 1]);
clusterInfo.perClusterAccuracy=zeros([length(reorganizedGroups.Peaks) 1]);
clusterInfo.runAccuracy=zeros([100 1]);
clusterInfo.wholePerCluster=0;
clusterInfo.whole_nPerCluster=0;
clusterInfo.whole_cluster_correct=0;
clusterInfo.whole_cluster_nPeaks=0;
clusterInfo.ClusterSeries=cell([length(reorganizedGroups.Peaks) 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%peak Preps
TestingPoints =0;
Class=[];
nPossibleTestPoints =0;
AnomPoints =0;
allCalls = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%run each dataset through the svm to see what is predicted
for K=1:length(reorganizedGroups.Peaks)
    %once again, find all the peaks that fall into the common pit
    disp('split indexs');
    peakIndexs= reorganizedGroups.Peaks{K}.Test(:,1:3);
    tSingleGroup= reorganizedGroups.Peaks{K}.Test(:,colNumbers);
    nPossibleTestPoints =nPossibleTestPoints + size(tSingleGroup,1);
    
    if (length(colNumbers)==2)
%         
%         
%         figure(reorganizedGroups.Peaks{K}.Graph);
%         scatter(tSingleGroup(:,1),tSingleGroup(:,2));
%         drawnow;
%         hold all;
%         tSingleGroupT= reorganizedGroups.Peaks{K}.Train(:,colNumbers);
%         scatter(tSingleGroupT(:,1),tSingleGroupT(:,2));
%         drawnow;
    end
    
    if isempty(commonSVM)==false
        disp('one class');
        classify = svmoneclassval(tSingleGroup,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
        uniqueS=find(classify<commonSVM.threshold);
        common=find(classify>commonSVM.threshold);
        for KK=1:length(common)
            extraInfo{peakIndexs(common(KK),1)}{peakIndexs(common(KK),3)}.Rating=3;
        end
        tSingleGroup=tSingleGroup(uniqueS,:);
    else
        uniqueS=1:size(tSingleGroup,1);
        common=[];
    end
    
    if isempty(anomolySVM)==false
        disp('one class');
        classify = svmoneclassval(tSingleGroup,anomolySVM.xsup,anomolySVM.alpha,anomolySVM.rho,anomolySVM.kernel,anomolySVM.kerneloption);
        uniqueA=find(classify<anomolySVM.threshold);
        anomaly=find(classify>anomolySVM.threshold);
        for KK=1:length(anomaly)
            extraInfo{peakIndexs(uniqueS(anomaly(KK)),1)}{peakIndexs(uniqueS(anomaly(KK)),3)}.Rating=4;
        end
        uniqueS=uniqueS(uniqueA);
        tSingleGroup=tSingleGroup(uniqueA,:);
    else
      %  uniqueS=1:size(tSingleGroup,1);
        anomaly=[];
    end
    
    
    Class=vertcat(Class, ones([size(tSingleGroup,1) 1])*K);
    %Testing=vertcat(Testing, tSingleGroup); %#ok<*AGROW>
    TestingPoints =TestingPoints + size(tSingleGroup,1);
    AnomPoints=AnomPoints+length(anomaly);
    
    disp('get groups');
    try
        predictedGroup  = svmmultivaloneagainstone(tSingleGroup,allPeaksSVM.xsup,allPeaksSVM.w,allPeaksSVM.b,allPeaksSVM.nbsv,allPeaksSVM.kernel,allPeaksSVM.kerneloption);
    catch mex
        disp('++++++++++++++++++++++++++++++++++++++++++++++');
        disp('svm error testing');
       try
            dispError(mex);
            disp(mex.identifier);
            disp(mex.message);
            disp(mex.stack(1));
            disp(mex.stack(2));
            disp(mex.stack(3));
        catch 
            
        end
        predictedGroup = zeros([size(tSingleGroup,1) 1]);
    end
    predictedGroups{K}=predictedGroup;
    
    
    wholePredicted = zeros([size(peakIndexs,1 ) 1]);
    %mark all the peaks in the peak tracker
    for KK=1:length(uniqueS)
        wholePredicted(uniqueS(KK))=predictedGroup(KK);
        d=predictedGroup(KK)+4;
        extraInfo{peakIndexs(uniqueS(KK),1)}{peakIndexs(uniqueS(KK),3)}.Rating=d;
%         if predictedGroups{K}(KK)==K
%             extraInfo{peakIndexs(uniqueS(KK),1)}{peakIndexs(uniqueS(KK),3)}.Rating=4;
%         else
%             extraInfo{peakIndexs(uniqueS(KK),1)}{peakIndexs(uniqueS(KK),3)}.Rating=5;
%         end
    end
    
    %if K==2  % record the ratios of the peak calling for the test
    calls =[];
    try 
        calls = histc(predictedGroup,0:(allPeaksSVM.kernalProps.nbclass+1));
        calls(1)=0;
        calls=calls/sum(calls)*100;
        calls(1)=K;
        allCalls = horzcat(allCalls,calls); %#ok<AGROW>
    catch mex
       try
            dispError(mex);
            disp(mex.identifier);
            disp(mex.message);
            disp(mex.stack(1));
            disp(mex.stack(2));
            disp(mex.stack(3));
        catch 
            
        end
    end
   % end
    
    disp('classify clusters');
    [clusterInfo,CS]=ClassifyClusters(clusterInfo,peakIndexs, wholePredicted, K, uniqueS,length(reorganizedGroups.Peaks));
    clusterInfo.ClusterSeries{K}=CS;
end




ColNames{1}='Good For Testing';
ColNames{2}='Anomalies';
DataTable {1} =  TestingPoints/nPossibleTestPoints*100;
DataTable {2} =AnomPoints/nPossibleTestPoints*100;
disp(['Good for Testing' num2str(DataTable{1})]);

if runParams.Calc_Accuracy_Spreads
    highestN=40;
    [tSingleGroup Singlefilled]=RateFrequencies(predictedGroups,highestN);
    %convert to cell array to make saving easier
    %     for JJJ=1:length(tSingleGroup)
    %         ColNames{2+JJJ}=['Run Length'  num2str(JJJ)]; %#ok<*AGROW>
    %         ColNames{2+JJJ+length(tSingleGroup)}=['Fully filled' num2str(JJJ)];
    %         DataTable{2+JJJ}=tSingleGroup(JJJ);
    %         DataTable{2+JJJ+length(tSingleGroup)}= Singlefilled(JJJ);
    %     end
    %
    for JJJ=1:length(reorganizedGroups.Peaks)
        Singlefilled{JJJ*3-1,1}=reorganizedGroups.Peaks{JJJ}.GroupName;
    end
else
    Singlefilled=[];
end


disp('final cluster');
%%%%%%%%%%%%%%%%%%% finalize all the cluster info for all the groups

clusterInfo.badRunLengths= clusterInfo.badRunLengths./clusterInfo.badClusterPeakCount;
clusterInfo.badMixtures = clusterInfo.badMixtures./clusterInfo.badClusterPeakCount;

clusterInfo.goodRunLengths=clusterInfo.goodRunLengths./clusterInfo.clusterPeakAccuracy;

clusterInfo.goodMajority= clusterInfo.goodMajority./clusterInfo.clusterPeakAccuracy;
clusterInfo.clusterPeakAccuracy= clusterInfo.clusterPeakAccuracy./clusterInfo.clusterPeakCount*100;
clusterInfo.runAccuracy=clusterInfo.runAccuracy./clusterInfo.clusterPeakCount*100;
clusterInfo.sClusterPeakAccuracy= clusterInfo.sClusterPeakAccuracy./clusterInfo.sClusterPeakCount*100;
clusterInfo.perClusterPeakAccuracy =clusterInfo. wholePerCluster/clusterInfo.whole_nPerCluster*100;

%%%%%%%%%%%%%%%%%Other cleaning%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('rate peaks and clusters');
[GeneralStatsPeak,perGroupStatsPeak,wholeTruePositive]=RatePeakGroups(reorganizedGroups, predictedGroups);
disp('rate clusters');
[GeneralStatsCluster,perGroupStatsCluster]=RateClusterGroups(reorganizedGroups, clusterInfo);

GeneralStats{1}.ColNames = ColNames;
GeneralStats{1}.DataTable = DataTable;

GeneralStats{2}=GeneralStatsPeak;
GeneralStats{3}=GeneralStatsCluster;


perGroupStats{1}=perGroupStatsPeak;
perGroupStats{2}=perGroupStatsCluster;

disp ('done rating');
end