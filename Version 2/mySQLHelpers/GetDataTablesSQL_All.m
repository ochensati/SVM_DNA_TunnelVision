function [colNames, dataTable, controlTable, analyteNames,runParams]=GetDataTablesSQL_All(conn,folderPaths,experimentIndex,runParams)

sql =sprintf(['select analytes.Analyte_Name, analytes.Analyte_Index from analytes \n' ...
    '   Join experiments \n' ...
    '       on experiments.Experiment_Index = analytes.Analyte_Experiment_Index \n' ...
    ' WHERE experiments.Experiment_Index=' num2str(experimentIndex) ';']);

ret =fetch( exec(conn,sql) );

analyteNames = ret.Data.Analyte_Name;
aN=ret.Data.Analyte_Name;

for I=1:length(ret.Data.Analyte_Index)
    aI(I)=    ret.Data.Analyte_Index(I);
    analyteNames{I,2}=ret.Data.Analyte_Index(I);
end

sql = ['select peaks.*,clusters.* from peaks ' ...
    'join clusters on clusters.Cluster_Index=peaks.Cluster_Index limit 1;'];
cur = exec(conn,sql);
ret=fetch(cur);

fields = fieldnames(ret.Data);
%setdbprefs('DataReturnFormat','numeric');
badCols={'Peak_Index', 'Cluster_Index', 'Folder_Index','File_Index' , 'startIndex' ,'endIndex' ,'SVM_Rating','P_identity' };

colNames = {'analytes.Analyte_Index','peaks.P_startIndex','peaks.P_endIndex','Folder_Index','Control','P_identity','File_Index','peakindex'};
names = 'analytes.Analyte_Index,peaks.P_startIndex,peaks.P_endIndex,peaks.Folder_Index,analytefolders.Control,peaks.P_identity,peaks.File_Index,peaks.Peak_Index';

% colNames = {'analytes.Analyte_Index','peaks.Peak_Index','clusters.Cluster_Index','File_Index','Identity','known_analyte'};
%names = 'analytes.Analyte_Index,peaks.Peak_Index,clusters.Cluster_Index,peaks.File_Index,analytefolders.Control,peaks.P_identity';
runParams.dataColStart = length(colNames)+1;
cc=runParams.dataColStart;
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
    '   join folders \n' ...
    '     on folders.Folder_Index = peaks.Folder_Index \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    '   join clusters \n' ...
    '     on clusters.Cluster_Index=peaks.Cluster_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control=1' ];

sql=sprintf(sql);
controlTable = double(mySQLAdapter.mySQLAdapterClass.GetData_mySQL(['DSN=recognition_L_20;UID=' runParams.dbUser ';PASSWORD=' runParams.dbPassword ';'],sql,6,aN,aI));

sql =['select ' names '\n'...
    ' from peaks \n' ...
    '   join folders \n' ...
    '     on folders.Folder_Index = peaks.Folder_Index \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    '   join clusters \n' ...
    '     on clusters.Cluster_Index=peaks.Cluster_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control!=1' ];

sql=sprintf(sql)

dataTable =  double(mySQLAdapter.mySQLAdapterClass.GetData_mySQL(['DSN=recognition_L_20;UID=' runParams.dbUser ';PASSWORD=' runParams.dbPassword ';'],sql,6,aN,aI));


sql =['select folders.Folder_Index,Folder from folders \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experimentIndex) ' AND analytefolders.Control!=1' ];

sql=sprintf(sql);

cur = exec(conn,sql);
ret=fetch(cur);

disp('Experiment folders that are being used:');

for I=1:length(ret.Data.Folder)
    fprintf('%s\n',ret.Data.Folder{I});
end

if (size(folderPaths,2)==3)
    dataTable(:,5)=0;
else
    for I=1:size(folderPaths,1)
        
        if (I==4)
            disp(I);
        end
        path = folderPaths{I,3};
        path = strrep(path, '/', '_');
        path = strrep(path, '\', '_');
        role = folderPaths{I,4} ;
        roleI=0;
        if (strcmp(role,'mix'))
            roleI=3;
        else
            if (strcmp(role,'test'))
                roleI=1;
            else
                roleI=0;
            end
        end
        for J=1:length(ret.Data.Folder)
            path2 = strrep(ret.Data.Folder{J}, '/', '_');
            path2 = strrep(path2, '\', '_');
            if (strcmp(path2, path))
                folder_index= ret.Data. Folder_Index(J);
                disp(folder_index);
                idx = find( dataTable(:,4)==folder_index);
                dataTable(idx,5)=roleI;
                break;
            end
        end
    end
end
end