function [accur, SVM,commonSVMParams, anomalySVMParams,lostPoints,lostPercent]=TrainAndTest(experiment_Index,parameterSet_Index,conn,analyteNames, colNames, reducedData,runParams, SVMParams,SVMParams2)

SVM=[];
lostPoints=0;
lostPercent=0;


analytes =unique( reducedData(:,1) );
accur=0;
kernalProps=CopyKernalParameters(SVMParams);%DefaultKernalParameters();
kernalProps.nbclass =length(analytes);

%create a filter that is made up of the overlap between the groups
if runParams.Remove_Common_Peaks==1
    commonSVMParams=DetermineCommon(analytes,reducedData,runParams, SVMParams);
else
    commonSVMParams=[];
end

%create a filter that is made up of the whole training set
if runParams.Remove_Anomaly ==1
    anomalySVMParams=DetermineAnomaly(analytes,reducedData,runParams, SVMParams);
else
    anomalySVMParams=[];
end

lostDictionary=[];

%cut out the data that has been filtered by the two filters and then reduce
%the sample set to a reasonable number
try
    disp('filtering');
    [reducedData,lostPoints,lostPercent, lostDictionary] = FilterData(conn,experiment_Index,parameterSet_Index, analytes,analyteNames,reducedData, anomalySVMParams, commonSVMParams,runParams );
catch mex
  dispError(mex)
end

%check if one of the analytes has been filtered out and then indicate it in
%the diary
ann = unique( reducedData(:,1) );
if length(ann)<5
    disp('shorted');
end

if runParams.Order_by_Random
    try
      [ accur, SVM]= TestOnRandom(conn,analyteNames,analytes,reducedData, SVMParams2, runParams, colNames,parameterSet_Index,lostDictionary);
    catch mex
       dispError(mex);
    end
end

if runParams.Keep_Ordered

    try
       % TestOnOrdered(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames,parameterSet_Index);
    catch mex
       dispError(mex);
    end
end

if runParams.Order_by_Cluster
    try
       % TestOnCluster(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames,parameterSet_Index);
    catch mex
        dispError(mex);
    end
end




end