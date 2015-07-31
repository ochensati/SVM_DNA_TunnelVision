function [reducedTables]=GetReducedTables(tabledGroups, maxPoints)
reducedTables.ColNames = tabledGroups.ColNames;
for I=1:length(tabledGroups.Peaks)
    t=tabledGroups.Peaks{I}.Train;
    nPoints = size(t,1 );
    if nPoints>maxPoints
        nPoints=maxPoints;
    end
    index = randperm( size(t,1 ),nPoints);
    peaks=struct('GroupName',tabledGroups.Peaks{I}.GroupName,'Train',t(index,:),'Test',tabledGroups.Peaks{I}.Test);
    reducedTables.Peaks{I}=peaks;%.GroupName=tabledGroups{I}.GroupName;
    %reducedTables.Peaks{I}.Train=t(index,:);
end

end