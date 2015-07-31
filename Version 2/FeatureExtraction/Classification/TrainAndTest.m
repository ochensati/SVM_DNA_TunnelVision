function TrainAndTest(experiment_Index,parameterSet_Index,conn,analyteNames, colNames, reducedData,runParams, SVMParams)
analytes =unique( reducedData(:,1) );

kernalProps=CopyKernalParameters(SVMParams);%DefaultKernalParameters();
kernalProps.nbclass =length(analytes);

if runParams.Remove_Common_Peaks==1
    commonSVMParams=DetermineCommon(analytes,reducedData,runParams, SVMParams);
else
    commonSVMParams=[];
end

if runParams.Remove_Anomaly ==1
    anomalySVMParams=DetermineAnomaly(analytes,reducedData,runParams, SVMParams);
else
    anomalySVMParams=[];
end

try
    disp('filtering');
    [reducedData] = FilterData(conn,experiment_Index,parameterSet_Index, analytes,analyteNames,reducedData, anomalySVMParams, commonSVMParams,runParams );
catch mex
    fprintf([mex.message '\n']);
    for I=1:length(mex.stack)
        try
            disp(mex.stack(I));
            fprintf([ mex.stack(I).name '\n' mex.stack(I).line '\n']);
        catch
        end
    end
end

if runParams.Order_by_Random
    try
        TestOnRandom(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames,parameterSet_Index);
    catch mex
        fprintf([mex.message '\n']);
        for I=1:length(mex.stack)
            try
                disp(mex.stack(I));
                fprintf([ mex.stack(I).name '\n' mex.stack(I).line '\n']);
            catch
            end
        end
    end
end

if runParams.Keep_Ordered

    try
        TestOnOrdered(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames,parameterSet_Index);
    catch mex
        fprintf([mex.message '\n']);
        for I=1:length(mex.stack)
            try
                disp(mex.stack(I));
                fprintf([ mex.stack(I).name '\n' mex.stack(I).line '\n']);
            catch
            end
        end
    end
end

if runParams.Order_by_Cluster
    try
        TestOnCluster(conn,analyteNames,analytes,reducedData, SVMParams, runParams, colNames,parameterSet_Index);
    catch mex
        fprintf([mex.message '\n']);
        for I=1:length(mex.stack)
            try
                disp(mex.stack(I));
                fprintf([ mex.stack(I).name '\n' mex.stack(I).line '\n']);
            catch
            end
        end
    end
end




end