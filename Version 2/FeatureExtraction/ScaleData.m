function [scaledData, scaledControl] = ScaleData(combinedGroups, controlTable)


nCols=length( combinedGroups.ColNames );

sums = zeros([1 nCols]);
count =0;

%get the mean
for I=1:length(combinedGroups.Peaks)
    sums=sums + sum(combinedGroups.Peaks{I}.Train);
    count = count + size(combinedGroups.Peaks{I}.Train ,1);
end
means = sums./count;

%get the standard deviation
sums = zeros([1 nCols]);
for I=1:length(combinedGroups.Peaks)
    for J=1:nCols
       sums(J)=sums(J) + sum( (combinedGroups.Peaks{I}.Train(:,J) -means(J)).^2 );
    end
end
stdev = (sums./count).^.5;

%now push these through the whole lot
for I=1:length(combinedGroups.Peaks)
    tempCut = combinedGroups.Peaks{I}.Train;
    for L=1:nCols
        tempCut(:,L)=(tempCut(:,L)-means(L))./stdev(L) ;
    end
    combinedGroups.Peaks{I}.Train=tempCut;
end

tempCut = controlTable.Peaks;
for L=1:nCols
    tempCut(:,L)=(tempCut(:,L)-means(L))./stdev(L) ;
end
controlTable.Peaks=tempCut;

scaledData = combinedGroups;
scaledControl=controlTable;
end