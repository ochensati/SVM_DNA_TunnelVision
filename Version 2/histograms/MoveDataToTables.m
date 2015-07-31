function [reorganizedGroups controlTable]=MoveDataToTables( tabledGroups,controlTable, runParams, keepOrdered)

disp('===============================');
disp('Reorganize data');

%now put all the groups that have matching labels together, seperate out
%data for the testing sets and clean off any groups that still have
%problems

badGroups=[];
[reorganizedGroups badGroups]=CombineSimilarGroups(tabledGroups,runParams, badGroups, keepOrdered);


maxSVMPoints =runParams.maxSVMPoints*2;
s = size(controlTable.Peaks);
if maxSVMPoints >s(1)
    maxSVMPoints =s(1);
end
indexs=randperm(s(1),maxSVMPoints);
controlTable.Peaks = controlTable.Peaks(indexs,:);
% %now put all the data over into .net to put it into the svm
% SVM=matlab_libSVM.SVM_Interface();
% for I=1:length(reorganizedGroups.Peaks)
%     arrObj = NET.convertArray(reorganizedGroups.Peaks{I}.Train,'System.Double');
%     SVM.SetTrainTable(I-1,arrObj);
% end
% 
% selectedSVMParameters=[];
% %do a C and Gamma search to get all the training to the maximum accuracy
% selectedSVMParameters=SVM.SelectParameters();
% 
% %now train the model for a final dataset
% disp('==========================================');
% disp('=========== All Parameter Accuracy =======');
% %trainingAccur = SVM.TrainModel()
% 
% disp('==========================================');
selectedSVMParameters=[];
end