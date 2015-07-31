function [same] = SameParams(groupParams, runParams)


   same =true;
   
   if groupParams.baseline_Threshold ~= runParams.baseline_Threshold
       same=false ;
   end
   
   if groupParams.minimum_Width ~= runParams.minimum_Width
       same=false ;
   end
   
   if groupParams.clusterSize ~= runParams.clusterSize
       same=false ;
   end
   
   if groupParams.minimum_FFT_Size ~= runParams.minimum_FFT_Size
       same=false ;
   end
   
   if groupParams.lowPass_Freq ~= runParams.lowPass_Freq
       same=false ;
   end
   
   if groupParams.minimum_cluster_FFT_Size ~= runParams.minimum_cluster_FFT_Size
       same=false ;
   end
  
             
end