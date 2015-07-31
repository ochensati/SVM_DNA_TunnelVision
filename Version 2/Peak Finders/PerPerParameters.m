function [ FixedPeaksInFile ] = PerPerParameters( PeaksInFile,runParameters )
%PERPERPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

    for I=1:length(PeaksInFile)
        groupInfo =PeaksInFile{I};
        
        %clean up the peaks to eliminate empties
        temp=groupInfo.Experiment.PeaksWithoutCluster;
        emptyCells=cellfun(@isempty,temp);
        temp(emptyCells)=[];
       % temp=cell2mat(temp);
        
        %get all the new parameters
        newSinglePeaks = PeakParameters(temp,runParameters );
 
        %now do the same with the controls
        temp=groupInfo.Control.PeaksWithoutCluster;
        emptyCells=cellfun(@isempty,temp);
        temp(emptyCells)=[];
        newSingleControlPeaks = PeakParameters(temp);
        
        ClusterLessPeaks{I} =struct('GroupName',rawPeaks.GroupName,'Parameters',  PeakParameters(rawPeaks.PeakNotInCluster));

        clusterPeaks =[];
        for K=1:length(rawPeaks.Clusters)
            cluster = rawPeaks.Clusters{K};
            clusterParam = ClusterParameters(cluster);
            peaks =  PeakParameters(cluster.PeaksInCluster);
            for J=1:length(peaks)
                peak =peaks(J);
                peak.ClusterInfo = clusterParam;
                peak.ClusterID = K;
                clusterPeaks=[clusterPeaks peak];
            end
            %clusterPeaks= horzcat(clusterPeaks,peaks);
        end
        ClusterWithPeaks{I}=struct('GroupName',rawPeaks.GroupName,'Parameters',clusterPeaks);

    end

end

