function TestOnRandom(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames, parameterSet_Index)

%put all the labels to the values 1-n where n is the number of analytes
Labels =reducedData(:,1);
for I=1:length(analytes)
    Labels(Labels==analytes(I))=200+I;
end
Labels =Labels-200;

idx = randperm(size(reducedData,1));

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


corrects= (predictedGroup==LabelsTesting);
accur = sum(corrects )/ length(predictedGroup)*100;
fprintf ('%f3\n', accur);


%Save the general data for all the experiment
sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
    ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_NumberTested) VALUES (' ...
    num2str(parameterSet_Index) ...
    ',''RandomOrdering''' ...
    ',''All''' ...
    ',' num2str(trainingAccuracy) ...
    ',' num2str(accur) ...
    ',' num2str(length(LabelsTesting)) '); '];

exec(conn,sql);

sql =[ 'select max(SVM_A_Result_Index) as m from SVM_Analyte_Results ' ...
    'where SVM_A_ParameterSet_Index='  num2str(parameterSet_Index) ';'];
ret = fetch(exec(conn,sql));
result_Index = ret.Data.m;

%now save all the data for each analyte
for I=1:length(analytes)
    idx = find( LabelsTesting==I);
    correctsA= (predictedGroup(idx)==LabelsTesting(idx));
    accurA = sum(correctsA )/ length(idx)*100;
    
    sql =['INSERT INTO SVM_Analyte_Results (SVM_A_ParameterSet_Index,SVM_A_Method,SVM_A_Analyte' ...
        ',SVM_A_Training_Accuracy,SVM_A_Testing_Accuracy,SVM_A_NumberTested) VALUES (' ...
        num2str(parameterSet_Index) ...
        ',''RandomOrdering''' ...
        ',''' analyteNames{I,1}  '''' ...
        ',' num2str(trainingAccuracy) ...
        ',' num2str(accurA) ...
        ',' num2str(length(idx)) '); '];
    
    exec(conn,sql);
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
        sql=[];
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