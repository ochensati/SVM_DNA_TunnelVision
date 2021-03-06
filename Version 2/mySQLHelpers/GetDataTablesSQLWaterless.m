function [colNames, dataTable,  analyteNames]=GetDataTablesSQLWaterless(conn,experimentIndex)
sql =sprintf(['select analytes.Analyte_Name, analytes.Analyte_Index from analytes \n' ...
    '   Join experiment_analytes \n' ...
    '       on experiment_analytes.Analyte_Index = analytes.Analyte_Index \n' ...
    '   Join experiments \n' ...
    '       on experiments.Experiment_Index = experiment_analytes.Experiment_Index \n' ...
    ' WHERE experiments.Experiment_Index=' num2str(experimentIndex) ';']);

ret =fetch( exec(conn,sql) );

analyteNames = ret.Data.Analyte_Name;
for I=1:length(ret.Data.Analyte_Index)
    analyteNames{I,2}=ret.Data.Analyte_Index(I);
end

sql = 'select peaks.*,clusters.* from peaks join clusters on clusters.Cluster_Index=peaks.Cluster_Index limit 1;';
ret=fetch(exec(conn,sql));

fields = fieldnames(ret.Data);
%setdbprefs('DataReturnFormat','numeric');
badCols={'Peak_Index', 'Cluster_Index','Folder_Index', 'File_Index' , 'startIndex' ,'endIndex' ,'SVM_Rating' };
colNames = {'analytes.Analyte_Index','peaks.Peak_Index','clusters.Cluster_Index'};
names = 'analytes.Analyte_Index,peaks.Peak_Index,clusters.Cluster_Index';
cc=4;
for I=1:length(fields)
    bads=0;
    for J=1:length(badCols)
         if isempty(strfind(fields{I}, badCols{J}))==false 
             bads = bads +1;
         end
    end
    if bads ==0
        colNames{cc}=fields{I};
        names =[names ',' fields{I}]; %#ok<AGROW>
        cc=cc+1;
    end
end
        

sql =['select ' names '\n'...
    ' from peaks \n' ...
    '   join files \n' ...
    '     on files.File_Index = peaks.File_Index \n' ...
    '   join folders \n' ...
    '     on folders.Folder_Index = files.Folder_Index \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    '   Join experiment_analytes \n' ...
    '       on experiment_analytes.Analyte_Index = analytes.Analyte_Index \n' ...
    '   Join experiments \n' ...
    '       on experiments.Experiment_Index = experiment_analytes.Experiment_Index \n' ...
    '   join clusters \n' ...
    '     on clusters.Cluster_Index=peaks.Cluster_Index \n' ...
    ' WHERE experiments.Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control=1 and peaks.P_SVM_Rating=0;' ];

sql=sprintf(sql);


dataTable =  double(mySQLAdapter.mySQLAdapterClass.GetData_mySQL('DSN=recognition;UID=honcho;PASSWORD=12Dnadna;',sql));

