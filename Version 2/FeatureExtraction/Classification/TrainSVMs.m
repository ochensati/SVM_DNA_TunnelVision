function [commonSVM anomolySVM allPeaksSVM GeneralStats ]=TrainSVMs(K,reorganizedGroups,runParams, colNumbers,kernalProps)


removeCommon=runParams.Remove_Common_Peaks ;
removeAnomaly = runParams.Remove_Anomaly;


for K=1:length(reorganizedGroups.Peaks)
    if (isempty(reorganizedGroups.Peaks{K}.Train)==false)
        tSingleGroup=reorganizedGroups.Peaks{K}.Train(:,colNumbers);
        clippedTables{K} =tSingleGroup; %#ok<AGROW>
    end
end

Training =[];
%Class =[];
oneSVM=cell([1 length(clippedTables)]);
peakTables=cell([1 length(clippedTables)]);
for K=1:length(clippedTables)
    tSingleGroup=  clippedTables{K};
    oneSVM{K}=CreateOneClass(tSingleGroup,CopyKernalParameters(kernalProps)) ;
    % Class=vertcat(Class, ones([size(tSingleGroup,1) 1])*K);
    Training=vertcat(Training, tSingleGroup); %#ok<AGROW>
    peakTables{K}=tSingleGroup;
end

%numberOriginalPoints = size(Training,1);
if removeCommon
    commonSVM= FindCommon2(oneSVM,peakTables,CopyKernalParameters(kernalProps));
else
    commonSVM=[];
end

if removeAnomaly
    anomolySVM=CreateOneClass(Training,CopyKernalParameters(kernalProps)) ;
    anomolySVM.threshold=anomolySVM.rho/6;
else
    anomolySVM=[];
end

Training=[];
Labels =[];

for K=1:length(clippedTables)
    peakIndexs= reorganizedGroups.Peaks{K}.Train(:,1:3);
    tSingleGroup=  clippedTables{K};
    if isempty(commonSVM)==false
        classify = svmoneclassval(tSingleGroup,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
        uniqueS=find(classify<commonSVM.threshold);
        commonS=find(classify>commonSVM.threshold);
        tSingleGroup=tSingleGroup(uniqueS,:);
    else
        uniqueS=[];
        commonS=[];
    end
    
    Training =vertcat(Training, tSingleGroup); %#ok<AGROW>
    Labels = vertcat( Labels, ones([size(tSingleGroup,1) 1]).*K); %#ok<AGROW>
    for KK=1:length(commonS)
        try
            
            extraInfo{peakIndexs(commonS(KK),1)}{peakIndexs(commonS(KK),3)}.Rating=3; %#ok<AGROW>
        catch mex %#ok<NASGU>
            
        end
    end
    
    for KK=1:length(uniqueS)
        
        try
            extraInfo{peakIndexs(uniqueS(KK),1)}{peakIndexs(uniqueS(KK),3)}.Rating=6; %#ok<AGROW>
        catch mex
            dispError(mex);
        end
    end
end

%uniquePoints = (size(Training,1))/numberOriginalPoints*100;

%now train the model for a final dataset

disp('=========== Training Accuracy ============');
%     trainingAccuracy= SVM.TrainModel() ;
%
kernalProps.nbclass = length(clippedTables);
[ allPeaksSVM trainingAccuracy]=  CreateMultiClass(Training,Labels, CopyKernalParameters(kernalProps));

allPeaksSVM.kernalProps = kernalProps;

disp(trainingAccuracy);

GeneralStats.ColNames{1}='Training Accuracy';
GeneralStats.DataTable{1}=trainingAccuracy;

end