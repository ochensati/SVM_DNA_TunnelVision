for I=1:length(RawGroupsInFile)
    
    group = RawGroupsInFile{I};
   % C = strsplit(group.FilePath,'\\');
    clear wholeCols;
    wholeCols{1,1}=group.FilePath;
    for J=1:length(group.ColNames)
        wholeCols{2,J} =group.ColNames(J) ;
    end
    for J=1:size( group.WorkingDataset,1)
        for K=1:size(group.WorkingDataset,2)
            wholeCols{3+J,K} = group.WorkingDataset(J,K);
        end
    end
    cell2csv(['c:\temp\suman\group_' group.GroupName '_' num2str(I) '.csv'],wholeCols);
    
end