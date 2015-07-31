function [ PeaksInFile ExtraInformations ] = LoadDataTraces( folderPaths , runParameters )
%LOADDATATRACES Summary of this function goes here
%   Detailed explanation goes here
nFolders  =size(folderPaths);
nFolders = nFolders(1);

PeaksInFile=cell([nFolders 1]);

Noise =cell([nFolders 1]);

groupCC=1;
ExtraInformations=[];
for I=1:nFolders
    fullExperimentTable=[];
    disp('===============================')
    disp('LOADING EXPERIMENT FILES')
    %do all the experiment files
    pathname = folderPaths{I,3};
    files = dir([pathname '\\*.tdms']);
    
    if isempty(files)
        files = dir([pathname '\\*.abf']);
    end
    
    clusterIndex=1;
    nSamples =1;
    
    
    
    nPeaks =1;
    nClusters=1;
    cc=1;
    currPeakIndex=1;
    clusterMax=0;
    
    bigTrace=[];
    
    
    fingerprint = zeros([4096/2 1]);
    allExamples =[];
    for k=1:length(files)
        try
            disp(['Loading: ' files(k).name]); %='21May2012_001.tdms';
            disp (k);
            disp('*******************************')
            disp('LoadAndFilter')
            %load the trace from this file, remove the background and the
            %high frequencies
            [trace ] =LoadAndFilter(pathname,files(k).name,runParameters);
            
%             if mod(k,4)==0 && k~=0
% %                 figure(1);
% %                 plot(bigTrace);
% %                 xlabel('samples');
% %                 ylim([-.01 .4]);
% %                 filename =['c:\temp\traces3\' folderPaths{I,1} ' ' num2str(I) ' ' num2str(k) '.png'];
% %                 saveas(1,filename);
%                 bigTrace=[];
%             else
%                 bigTrace=[bigTrace trace];
%             end
           
          %  trace=trace(1000);
            
            nSamples =nSamples + length(trace);
            disp('*******************************')
            
            
            %now find all the peaks in the trace
            disp('*******************************')
            disp('PeakFinder')
            
            if (isempty(findstr(files(k).name,'abf'))==false)
                [allStarts  allEnds]=FixedJunctionFinder( trace,  runParameters );
            else
                [allStarts allEnds] = PeakRangeFinder( trace,  runParameters );
            end
            
         
            
            if isempty(allStarts)==false && (length(allStarts)>0)
                %trace, startIndexs, endIndexs,minFFTSize,nComponents ,currPeakIndex
                [peakTable peakParamNames currPeakIndex, examplePeaks] = SinglePeakParameters(trace, allStarts, allEnds,runParameters.minimum_FFT_Size,10,currPeakIndex ,runParameters );
                [clusterTable clusterParamNames clusterOnlyTable clusterAssignments,fingerprint] = ClusterPeakParameters(trace, allStarts, allEnds,runParameters.minimum_cluster_FFT_Size,61,runParameters,fingerprint  );
                
                allExamples=vertcat(allExamples,examplePeaks);
                clusterAssignments = clusterAssignments + clusterMax;
                clusterMax = max(clusterAssignments);
                %add in all the parameter labels.  not sure if this is the
                %best way to keep everything together, but this is where it
                %seems to work at the moment.
                peakParamNames = horzcat({'GroupIndex','ClusterIndex'}, peakParamNames);
                peakTable=horzcat(clusterAssignments , peakTable);
                %peakTable=horzcat(allStarts , peakTable);
                peakTable(:,2)=allStarts;
                peakTable=horzcat(ones([size(peakTable,1) 1])*(I*1000+k) , peakTable);
                
                
                allTable{cc}=horzcat(peakTable,clusterTable);
                allCluster{cc}=clusterOnlyTable;
                
                allExpNames = horzcat(peakParamNames,clusterParamNames);
                
                nPeaks = nPeaks + size(peakTable,1);
                nClusters =nClusters + size(clusterOnlyTable,1);
                disp('*******************************')
                
                traceFile=[runParameters.Output_Folder  '\\traces\\Trace_' folderPaths{I,1} '_I_' num2str(I) '_peaks_' num2str(k) '.mat'];
                if (exist([runParameters.Output_Folder  '\\traces'],'dir')==false)
                    mkdir([runParameters.Output_Folder  '\\traces']);
                end
                
                save(traceFile,'trace');
                for L=1:length(allStarts)
                    temp=struct('StartIndex',allStarts(L),'EndIndex',allEnds(L),'Filename',traceFile,'Rating',0,'Cluster',clusterAssignments(L));
                    extraInfo{L}=temp;
                end
                allExtras{cc}=extraInfo;
                cc=cc+1;
            end
            
            
            %sixtyHZtrace =[sixtyHZtrace, Peak60Noise]; %#ok<AGROW>
            delete(['~$' files(k).name]);
        catch me
            disp(me);
            disp(me.stack(1,1));
        end
    end
    
    if (nPeaks>4)
        % now build just one datatable for the whole dataset
        fullExperimentTable = zeros([nPeaks size(allTable{1},2)]);
        fullExtraInfo = cell([nPeaks 1]);
        curRow=1;
        for K=1:length(allTable)
            endRow = curRow + size(allTable{K},1)-1;
            try 
               
            fullExperimentTable(curRow:endRow,:)=allTable{K};
            
            catch mex
                dispError(mex);
            end
            % fullExtraInfo{curRow:endRow}=allExtras{K};
            extras=allExtras{K};
            KK=1;
            for L=curRow:endRow
                fullExtraInfo{L}=extras{KK};
                KK=KK+1;
            end
            curRow=endRow+1;
        end
        fullExperimentTable (:,3)=1:size(fullExperimentTable,1);
        %put together the cluster information
        fullClusterTable = zeros([nClusters size(allCluster{1},2)]);
        curRow=1;
        for K=1:length(allTable)
            endRow = curRow + size(allCluster{K},1)-1
            fullClusterTable(curRow:endRow,:)=allCluster{K};
            curRow=endRow+1;
        end
        
    end
    
    nExperimentClusters=clusterIndex;
    
    disp('===============================')
    disp('LOADING CONTROL FILES')
    
    %then get all the control files
    pathname = folderPaths{I,2};
    files = dir([pathname '\\*.tdms']);
    
    clusterIndex=1;
    nControlSamples=1;
    cc=1;
    nPeaks=0;
    allTable=[];
    clusterMax=0;
    for k=1:length(files)
        try
            disp(['Loading: ' files(k).name]); %='21May2012_001.tdms';
            disp (k);
            disp('*******************************')
            disp('LoadAndFilter')
            %load the trace from this file, remove the background and the
            %high frequencies
            [trace ] =LoadAndFilter(pathname,files(k).name,runParameters);
            
            nControlSamples =nControlSamples + length(trace);
            disp('*******************************')
            
            
            %now find all the peaks in the trace
            disp('*******************************')
            disp('PeakFinder')
            %[ allStarts allEnds ] = PeakRangeFinder( trace,  runParameters );
            
            if (isempty(findstr(files(k).name,'abf'))==false)
                [allStarts  allEnds]=FixedJunctionFinder( trace,  runParameters );
            else
                [allStarts allEnds] = PeakRangeFinder( trace,  runParameters );
            end
            
            if isempty(allStarts)==false && (length(allStarts)>0)
                [peakTable peakParamNames] = SinglePeakParameters(trace, allStarts, allEnds,runParameters.minimum_FFT_Size,10,0,runParameters  );
                [clusterTable clusterParamNames clusterOnlyTable clusterAssignments] = ClusterPeakParameters(trace, allStarts, allEnds,runParameters.minimum_cluster_FFT_Size,61,runParameters  );
                
                
                clusterAssignments = clusterAssignments + clusterMax;
                clusterMax = max(clusterAssignments);
                %add in all the parameter labels.  not sure if this is the
                %best way to keep everything together, but this is where it
                %seems to work at the moment.
                
                peakTable=horzcat(clusterAssignments , peakTable);
                peakTable=horzcat(ones([size(peakTable,1) 1])*I , peakTable);
                
                
                allTable{cc}=horzcat(peakTable,clusterTable);
                cc=cc+1;
                
                if isempty(peakParamNames)==false
                    allNames = horzcat(peakParamNames,clusterParamNames);
                end
                
                nPeaks = nPeaks + size(peakTable,1);
                disp('*******************************')
            end
            
            %             cutTraceCurrent =[];
            %             cutTraceVoltage=[];
            %
            %             for KK=1:length(rawClusters)
            %                 cutTraceCurrent=vertcat(cutTraceCurrent, trace(rawClusters{KK}.StartIndex:rawClusters{KK}.EndIndex));
            %                 cutTraceVoltage=vertcat(cutTraceVoltage,( Voltage(rawClusters{KK}.StartIndex:rawClusters{KK}.EndIndex)));
            %             end
            %
            %             cutTraceVoltage=double(cutTraceVoltage);
            %
            %             cutTraceVoltage2 =cutTraceVoltage-mean(cutTraceVoltage);
            %             cutTraceVoltage2 = cutTraceVoltage2 * voltScaling;
            %             figure;plot(cutTraceCurrent); hold all;plot(cutTraceVoltage2/15);hold all;
            delete(['~$' files(k).name]);
        catch me
            me
        end
    end
    
    % now build just one datatable for the whole dataset
    if isempty(allTable)==false && nPeaks>4
        
        try
            fullControlTable = zeros([nPeaks size(allTable{1},2)]);
            
            curRow=1;
            for K=1:length(allTable)
                curRow
                endRow = curRow + size(allTable{K},1)-1
                fullControlTable(curRow:endRow,:)=allTable{K};
                curRow=endRow+1;
            end
            
            countIndex=FindColumnNumber(allNames, 'ClusterInfo.Peaks In Cluster');
            nControlClusters =length( find(fullControlTable(:,countIndex)>2) );
        catch me
            fullControlTable=[];
            nControlClusters=0;
            allNames=[];
        end
    else
        fullControlTable=[];
        nControlClusters=0;
        allNames=[];
    end
    
    if isempty(fullExperimentTable)==false
        
        countIndex=FindColumnNumber(allExpNames, 'ClusterInfo.Peaks In Cluster');
        nExpClusters =length( find(fullExperimentTable(:,countIndex)>2) );
        
        
        peakInformation    = struct('Samples',nSamples,'ColNames',{allExpNames} ,'TableData', fullExperimentTable(1:end-1,:),'NumberOfClusters',nExpClusters,'ClusterTable',fullClusterTable );
        controlInformation = struct('Samples',nControlSamples,'ColNames',{allNames} ,'TableData', fullControlTable(1:end-1,:),'NumberOfClusters',nControlClusters);
        
        PeaksInFile{groupCC} = struct('GroupName',folderPaths{I,1},'FilePath',folderPaths{I,3},'Control',{controlInformation},'Experiment',{peakInformation});
        ExtraInformations{groupCC}=fullExtraInfo(1:end-1);
        groupCC=groupCC+1;
    end
    % Noise {I}= sixtyHZtrace;
end

% if (runParameters.Show_60hz_Noise==1)
%     figure;
%     plot(Noise{1});
%     for I=2:nFolders
%         hold all;
%         plot( Noise {I});
%     end
%     title('60 hz noise along control traces');
% end


end

