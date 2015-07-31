function [experiment_Index,analyteList,runParams]=OrganizeDB(folderPaths, runParams,  conn)
% Creates all the tables and connections between the tables needed for this
% experiment.  All the information is loaded into runParams


%get the experiment index for this run
[experiment_Index,runParams] =SaveExperiment(conn,runParams,true);

%clear out anything that might have been left over from another experiment
sql = 'delete from files where FileName like ''temp''';
ret = exec(conn,sql); %#ok<NASGU>

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
    whereSQL=[whereSQL ' AND Round(' field ',4)=Round(' num2str( runParams.(field)) ',4)']; %#ok<AGROW>
end

sql =['select folders.Folder_Index, folders.Folder from folders ' whereSQL ';'];

ret = exec(conn,sql);
ret = fetch(ret);


FolderNames=(ret.Data.Folder);
for I=1:size(folderPaths,1)
    for J=1:size(FolderNames)
        a=folderPaths{I,2};
        a=strrep(a,'\','/');
        if strcmp(a,char(FolderNames{J}))
            folderPaths{I,5}=ret.Data.Folder_Index(J);
        end
    end
end


for I=1:size(folderPaths,1)
    for J=1:size(FolderNames)
        a=folderPaths{I,3};
        a=strrep(a,'\','/');
        if strcmp(a,char(FolderNames{J}))
            folderPaths{I,6}=ret.Data.Folder_Index(J);
        end
    end
end

sql = ['select * from analytes where Analyte_Experiment_Index=' num2str(experiment_Index) ';'];
ret = fetch(exec(conn,sql));

if isstruct(ret.Data)==false
    DoFolders=unique(folderPaths(:,1),'stable');
    for I=1:size(DoFolders,1)
        sql = ['insert into analytes (Analyte_Experiment_Index, Analyte_Name, ' ...
            'Ana_num_Experiment_Samples, Ana_num_Control_Samples,Ana_numPeaks,' ...
            'Ana_percentWaterPeaks,Ana_numClusters) values ' ...
            '('  num2str(experiment_Index) ' ,''' DoFolders{I} ''',0,0,0,0,0);'];
        exec(conn,sql);
    end
else
    FolderNames=(ret.Data.Analyte_Name);
    cc=1;
    alreadyDone=[];
    for I=1:size(folderPaths,1)
        for J=1:size(FolderNames)
            a=folderPaths{I,1};
            a=strrep(a,'\','/');
            if strcmp(a,char(FolderNames{J}))
                alreadyDone(cc)=I; %#ok<AGROW>
                cc=cc+1;
            end
        end
    end
    rows=1:size(folderPaths,1);
    rows(alreadyDone)=[];
    DoFolders = folderPaths(rows,:);
    DoFolders=unique(DoFolders(:,1));
    
    for I=1:size(DoFolders,1)
        sql = ['insert into analytes (Analyte_Experiment_Index, Analyte_Name, ' ...
            'Ana_num_Experiment_Samples, Ana_num_Control_Samples,Ana_numPeaks,'...
            'Ana_percentWaterPeaks,Ana_numClusters) values ' ...
            '('  num2str(experiment_Index) ' ,''' DoFolders{I} ''',0,0,0,0,0);'];
        exec(conn,sql);
    end
end


sql = ['select * from analytes where Analyte_Experiment_Index=' num2str(experiment_Index) ';'];
ret = fetch(exec(conn,sql));


    FolderNames=(ret.Data.Analyte_Name);
    Indexs= ret.Data.Analyte_Index;
    cc=1;
    alreadyDone=[];
    for I=1:size(folderPaths,1)
        for J=1:size(FolderNames)
            a=folderPaths{I,1};
            a=strrep(a,'\','/');
            if strcmp(a,char(FolderNames{J}))
                alreadyDone(cc)=Indexs(J); %#ok<AGROW>
                folderPaths{I,7}=Indexs(J);
                cc=cc+1;
            end
        end
    end
    
    analyteList=unique(alreadyDone);
    
    for I=1:length(analyteList)
        sql = ['delete from analytefolders where Analyte_Index=' num2str(analyteList(I)) ';'];
        exec(conn,sql);
    end


for I=1:size(folderPaths,1)
    if isempty(folderPaths{I,5})==true
        folderPaths{I,5}=0;
    end
    if (size(folderPaths,2)<7)
        folderPaths{I,7}=0;
    end
    if isempty(folderPaths{I,7})==true
        folderPaths{I,7}=0;
    end
    sql = ['Insert into analytefolders (Analyte_Index, Folder_Index, Control) Values (' ...
        num2str(folderPaths{I,7}) ',' num2str( folderPaths{I,5}) ',1),(' ];
    
    if strcmp(folderPaths{I,4},'test')
        sql =[sql  num2str(folderPaths{I,7}) ',' num2str( folderPaths{I,6}) ',2);']; %#ok<AGROW>
    else
        
        if strcmp(folderPaths{I,4},'mix')
            sql =[sql  num2str(folderPaths{I,7}) ',' num2str( folderPaths{I,6}) ',3);']; %#ok<AGROW>
        else
            sql =[sql  num2str(folderPaths{I,7}) ',' num2str( folderPaths{I,6}) ',0);']; %#ok<AGROW>
        end
    end
    exec(conn,sql);
end





return;


