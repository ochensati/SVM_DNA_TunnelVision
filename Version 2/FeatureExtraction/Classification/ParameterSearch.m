function [Accuracy, AccuracyTableColNames]= ParameterSearch(superIteration, reorganizedGroups, runParams,SVMParams  )
%ParameterSearch uses the given parameters to
allColNames=reorganizedGroups.ColNames;

nIterations =  length(runParams.SVM_Parameters);
Accuracy = cell([nIterations (4 + 4*length(reorganizedGroups))]);

%get the column names for the accuracy table
AccuracyTableColNames=cell([length(reorganizedGroups.Peaks)*4+3 1 ]);
AccuracyTableColNames{1}='Parameters';
AccuracyTableColNames{2}='Whole Training Accuracy';
AccuracyTableColNames{3}='Whole Testing Accuracy (true/positive)';
AccuracyTableColNames{4}='Strange Points';
AccuracyTableColNames{5}='Common Points';
AccuracyTableColNames{6}='Surviving Points';
for K=1:length(reorganizedGroups.Peaks)
    AccuracyTableColNames{6+ (K-1) *4  + 1} = [reorganizedGroups.Peaks{K}.GroupName ' called correctly in group (true/positive)'];
    AccuracyTableColNames{6+ (K-1) *4  + 2} = [reorganizedGroups.Peaks{K}.GroupName ' called incorrectly in other groups (false/positive)'];
    AccuracyTableColNames{6+ (K-1) *4  + 3} = [reorganizedGroups.Peaks{K}.GroupName ' misscalled as '];
    AccuracyTableColNames{6+ (K-1) *4  + 4} = [reorganizedGroups.Peaks{K}.GroupName ' misscalled in '];
end


%set the basic parameters of the svm training

kernalProps=CopyKernalParameters(SVMParams);%DefaultKernalParameters();
kernalProps.nbclass =length(reorganizedGroups.Peaks);

for I=1:nIterations
    disp('Running iteration');
    disp(I);
    
    %randomly select cols
    rSVMParameters = runParams.SVM_Parameters{I};
    nParams =  length(rSVMParameters);
    colNumbers = [];%randperm(length(allColNames),nParams);
    for J=1:nParams
        for K=1:length(allColNames)
            if (strcmp( rSVMParameters{J}, allColNames{K})==true)
                colNumbers =[colNumbers K];
            end
        end
    end
    
    nParams = random('unid',length(allColNames)-1)+1;
    colNumbers = randperm(length(allColNames),nParams);
    SelectedParams = allColNames(colNumbers );
    disp(SelectedParams);
    
    
    if isempty(colNumbers)==false
        
        SelectedParams = allColNames(colNumbers );
        disp(SelectedParams);
        
        %write out the parameters used, with a format that can be written to a
        %csv file
        parameterColNames =[];
        for K=1:(length(SelectedParams)-1)
            parameterColNames =[parameterColNames  SelectedParams{K} '| ']; %#ok<AGROW>
        end
        parameterColNames =[parameterColNames  SelectedParams{length(SelectedParams)} ]; %#ok<AGROW>
        
        %now build a training set
        % SVM=matlab_libSVM.SVM_Interface(SVMParams);
        
        
        Training =[];
        
        for K=1:length(reorganizedGroups.Peaks)
            t= reorganizedGroups.Peaks{K}.Train(:,colNumbers);
            % arrObj = NET.convertArray(t,'System.Double');
            
            %         oneS=matlab_libSVM.SVM_Interface(SVM.CopyParameter());
            %         oneS.SetTrainTable(0,arrObj);
            %         oneS.SetToOneClass(.7);
            %         oneS.TrainModel();
            %         oneSVM{K}=oneS;
            oneSVM{K}=CreateOneClass(t,CopyKernalParameters(kernalProps)) ;
            
            
            Training=vertcat(Training, t);
            peakTables{K}=t;
            %         e=zeros(1,length(reorganizedGroups.Peaks{K}.Train))+K;
            %         TrainingGroupNumbers =[TrainingGroupNumbers e]; %#ok<AGROW>
            %         Training=vertcat(Training, reorganizedGroups.Peaks{K}.Train(:,colNumbers)); %#ok<AGROW>
        end
        
        % commonSVM= FindCommon(oneSVM,peakTables,SVM.CopyParameter());
        commonSVM= FindCommon(oneSVM,peakTables,CopyKernalParameters(kernalProps));
        
        %     anomolySVM= matlab_libSVM.SVM_Interface(SVM.CopyParameter());
        %     arrObj = NET.convertArray(Training,'System.Double');
        %     anomolySVM.SetTrainTable(0,arrObj);
        %     anomolySVM.SetToOneClass(.2);
        %     anomolySVM.TrainModel();
        anomolySVM=CreateOneClass(Training,CopyKernalParameters(kernalProps)) ;
        anomolySVM.threshold =( anomolySVM.threshold +anomolySVM.rho)/2;
        Training=[];
        Labels =[];
        for K=1:length(reorganizedGroups.Peaks)
            %first remove thos points that are common to all the datasets
            t= reorganizedGroups.Peaks{K}.Train(:,colNumbers);
            %         arrObj = NET.convertArray(t,'System.Double');
            %         uniqueS=find(double( commonSVM.PredictTest(arrObj))==-1);
            
            classify = svmoneclassval(t,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
            uniqueS=find(classify<commonSVM.threshold);
            t=t(uniqueS,:);
            
            Training =vertcat(Training, t);
            Labels = vertcat( Labels, ones([size(t,1) 1]).*K);
            %then train the svm with the remaining points
            %         arrObj = NET.convertArray(t,'System.Double');
            %         SVM.SetTrainTable(K-1,arrObj);
        end
        
        %do a C and Gamma search to get all the training to the maximum accuracy
        %selectedSVMParameters=SVM.SelectParameters();
        
        %now train the model for a final dataset
        
        disp('=========== Training Accuracy ============');
        %     trainingAccuracy= SVM.TrainModel() ;
        %
        try
            [ allPeaksSVM trainingAccuracy]=  CreateMultiClass(Training,Labels, CopyKernalParameters(kernalProps));
            
            disp(trainingAccuracy);
            
            %run each dataset through the svm to see what is predicted
            nTotalPeaks=0;
            nGood=0;
            nMixed=0;
            nLeft =0;
            for K=1:length(reorganizedGroups.Peaks)
                %once again, find all the peaks that fall into the common pit
                t= reorganizedGroups.Peaks{K}.Test(:,colNumbers);
                %         arrObj = NET.convertArray(t,'System.Double');
                %         common=find(double( commonSVM.PredictTest(arrObj))==-1);
                %
                nTotalPeaks = nTotalPeaks+ size(t,1);
                classify = svmoneclassval(t,anomolySVM.xsup,anomolySVM.alpha,anomolySVM.rho,anomolySVM.kernel,anomolySVM.kerneloption);
                goodPeaks=find(classify>anomolySVM.threshold);
                nGood =nGood + length(goodPeaks);
                t=t(goodPeaks,:);
             
                classify = svmoneclassval(t,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
                uniqueS=find(classify<commonSVM.threshold);
                nMixed =nMixed +size(t,1)-length(uniqueS) ;
                t=t(uniqueS,:);
                nLeft =nLeft + size(t,1);
                %         arrObj = NET.convertArray(t,'System.Double');
                %         predictedGroups{K} =double( SVM.PredictTest(arrObj));
                %         unknowns{K}=double( anomolySVM.PredictTest(arrObj));
                
                predictedGroups{K}  = svmmultivaloneagainstone(t,allPeaksSVM.xsup,allPeaksSVM.w,allPeaksSVM.b,allPeaksSVM.nbsv,allPeaksSVM.kernel,allPeaksSVM.kerneloption);
            end
            
            
            Accuracy{I,1}=parameterColNames;
            Accuracy{I,2}=trainingAccuracy;
            Accuracy{I,4}=nGood/nTotalPeaks*100;
            Accuracy{I,5}=nMixed/nTotalPeaks*100;
            Accuracy{I,6}=nLeft/nTotalPeaks*100;
            wholeTruePositive =0;
            wholeCount =0;
            for K=1:length(reorganizedGroups.Peaks)
                
                predict= predictedGroups{K};
                truePositive =  length(find(predict==K));
                wholeTruePositive =wholeTruePositive + truePositive;
                wholeCount =wholeCount + length(predict);
                
                truePositive = truePositive / length(predict) *100;
                
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
                [v idx]=max(counts);
                
                mostCommon_In_Miscall =     reorganizedGroups.Peaks{idx}.GroupName;
                
                [v idx]=max(missCallFreq);
                mostCommon_Out_Misscall =     reorganizedGroups.Peaks{idx}.GroupName;
                
                Accuracy{I,6+(K-1)*4+1}= truePositive;
                Accuracy{I,6+(K-1)*4+2}= trueNegative;
                Accuracy{I,6+(K-1)*4+3}= mostCommon_In_Miscall;
                Accuracy{I,6+(K-1)*4+4}= mostCommon_Out_Misscall;
            end
            Accuracy{I,3}=wholeTruePositive/wholeCount*100;
        catch mex
            dispError(mex);
        end
    end
end


figure;
uitable('Data',Accuracy,'ColumnName',AccuracyTableColNames,'Units','normalized','position',[0,0,1,1]);
disp('===============================')


t=vertcat(AccuracyTableColNames',Accuracy);
cell2csv(['c:\temp\randomAccuracy' num2str(superIteration) '.csv'],t);

end

