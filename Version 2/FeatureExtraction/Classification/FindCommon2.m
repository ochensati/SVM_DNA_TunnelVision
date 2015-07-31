function [commonSVM]=FindCommon2(oneSVM, peakTables,SVMParams)

try 
commonPeaks=[];
for K=1:length(peakTables)
    t=peakTables{K};
    
    votes =zeros([1 size(t,1)]);
    %cycle through all the points and find those that are common to all
    %the svms
    for J=1:length(peakTables)
        
        if (K~=J && isempty(t)==false)
            predictedGroups = svmoneclassval(t,oneSVM{J}.xsup,oneSVM{J}.alpha,oneSVM{J}.rho,oneSVM{J}.kernel,oneSVM{J}.kerneloption);
            idx = find(predictedGroups<oneSVM{J}.threshold/3);
            votes(idx)=votes(idx)+1;
            %t(idx,:)=[];
        end
    end
    t(votes>(length(peakTables)),:)=[];
    commonPeaks = vertcat(commonPeaks,t);
end

% commonSVM= matlab_libSVM.SVM_Interface(SVMParams);
% arrObj = NET.convertArray(commonPeaks,'System.Double');
% commonSVM.SetTrainTable(0,arrObj);
% commonSVM.SetToOneClass(.85);
% commonSVM.TrainModel();
if isempty( commonPeaks)==false
    commonSVM=CreateOneClass(commonPeaks,SVMParams);
    commonSVM.threshold =commonSVM.rho/4/SVMParams.rhoReduction;;
else 
    commonPeaks=[];
    commonSVM=[];
end
catch mex
   disp( mex )
end
end