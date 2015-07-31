function RecordStats(I,superIteration,experimentName,parameterColNames,runParams,wholeTruePositive,generalStats,perGroupStatsTesting);


fileTag = ['_' experimentName '_' num2str(superIteration) '.csv' ];

gColNames ={'ColNames', 'Whole Accuracy'};
gDataTable{1} =parameterColNames ;
gDataTable{2} = wholeTruePositive;


colNames ={};
DataTable ={};
for K=1:length(generalStats)
    colNames =horzcat( colNames, generalStats{K}.ColNames); %#ok<AGROW>
    
    % colNames =horzcat( colNames, {'   '}); %#ok<AGROW>
    
    DataTable = horzcat(DataTable,generalStats{K}.DataTable); %#ok<AGROW>
    %DataTable = horzcat(DataTable,{'    '}); %#ok<AGROW>
end

colNames = horzcat(gColNames, colNames);
DataTable = horzcat(gDataTable,DataTable);

filename =[runParams.Output_Folder '/summary_All_' fileTag];

saveDataTable(I,filename,colNames,DataTable)

clear colNames;
clear DataTable;
colNames ={};
colNames2 ={};
DataTable ={};
DataTable2={};
group = perGroupStatsTesting{1};
group2 = perGroupStatsTesting{2};
for J=1:length(group)
    colNames =horzcat( colNames, group{J}.ColNames); %#ok<AGROW>
    DataTable = horzcat(DataTable, group{J}.DataTable); %#ok<AGROW>
    
    
    dt =group2{J}.DataTable;
    arrayIdx =[];
    for K=1:size(dt,2)
        t=dt{K};
        if (size(t,2) >1 || size(t,1)>1)
            t=t(2);
            if ( ischar(t)==false )
                arrayIdx=[arrayIdx K]; %#ok<AGROW>
            end
        end
    end
    goodIDX=1:length(dt);
    goodIDX(arrayIdx)=[];
    
    colNames = horzcat(colNames,group2{J}.ColNames(goodIDX));%#ok<AGROW>
    DataTable = horzcat(DataTable,dt(goodIDX) ); %#ok<AGROW>
    
    
    colNames2 = horzcat(colNames2,group2{J}.ColNames(arrayIdx));%#ok<AGROW>
    DataTable2 = horzcat(DataTable2,dt(arrayIdx) ); %#ok<AGROW>
end

filename =[runParams.Output_Folder '/summary_PerGroup_' fileTag];
saveDataTable(I,filename,colNames,DataTable)

filename =[runParams.Output_Folder '/summary_PerGroup_Arrays' fileTag];

cc=1;
for J=1:length(colNames2)
    for K=1:length(DataTable2{J})
       colNames3{cc}=[colNames2{J} ' ' num2str(      K)];
       cc=cc+1;
    end
end
saveDataTable(I,filename,colNames3,DataTable2)


% try
%     figure;
%     uitable('Data',Accuracy,'ColumnName',AccuracyTableColNames,'Units','normalized','position',[0,0,1,1]);
%     disp('===============================')
%
%
%     tSingleGroup=vertcat(AccuracyTableColNames',Accuracy);
%     cell2csv(['c:\temp\randomAccuracy' experimentName num2str(superIteration) '.csv'],tSingleGroup);
%
%     cell2csv(['c:\temp\randomAccuracySummary' experimentName num2str(superIteration) '.csv'],Summary);
%
%     for J=1:length(colNumbers)
%         if paramOcc(colNumbers(J))~=0
%             paramSig(colNumbers(J))= paramSig(colNumbers(J))/paramOcc(colNumbers(J));
%             paramOpt(colNumbers(J))= paramOpt(colNumbers(J))/paramOcc(colNumbers(J));
%         end
%     end
%
%     cell2csv(['c:\temp\frequencySummary' experimentName num2str(superIteration) '.csv'],AllFrequencies);
%     cell2csv(['c:\temp\ClusterSummary' experimentName num2str(superIteration) '.csv'],AllFrequenciesClusters);
%
% catch mex
%     dispError(mex);
%     disp(mex.stack(1));
% end
end

function saveDataTable(I,filename,colNames,DataTable)

if I==1
    
    fid = fopen(filename, 'wt');
    try 
    for K=1:length(colNames)
        
%         if (length(colNames)==length(DataTable))
%             t=DataTable(K);
%             if (length(t)>1 && ischar(t)==false)
%                 for J=1:length(t)
%                     fprintf(fid,'%6s %3d,' , colNames{K},J);
%                 end
%             else
%                 
%                 fprintf(fid,'%6s ,' , colNames{K});
%             end
%         else
            fprintf(fid,'%6s ,' , colNames{K});
%         end
    end
    catch 
        
    for K=1:length(colNames)
        
%         if (length(colNames)==length(DataTable))
%             t=DataTable(K);
%             if (length(t)>1 && ischar(t)==false)
%                 for J=1:length(t)
%                     fprintf(fid,'%6s %3d,' , colNames{K},J);
%                 end
%             else
%                 
%                 fprintf(fid,'%6s ,' , colNames{K});
%             end
%         else
            fprintf(fid,'%6s ,' , colNames(K));
%         end
    end
        
    end
    fprintf(fid,'\n');
else
    fid = fopen(filename, 'at');
    
end


for i = 1:size(DataTable,1)
    for j=1:size(DataTable,2)-1
        printDataTableCell(fid,DataTable{i,j});
    end
    j=j+1;
    printDataTableCell(fid,DataTable{i,j});
    fprintf(fid,'\n');
end


fclose(fid);

end

function printDataTableCell(fid,t)

var = eval(['t']);
%disp(var);
% If zero, then empty cell
if size(var, 1) == 0
    var = '';
end

% If numeric -> String
if isnumeric(var)
    
    if length(var)>1
        %var = num2str(var);
        var(isnan(var))=-1;
        fprintf(fid,'%f,',var);
        return;
    else
        var = num2str(var);
    end
    % Conversion of decimal separator (4 Europe & South America)
    % http://commons.wikimedia.org/wiki/File:DecimalSeparator.svg
    %             if decimal ~= '.'
    %                 var = strrep(var, '.', decimal);
    %             end
end
% If logical -> 'true' or 'false'
if islogical(var)
    if var == 1
        var = 'TRUE';
    else
        var = 'FALSE';
    end
end

if iscell(var)
    var =var{1};
end

% OUTPUT value
fprintf(fid, '%s,', var);


end