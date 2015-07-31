function [experiment_Index,runParams]=SaveExperiment(conn,runParams, createNewExperiment)
%%%%%
% function to determine if the current experiment is already in the
% database and if it is, does it have the same data collection parameters

%check if the experiment even exists
sql = ['SELECT Experiment_Index FROM Experiments WHERE Experiment_Name='''  runParams.Experiment_Name ''';'];

ret = exec(conn,sql);
ret = fetch(ret);

if createNewExperiment ==true && isstruct(ret.Data)==true
    s=runParams.Experiment_Name;
    for J=1:100
        runParams.Experiment_Name =[s num2str(J)];
        sql = ['SELECT Experiment_Index FROM Experiments WHERE Experiment_Name='''  runParams.Experiment_Name ''';'];
        
        ret = exec(conn,sql);
        ret = fetch(ret);
        
        if (isstruct(ret.Data)==false)
            runParams.outputPath =[runParams.outputPath num2str(J)];
            break;
        end
    end
end

fields = {'maxSVMPoints','Calc_Accuracy_Spreads',...
    'Remove_Water','Remove_Common_Peaks','Remove_Anomaly','Number_SVM_Iterations'};

dateV = datevec(date);
D=[num2str(dateV(1)) '-' num2str(dateV(2)) '-' num2str(dateV(3)) ];


if (isstruct(ret.Data)==false)
    %if it does not exist, then create the record
   
    sql='INSERT INTO experiments (Experiment_Name,Experiment_Date,Experiment_Comments';
    sql2=[' VALUES ('''  runParams.Experiment_Name ''',''' D ''','' '''];
    
    for I=1:length(fields)
        field = fields{I};
        sql=[sql ',' field]; 
        sql2=[sql2 ',' num2str( runParams.(field))]; %#ok<*AGROW>
    end
    sql2=([sql2 ')']);
    sql =[sql ')' sql2 ';']
    
    exec(conn,sql);
    
    sql = ['SELECT Experiment_Index FROM Experiments WHERE Experiment_Name='''  runParams.Experiment_Name ''';'];
    ret = exec(conn,sql);
    ret = fetch(ret);
    experiment_Index = ret.Data.Experiment_Index;
    
else
    %if it does exist check if it matches the important parameters
    experiment_Index = ret.Data.Experiment_Index;
    
    sql=['update experiments SET Experiment_Date=''' D ''''];
    for I=1:length(fields)
        field = fields{I};
        sql=[sql ',' field '=' num2str( runParams.(field))];
    end
    sql =[sql ');'] %#ok<*NOPRT>
    
    exec(conn,sql);
end


sql = ['delete svm_length_results from svm_length_results \n' ...
   'join svm_analyte_results on svm_analyte_results.SVM_A_Result_Index = svm_length_results.SVM_L_Result_Index \n' ...
    'join svm_results on svm_analyte_results.SVM_A_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index  \n' ...
    'join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index  \n' ...
    'where experiments.Experiment_Name=''' runParams.Experiment_Name  ''' ;'];

sql=sprintf(sql);
ret=exec(conn,sql);


sql = ['delete svm_analyte_results from svm_analyte_results \n' ...
    'join svm_results on svm_analyte_results.SVM_A_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index  \n' ...
    'join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index  \n' ...
    'where experiments.Experiment_Name=''' runParams.Experiment_Name  ''' ;'];

sql=sprintf(sql);
ret=exec(conn,sql);

sql = ['delete svm_filtering from svm_filtering \n' ...
    'join svm_results on svm_filtering.SVM_F_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index  \n' ...
    'join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index  \n' ...
    'where experiments.Experiment_Name=''' runParams.Experiment_Name  ''' ;'];

sql=sprintf(sql);
ret=exec(conn,sql);

sql = ['delete svm_results from svm_results \n' ...
    'join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index  \n' ...
    'where experiments.Experiment_Name=''' runParams.Experiment_Name  ''' ;'];

sql=sprintf(sql);
ret=exec(conn,sql); %#ok<*NASGU>

% 
% for I=1:length(analyteList)
%    sql =['Insert into experiment_analytes (Experiment_Index,Analyte_Index,EA_Role) Values (' ...
%        num2str(experiment_Index) ',' num2str(analyteList(I)) ',''N'');'];
%    exec(conn,sql);
% end


end