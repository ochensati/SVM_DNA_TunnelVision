folderNumbers = unique(dataTable(:,4));
roles=refinedData.dataTable(:,5);

indexs = refinedData.dataTable(:,1);
analytes = unique(indexs);
maxFolders=0;
for I=1:length(analytes)
    idx = find(refinedData.dataTable(:,1)==analytes(I));
    idx=unique( refinedData.dataTable(idx,4));
    maxFolders = max([ maxFolders, length(idx)]);
    analyteFolders {I}= idx;
end

for I=1:maxFolders
    
    refinedData.dataTable(:,5)=0;
    
    for J=1:length(analytes)
        idx = analyteFolders{J};
        if length(idx)>=I
            idx = find(refinedData.dataTable(:,4)==idx(I));
            refinedData.dataTable(idx,5)=1;
        end
    end
    
    description= num2str(I);
    try
        [A,cols,tempRunParams]=  RandomFeatureSelectionSearchPCA(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,description );
        AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData,  tempRunParams, SVMParams,analyteNames,['aRan' description] );
    catch mex
        dispError(mex);
    end
    try
        RandomFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,description )
    catch mex
        dispError(mex);
    end
    
    try
        [bestAccur,bestSVM,bestCommonSVM,bestAnomalySVM,bestColNumbers]=AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData,  runParams, SVMParams,analyteNames,description );
    catch mex
        dispError(mex);
    end
end