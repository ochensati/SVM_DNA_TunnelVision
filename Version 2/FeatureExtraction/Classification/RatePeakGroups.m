function [GeneralStats,perGroupStats,wholeTruePositive]=RatePeakGroups(reorganizedGroups, predictedGroups)

wholeTruePositive =0;
wholeCount =0;

truePositives =zeros([1 length(reorganizedGroups.Peaks)]);
perGroupStats=cell([1 length(reorganizedGroups.Peaks)]);
for K=1:length(reorganizedGroups.Peaks)
    
    ColNames{ 1} = [reorganizedGroups.Peaks{K}.GroupName ' called correctly in group (true/positive)'];
    ColNames{ 2} = [reorganizedGroups.Peaks{K}.GroupName ' called incorrectly in other groups (false/positive)'];
    ColNames{ 3} = [reorganizedGroups.Peaks{K}.GroupName ' misscalled as '];
    ColNames{ 4} = [reorganizedGroups.Peaks{K}.GroupName ' misscalled in '];
    
    
    predict = predictedGroups{K};
    truePositive =  length(find(predict==K));
    
    wholeTruePositive = wholeTruePositive + truePositive;
    wholeCount = wholeCount + length(predict);
    
    truePositive = truePositive / length(predict) *100;
    truePositives(K) = truePositive;
    
    otherPredict = [];
    missCallFreq=zeros([length(reorganizedGroups.Peaks) 1]);
    for J=1:length(reorganizedGroups.Peaks)
        if K~=J
            temp =predictedGroups{J};
            otherPredict = [otherPredict  temp'];
            missCallFreq(J)=length(find(K== temp));
        end
    end
    
    otherPredict=otherPredict(:);
    
    trueNegative = length(find(otherPredict==K))/length(otherPredict)*100;
    
    counts = histc(predict,1:length(reorganizedGroups.Peaks));
    counts(K)=0;
    [v idx]=max(counts); %#ok<ASGLU>
    
    mostCommon_In_Miscall =     reorganizedGroups.Peaks{idx}.GroupName;
    
    [v idx]=max(missCallFreq); %#ok<ASGLU>
    mostCommon_Out_Misscall =     reorganizedGroups.Peaks{idx}.GroupName;
    
    
    gAccuracy{1}= truePositive; %#ok<*AGROW>
    gAccuracy{2}= trueNegative;
    gAccuracy{3}= mostCommon_In_Miscall;
    gAccuracy{4}= mostCommon_Out_Misscall;
    
    perGroupStats {K}.ColNames=ColNames;
    perGroupStats {K}.DataTable=gAccuracy;
end






clear ColNames;

ColNames{1}='Whole Testing Accuracy (true/positive)';
ColNames{2}='Worst Accuracy (true/positive)';

wholeTruePositive=wholeTruePositive/wholeCount*100;
DataTable{1}=wholeTruePositive;
DataTable{2}=min(truePositives);






maxRunPeaks =40;
goodFreqs=zeros([40 1]);
badFreqs=zeros([40 1]);
for K=1:length(predictedGroups)
    goodFreqs=zeros([40 1]);
    badFreqs=zeros([40 1]);
    predictedGroup=predictedGroups{K};
    if (isempty(predictedGroup)==false)
        runCount =0;
        lPeak= predictedGroup(1);
        for peakI=1:length(predictedGroup)
            if predictedGroup(peakI)==lPeak
                runCount =runCount+1;
            else
                if (runCount>0)
                    if (runCount>maxRunPeaks)
                        runCount =maxRunPeaks;
                    end
                    if (lPeak==K)
                        goodFreqs(runCount)=goodFreqs(runCount)+1;
                    else
                        badFreqs(runCount)=badFreqs(runCount)+1;
                    end
                end
                lPeak = predictedGroup(peakI);
                runCount=1;
            end
        end
        
        if (runCount>0)
            if (runCount>maxRunPeaks)
                runCount =maxRunPeaks;
            end
            if (lPeak==K)
                goodFreqs(runCount)=goodFreqs(runCount)+1;
            else
                badFreqs(runCount)=badFreqs(runCount)+1;
            end
        end
        
    end
   % disp(goodFreqs);
   ClusterCounts{K}=goodFreqs;
end

ClusterCountTable=zeros([100 length(predictedGroups)]);


for J=1:length(predictedGroups)
     goodFreqs=ClusterCounts{J};
    for K=1:length(goodFreqs)
%        ColNamesG{K}= ['Good Frequency ' num2str(K)];
        ClusterCountTable(K,J)=goodFreqs(K);
    end
end

% ColNames=horzcat( horzcat(ColNames,ColNamesG),ColNamesB);
% DataTable=horzcat( horzcat(DataTable,data),dataB);

GeneralStats.ColNames=ColNames;
GeneralStats.DataTable=DataTable;
end