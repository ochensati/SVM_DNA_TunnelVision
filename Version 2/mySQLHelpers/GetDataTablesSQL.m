function [colNames, dataTable, controlTable, analyteNames,runParams]=GetDataTablesSQL(conn,folderPaths,experimentIndex,runParams)


%mostly database code to load all the information from the peaks and
%clusters.  Run onces for the experiment, and once for the control.

%included is a conversion from index to absolution time from the beginning
%of the experiment
sql =sprintf(['select analytes.Analyte_Name, analytes.Analyte_Index from analytes \n' ...
    '   Join experiments \n' ...
    '       on experiments.Experiment_Index = analytes.Analyte_Experiment_Index \n' ...
    ' WHERE experiments.Experiment_Index=' num2str(experimentIndex) ';']);

ret =fetch( exec(conn,sql) );

analyteNames = ret.Data.Analyte_Name;
aN=ret.Data.Analyte_Name;

for I=1:length(ret.Data.Analyte_Index)
    aI(I)=    ret.Data.Analyte_Index(I); %#ok<AGROW>
    analyteNames{I,2}=ret.Data.Analyte_Index(I);
end

sql = ['select peaks.*,clusters.* from peaks ' ...
    'join clusters on clusters.Cluster_Index=peaks.Cluster_Index limit 1;'];
cur = exec(conn,sql);
ret=fetch(cur);

fields = fieldnames(ret.Data);

badCols={'Peak_Index', 'Cluster_Index', 'Folder_Index','File_Index' , 'startIndex' ,'endIndex' ,'SVM_Rating','P_identity','P_Reserved1','P_Reserved2' };

colNames = {'analytes.Analyte_Index','peaks.P_startIndex','peaks.P_endIndex','Folder_Index','Control','P_identity','File_Index','peakindex'};
names = 'analytes.Analyte_Index,peaks.P_startIndex,peaks.P_endIndex,peaks.Folder_Index,analytefolders.Control,peaks.P_identity,peaks.File_Index,peaks.Peak_Index';

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

sql=sprintf(sql);

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
        roleI=0; %#ok<NASGU>
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
                dataTable(idx,5)=roleI; %#ok<FNDSB>
                break;
            end
        end
    end
end

%get the start time of each file
sql = 'select * from files';
cur = exec(conn,sql);
ret=fetch(cur);
data = ret.Data;
indexs = data.File_Index;
names  =data.FileName;
for I=1:length(names)
    [~, t]=fileparts(names{I});
    t=strrep(t,'_EXPORT','');
    try
        
        dt=str2num(t(end-5:end)); %#ok<ST2NM>
        if isempty(dt)
            startTimes(indexs(I))=0; %#ok<AGROW>
        else
            startTimes(indexs(I))=dt; %#ok<AGROW>
        end
    catch mex %#ok<NASGU>
        
    end
end

%this section organizes the table according to the time, and then puts in
%an index that roughly corresponds to seconds
startTimes = startTimes - min(startTimes(startTimes~=0));

%the start index of the peaks corresponds to its time signal
t=dataTable(:,7);
t2= startTimes(t);

[t2 , idx]=sort(t2);
dataTable = dataTable(idx,:);

t2=t2-min(t2);

t7 = zeros(size(t2));
d = unique(t2);
newStarts(1) =0;
for I=1:length(d)
    idx = find(t2 == d(I));
    data =  dataTable(idx,2); %' conversion to seconds is only correct for the chimera data.
    newStarts(I+1)= newStarts(I) + (max( data) - min(data))/4.1667e6*4;     %#ok<AGROW>
    t7(idx)=newStarts(I);
end

t3 = zeros(size(t2));
for I=1:length(d)
    idx = find(t2 == d(I));
    data =  dataTable(idx,2)';%' conversion to seconds is only correct for the chimera data.
    t3(idx) = t7(idx) + ( data - min(data))/4.1667e6*4;   
end

[t4 , idx]=sort(t3);
dataTable = dataTable(idx,:);
dataTable(:,7)=t4;


%display the resulting information
colors = {'y','m','c','r','g','b','k','y','m','c','r','g','b','k'};

colorsA = unique(dataTable(:,1));
m = min(colorsA)-1;
colorsB = colorsA -m;
for I=1:length(colorsB)
    colorMap(colorsB(I))=I; %#ok<AGROW>
end

C= colorMap( dataTable(:,1) -m);
X=dataTable(:,7) ;

figure(33);clf;hold all;
for I=1:max(C)
    try
        idx = find( C==I );
        plot(X(idx),smooth(dataTable(idx,10)),colors{mod(I, length(colors))});
    catch mex
        dispError(mex)
    end
end
end