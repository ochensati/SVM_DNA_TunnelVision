function DoPlots(peaksInFile, runParams)
    
   colors ={ 'r','g','b','y','m','c','k', 'r','g','b','y','m','c','k', 'r','g','b','y','m','c','k' };

   if (runParams.Default_Plots==1)
      PlotDefault(peaksInFile, runParams, colors);
   end

   PlotCustom(peaksInFile,runParams,colors);
end 


function PlotCustom(peaksInFile,runParams,colors)
   s = fieldnames (runParams);
   idx = strfind(s,'Plot');
   plotDefines =[];
 
   cc=1;
   %find the fields that tell what graphs are desired
   for I=1:length(idx)
       val=  runParams.(s{I})
       %if it is a plot and it asks for a string, it is probably what we
       %want
       if (isempty(idx{I})==0 && idx{I}~=0 && idx{I}==idx{I})
           if (  isa(val ,'char')==1)
               axis = regexp(val,'vs','split');
               %now get the desired axis, and make sure that they are not
               %already asked for (no dictionary?)
               if (length(axis)>1)
                   vectorPos = zeros([length(axis) 1]);
                   for K=1:length(axis)
                       axis(K)=strtrim(axis(K));
                       if (length(axis)>1)
                            positions =find(strcmp(plotDefines,axis{K}));
                       else
                           positions=[];
                       end
                       
                       if (isempty(positions)==1)
                           plotDefines=[plotDefines axis(K)];
                           vectorPos(K)=length(plotDefines); 
                       else 
                           vectorPos(K) = positions(1);    
                       end
                   end
                   graphs {cc}={vectorPos};
                   cc=cc+1;
               end 
           end
       end
   end
   selectedParam=plotDefines;
   
   plotParamExperiment = cell([length(peaksInFile) 1]);
   plotParamControl = cell([length(peaksInFile) 1]);

   nRows =0;
   for I=1:length(peaksInFile)
        temp=UnwrapParameters(selectedParam,peaksInFile{I}.WorkingDataset);
        plotParamExperiment{I}=temp;
        nRows = nRows + length(peaksInFile{I}.WorkingDataset);
   end
   
   nRowsControl =0;
   for I=1:length(peaksInFile)
        temp=UnwrapParameters(selectedParam,peaksInFile{I}.Control.PeaksInCluster);
        plotParamControl{I}=temp;
        nRowsControl = nRowsControl + length(peaksInFile{I}.Control.PeaksInCluster);
   end

   for I=1:length(graphs)
        figure;
        graph=graphs{I};
        graph=graph{1};
        
        %some of the data has empty arrays, make sure to skip those
        startI=2;
        for K=1:length(plotParamExperiment)
            sz= size(plotParamExperiment{K});
            if sz(1)~=0
                plot(plotParamExperiment{K}(:,graph(1)),plotParamExperiment{K}(:,graph(2)),['.' colors{K}]);
                startI=K+1;
                break;
            end
        end
        
        for K=startI:length(plotParamExperiment)
            sz= size(plotParamExperiment{K});
            if sz(1)~=0
               hold all;
               plot(plotParamExperiment{K}(:,graph(1)),plotParamExperiment{K}(:,graph(2)),['.' colors{K}]);
            end    
        end
        title([plotDefines(graph(1)) 'vs' plotDefines(graph(2))]);
        xlabel(plotDefines(graph(1)));
        ylabel( plotDefines(graph(2)));
       
   end
end

function PlotDefault(peaksInFile,runParams, colors)
   selectedParam{1}='Amplitude';
   selectedParam{2}='Peakwidth';
   selectedParam{3}='ClusterInfo.Amplitude';
   selectedParam{4}='ClusterInfo.Totalpower';
   
   plotParamExperiment = cell([length(peaksInFile) 1]);
   plotParamControl = cell([length(peaksInFile) 1]);

   nRows =0;
   for I=1:length(peaksInFile)
        temp=UnwrapParameters(selectedParam,peaksInFile{I}.WorkingDataset);
        plotParamExperiment{I}=temp;
        nRows = nRows + length(peaksInFile{I}.WorkingDataset);
   end
   
   nRowsControl =0;
   for I=1:length(peaksInFile)
        temp=UnwrapParameters(selectedParam,peaksInFile{I}.Control.PeaksInCluster);
        plotParamControl{I}=temp;
        nRowsControl = nRowsControl + length(peaksInFile{I}.Control.PeaksInCluster);
   end

    
    %do the comparison of the 'normal' parameters
    figure;
    startI=2;
    for I=1:length(plotParamExperiment)
        sz= size(plotParamExperiment{I});
        if sz(1)~=0
            semilogx(plotParamExperiment{I}(:,1),plotParamExperiment{I}(:,2),['.' colors{I}]);
            startI=I+1;
            break;
        end
    end
    
    for I=startI:length(plotParamExperiment)
       hold all;
       sz= size(plotParamExperiment{I});
      
       if sz(1)~=0
          semilogx(plotParamExperiment{I}(:,1),plotParamExperiment{I}(:,2),['.' colors{I}]);
       end   
    end
    title('Amplitude vs width');
    xlabel('Amplitude (pA)');
    ylabel('Peak Time (Samples)');

    
    
     %do the comparison of the 'normal' parameters
    figure;
    for I=1:length(plotParamExperiment)
      sz= size(plotParamExperiment{I});
      if sz(1)~=0
         semilogx(plotParamExperiment{I}(:,3),plotParamExperiment{I}(:,4),['.' colors{I}]);
         startI=I+1;
         break;
      end
    end
      
    for I=startI:length(plotParamExperiment)
       sz= size(plotParamExperiment{I});
       if sz(1)~=0
        hold all;
        semilogx(plotParamExperiment{I}(:,1),plotParamExperiment{I}(:,2),['.' colors{I}]);
       end
    end
    title('Cluster Amplitude vs Cluster Power');
    xlabel('Amplitude (pA)');
    ylabel('Power (pA)')
    
     %run a amplitude histogram

    figure;
    Amplitude =  plotParamExperiment{1}(:,1);
    AmpMean = mean(Amplitude);
    AmpSTD =std(Amplitude);

    aMin =min(Amplitude);

    XX=aMin:(AmpSTD/40):(AmpMean+.5*AmpSTD);
    [x y] = hist(Amplitude,XX);
    s=sum(x)/100;

    plotData = zeros([length(plotParamExperiment) length(XX)]);
    plotData(1,:)=x./s;

    for I=2:length(plotParamExperiment)
       hold all;
       Amplitude =plotParamExperiment{I}(:,1); 
       [x y]=hist(Amplitude,XX);
       s=sum(x)/100;
       plotData(I,:)=x./s;
    end

    bar(plotData');
    title('Amplitude Comparison');
    xlabel('Amplitude (pA)');
    ylabel('Frequency (Samples)');
end

function PlotPeaks(peaksInFile,runParams, colors)
 %show the peaks
        figure;
        for I=1:length(peaksInFile)
           peaks =[]; 
           allPeaks=peaksInFile{I}.WorkingDataset;
           for J=1:length(allPeaks)
              trace=allPeaks{J}.Trace; 
              peaks=vertcat(peaks, trace, zeros([10 1]) );
           end
           plot(peaks,colors{I});
           hold all;
        end
        title('Just Peaks Experiment');
        xlabel('Time (Samples) ');
        ylabel('Amplitude (pA)');
        
        
        %show the peaks
        figure;
        for I=1:length(peaksInFile)
           peaks =[]; 
           allPeaks=peaksInFile{I}.Control.AllPeaks;
           for J=1:length(allPeaks)
              trace=allPeaks{J}.Trace; 
              peaks=vertcat(peaks, trace, zeros([10 1]) );
           end
           plot(peaks,colors{I});
           hold all;
        end
        title('Just Control Peaks');
        xlabel('Time (Samples) ');
        ylabel('Amplitude (pA)');

end

function PlotClusters(peaksInFile,runParams, colors)
  %show the peaks
        figure;
        for I=1:length(peaksInFile)
           peaks =[]; 
           allPeaks=peaksInFile{I}.WorkingDataset;
           for J=1:length(allPeaks)
              trace=allPeaks{J}.Trace; 
              peaks=vertcat(peaks, trace, zeros([40 1]) );
           end
           plot(peaks,colors{I});
           hold all;
        end
        title('Just Clusters Experiment');
        xlabel('Time (Samples) ');
        ylabel('Amplitude (pA)');
        
        
        %show the peaks
        figure;
        for I=1:length(peaksInFile)
           peaks =[]; 
           allPeaks=peaksInFile{I}.Control.PeaksInCluster;
           for J=1:length(allPeaks)
              trace=allPeaks{J}.Trace; 
              peaks=vertcat(peaks, trace, zeros([40 1]) );
           end
           plot(peaks,colors{I});
           hold all;
        end
        title('Just Control Clusters');
        xlabel('Time (Samples) ');
        ylabel('Amplitude (pA)');

end