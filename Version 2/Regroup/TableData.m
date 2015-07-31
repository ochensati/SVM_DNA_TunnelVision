function [reorganizedPeaksInFile,badGroups,controlTable]= TableData( peaksInFile, runParams  )
%TableAndNormalize puts all the parameters in the form of a table, and then
%scales the data by the mean and stddev of the first dataset
%peaksInFile=RawGroupsInFile;
mPoints = 1 ;
mIndex =1;
for I=1:length(peaksInFile)
    if isempty(peaksInFile{I}.WorkingDataset)==0
        if length(peaksInFile{I}.WorkingDataset)>mPoints
            mPoints =length(peaksInFile{I}.WorkingDataset);
            mIndex = I;
        end
    end
end

colNames = AllColumnNames( peaksInFile{mIndex}.WorkingDataset{1}, runParams  );
maxPoints = 1000;
if maxPoints>length(peaksInFile{mIndex}.WorkingDataset)
    maxPoints = length(peaksInFile{mIndex}.WorkingDataset);
end


colNamesControl = runParams.Simularity_Cols ;
colNamesControl = strtrim(regexp(colNamesControl,'\|','split'));
if ( strcmp( colNamesControl(1) , 'All') )
    colNamesControl =  AllColumnNames(  peaksInFile{1}.Control.AllPeaks{1}, runParams  );
end

cc=1;
ccB=1;
badGroups=[];
controlData=[];
ccAverage=0;
goodGroup=0;
for I=1:length(peaksInFile)
    %put the data into the format of a table
    temp=UnwrapParameters(colNames,peaksInFile{I}.WorkingDataset );
    
    if (isempty(temp)==0)
        newPeaksInFile{cc}.Train=temp; %#ok<*AGROW>
        newPeaksInFile{cc}.GroupName = peaksInFile{I}.GroupName;
        %just need to get the index onf one of the good groups
        goodGroup=cc;
        cc=cc+1;
        
        if ccAverage==0
            AverageTable = sum(temp);
        else
            AverageTable = sum(temp) + AverageTable;
        end
        ccAverage=ccAverage+size(temp,1);
    else
        badGroups{ ccB } = peaksInFile{I}.GroupName;
        ccB=ccB+1;
    end
    tempC=UnwrapParameters(colNamesControl,peaksInFile{I}.Control.AllPeaks);
    if (isempty(tempC)==0)
        controlData =vertcat(controlData,tempC);
    end
end

AverageTable=AverageTable./ccAverage;
%determine the mean and std deviation of each col
stddev = std( newPeaksInFile{goodGroup}.Train);
% for I=1:length(newPeaksInFile)
%     t=newPeaksInFile{I}.Train;
%     for J=1:length(AverageTable)
%         t(J,:)=(t(J,:)-AverageTable(J))./stddev(J);
%     end
%     newPeaksInFile{I}.Train=t;%( newPeaksInFile{I}.Train-AverageTable)./stddev;
% end
% 
% t=controlData;
% for J=1:length(colNamesControl)
%     t(J,:)=(t(J,:)-AverageTable(J))./stddev(J);
% end
controlTable.Peaks=controlData;% (controlData-AverageTable(1:length(colNamesControl)))./stddev(1:length(colNamesControl));
controlTable.ColNames=colNamesControl;


reorganizedPeaksInFile.ColNames = colNames;
reorganizedPeaksInFile.Peaks = newPeaksInFile;
end