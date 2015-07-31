function [ allPeaks, allSinglePeaks,allPeaksInClusters,allJustClusters, sixtyHZtrace,clusterIndex ] = PeakClipper( wholeTrace,peakSelectParams,clusterIndex,fid_peak,fid_cluster )
%PEAKCLIPPER Summary of this function goes here
%   Detailed explanation goes here

allSinglePeaks=[];
allPeaks =[];
allPeaksInClusters =[];
allJustClusters=[];
sixtyHZtrace=[];


delta =floor(length(wholeTrace)/10);
%aPeakIndicators =[];
for I=1:10
    StartIndexTrace=(delta*(I-1)+1);
    trace = wholeTrace(StartIndexTrace :I*delta);
    
    disp('-------')
    disp('60 hz noise')
    disp('-------')
    %Figure out the amount of 60hz noise that is in the file.  assumes
    %50 khz sampling. this will take out the whole computer sometimes
    %with the full data trace.  make sure to cut it down.
    scales=520;
    wname='cgau6';
    %waveletCoef = cwt(trace,scales,wname);
    %waveletCoef= downsample(abs(waveletCoef),8);
    
    disp('===============================')
    disp('PeakRangeFinder')
    %get an array of structs showing the start and end of each peak
    PeakIndexs =  PeakRangeFinder(trace,peakSelectParams);
    disp('===============================')
    
    %         temp=[];
    %         for KKKK=1:length(PeakIndexs)
    %             temp=vertcat(temp,trace(PeakIndexs{KKKK}.StartIndex:PeakIndexs{KKKK}.EndIndex));
    %         end
    
    
    if (length(PeakIndexs)>1)
        %clip the peaks out, assign peak parameters
        [Peaks singlePeaks clusters,clusterIndex] = PeakAssignment(trace,PeakIndexs,peakSelectParams, clusterIndex);
        
        
        
        if (fid_peak~=0)
            for M=1:length(Peaks)
                fwrite(fid_peak,trace(Peaks{M}.StartIndex:Peaks{M}.EndIndex),'single');
                fwrite(fid_peak,zeros([15 1]),'single');
            end
        end
        
        %this is an afterthough, but gets all the information that
        %comes only from the cluster,  may be good to also collect
        %information from the peaks in this cluster
        justClusters = [];
        lastCluster =0;
        CC=1;
        for M=1:length(clusters)
            if (clusters{M}.ClusterInfo.ClusterIndex ~= lastCluster)
                justClusters{CC} = clusters{M}.ClusterInfo;
                CC=CC+1;
                lastCluster = clusters{M}.ClusterInfo.ClusterIndex;
            end
        end
        
        
        lastCluster =0;
        if (fid_cluster~=0)
            for M=1:length(clusters)
                if (clusters{M}.ClusterInfo.ClusterIndex ~= lastCluster)
                    fwrite(fid_cluster,trace(clusters{M}.ClusterInfo.StartIndex:clusters{M}.ClusterInfo.EndIndex),'single');
                    fwrite(fid_cluster,zeros([100 1]),'single');
                    lastCluster = clusters{M}.ClusterInfo.ClusterIndex;
                end
            end
        end
        
        for M=1:length(Peaks)
            Peaks{M}.Trace=[];
            Peaks{M}.StartIndex = Peaks{M}.StartIndex + StartIndexTrace;
            Peaks{M}.EndIndex = Peaks{M}.EndIndex + StartIndexTrace;
        end
        for M=1:length(clusters)
            clusters{M}.Trace=[];
            clusters{M}.StartIndex = clusters{M}.StartIndex + StartIndexTrace;
            clusters{M}.EndIndex = clusters{M}.EndIndex + StartIndexTrace;
            
        end
        
        for M=1:length(singlePeaks)
            singlePeaks{M}.Trace=[];
            singlePeaks{M}.StartIndex = singlePeaks{M}.StartIndex + StartIndexTrace;
            singlePeaks{M}.EndIndex = singlePeaks{M}.EndIndex + StartIndexTrace;
        end
        
        for M=1:length(justClusters)
           
            justClusters{M}.StartIndex = justClusters{M}.StartIndex + StartIndexTrace;
            justClusters{M}.EndIndex = justClusters{M}.EndIndex + StartIndexTrace;
        end
        
        allPeaks = horzcat(allPeaks,Peaks);
        allSinglePeaks   = horzcat(allSinglePeaks,singlePeaks);
        allPeaksInClusters = horzcat(allPeaksInClusters,clusters);
        allJustClusters = horzcat(allJustClusters,justClusters);
        
        sixtyHZtrace =[sixtyHZtrace,0];%sixtyHZtrace, waveletCoef];
    end
end

% I=length(aPeakIndicators);
end

