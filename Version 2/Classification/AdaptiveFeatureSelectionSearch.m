function [bestAccur,bestSVM,bestCommonSVM,bestAnomalySVM,bestColNumbers]=  AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData,controlTable,  runParams, analyteNames)

%not used for this application
if  isfield(runParams,'dataTable')
    refinedData.dataTable=runParams.dataTable;
    refinedData.colNames=runParams.colNames;
end

%sometimes this comes in at the wrong dimensions.  just make it correct
refinedData.colNames=refinedData.colNames(:)';
%this keeps track of the current cols that are in use
colNames= refinedData.colNames ;
%only use the data that has been marked as known for the feature solution
trainableIDX = find(refinedData.dataTable(:,5)==0);

%get the names of the different analytes
analytes = unique(refinedData.dataTable(trainableIDX,1)); %#ok<FNDSB>
halfAnalyte = analytes(max([1 fix(end/2)]));
C = 10;


description='standard';
% sigma tuning

option  = runParams.Adaptive_Feature_Method; %['wbfixed','wfixed','lbfixed','lfixed','lupdate'].
pow = 1 ;

%take remove those parameters that vary wildly within the analyte group,
%but do not vary well between analytes
if (runParams.Remove_Water==0 || isempty(controlTable)==false  )
    if runParams.Do_In_vs_outgroup==1
        [ refinedData] = GoodParameters2( refinedData,  runParams );
    end
end


waterfreeIDX=1:size(refinedData.dataTable,1);
bestAccur=0;
bestSVM = [];
bestCommonSVM = [];
bestAnomalySVM = [];
cols=1:size(refinedData.dataTable,2);
colNumbers = 1:length(colNames);

%make a list of those parameters that have not been removed
allGoodParams =runParams.dataColStart:size(refinedData.dataTable,2);

predictive=true;

%make a copy of the data that can have columns removed
refinedData2 = refinedData;


sql = 'UPDATE peaks SET P_Reserved1 = 0';
exec(conn,sql);
sql = 'UPDATE peaks SET P_Reserved2 = 0';
exec(conn,sql);


%assume that only one col is removed per cycle (this is not true usually)
for i=1:length(cols)
    try
        
        if (runParams.Remove_Water==1 && isempty(controlTable)==false  )
            disp('===============================');
            disp('Removing Water Signal');
            if (i==1)
                %determine the best SVM parameters for this dataset by a
                %grid search
                SVMParams=CrossValidate(experiment_Index,refinedData.dataTable(:,cols), refinedData.colNames(cols),runParams,predictive);
                SVMParams2=CrossValidate(experiment_Index,refinedData.dataTable(:,cols), refinedData.colNames(cols),runParams,false);
            end
            
            try
                %remove the water
                refinedData2.colNames=   refinedData.colNames(cols);
                [refinedData2.dataTable, waterfreeIDX] = QuickWaterFilter(analytes, controlTable(:,cols), refinedData.dataTable(:,cols), runParams, SVMParams );
            catch mex
                dispError (mex);
            end
            
            %take remove those parameters that vary wildly within the analyte group,
            %but do not vary well between analytes
            if runParams.Do_In_vs_outgroup==1
                [ refinedData2] = GoodParameters2( refinedData2,  runParams );
            end
        end
        
        %the water filter has completely removed an analyte.  Send this
        %information to the diary.
        ann = unique(refinedData2.dataTable(:,1));
        if length(ann)<4
            disp('shorted');
        end
        
        
        if runParams.Do_PCA==1
            %the PCA will remove correlated features, but loses any meaningful
            %information about the feature names.
            [refinedData2] = PCA_Prefilter(refinedData2,runParams,analyteNames );
            
        else
            if runParams.Do_Covariance==1
                %remove the datapoints that are correlated.  They slow down the processing
                %and screw up the svm
                try
                    [refinedData2] = CovarianceClean3(refinedData2, runParams.Covariance_Cutoff,runParams);
                catch mex
                    dispError(mex)
                end
            end
        end
        
        if (i==1 )
            disp('===============================');
            disp('Cross Validation and Grid search');
             %determine the best SVM parameters for this dataset by a
                %grid search
            SVMParams=CrossValidate(experiment_Index,refinedData2.dataTable, refinedData2.colNames,runParams,predictive);
            SVMParams2=CrossValidate(experiment_Index,refinedData2.dataTable, refinedData2.colNames,runParams,false);
        end
        
        if length(refinedData2.colNames)<=runParams.dataColStart
            break;
        else
            baccur=100;
            for I=1:1
                %make sure to do a placeholder, just in case two of these are
                %running at the same time.
                sql =['insert into svm_results (SVM_R_Experiment_Index, SVM_R_parameters,SVM_R_parameterMethod) VALUES (' num2str(experiment_Index) ...
                    ',''' sprintf('%s,', refinedData2.colNames{1:end}) ''',''Adaptive' description ''');'];
                ret = exec(conn,sql);
                
                %sometimes the database times out
                if (isempty(ret.Message)==false)
                    conn=database('recognition_L_20',runParams.dbUser,runParams.dbPassword);
                    setdbprefs('DataReturnFormat','structure');
                    
                    sql =['insert into svm_results (SVM_R_Experiment_Index, SVM_R_parameters,SVM_R_parameterMethod) VALUES (' num2str(experiment_Index) ...
                        ',''' sprintf('%s,', refinedData2.colNames{1:end}) ''',''Adaptive' description ''');'];
                    ret = exec(conn,sql);
                end
                
                %print any errors that came up
                ret.Message
               
                sql =['select SVM_R_ParameterSet_Index from svm_results where SVM_R_Experiment_Index=' num2str(experiment_Index)  ...
                    ' AND SVM_R_parameters=''' sprintf('%s,', refinedData2.colNames{1:end}) ''';'];
                ret = fetch(exec(conn,sql));
                ret.Message
                try
                    parameterSet_Index=ret.Data.SVM_R_ParameterSet_Index(1);
                    
                    %do the actual work of filtering out the data and then
                    %testing the trainability of the SVM on this dataset
                    [ accur, SVM,commonSVMParams, anomalySVMParams,lostPoints,lostPercent]= ...
                        TrainAndTest(experiment_Index,parameterSet_Index,conn,analyteNames, refinedData2.colNames, refinedData2.dataTable,runParams, SVMParams,SVMParams2);
                catch mex
                    dispError(mex);
                end
                
                if accur<baccur
                    baccur=accur;
                    aSearch.SVM=SVM;
                    aSearch.commonSVMParams=commonSVMParams;
                    aSearch.anomalySVMParams=anomalySVMParams;
                    aSearch.colNumbers=colNumbers;
                    aSearch.accur=accur;
                end
                
                sql = ['update svm_results ' ...
                    'set SVM_R_LostPercent=' num2str(lostPercent) ', SVM_R_LostPoints=' num2str(lostPoints) ...
                    ' where SVM_R_ParameterSet_Index=' num2str(parameterSet_Index) ';'];
                
            end
            
            if (baccur>bestAccur)
                bestSVM = aSearch.SVM;
                bestCommonSVM = aSearch.commonSVMParams;
                bestAnomalySVM = aSearch.anomalySVMParams;
                bestColNumbers = aSearch.colNumbers;
                bestAccur=aSearch.accur;
            end
            %   sql = ['update svm_results set SVM_R_LostPercent=' num2str(accur) ' where SVM_R_ParameterSet_Index=' num2str(parameterSet_Index) ';'];
            exec(conn,sql);
            
        end
        
        
        refinedData2.dataTable= refinedData.dataTable( waterfreeIDX,:);
        trainableIDX = find(refinedData2.dataTable(:,5)==0);
        trainTable = refinedData2.dataTable(trainableIDX,:);
        
        positiveIDX =( find(trainTable(:,1)>halfAnalyte));
        negativeIDX =( find(trainTable(:,1)<=halfAnalyte));
        
        labels =zeros([1 size(trainTable,1)]);
        labels(positiveIDX)=1;
        labels(negativeIDX)=-1;
        
        idxP=randperm(length(positiveIDX),min([length(positiveIDX) 250]));
        idxN=randperm(length(negativeIDX),min([length(negativeIDX) 250]));
        
        indapp=[  positiveIDX(idxP)' negativeIDX(idxN)'];
        x=trainTable(indapp,allGoodParams);
        
        
        y=labels(indapp)';
        
        Sigma =0.01*ones(1,size(x,2));
        
        if isempty(x)
            break;
        end
        
        %------------------------------------------------------------------%
        %                       Feature Selection and learning
        %------------------------------------------------------------------%
        [Sigma,Xsup,Alpsup,w0,pos,nflops,crit,SigmaH] = svmfit(x,y,Sigma,C,option,pow,0);
        
        
        
        badParams=find(Sigma==0);
        
        if length(badParams)>2
            idx=randperm(length(badParams));
            badParams=badParams(idx(1:min([6 length(idx)-1])));
        end
        
        if (isempty(badParams)==true)
            [v idx]=sort(Sigma);
            
            Sigma2=Sigma==.01;
            Sigma2(Sigma2==1)=[];
            if isempty(Sigma2) || isnan(std(Sigma))
                idx=randperm(length(Sigma));
            end
            if (length(idx)==1)
                break;
            end
            
            badParams = idx(1:min([6 length(idx)-1]));
        end
        
        badParams2 = allGoodParams(badParams);
        allGoodParams(badParams)=[];
        badParams=badParams2;
        
        disp('=====================bad Params===================');
        fprintf( '%s\n',refinedData.colNames{badParams});
        
        cols=[1:(runParams.dataColStart-1)  allGoodParams];
        
        refinedData2.dataTable=refinedData.dataTable(waterfreeIDX,cols);
        colNumbers=cols;
        refinedData2.colNames=refinedData.colNames(cols);
        
        disp('=====================good Params===================');
        fprintf( '%s\n', refinedData2.colNames{:});
        
        if (length(cols)<runParams.dataColStart)
            break;
        end
    catch mex
        dispError(mex)
        
    end
end



end

