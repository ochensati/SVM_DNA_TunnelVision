function [analyte_index]=SaveAnalyte(conn,runParams, analyteName)
%%%%%
% function to determine if the current experiment is already in the
% database and if it is, does it have the same data collection parameters



fields = {'baseline_Threshold', ...
'num_ClusterFFT_coef', ...
'num_peakFFT_coef', ...
'minimum_Width', ...
'clusterSize', ...
'minimum_FFT_Size', ...
'lowPass_Freq', ...
'minimum_cluster_FFT_Size'};

field = fields{1};
whereSQL = ['WHERE Round(' field ',4)=Round(' num2str( runParams.(field)) ',4)'];
for I=2:length(fields)
    field = fields{I};
    whereSQL=[whereSQL ' AND Round(' field ',4)=Round(' num2str( runParams.(field)) ',4)'];
end
    
sql =['select folders.Folder_Index, folders.Folder from folders ' whereSQL ';'];

ret = exec(conn,sqlO)
FoldersCompletered = fetch(ret);


if (isstruct(ret.Data)==false)
    %if it does not exist, then create the record
   
    whereSQL='INSERT INTO analytes (Analyte_Name';
    sql2=[' VALUES ('''  analyteName ''''];
    
    for I=1:length(fields)
        field = fields{I};
        whereSQL=[whereSQL ',' field]; 
        sql2=[sql2 ',' num2str( runParams.(field))]; %#ok<*AGROW>
    end
    sql2=([sql2 ')']);
    whereSQL =[whereSQL ')' sql2 ';']
    
    exec(conn,whereSQL);
    
    ret = exec(conn,sqlO);
    ret = fetch(ret);
    analyte_index = ret.Data.Analyte_Index;
else
    %if it does exist check if it matches the important parameters
    analyte_index = ret.Data.Analyte_Index;
end

end