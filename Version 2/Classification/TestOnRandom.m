function [accur,allPeaksSVM]=TestOnRandom(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames, parameterSet_Index, lostDictionary)


if (length(colNames)<10)
    disp('   ');
end
%put all the labels to the values 1-n where n is the number of analytes
Labels =reducedData(:,1);

realLabels=unique(Labels);

for I=1:length(realLabels)
    Labels(Labels==realLabels(I))=I*(-1);
end


Labels =-1*Labels;

genericSVM= CopyKernalParameters(SVMParams);
genericSVM.nbclass = length(analytes);

%find the data that is labeled as mix and remove it from the training
if isempty( find( reducedData(:,5)~=0 ) )==false
    trainableIDX = find(reducedData(:,5)==0);
    trainableIDX =trainableIDX( randperm(size(trainableIDX,1)));
    
    halfIndex=fix( length(trainableIDX)/2);
    fTrainIDX = trainableIDX(1:halfIndex);
    sTrainIDX=trainableIDX(halfIndex+1:end);
    
    Training = reducedData(fTrainIDX,runParams.dataColStart:end);
    LabelsTraining = Labels(fTrainIDX);
    
    genericSVM.nbclass=length(unique(LabelsTraining));
    
    Testing=reducedData(sTrainIDX,runParams.dataColStart:end);
    LabelsTesting=Labels(sTrainIDX);
    peakIndexs = reducedData(sTrainIDX,8);
    
    testableIDX = find(reducedData(:,5)~=0);
    testableIDX =testableIDX( randperm(size(testableIDX,1)));
    Testing =vertcat(Testing, reducedData(testableIDX,runParams.dataColStart:end));
    
    peakIndexs =vertcat(peakIndexs , reducedData(testableIDX,8));
    
    LT= Labels(testableIDX);
    PreLabeled = reducedData(testableIDX,runParams.dataColStart-1);
    %some data can be prelabeled to allow it to be directly tested    
    if (mean(PreLabeled )~=-1)
        
        for I=1:length(realLabels)
            PreLabeled(PreLabeled==realLabels(I))=I*(-1);
        end
        
        LabelsTesting =vertcat(LabelsTesting,-1*PreLabeled);
        ActualLabels=LabelsTesting;
        
    else
        LabelsTesting =vertcat(LabelsTesting, LT);
        ActualLabels=LabelsTesting;
    end
else
    Training =[];
    Testing =[];
    LabelsTraining=[];
    LabelsTesting=[];
    for I=1:length(realLabels)
       idx=find(Labels==I);
       idx = idx(randperm(length(idx)));
       halfIndex = floor(length(idx)/2);
       Training = vertcat(Training, reducedData(idx(1:halfIndex),runParams.dataColStart:end)); %#ok<AGROW>
       Testing = vertcat(Testing, reducedData(idx(1+halfIndex:end),runParams.dataColStart:end)); %#ok<AGROW>
       LabelsTraining=vertcat(LabelsTraining, zeros([halfIndex 1])+I); %#ok<AGROW>
       LabelsTesting =vertcat(LabelsTesting, zeros( [length(idx)-halfIndex 1])+I); %#ok<AGROW>
    end

    if (size(Training,1)>10000)
        hIndex = floor(halfIndex/5);
        idx2=randperm(size(Training,1));
        idx2=idx2(1:hIndex);
        Training = Training(idx2,:);
        LabelsTraining = LabelsTraining(idx2);
    end
     ActualLabels=LabelsTesting;
end

genericSVM.nbclass =length(unique(LabelsTraining));

disp('training');
%train with all the analytes
[allPeaksSVM, trainingAccuracy]=  CreateMultiClass(Training,LabelsTraining,genericSVM);
allPeaksSVM.kernalProps = genericSVM;
disp(trainingAccuracy);
%test on the whole data set
predictedGroup  = svmmultivaloneagainstone(Testing,allPeaksSVM.xsup,allPeaksSVM.w,allPeaksSVM.b,allPeaksSVM.nbsv,allPeaksSVM.kernel,allPeaksSVM.kerneloption);
%check the accuracy of the whole set
corrects= (predictedGroup==LabelsTesting);
accur = sum(corrects )/ length(predictedGroup)*100;
fprintf ('%f3\n', accur);

if (exist('peakIndexs','var'))
for I=1:length(predictedGroup)
    sql = ['UPDATE peaks SET P_Reserved1 = P_Reserved1+1 WHERE Peak_Index = ' num2str( peakIndexs(I) )];
    ret  =exec(conn,sql); %#ok<NASGU>
    if (corrects(I)==1)
        sql = ['UPDATE peaks SET P_Reserved2 = P_Reserved2+1 WHERE Peak_Index = ' num2str( peakIndexs(I) )];
        exec(conn,sql);
    end
end
end



%Save the general data for all the experiment
sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
    ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_NumberTested, SVM_A_RatioCallsS) VALUES (' ...
    num2str(parameterSet_Index) ...
    ',''RandomOrdering''' ...
    ',''All''' ...
    ',' num2str(trainingAccuracy) ...
    ',' num2str(accur) ...
    ',' num2str(length(LabelsTesting)) ','' ''); '];

exec(conn,sql);

sql =[ 'select max(SVM_A_Result_Index) as m from SVM_Analyte_Results ' ...
    'where SVM_A_ParameterSet_Index='  num2str(parameterSet_Index) ';'];
ret = fetch(exec(conn,sql));
result_Index = ret.Data.m;

predictedGroup=realLabels(predictedGroup);
LabelsTesting=realLabels(LabelsTesting);
%now save all the data for each analyte
for K=1:length(analytes)
  
    idx = find( ActualLabels==K);
    if isempty(idx)==false
        disp(['analyte:' num2str(K)]);
        correctsA= (predictedGroup(idx)==LabelsTesting(idx));
        accurA = sum(correctsA )/ length(idx)*100 %#ok<NOPRT>
        
        tPred = predictedGroup(idx);
        ratios ='';
        for J=1:length(analytes)
            ratios = [ratios num2str(100*length(find(tPred == (analytes(J))))/length(idx)) '|']; %#ok<AGROW>
        end
        disp(ratios);
        
        if isempty(lostDictionary)==false
            
            sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
                ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_NumberTested,SVM_A_RatioCallsS, ' ...
                'SVM_A_LostPoints, SVM_A_LostPercent) VALUES (' ...
                num2str(parameterSet_Index) ...
                ',''RandomOrdering''' ...
                ',''' analyteNames{K,1}  '''' ...
                ',' num2str(trainingAccuracy) ...
                ',' num2str(accurA) ...
                ',' num2str(length(idx)) ...
                ',''' ratios '''' ...
                ',' num2str(lostDictionary{K,2}) ...
                ',' num2str(lostDictionary{K,3}) '); '];
        else
            sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
                ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_NumberTested,SVM_A_RatioCallsS ' ...
                ') VALUES (' ...
                num2str(parameterSet_Index) ...
                ',''RandomOrdering''' ...
                ',''' analyteNames{K,1}  '''' ...
                ',' num2str(trainingAccuracy) ...
                ',' num2str(accurA) ...
                ',' num2str(length(idx)) ...
                ',''' ratios ''''  '); '];
            
        end
        exec(conn,sql);
    end
end


if runParams.Order_by_Run
    runCorrect =zeros([21 1]);
    for I=1:20
        
        good =0;
        bad =0;
        for J=1:I:length(corrects)-I
            
            snap = sum( corrects(J :J+I))/ I*100;
            if snap>50
                good=good+1;
            else
                bad =bad+ 1;
            end
        end
        runCorrect(I+1) = good/(bad+good)*100;
    end
    runCorrect(1)=sum(corrects)/length(corrects)*100;
    
    for I=1:length(runCorrect)
        sql=['insert into SVM_Length_Results VALUES (' ...
            num2str(result_Index) ',' ...
            '''RunLength'',' ...
            '''All'','...
            '''' ['item' num2str(I)] ''',' ...
            num2str(runCorrect(I)) ');'];
        exec(conn, sql);
    end
    
    sql= ['update SVM_Analyte_Results Set SVM_A_AfterRun=' num2str(runCorrect(4)) ...
        ' where SVM_A_ParameterSet_Index=' num2str(parameterSet_Index) ' AND ' ...
        ' SVM_A_Analyte=''All'';'];
    exec(conn,sql);
    
    %now repeat this for each of the individual analytes
    for K=1:length(analytes)
        idx = find( LabelsTesting==K);
        correctsA= (predictedGroup(idx)==LabelsTesting(idx));
        accurA = sum(correctsA )/ length(idx)*100;
        runCorrect =zeros([21 1]);
        for I=1:20
            
            good =0;
            bad =0;
            for J=1:I:length(corrects)-I
                
                snap = sum( corrects(J :J+I))/ I*100;
                if snap>50
                    good=good+1;
                else
                    bad =bad+ 1;
                end
            end
            runCorrect(I+1) = good/(bad+good)*100;
        end
        runCorrect(1)=accurA;
     
        for I=1:length(runCorrect)
            sql=['insert into SVM_Length_Results VALUES (' ...
                num2str(result_Index) ',' ...
                '''RunLength'',' ...
                '''' analyteNames{K,1}  ''','...
                '''' ['item' num2str(I)] ''',' ...
                num2str(runCorrect(I)) ');'];
            exec(conn, sql);
        end
        
    end
end



end