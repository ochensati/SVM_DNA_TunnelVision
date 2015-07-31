function [cnames,StatsTable]=GetBasicStats(RawGroupsInFile)

%now give the user a report on the viability of the experiment
cnames = {'Groupname' , 'Control Peaks', 'Experiment Peaks', 'Control Clusters', 'Experiment Clusters', 'Percent Control Peaks in Clusters','Percent Experiment Peaks in Clusters', 'Experiment Peaks Per Second','Control Peaks Per Second'};
tableValues = cell([length(RawGroupsInFile) length(cnames)]);
%clear tableValues;

for I=1:length(cnames)
    tableValues{1,I} =  cnames{I};
end

for I=1:length(RawGroupsInFile)
    
    try
        tableValues{I+1,1}=RawGroupsInFile{I}.GroupName;
        experiment =RawGroupsInFile{I}.Experiment;
        colNames = experiment.ColNames;
        countIndex=FindColumnNumber(colNames, 'ClusterInfo.Peaks In Cluster');
        inClusters=length( find(experiment.TableData(:,countIndex)>2)) ;
        
        nPeaks = size(experiment.TableData,1);
        
        tableValues{I+1,3}=nPeaks;
        tableValues{I+1,5}=experiment.NumberOfClusters;
        tableValues{I+1,7}=(inClusters)/nPeaks;%percent in cluster
        tableValues{I+1,8}=nPeaks / (experiment.Samples/50000); %peaks per second
    catch err
        disp(err);
    end
    
    try
        Control =RawGroupsInFile{I}.Control;
        inClusters=length( find(Control.TableData(:,countIndex)>2)) ;
        nPeaks = size(Control.TableData,1);
        
        tableValues{I+1,2}=nPeaks;
        tableValues{I+1,4}=Control.NumberOfClusters;
        tableValues{I+1,6}=(inClusters)/nPeaks;%percent in cluster
        tableValues{I+1,9}=nPeaks / (experiment.Samples/50000); %peaks per second
    catch err
        tableValues{I+1,2}=0;
        tableValues{I+1,4}=0;
        tableValues{I+1,6}=0;%percent in cluster
        tableValues{I+1,9}=0; %peaks per second
        disp(err);
    end
    
    
end



StatsTable=tableValues ;
end