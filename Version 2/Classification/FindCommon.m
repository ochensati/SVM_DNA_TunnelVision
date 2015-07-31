function [commonSVM]=FindCommon(oneSVM, peakTables,SVMParams)

try 
commonPeaks=[];
for K=1:length(peakTables)
    t=peakTables{K};
    
    %cycle through all the points and find those that are common to all
    %the svms
    for J=1:length(peakTables)
        
        if (K~=J && isempty(t)==false)
            % arrObj = NET.convertArray(t,'System.Double');
            % predictedGroups =double( oneSVM{J}.PredictTest(arrObj));
            predictedGroups = svmoneclassval(t,oneSVM{J}.xsup,oneSVM{J}.alpha,oneSVM{J}.rho,oneSVM{J}.kernel,oneSVM{J}.kerneloption);
            idx = find(predictedGroups<oneSVM{J}.threshold/2);
            t(idx,:)=[];
        end
    end
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