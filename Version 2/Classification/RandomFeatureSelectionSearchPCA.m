function  [bestAccur, bestParams, tempRunParams]= RandomFeatureSelectionSearchPCA(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames, description)
% refinedData.colNames=refinedData.colNames(1:30);
% refinedData.dataTable=refinedData.dataTable(:,1:30);
% colNames=refinedData.colNames(1:30)';
tempRunParams = runParams;

colNames=refinedData.colNames(:)';

dataTable=refinedData.dataTable;
maxN= size( dataTable,2)-2;

maxLimit =min([20 round(maxN/3)]);
bestAccur =0;
bestParams =[];
for i=1:20
    try
        
        n=randi(maxN);
        idx = randperm(maxN);
        
        badParams = idx(1:n);
        
        badParams(badParams<runParams.dataColStart)=[];
        
        cols=1:size(dataTable,2);
        cols(badParams)=[];
        
        
        
        disp('=====================good Params===================');
        fprintf( '%s\n', colNames{cols});
        
        
        dataTable2=  dataTable(:,cols);
        colNames2=colNames(cols);
        
        [dataTable2,colNames2] = PCA_PrefilterAfter(dataTable2,colNames2,runParams,analyteNames);
        
        if length(cols)>runParams.dataColStart
            baccur=100;
            for J=1:2
                %make sure to do a placeholder, just in case two of these are
                %running at the same time.
                sql =['insert into svm_results (SVM_R_Experiment_Index, SVM_R_parameters,SVM_R_parameterMethod) VALUES (' num2str(experiment_Index) ...
                    ',''' sprintf('%s,', colNames2{1:end}) ''',''RandomPCA' description ''');'];
                exec(conn,sql);
                
                %sql ='select max(SVM_R_ParameterSet_Index) as m from svm_results';
                sql =['select SVM_R_ParameterSet_Index from svm_results where SVM_R_Experiment_Index=' num2str(experiment_Index)   ' AND SVM_R_parameters=''' sprintf('%s,', colNames2{1:end}) ''';'];
                ret = fetch(exec(conn,sql));
                parameterSet_Index=ret.Data.SVM_R_ParameterSet_Index(1);
                
                
                [ accur, SVM,commonSVMParams, anomalySVMParams,lostPoints,lostPercent]= ...
                    TrainAndTest(experiment_Index,parameterSet_Index,conn,analyteNames, colNames, dataTable,runParams, SVMParams);
                sql = ['update svm_results ' ...
                    'set SVM_R_LostPercent=' num2str(lostPercent) ', SVM_R_LostPoints=' num2str(lostPoints) ...
                    ' where SVM_R_ParameterSet_Index=' num2str(parameterSet_Index) ';'];
                exec(conn,sql);
                if accur<baccur
                    baccur=accur;
                    aSearch.SVM=SVM;
                    aSearch.commonSVMParams=commonSVMParams;
                    aSearch.anomalySVMParams=anomalySVMParams;
                    aSearch.colNumbers=cols;
                    aSearch.accur=accur;
                end
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
    catch mex
        dispError(mex)
    end
end



tempRunParams.colNames=bestParams;
tempRunParams.dataTable=  dataTable(:,bestCols);

end

