function TestOnCluster(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames,parameterSet_Index)

%put all the labels to the values 1-n where n is the number of analytes
Labels =reducedData(:,1);
for I=1:length(analytes)
    Labels(Labels==analytes(I))=200+I;
end
Labels =Labels-200;

cluster_Indexs=reducedData(:,3);
cluster_Index = unique(cluster_Indexs);
cluster_Index = cluster_Index(randperm(length(cluster_Index)));

idx=[];
for I=1:length(cluster_Index)
    idx = [idx find(cluster_Indexs==cluster_Index(I))']; %#ok<AGROW>
end


halfIndex= fix(length(Labels)/2);

Training = reducedData(idx(1:halfIndex),5:end);
LabelsTraining = Labels(idx(1:halfIndex));

genericSVM= CopyKernalParameters(SVMParams);
genericSVM.nbclass = length(analytes);
disp('training');
[ allPeaksSVM, trainingAccuracy]=  CreateMultiClass(Training,LabelsTraining,genericSVM);

allPeaksSVM.kernalProps = genericSVM;

disp(trainingAccuracy);

Testing = reducedData(idx(halfIndex+1:end),5:end);
LabelsTesting = Labels(idx(halfIndex+1:end));
predictedGroup  = svmmultivaloneagainstone(Testing,allPeaksSVM.xsup,allPeaksSVM.w,allPeaksSVM.b,allPeaksSVM.nbsv,allPeaksSVM.kernel,allPeaksSVM.kerneloption);

accur = sum( predictedGroup==LabelsTesting)/ length(predictedGroup)*100;

byLengthCount=zeros([100 1]);
byLengthCorrect = zeros([100 1]);

for I=1:length(analytes)
    idxG=find(LabelsTesting==I);
    accurByGroup(I) = sum( predictedGroup(idxG)==LabelsTesting(idxG))/ length(predictedGroup(idxG))*100;
end

cluster_Indexs=reducedData(idx(halfIndex+1:end),3);
cluster_Index=unique(cluster_Indexs);
for I=1:length(cluster_Index)
    idx = find(cluster_Indexs == cluster_Index(I));
    if (length(idx)<100)
        cAccur = sum( predictedGroup(idx)==LabelsTesting(idx))/ length(predictedGroup(idx))*100;
        if cAccur>50
            predictedGroup(idx)=LabelsTesting(idx);
            if length(idx)<length(byLengthCorrect)
                byLengthCorrect(length(idx)) =  byLengthCorrect(length(idx))+1;
            end
        end
        byLengthCount(length(idx)) =  byLengthCount(length(idx))+1;
    end
end

byLengthCount(byLengthCount==0)=1;
accurByLength = byLengthCorrect./byLengthCount*100;



afterVotingAccur = sum( predictedGroup==LabelsTesting)/ length(predictedGroup)*100;

fprintf ('%f3\n', accur);

%Save the general data for all the experiment
sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
    ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_NumberTested,SVM_A_AfterCluster) VALUES (' ...
    num2str(parameterSet_Index) ...
    ',''ClusterOrdering''' ...
    ',''All''' ...
    ',' num2str(trainingAccuracy) ...
    ',' num2str(accur) ...
    ',' num2str(length(LabelsTesting)) ...
    ',' num2str(afterVotingAccur) '); '];

exec(conn,sql);

sql =[ 'select max(SVM_A_Result_Index) as m from SVM_Analyte_Results ' ...
    'where SVM_A_ParameterSet_Index='  num2str(parameterSet_Index) ';'];
ret = fetch(exec(conn,sql));
result_Index = ret.Data.m;


sql=[];
for I=1:length(accurByLength)
    sql=['insert into SVM_Length_Results VALUES (' ...
        num2str(result_Index) ',' ...
        '''ClusterLength'',' ...
        '''All'','...
        '''' ['item' num2str(I)] ''',' ...
        num2str(accurByLength(I)) ');'];
    exec(conn, sql);
end



for I=1:length(analytes)
    idx = find( LabelsTesting==I);
    correctsA= (predictedGroup(idx)==LabelsTesting(idx));
    accurA = sum(correctsA )/ length(idx)*100;
    
    sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
        ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_AfterCluster,SVM_A_NumberTested) VALUES (' ...
        num2str(parameterSet_Index) ...
        ',''ClusterOrdering''' ...
        ',''' analyteNames{I,1} '''' ...
        ',' num2str(trainingAccuracy) ...
        ',' num2str( accurByGroup(I) ) ...
        ',' num2str(accurA) ...
        ',' num2str(length(idx)) '); '];
    
    exec(conn,sql);
end

%now save all the data for each analyte



for K=1:length(analytes)
    
    c_IDX = find(LabelsTesting==K);
    cluster_Index=unique(cluster_Indexs(c_IDX));
    for I=1:length(cluster_Index)
        idx = find(cluster_Indexs == cluster_Index(I));
        if (length(idx)<100)
            cAccur = sum( predictedGroup(idx)==LabelsTesting(idx))/ length(predictedGroup(idx))*100;
            if cAccur>50
                predictedGroup(idx)=LabelsTesting(idx);
                if length(idx)<length(byLengthCorrect)
                    byLengthCorrect(length(idx)) =  byLengthCorrect(length(idx))+1;
                end
            end
            byLengthCount(length(idx)) =  byLengthCount(length(idx))+1;
        end
    end
    
    accurByLength = byLengthCorrect./byLengthCount*100;
    
    sql=[];
    for I=1:length(accurByLength)
        sql=['insert into SVM_Length_Results VALUES (' ...
            num2str(result_Index) ',' ...
            '''ClusterLength'',' ...
            '''' analyteNames{K,1}  ''','...
            '''' ['item' num2str(I)] ''',' ...
            num2str(accurByLength(I)) ');'];
        exec(conn, sql);
    end
    
    
end

end