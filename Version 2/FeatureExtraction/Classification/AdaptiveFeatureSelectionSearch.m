function   AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames)

colNames=refinedData.colNames;
analytes = unique(refinedData.dataTable(:,1));
halfAnalyte = analytes(fix(end/2));
C = 10;

% in order to properly reproduce the results presented in the NIPS paper
% one has to select C and Sigma using a span estimate criterion

positiveIDX = find(refinedData.dataTable(:,1)>halfAnalyte);
negativeIDX = find(refinedData.dataTable(:,1)<=halfAnalyte);

labels =zeros([1 size(refinedData.dataTable,1)]);
labels(positiveIDX)=1;
labels(negativeIDX)=-1;

% sigma tuning

option  = runParams.Adaptive_Feature_Method  ; %['wbfixed','wfixed','lbfixed','lfixed','lupdate'].
pow = 1 ;
dataTable=refinedData.dataTable;
testAccur =[];
for i=1:100
    try
        d=size(dataTable,2)-4;
        
        Sigma =0.01*ones(1,d);
        
        idxP=randperm(length(positiveIDX),500);
        idxN=randperm(length(negativeIDX),500);
        
        indapp=[  positiveIDX(idxP)' negativeIDX(idxN)'];
        x=dataTable(indapp,5:end);
        y=labels(indapp)';
        
        if isempty(x)
            break;
        end
        %------------------------------------------------------------------%
        %                       Feature Selection and learning
        %------------------------------------------------------------------%
        [Sigma,Xsup,Alpsup,w0,pos,nflops,crit,SigmaH] = svmfit(x,y,Sigma,C,option,pow,0);
        nsup=size(Xsup,1);
        
        badParams=find(Sigma==0)+3;
        
        if (isempty(badParams)==true)
            [v idx]=sort(Sigma);
            badParams = idx(1:2)+4;
        end
        
        disp('=====================bad Params===================');
        fprintf( '%s\n', colNames{badParams});
        
        
        cols=1:size(dataTable,2);
        cols(badParams)=[];
        
       
        dataTable=refinedData.dataTable(:,cols);
        colNames=colNames(cols);
        
         %make sure to do a placeholder, just in case two of these are
        %running at the same time.
        sql =['insert into svm_results (SVM_R_Experiment_Index, SVM_R_parameters,SVM_R_parameterMethod) VALUES (' num2str(experiment_Index) ...
              ',''' sprintf('%s,', colNames{1:end}) ''',''Adaptive'');'];
        exec(conn,sql);
          
        sql ='select max(SVM_R_ParameterSet_Index) as m from svm_results';
        ret = fetch(exec(conn,sql));
        parameterSet_Index=ret.Data.m;
        
        if isnan(parameterSet_Index)
            parameterSet_Index=0;
        end
        
        TrainAndTest(experiment_Index,parameterSet_Index,conn,analyteNames, colNames, dataTable,runParams, SVMParams)
        
    catch mex
        fprintf([mex.message '\n']);
        for I=1:length(mex.stack)
            try
                disp(mex.stack(I));
                fprintf([ mex.stack(I).name '\n' mex.stack(I).line '\n']);
            catch
            end
        end
    end
end

end

