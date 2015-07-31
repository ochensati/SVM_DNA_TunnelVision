function TestOnRun(analytes,reducedData, SVMParams, runParams, colNames)

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

accur = sum( predictedGroup==LabelsTesting)/ length(predictedGroup)*100;
fprintf ('%f3\n', accur);

sql =['INSERT INTO SVM_Results SET SVM_Experiment_Index =' num2str(experiment_Index) ...
      ', SVM_parameters=''' sprintf('%s,', colNames{1:end}) ''''  ...
      ', SVM_Training_Accuracy=' num2str(trainingAccuracy) ...
      ',SVM_Testing_Accuracy=' num2str(accur) ...
      ',SVM_LostPoints=' num2str(lostPercent) ];

exec(conn,sql);  
  


end