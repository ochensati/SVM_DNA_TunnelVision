function [allPeaks,singlePeaks,clusterPeaks, clusterIndex] = PeakAssignment(trace, peakIndexs, peakFindParameters, clusterIndex )
    %PEAKASSIGNMENT Summary of this function goes here
    %   Detailed explanation goes here

    %now assign the peaks to their cluster
    %copy the traces into each peak information struct
    %peakIndicators = zeros([length(trace) 1]);
    
    scales = 2:8:64;
    wname = 'coif3';
    waveletCoef = cwt(trace,scales,wname);
    nWavelets = length(scales);
       
    BadIndex =[];
    for K=1:length(peakIndexs)
        try 
            peakIndexs{K}.Trace=trace(peakIndexs{K}.StartIndex:peakIndexs{K}.EndIndex);
        catch me
            BadIndex = [BadIndex , K];
        end
     %  peakIndicators(peakIndexs{K}.StartIndex:peakIndexs{K}.EndIndex)=.01;
    end

    peakIndexs(BadIndex)=[];
    
    %build a trace with the peak frequency at each point
    slidingFreq=makeSlidingFrequecyTrace(trace,peakIndexs,peakFindParameters);
    
    %build a trace where each point specifies the peak or cluster address
    [clusterAssignment peakNumMax clusterNumMax]  = markClusters(trace,slidingFreq,peakFindParameters);

    
    %  plot([clusterAssignment/100 slidingFreq/100 trace peakIndicators]);
    
    %put all the generic parameters information into the peaks
    clusterWindowSize=peakFindParameters.clusterSize;
    for K=1:length(peakIndexs)
       peak=peakIndexs{K};
       peakStart = peak.StartIndex;% peakIndex(K);
       %check the value at the center of the peak, where the gaussian was drawn
       midPeak =peakStart +floor( length(peak.Trace)/ 2);
       peakIndexs{K}.Frequency = slidingFreq(midPeak)/clusterWindowSize;
       peakIndexs{K}=PeakParameters(peakIndexs{K},peakFindParameters,  peakFindParameters.minimum_FFT_Size);
    end
    
    %allow the user to manipulate the peaks, they may eliminate peaks, so
    %return the whole array
    peakIndexs = CustomPeakInformation(trace,peakFindParameters,peakIndexs);
    
    
     for J=1:length(peakIndexs)
      startPeak = peakIndexs{J}.StartIndex;
      endPeak = peakIndexs{J}.EndIndex;
      peakWavelets=zeros([nWavelets 1]);
      for I=1:nWavelets
         level = waveletCoef(I,startPeak:endPeak);
         peakWavelets(I)=max(level);
      end
      peakIndexs{J}.Wavelets = peakWavelets;
    end
 
   
    %and the complicated one, put a little extra information into all the
    %peaks, then group them into those peaks that are all alone and those
    %that are in a cluster.
    [allPeaks, singlePeaks, tclusterPeaks]=AssignPeaksToClusters(trace,peakIndexs,slidingFreq,clusterAssignment, peakNumMax,clusterNumMax,peakFindParameters);
    
    emptyCells=cellfun(@isempty,singlePeaks);
    singlePeaks(emptyCells)=[];

    emptyCells=cellfun(@isempty,tclusterPeaks);
    tclusterPeaks(emptyCells)=[];
    
    %now allow the user to manipulate the clusters, once again, they are
    %allowed to eliminate the clusters
    tclusterPeaks= CustomClusterInformation(trace,slidingFreq, peakFindParameters, tclusterPeaks);

    nPeaks =0;
    %now do the same work on the whole cluster
    for K=1:length(tclusterPeaks)
        tclusterPeaks{K}=PeakParameters(tclusterPeaks{K},peakFindParameters, peakFindParameters.minimum_cluster_FFT_Size);
        tclusterPeaks{K}.Frequency = length( tclusterPeaks{K}.PeaksInCluster) / (tclusterPeaks{K}.EndIndex - tclusterPeaks{K}.StartIndex);
        
        startPeak =tclusterPeaks{K}.StartIndex;
        endPeak = tclusterPeaks{K}.EndIndex;
        peakWavelets=zeros([nWavelets 1]);
        for I=1:nWavelets
             level = waveletCoef(I,startPeak:endPeak);
             peakWavelets(I)=max(level);
        end
        tclusterPeaks{K}.Wavelets = peakWavelets;
               
        nPeaks=nPeaks + length(tclusterPeaks{K}.PeaksInCluster);
    end
    
    
    ClusterPeaks=cell([nPeaks 1]);
    cc=1;
    for K=1:length(tclusterPeaks)
        cluster = tclusterPeaks{K};
        peaks = tclusterPeaks{K}.PeaksInCluster;
        %add information for each peak into the cluster
        for J=1:length(peaks)
           peak = peaks{J};
           peak.ClusterInfo=struct('ClusterIndex',clusterIndex);
           s=fieldnames (cluster);
           %copy the data for the whole cluster into each peak
           for I=1:length(s)
              name=s{I};
              if (strcmp(name,'PeaksInCluster')==false && strcmp(name,'Trace')==false)
                peak.ClusterInfo.(name)=cluster.(name);
              end
          end
          ClusterPeaks{cc}=peak;
          cc=cc+1;
        end
        clusterIndex=clusterIndex +1;
    end
    
    clusterPeaks=ClusterPeaks';
end



function [allPeaks, singlePeaks, clusterPeaks]=AssignPeaksToClusters(trace,peakIndexs, slidingFreq, clusterAssignment, peakNumMax, clusterNumMax,peakFindParameters)
    %clusterWindowSize=peakFindParameters.clusterSize;
    %allocate space
    singlePeaks=cell([(peakNumMax-1) 1]);
    clusterPeaks = cell([(clusterNumMax-1) 1]);

    startClusterK=0;
    clusterIND=0;
    lpeak =0;
    %now just assign each by whether it is positive or negative
    for K=1:length(peakIndexs)
       peak=peakIndexs{K};
       peakStart = peak.StartIndex;% peakIndex(K);
       %check the value at the center of the peak, where the gaussian was drawn
       midPeak =peakStart +floor( length(peak.Trace)/ 2);
       
       if(peakStart>1)
           assignment =clusterAssignment(midPeak);

           %if it is a single peak then record
           if (assignment>0 )
                peak = peakIndexs{K};
                slidingFreq(midPeak)=10;
                if (assignment-1~=lpeak)
                    lpeak;
                    plot([slidingFreq, clusterAssignment]);
                end
                %some times there are empty peaks
                if (isstruct(peak))
                    singlePeaks{assignment} =peak;
                end    

                lpeak=assignment;
           end

           %if it is the end of a cluster (the assinemnt has changed) then
           %close off the cluster
           if (startClusterK >0 && (clusterIND~=assignment || K==length(peakIndexs)))
                    %get the starting and closing indexs
                    startCluster =peakIndexs{startClusterK}.StartIndex-2;% peakIndex(K-nPeaks)-2;
                    endCluster =peakIndexs{K-1}.StartIndex+ length(peakIndexs{K-1}.Trace)+2;% peakIndex(K-1)+2;
                    peaksInCluster = peakIndexs( (startClusterK):(K-1));

                    if (startCluster<1)
                        startCluster=1;
                    end
                    if (endCluster>length(slidingFreq)-1) 
                        endCluster =length(slidingFreq);
                    end

                    clusterData = trace(startCluster:endCluster);
                    clusterInfo =struct('PeaksInCluster', {peaksInCluster} ,'Trace', {clusterData},'StartIndex',startCluster,'EndIndex',endCluster );
                    clusterPeaks{clusterIND*(-1)} = clusterInfo;

                    %put back the indicators
                    startClusterK=0;           
                    clusterIND=0;
           end

           if (startClusterK ==0 && assignment<0)
               startClusterK = K;
               clusterIND=assignment;
           end
       end
    end
    allPeaks=peakIndexs;
    singlePeaks=singlePeaks';
    clusterPeaks=clusterPeaks';
end

function [ clusterAssignment, numPeaks,numClusters ] = markClusters(trace,slidingFreq, peakFindParameters )
    clusterAssignment = zeros([length(trace) 1]);
    %peaks that are close together are grouped.  singles are marked positive,
    %clusters are negative
    startPeak=0;
    clusterIND=-1;
    peakIND=1;
    for K=1:length(trace)
        if (slidingFreq(K)>.1)
           if (startPeak==0)
               startPeak=K;
           end
        end

        if ((slidingFreq(K)<.1 || K==length(trace)) && startPeak~=0 )
           trace =slidingFreq(startPeak:K);
           maxCluster =max(trace);

           Y=diff(trace);
           ind = find(Y(1:end-1).*Y(2:end) < 0)+1;

           endPeak=K;
           if (maxCluster>1.0001 || length(ind)>1)
               for I=startPeak:endPeak
                   clusterAssignment(I)=clusterIND;
               end
               clusterIND=clusterIND-1;
           else 
               for I=startPeak:endPeak

                   clusterAssignment(I)=peakIND;
               end
               peakIND=peakIND+1;
           end
           startPeak=0;
        end
    end
    numPeaks = peakIND;
    numClusters=clusterIND*(-1);
end

