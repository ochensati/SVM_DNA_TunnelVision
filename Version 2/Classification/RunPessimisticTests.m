

for TestI=1:length(RawGroupsInFile)
    
    OriginalGroupName = RawGroupsInFile{TestI}.GroupName;
    
    RawGroupsInFile{TestI}.GroupName = strcat( RawGroupsInFile{TestI}.GroupName,'_Test');
    
    disp('===============================');
    disp('Reorganize data');
    [tabledGroups badGroups] = TableData(RawGroupsInFile,runParams);
    
    %%
    %remove those parameters that badly match the similar groups.  Hopefully
    %this removes those random variables
    [cleanedGroups badParameterNames] =  GoodParameters(tabledGroups,runParams);
    
    %%
    [cleanedGroups badParams] = CovarianceClean(cleanedGroups);
    
    badParameterNames =[badParameterNames badParams];
    
    cleanedGroups = ScaleData(cleanedGroups);
    [reorganizedGroups badGroups]=CombineSimilarGroups(cleanedGroups,runParams, badGroups);
    
    % reorganizedGroups = ScaleData(combinedGroups);
    if (isempty(badParameterNames)==0)
        figure;
        uitable('Data',badParameterNames','ColumnName',['Bad Parameters'],'Units','normalized','position',[0,0,1,1]);
        title('Removed Parameters');
    end
    
    if (isempty(badGroups)==0)
        figure;
        uitable('Data',badGroups','ColumnName',['BadGroups'],'Units','normalized','position',[0,0,1,1]);
        title('Removed Groups');
    end
    %%
    
    clear combinedGroups;
    clear tabledGroups;
    
    
    disp('Running Random Parameter Search');
    
    RandomSearch(reorganizedGroups,runParams);
    
    disp('===============================')
    
    
    RawGroupsInFile{TestI}.GroupName=OriginalGroupName;
end