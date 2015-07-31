function [reorganizedGroups] = CovarianceClean2(groupsInFile)
reorganizedGroups.ColNames = groupsInFile{1}.ColNames;
controlTable.ColNames = groupsInFile{1}.ColNames;
controlTable.Peaks=[];

%build an average covariance table for the experiments
covar = zeros(size( groupsInFile{1}.WorkingDataset,2));
for I=1:length(groupsInFile)
    t=groupsInFile{I}.WorkingDataset;
    covar = covar + corrcoef(t);
    
    reorganizedGroups.Peaks{I}.Train=t;
    reorganizedGroups.Peaks{I}.GroupName= groupsInFile{I}.GroupName;
    reorganizedGroups.Peaks{I}.Test= groupsInFile{I}.Test;
    controlTable.Peaks = vertcat( controlTable.Peaks, groupsInFile{I}.ControlDataset);
end


end