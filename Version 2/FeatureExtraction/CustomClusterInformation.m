function  varargsout= CustomClusterInformation(trace,slidingFrequency, peakFindParams, clusters)
%CustomWholeClusterInformation: algorythm to allow user to add parameters
%for the cluster processing utility and also to allow user to remove clusters that are bad
%.  For those parameters that require the
%whole data trace to be present
%   INPUTS:
%       data -The whole data file trace
%       slidingFrequency - a trace containing the spike frequency at each
%       point
%       peakFindParams - a structure of all the parameters passed from the
%       initialization file
%       clusters -  array of cells with each cluster, its start and stop
%       point and all 
%   OUTPUTS:
%       an array of clusters with the new parameters.  
   for I=1:length(clusters)
       I
      
       cluster=clusters{I}
       
       if (I==3 && isempty(cluster)==1)
           I=3;
       end
       peaks = cluster.PeaksInCluster
       maxes = zeros([length(peaks) 1]);
       for J=1:length(peaks)
           maxes(J)=max(peaks{J}.Trace);
       end
       variability = var(maxes);
       clusters{I}.Variability = variability;
   end
   
   varargsout =clusters;
end