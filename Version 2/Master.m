try
    
    %IMPORTANT: Do not try to run this code without first setting up the database.  It
    %will not run.  The readme has the instructions for setting up the
    %database.
    
    
    %batchExcel holds all the settings needed to run the peak
    %finding, parameterization of the peaks, and finally the SVM classification
    %of the feature sets. It can be edited and extended easily in excel.
    %
    batchExcel='C:\Data\flowthrough_20150318.xlsx';
    
    %this is the default path for the output.  Each experiment (run) will be
    %given an unique folder determined by the flowthrough file
    outputPath = 's:\research\svm_results\_';
    
    %access to the ODBC connection
    dbUser='honcho';
    dbPassword='12Dnadna';
    
    %first we need to get all the execuatebles set up.  This project uses a
    %tdms reader to handle the labview files, and a c# wrapper to deal with the
    %one big data transfer from the database (matlab has a memory leak,
    %resulting in a silly hack to get the data)
    InitializeDLLs
    
    
    disp('===============================')
    disp('LoadingXLSParameters')
    %load the setting file and the data folders
    %rather than make a GUI, I just used a nice excel file.  This allows
    %infinite flexibility in adjusting the settings and makes persistence of
    %the setting very easy
    doAnalysis=true;
    sprintf('%s\nLoading the following settings file: \n ', batchExcel);
    [folderPaths runParams]=  LoadXLSParameters(batchExcel,'FlowThrough');
    disp('===============================')
    
    
    %runParams is the main settings conduate.  It contains all the settings
    %from the flowthrough file as well as all the information picked up
    %along the way
    runParams.outputPath =[outputPath runParams.Experiment_Name];
    runParams.dbUser=dbUser;
    runParams.dbPassword=dbPassword;
    
    %now we make a ODBC connection.  This requires that a ODBC setting is in
    %the windows registry (once again, trying to get around the matlab memory
    %problems) check the instructions for setting up the database.
    conn=database('recognition_L_20',runParams.dbUser,runParams.dbPassword);
    setdbprefs('DataReturnFormat','structure');
    
    %this if is just a convience, it is annoyingly expensive to do the water
    %filtering and the svm parameter optimization.  Once the data is loaded, it
    %is best to just keep going.
    if (true)
        %peak and cluster processing and insertion into the database
        %set this to true to clear out the older data and restart the
        %processing. This is slow, so it is usually wise to only run this
        %once per dataset.
        redoLoad = false;
        disp('===============================')
        disp('Loading data traces - this could be really slow.')
        %load all the data from the control files
        SaveFolders(folderPaths, runParams, redoLoad,true, conn );
        %load all the data from the experiment traces
        SaveFolders(folderPaths, runParams, redoLoad,false, conn );
        
        
        %It defines the experiment, analyte, and
        %the other database tables that relate to this experiment.
        [experiment_Index, analyteList,runParams ]=OrganizeDB(folderPaths, runParams,  conn );
        
        %Now, we really do get all the data from the database.  (This is where
        %the c# code is hidden).  The data is returned as a big ugly datatable
        %with the analyte index, peak index and cluster index as the first
        %three cols.
        
        %todo: include the sampling rate in the flow through so the
        %conversion to time can be universal.  Column 7 is only correct
        %with sampling rate of 4.16e6 at the moment
        [colNames,dataTable, controlTable, analyteNames,runParams]=GetDataTablesSQL(conn,folderPaths,experiment_Index,runParams);
        
        
        %set up the output folder
        try
            rmdir(runParams.outputPath,'s');
        catch
            
        end
        
        try
            mkdir(runParams.outputPath);
        catch
            runParams.outputPath
            mkdir(runParams.outputPath);
        end
        
        try
            copyfile(batchExcel,[runParams.outputPath '\flowthrough.xlsx'],'f');
        catch mex
            dispError(mex);
        end
        
        diary( [runParams.outputPath '\diary.txt']);
        
        
        %some applications do not have clusters like the tunneling signals
        %do.  Just remove all the features that have the cluster marker
        if isfield(runParams,'Remove_Clusters')
            if runParams.Remove_Clusters==1
                clusterCols=[];
                for I=1:length(colNames)
                    if isempty(findstr(colNames{I},'C_'))==false %#ok<FSTR>
                        clusterCols=[clusterCols I]; %#ok<AGROW>
                    end
                end
                colNames(clusterCols)=[];
                dataTable(:,clusterCols)=[];
                clear clusterCols;
            end
        end
        
        %the data is now scaled to make it more pleasant for the machine
        %learning routines.
        [colNames,dataTable, controlTable]=ScaleData2(colNames,dataTable, controlTable,runParams);
        
        %plot out histograms of the various parameters.  This is really
        %slow
        %PlotDiffs2_2( colNames,  dataTable,  runParams,analyteNames);
        
        
        %Remove the time signal of the data if possible using column 7 as
        %the index
        %[dataTable]= RemoveTime3(dataTable, runParams,analyteNames);
        
        %load everything into a easy to transport structure.
        refinedData.experiment_Index = experiment_Index;
        refinedData.colNames = colNames ;
        refinedData.dataTable = dataTable;
        
        clear dataTable;
        clear colNames;
    end
    
    
    disp('Running Parameter Search');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    description='';
    if doAnalysis
        try
            %the features will be removed from what is determined to be the
            %least useful to the most useful.  Each iteration should
            %improve slightly over the previous, until the algorythm gets
            %the answer wrong.
            [bestAccur,bestSVM,bestCommonSVM,bestAnomalySVM,bestColNumbers]=AdaptiveFeatureSelectionSearch(experiment_Index,conn, refinedData, controlTable, runParams, analyteNames );
        catch mex
            dispError(mex);
        end
        
    end
    disp('===============================')
    PlotAllResults
    
catch mex
    
    dispError(mex)
    
end



