
function  varargsout= CustomPeakInformation(trace, peakFindParams, peaks)
%CustomWholePeakInformation: algorythm to allow user to add parameters
%for the peak processing utility and also to allow user to remove peaks that are bad
%  For those parameters that require the
%   whole data trace to be present
%   INPUTS:
%       data -The whole data file trace
%       peakFindParams - a structure of all the parameters passed from the
%       initialization file
%       peaks -  array of cells with each cluster, its start and stop
%       point and all 
%   OUTPUTS:
%       an array of peaks with the new parameters.


%   scales = 2:8:64;
%   wname = 'coif3';
%   waveletCoef = cwt(trace,scales,wname);
%   nWavelets = length(scales);
   
   
%   for J=1:length(peaks)
%      startPeak = peaks{J}.StartIndex;
%      endPeak = peaks{J}.EndIndex;
%      peakWavelets=zeros([nWavelets 1]);
%      for I=1:nWavelets
%         level = waveletCoef(I,startPeak:endPeak);
%         peakWavelets(I)=max(level);
%      end
%      peaks{J}.Wavelets = peakWavelets;
%   end
   
   varargsout =peaks;
end



