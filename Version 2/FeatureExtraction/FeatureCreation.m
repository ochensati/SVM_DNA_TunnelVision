function [folderNSamples, folderNPeaks, folderNClusters, folderBaseLine]=FeatureCreation(conn,analyteName, folder_Index,  folderPath, runParams , isControl)

folderNSamples=0;
folderNPeaks=0;
folderNClusters=0;
folderBaseLine=0;

disp('===============================')
disp('LOADING EXPERIMENT FILES')
%do all the experiment files
folderP = strrep(folderPath,'''''','''');
files = dir([folderP '\\*.tdms']);
%determine the file type in the folder
if isempty(files)
    files = dir([folderP '\\*.abf']);
end

csvFile =false;
if isempty(files)
    files = dir([folderP '\\*.csv']);
    csvFile=true;
end


if (csvFile ==false)
    grapheneFile = false;
    if isempty(files)
        tfiles = dir([folderP '\\*.mat']);
        csvFile=true;
        
        
        cc=1;
        for I=1:length(tfiles)
            if (findstr(tfiles(I).name,'EXPORT')) %#ok<*FSTR>
                files(cc)= tfiles(I);
                cc=cc+1;
            end
        end
        if (cc==1)
            grapheneFile=true;
            for I=1:length(tfiles)
                files(cc)= tfiles(I);
                cc=cc+1;
            end
        end
    end
end

bDataFile=false;
if isempty(files)
    bDataFile=true;
    tfiles = dir([folderP '\\*.dat']);
    
    
    cc=1;
    for I=1:length(tfiles)
        if (findstr(tfiles(I).name,'-e')) 
            files(cc)= tfiles(I);
            cc=cc+1;
        end
    end
    
end
%none of the files can be loaded
if isempty(files)
    disp('no files found for folder');
    fprintf('%s\n',folderP);
    return
end

[pathstr,dname,~] = fileparts(folderP) ;
[~,dname2,~] = fileparts(pathstr) ;
dname=[dname dname2];

%canvas and plot params are used to make the composite plot of all the
%peaks
canvas=[];
plotParams=[];
endFiles = min([length(files)+1 length(files)]);
for k=1:endFiles
    try
        %determine if this file has already been encoded with the correct
        %parameters
        fileName =[folderP '\' files(k).name];
        disp(fileName);
        
        a=strrep(fileName,'\','//');
        
        sql =['SELECT file_Index FROM files where FileName=''' a '''' ...
            'AND Folder_Index=' num2str(folder_Index) ';'];
        
        ret=fetch(exec(conn,sql));
        
        if isstruct(ret.Data)
            alreadyDone =true;
            file_Index = ret.Data.File_Index;
        else
            alreadyDone = false;
            sql =['INSERT INTO files (Folder_Index,FileName,Fl_numSamples,Fl_numPeaks,Fl_numClusters,Fl_BaselineVariance,Fl_60Hz) VALUE (' ...
                num2str( folder_Index) ',''temp'',0,0,0,0,0);' ];
            exec(conn,sql);
            
            sql = ['SELECT file_Index as m from files where Folder_Index=' num2str( folder_Index) ' and FileName=''temp'';'];
            ret = exec(conn,sql);
            ret = fetch(ret);
            
            file_Index=ret.Data.m;
            if length(file_Index)>1
                disp('FeatureCreation: overlap');
                
                sql = ['delete from files where Folder_Index=' num2str( folder_Index) ' and FileName=''temp'';'];
                 exec(conn,sql);
                
                
                sql =['INSERT INTO files (Folder_Index,FileName,Fl_numSamples,Fl_numPeaks,Fl_numClusters,Fl_BaselineVariance,Fl_60Hz) VALUE (' ...
                    num2str( folder_Index) ',''temp'',0,0,0,0,0);' ];
                exec(conn,sql);
                
                sql = ['SELECT file_Index as m from files where Folder_Index=' num2str( folder_Index) ' and FileName=''temp'';'];
                ret = exec(conn,sql);
                ret = fetch(ret);
                
                file_Index=ret.Data.m;
            end
            
        end
        
        if (alreadyDone == false)
            %if it has not, then do the collection
            disp('Loading: '); %='21May2012_001.tdms';
            disp (k);
            disp('*******************************')
            disp('LoadAndFilter')
            
            
            %load the trace from this file, remove the background and the
            %high frequencies
          
            [trace,assignmentNames ] = LoadAndFilterDat(folderP,files(k).name,runParams);
            drawnow;
            
            %a datafile does not have peaks, it is all signal, so we just
            %subdivide it into even sections.
            if bDataFile==true
                
                
                idx=find(strcmp(assignmentNames,'NN')==false);
                idx2=idx(2:end)-idx(1:end-1);
                edges = find(idx2~=1)';
                
                allStarts=[];
                allEnds=[];
                ccPeaks=1;
                for I=1:length(edges)-1
                    if idx2(edges(I)+1)==1
                        allStarts(ccPeaks)=idx(edges(I)+1)-1; %#ok<*AGROW>
                        allEnds(ccPeaks)=idx(edges(I+1)-1)+2;
                        ccPeaks=ccPeaks+1;
                    end
                end
                
                if length(allStarts)~=length(allEnds)
                    allEnds=allEnds(1:length(allStarts));
                end
                
                diffends=allEnds-allStarts;
                idx=find(diffends<4);
                allStarts(idx)=[];
                allEnds(idx)=[];
               
            else
                if (csvFile==true)
                    %the ionic peaks are downward and square so they have
                    %their own peak finders
                    if (grapheneFile==true)
                        [allStarts, allEnds, trace ] = EPFLPeakFinder(trace,runParams,dname,k );
                       
                    else
                        [allStarts, allEnds, trace ] = WPeakFinder(trace,runParams,dname,k );
                    end
                else
                    %tunneling peaks are upward and tend to be bunched
                    [allStarts, allEnds] = PeakRangeFinder( trace,  runParams );
                end
            end
            
            %plot all peaks over the top of each other
            runParams.examplePeaks=false;
            if (runParams.examplePeaks==true && isempty(allEnds)==false)
                if k==endFiles
                    [canvas,plotParams]=PlotConsensusGraph(trace, allStarts+700,allEnds-700,canvas,plotParams,true, ['C:\temp\mix\example_' num2str(folder_Index) '.jpg']);
                else
                    [canvas,plotParams]=PlotConsensusGraph(trace, allStarts+700,allEnds-700,canvas,plotParams,false);
                end
            end
            
            
            
            if isempty(allStarts)==false
                
                if (length(assignmentNames)==1)
                    assignmentNames={analyteName};
                end
                %Parameterize the peaks and clusters
                [numPeaks, numClusters]= ClusterPeakParameters(conn,assignmentNames,folder_Index,file_Index,trace, allStarts, allEnds,runParams );
                %determine how much 60 hz noise in the trace
                [ Hz60, baseLine  ] = GetTraceQuality( trace );
            else
                numPeaks=0;
                numClusters=0;
                Hz60=1000;
                baseLine=1000;
            end
            
            if isnan(Hz60)==true
                Hz60=0;
            end
            
            a=strrep(a,'''','''''');
            sql = ['update files set FileName=''' a ''', Fl_numSamples='  num2str(length(trace)) ',Fl_numPeaks=' num2str(numPeaks) ...
                ',Fl_numClusters=' num2str(numClusters) ',Fl_BaselineVariance='  num2str(baseLine)  ',Fl_60Hz='  num2str(Hz60)  ...
                ' where File_Index=' num2str(file_Index) ';'];
            
            ret= exec(conn,sql);
            
            if isempty( ret.Message)==false
                disp(ret.Message);
            end
            
            folderNSamples=folderNSamples + length(trace);
            folderNPeaks=folderNPeaks +numPeaks ;
            folderNClusters=folderNClusters + numClusters;
            folderBaseLine=folderBaseLine + baseLine;
        end
    catch mex
        dispError(mex)
        
        
    end
end
folderBaseLine=folderBaseLine/length(files);
end