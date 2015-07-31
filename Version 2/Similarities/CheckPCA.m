function [ accuracies, controlAccuracies ] = CheckPCA( peaksInFile, runParams )
%CHECKSIMULARITY Summary of this function goes here
%   Detailed explanation goes here

    colNames = {'PeakFFTCoef+1','PeakFFTCoef+2','PeakFFTCoef+3','PeakFFTCoef+4','Frequency',  'ClusterInfo.Totalpower','ClusterInfo.PeakFFTCoef+1','ClusterInfo.PeakFFTCoef+2','ClusterInfo.PeakFFTCoef+3','ClusterInfo.PeakFFTCoef+4'};

    accuracies=1;
    controlAccuracies=1;

   
    allParam=[];
    allM = [];
    for I=1:length(peaksInFile)
        %length(peaksInFile{I}.Experiment.PeaksInCluster)/4
        idx = randi(length(peaksInFile{I}.Experiment.PeaksInCluster),[100 1]);
        temp{I}=UnwrapParameters(colNames,peaksInFile{I}.Experiment.PeaksInCluster(idx));
        allParam = vertcat(allParam, temp{I});
        
        allM = vertcat(allM , median(temp{I}));
    end
    
    
   
    %determine the mean and std deviation of each col
    s = size(allParam);
    nCols=s(2);
    means = median(allParam);
    stdev = std(allParam);

    for I=1:nCols
        allParam(:,I) = (allParam(:,I) - means(I))/stdev(I);
    end
    
    [coeff]=  princomp(allParam);
    
    figure;
    hold all;
    for J=1:length(peaksInFile)
        allParam = temp{J};
        for I=1:nCols
          allParam(:,I) = (allParam(:,I) - means(I))/stdev(I);
        end

        graphable = allParam*coeff;
        scatter( graphable(:,1),graphable(:,2));
    end
    

    means = median(allM);
    stdev = std(allM);

    for I=1:nCols
        allM(:,I) = (allM(:,I) - means(I))/stdev(I);
    end

    
    [coeff]=  princomp(allM);
    
    figure;
    hold all;
    for J=1:length(peaksInFile)
        allParam = temp{J};
        for I=1:nCols
          allParam(:,I) = (allParam(:,I) - means(I))/stdev(I);
        end

        graphable = allParam * coeff ;
        scatter( graphable(:,1),graphable(:,2));
    end
    
end
    


