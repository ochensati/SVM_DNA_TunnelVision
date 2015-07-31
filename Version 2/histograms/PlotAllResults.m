waterPercent=0;
methods =0;
try
    sql =['select svm_results.SVM_R_parameters,svm_analyte_results.* from svm_analyte_results ' ...
        'join svm_results on svm_analyte_results.SVM_A_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index ' ...
        'join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index ' ...
        'where experiments.Experiment_Name=''' runParams.Experiment_Name ''' ' ...
        'AND svm_analyte_results.SVM_A_Analyte=''All'';'];
    
    [data]=GetCSSQLData(runParams,sql);
    
    %     cur=exec(conn,sql);
    %     ret = fetch(cur);
    %     data=ret.Data;
    
    methods = unique(data.SVM_A_Method);
    data.cSVM_A_Method=data.SVM_A_Method;
    
    PlotAccuracies([runParams.outputPath '\Accur_All.png'], data,1);
    
    [v idxBest] =sort( data.SVM_A_Testing_Accuracy);
    bestResultIndex = data.SVM_A_Result_Index(idxBest(end));
catch mex
    dispError(mex)
end


clear methods
methods{1}='RandomOrdering';
for J=1:length(methods)
    try
        sql =['select svm_results.SVM_R_parameters,svm_analyte_results.* from svm_analyte_results ' ...
            'join svm_results on svm_analyte_results.SVM_A_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index ' ...
            'join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index ' ...
            'where experiments.Experiment_Name=''' runParams.Experiment_Name ''' ' ...
            'AND svm_analyte_results.SVM_A_Analyte!=''All'' AND SVM_A_Method=''' methods{J} ''''];
        
        %         cur=exec(conn,sql);
        %         ret = fetch(cur);
        %         data2=ret.Data;
        [data2]=GetCSSQLData(runParams,sql);
        saveFile =[runParams.outputPath '\Accuricies_' data2.SVM_A_Method{J} '.png'];
        removeIDX=[];
        for I=1:length(data2.SVM_A_Method)
            data2.cSVM_A_Method{I} = [ data2.SVM_A_Method{J}  data2.SVM_A_Analyte{I}];
        end
        
        PlotAccuracies(saveFile, data2,2+J);
        
        try
            SaveRatios(runParams,data2.SVM_A_Method{J}, data2)
        catch mex
            dispError(mex)
        end
    catch mex
        dispError(mex);
    end
end

plotIndex = 3 + length(methods);

sql = ['select svm_results.SVM_R_parameters,svm_filtering.* from svm_filtering ' ...
    ' join svm_results on svm_filtering.SVM_F_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index ' ...
    ' join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index  ' ...
    'where experiments.Experiment_Name=''' runParams.Experiment_Name ''''];

% cur=exec(conn,sql);
% ret = fetch(cur);
% data2=ret.Data;
[data2]=GetCSSQLData(runParams,sql);
analytes = unique(data2.SVM_F_Analyte);
cc=1;
for I=1:length(analytes)
    
    idx = find(strcmp(data2.SVM_F_Analyte(1:end),analytes{I}));
    pNames = data2.SVM_R_parameters(idx);
    lost= data2.SVM_F_LostPercent(idx);
    indexs=data2.SVM_F_ParameterSet_Index(idx);
    
    [v idx]=sort(indexs);
    
    pNames=pNames(idx);
    lost=lost(idx);
    pNames =pNames(idx);
    
    clear pNumbers
    for J=1:length(pNames)
        pNumbers(J) =length(strsplit(pNames{J},','))-3;
    end
    
    if strcmp(analytes{I},'All')
        figure(plotIndex)
    else
        figure(plotIndex+1);
        legendTest{cc}=analytes{I};
        cc=cc+1;
    end
    lost=100*(1-(1-waterPercent/100).*(1-lost/100));
    
    plot(pNumbers,lost,'-o');
    hold all;
    
    xlabel('Number of parameters');
    ylabel('Percent Peaks Filtered');
    title('Filtering');
end
figure(plotIndex);
legend('All','Location','North');

figure(plotIndex+1);
legend(legendTest{1:end},'Location','North');

saveFile =[runParams.outputPath '\Lost_All.png'];
saveas(plotIndex,saveFile);

saveFile =[runParams.outputPath '\Lost_Analytes.png'];
saveas(plotIndex+1,saveFile);

plotIndex=plotIndex+3;

sql =['select * from svm_length_results where SVM_L_Result_Index=' ...
    num2str(bestResultIndex) ' ;'];

try
    cur=exec(conn,sql);
    ret = fetch(cur);
    methods = unique(ret.Data.SVM_L_Length_Method);
    
    for J=1:length(methods)
        
        cc=1;
        for I=1:length(analytes)
            
            sql =['select * from svm_length_results where SVM_L_Result_Index=' ...
                num2str(bestResultIndex) ' AND SVM_L_Analyte=''' analytes{I} ''' AND ' ...
                'SVM_L_Length_Method=''' methods{J} ''';'];
            
            %             cur=exec(conn,sql);
            %             ret = fetch(cur);
            %             data2=ret.Data;
            %
            [data2]=GetCSSQLData(runParams,sql);
            
            if strcmp( analytes{I},'All')==true
                figure(plotIndex+J);
            else
                figure(plotIndex+length(methods) + J);
            end
            accur = data2.SVM_L_Value;
            plot(accur,'-o');
            hold all;
            
            xlabel('Number of Peaks');
            ylabel('Accuracy');
            title(['Run Length' methods{J}]);
        end
        
        figure(plotIndex+J);
        saveFile =[runParams.outputPath '\RunLength_All_'  methods{J}  '.png'];
        saveas(plotIndex+J,saveFile);
        
        figure(plotIndex+length(methods) + J);
        saveFile =[runParams.outputPath '\RunLength_Analytes_'  methods{J}  '.png'];
        saveas(plotIndex+length(methods) + J,saveFile);
    end
catch
end
plotIndex=plotIndex+2*length(methods) + 1;

sql =['select folders.*,files.*,analytes.Analyte_Name, analytefolders.Control ' ...
    ' from files  ' ...
    '   join folders ' ...
    ' on folders.Folder_Index = files.Folder_Index ' ...
    ' join analytefolders  ' ...
    '  on analytefolders.Folder_Index = folders.Folder_Index  ' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    '   Join experiments \n' ...
    '       on experiments.Experiment_Index = analytes.Analyte_Experiment_Index \n' ...
    'WHERE experiments.Experiment_Name=''' runParams.Experiment_Name ''''];

sql=sprintf(sql);
% cur=exec(conn,sql);
% ret = fetch(cur);
% data2=ret.Data;
[data2]=GetCSSQLData(runParams,sql);

expIDX = find(data2.Control==0);
conIDX = find(data2.Control==1);

[e_folder_Index , idx ]=unique(data2.Folder_Index(expIDX));
efolderlines=expIDX(idx);

[c_folder_Index , idx ]=unique(data2.Folder_Index(conIDX));
cfolderlines=conIDX(idx);

eAnalytes = data2.Analyte_Name(efolderlines);
eFolders = data2.Folder(efolderlines);
eSamples=data2.Fold_number_Samples(efolderlines)/50000;
ePeaks = data2.Fold_numPeaks(efolderlines)./(eSamples);
eClusters = data2.Fold_numClusters(efolderlines)./(eSamples);
eWaterP = 100*data2.Fold_numWaterPeaks(efolderlines)./data2.Fold_numPeaks(efolderlines);
eWater = data2.Fold_numWaterPeaks(efolderlines)./(eSamples);
etab={};
eSamples =eSamples/(60*60);
for I=1:length(e_folder_Index)
    idx=find(data2.Folder_Index==e_folder_Index(I));
    numberFiles (I)=length(idx);
    nBadFiles(I)=length(find(data2.Fl_BaselineVariance(idx)==1000));
    
    etab{I,1}=eAnalytes{I};
    etab{I,2}=eSamples(I);
    etab{I,3}=ePeaks(I);
    etab{I,4}=eWater(I);
    etab{I,5}=eClusters(I);
    etab{I,6}=eWaterP(I);
    etab{I,7}=numberFiles(I);
    etab{I,8}=nBadFiles(I);
    etab{I,9}=eFolders{I};
end

cNames ={'Analyte','Time(h)','Peaks (peaks/s)','Water peaks (peaks/s)','Clusters (cluster/s)', ...
    'Percent Water','Number Files','Bad Files','Folder'};

FigHandle=figure(plotIndex);
set(FigHandle, 'Position', [100, 100, 1100, 800]);
set(FigHandle, 'Name', 'Experiments');
table=uitable('Data',etab,'ColumnName',cNames,'Position',[0,0,1000,800]);


saveFile =[runParams.outputPath '\Stats_Experiment.png'];
saveas(plotIndex,saveFile);

saveFile =[runParams.outputPath '\Stats_Experiment.csv'];
fid=fopen(saveFile,'w');
fprintf(fid,'%s,',cNames{1:end});
fprintf(fid,'\n');
for I=1:size(etab,1)
    fprintf(fid, '%s,%f,%f,%i,%f,%i,%i,%i,%s\n',etab{I,:});
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cAnalytes = data2.Analyte_Name(cfolderlines);
cFolders = data2.Folder(cfolderlines);
cSamples=data2.Fold_number_Samples(cfolderlines)/50000;
cPeaks = data2.Fold_numPeaks(cfolderlines)./(cSamples);
cClusters = data2.Fold_numClusters(cfolderlines)./(cSamples);
cWaterP = 100*data2.Fold_numWaterPeaks(cfolderlines)./data2.Fold_numPeaks(cfolderlines);
cWater = data2.Fold_numWaterPeaks(cfolderlines)./(cSamples);
ctab={};
cSamples =cSamples/(60*60);
for I=1:length(c_folder_Index)
    idx=find(data2.Folder_Index==c_folder_Index(I));
    numberFiles (I)=length(idx);
    nBadFiles(I)=length(find(data2.Fl_BaselineVariance(idx)==1000));
    
    ctab{I,1}=cAnalytes{I};
    ctab{I,2}=cSamples(I);
    ctab{I,3}=cPeaks(I);
    ctab{I,4}=cWater(I);
    ctab{I,5}=cClusters(I);
    ctab{I,6}=cWaterP(I);
    ctab{I,7}=numberFiles(I);
    ctab{I,8}=nBadFiles(I);
    ctab{I,9}=cFolders{I};
end

cNames ={'Analyte','Time(h)','Peaks (peaks/s)','Water peaks (peaks/s)','Clusters (cluster/s)', ...
    'Percent Water','Number Files','Bad Files','Folder'};

FigHandle=figure(plotIndex+1);
set(FigHandle, 'Position', [100, 100, 1100, 800]);
set(FigHandle, 'Name', 'Controls');
table=uitable('Data',ctab,'ColumnName',cNames,'Position',[0,0,1000,800]);

saveFile =[runParams.outputPath '\Stats_Control.png'];
saveas(plotIndex +1 ,saveFile);

saveFile =[runParams.outputPath '\Stats_Control.csv'];
fid=fopen(saveFile,'w');
fprintf(fid,'%s,',cNames{1:end});
fprintf(fid,'\n');
for I=1:size(ctab,1)
    fprintf(fid, '%s,%f,%f,%i,%f,%i,%i,%i,%s\n',ctab{I,:});
end
fclose(fid);

plotIndex = plotIndex +2;

saveFile =[runParams.outputPath '\All_stats.csv'];
fid=fopen(saveFile,'w');


sql =['select * from svm_analyte_results ' ...
    ' join svm_results on svm_results.SVM_R_ParameterSet_Index=svm_analyte_results.SVM_A_ParameterSet_Index ' ...
    ' join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index ' ...
    ' where  experiments.Experiment_Index=' num2str(experiment_Index ) ';'];


% sql =['select * from svm_analyte_results as t ' ...
%     'join ( ' ...
%     'select * from svm_filtering as t '...
%     '   join svm_results on SVM_F_ParameterSet_Index=svm_results.SVM_R_ParameterSet_Index  ' ...
%     '    join experiments on svm_results.SVM_R_Experiment_Index=experiments.Experiment_Index  '...
%     ' where experiments.Experiment_Name=''' runParams.Experiment_Name ''' ) t ' ...
%     'on SVM_A_ParameterSet_Index=SVM_R_ParameterSet_Index and SVM_F_Analyte=SVM_A_Analyte' ];

cur=exec(conn,sql);
ret = fetch(cur);
data2=ret.Data;
[data2]=GetCSSQLData(runParams,sql);


data2.SVM_A_LostPercent=100*(1-(1-data2.percentWater/100).*(1-data2.SVM_A_LostPercent/100));
% data2.SVM_F_LostPercentCommon=100*(1-(1-data2.percentWater/100).*(1-data2.SVM_F_LostPercentCommon/100));
% data2.SVM_F_LostPercentAnomaly=100*(1-(1-data2.percentWater/100).*(1-data2.SVM_F_LostPercentAnomaly/100));
data2.SVM_R_parameters = strrep(data2.SVM_R_parameters, ',', '|');

try
    t=strfind(data2.SVM_R_parameters,'|');
    for I=1:length(t)
        data2.SVM_R_parCount(I) = length(t{I});
    end
    
    t=regexp(data2.SVM_R_parameterMethod,'\d+');
    data2.SVM_B_FolderNumber=zeros(size(data2.SVM_R_parameterMethod));
    for I=1:length(t)
        tt=data2.SVM_R_parameterMethod{I};
        tt=tt(t{I}:end );
        data2.SVM_B_FolderNumber(I)=str2num(tt); %#ok<ST2NM>
    end
    clear predictive;
    
    folders = unique(data2.SVM_B_FolderNumber);
    K=1;
    for I=1:length(folders)
        idx = find(data2.SVM_B_FolderNumber == folders(I));
        t=data2.SVM_A_Testing_Accuracy(idx);
        names = data2.SVM_A_Analyte(idx);
        idx2=find(strcmp(names,'All'));
        names(idx2)=[];
        t(idx2)=[];
        
        names2 = unique(names);
        
        maxGroup=0;
        for J=1:length(names2):length(t)-1
            try
                t2 = t(J:J+length(names2));
                idx4 = find(t2==0);
                if (length(idx4)>0)
                    t2(idx4(1))=[];
                end
                m=mean(t2);
                if (m>maxGroup)
                    maxGroup=m;
                end
            catch mex
            end
        end
        
        for J=1:length(names2)
            idx2=find(strcmp(names2(J),names));
            t2 = t(idx2);
            predictive{K,1} = names2{J};
            predictive{K,2} = folders(I);
            predictive{K,3} = max( t2);
            t2(t2==0)=[];
            predictive{K,4} = mode(t2);
            predictive{K,5} = mean(t2);
            t2(t2<50)=[];
            predictive{K,6} = mean(t2);
            predictive{K,7} = maxGroup;
            K=K+1;
        end
    end
    %     clear predictive;
    %
    %     folders = unique(data2.SVM_B_FolderNumber);
    %     K=1;
    %     for I=1:length(folders)
    %         idx = find(data2.SVM_B_FolderNumber == folders(I));
    %         t=data2.SVM_A_Testing_Accuracy(idx);
    %         names = data2.SVM_A_Analyte(idx);
    %         idx2=find(strcmp(names,'All'));
    %         names(idx2)=[];
    %         t(idx2)=[];
    %
    %         names2 = unique(names);
    %         for J=1:length(names2)
    %             idx2=find(strcmp(names2(J),names));
    %             t2 = t(idx2);
    %             predictive{K,1} = names2{J};
    %             predictive{K,2} = folders(I);
    %             predictive{K,3} = max( t2);
    %             predictive{K,4} = mean(t2);
    %             t2(t2<50)=[];
    %             predictive{K,5} = mean(t2);
    %             K=K+1;
    %         end
    %     end
    
catch mex
end

fields = fieldnames(data2);
%%
fprintf(fid,'%s,',fields{:});
fprintf(fid,'\n');

for I=1:length(data2.SVM_R_parameters)
    for J=1:length(fields)
        vs=data2.(fields{J});
        
        v=vs(I);
        
        if iscell(v) ==1
            v2=v{1};
            
            fprintf(fid,'%s,',v2);
        else
            fprintf(fid,'%s,',num2str(v));
        end
        %      fprintf(fid, '%s,',v);
    end
    fprintf(fid,'\n');
end


fclose(fid);
