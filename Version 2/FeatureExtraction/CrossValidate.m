function [SVMParams]=CrossValidate(experiment_Index,tabledGroups, colNames, runParams, predictive)

%get the clean peaks
trainableIDX = find(tabledGroups(:,5)==0);
tabledGroups=tabledGroups(trainableIDX,:);

%start with the default optimal parameters
kernalProps=DefaultKernalParameters();
kernalProps.nbclass =2;

%make sure to get a sample from each analyte
analytes = unique(tabledGroups(:,1));

%if it is not predictive, just cut up the analytes randomly and put them into a
%train and validate group
if (predictive==false)
    idx1 = find(tabledGroups(:,1)==analytes(1));
    table1=tabledGroups(idx1,:);
    
    idx2 = find(tabledGroups(:,1)==analytes(2));
    table2=tabledGroups(idx2,:);
    
    
    idx=randperm(length(idx1));
    idx=idx(1:floor(end/2));
    Testing1 = table1(idx,:);
    table1(idx,:)=[];
    
    idx=randperm(length(idx2));
    idx=idx(1:floor(end/2));
    Testing2 = table2(idx,:);
    table2(idx,:)=[];
    
    
   
    Testing=vertcat(Testing1,Testing2);
    Training = vertcat(table1,table2);
    
    Labels=zeros([size(Training,1) 1])+1;
    LabelsT=zeros([size(Testing,1) 1])+1;
    Labels(1:size(table1,1))=2;
    LabelsT(1:size(Testing1,1))=2;
    
else
    
    idx = find(tabledGroups(:,1)==analytes(1));
    table1=tabledGroups(idx,:); %#ok<FNDSB>
    
    idx = find(tabledGroups(:,1)==analytes(2));
    table2=tabledGroups(idx,:); %#ok<FNDSB>
    
    
    folders1= unique( table1(:,4) );
    folders2= unique( table2(:,4) );
    
    if (length(folders1)==1 || length(folders2)==1)
        Training = vertcat(table1,table2);
        idx = randperm(size(Training, 1));
        idx=idx(1:round(end/2));
        Testing = Training(idx,:);
        Training(idx,:)=[];
        
        Labels=zeros([size(Training,1) 1])+1;
        LabelsT=zeros([size(Testing,1) 1])+1;
        
        idx = find(Training(:,1)==analytes(1));
        Labels(idx)=2; %#ok<FNDSB>
        idx = find(Testing(:,1)==analytes(1));
        LabelsT(idx)=2; %#ok<FNDSB>
    else
        idx=find(table1(:,4)==folders1(1));
        Testing1 = table1(idx,:);
        table1(idx,:)=[];
        
        idx=find(table2(:,4)==folders2(1));
        Testing2 = table2(idx,:);
        table2(idx,:)=[];
        
        Testing=vertcat(Testing1,Testing2);
        Training = vertcat(table1,table2);
        
        Labels=zeros([size(Training,1) 1])+1;
        LabelsT=zeros([size(Testing,1) 1])+1;
        Labels(1:size(table1,1))=2;
        LabelsT(1:size(Testing1,1))=2;
    end
end



idx= randperm(size(Training,1));
idx = idx(1:min([500 size(Training,1)]));
Training = Training(idx,runParams.dataColStart:end);
Labels = Labels(idx);

Testing=Testing(:,runParams.dataColStart:end);

clear table1;
clear table2;
clear tabledGroups;
clear Testing1;
clear Testing2;

%cycle through the parameters to get the best SVM parameters
maxTraining = 0;
for C=.005:.01:.1
    for gamma=.2:.6:5
        disp('----------------------------------');
        kernalProps.kerneloption=[C gamma];
        [ allPeaksSVM, trainingAccuracy]=  CreateMultiClass(Training,Labels, kernalProps);
        disp(trainingAccuracy);
        predictedGroups  = svmmultivaloneagainstone(Testing,allPeaksSVM.xsup,allPeaksSVM.w,allPeaksSVM.b,allPeaksSVM.nbsv,allPeaksSVM.kernel,allPeaksSVM.kerneloption);
        testAccuracy = length(find(predictedGroups ==LabelsT))/length(LabelsT)*100;
        disp(testAccuracy);
        dist =testAccuracy;
        disp(gamma);
        disp(C);
        if dist>maxTraining
            maxTraining=dist;
            maxC=C;
            maxGamma=gamma;
        end
    end
end
kernalProps.kerneloption=[maxC maxGamma];
SVMParams=kernalProps;

end