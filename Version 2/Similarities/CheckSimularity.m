function  CheckSimularity( peaksInFile, runParams )
%CHECKSIMULARITY uses something like a chi squared test of the pdf of the
%points
%   Detailed explanation goes here
    colNames = runParams.Simularity_Cols ;

   % use the first peaks to get the normalization factors
    cols = strtrim(regexp(colNames,'\|','split'));
    if ( strcmp( cols(1) , 'All') )
       cols =  peaksInFile.ColNames; %AllColumnNames( peaksInFile{1}.WorkingDataset{1}, runParams  );
    end
    allColNames=peaksInFile.ColNames;
    
    accuracies = zeros(length(peaksInFile.Peaks));
   
    peaks1=  PickCols(allColNames, peaksInFile.Peaks{1}.Train, cols);
    variance = GetGroupChiSquaredVariance(peaks1);
    %now apply these to each experiment, and use the SVM (one class)to compare the
    %datasets
    for I=1:length(peaksInFile.Peaks)
        for J=(I):length(peaksInFile.Peaks)
            
            if (isempty(peaksInFile.Peaks{I}.Train)==0 && isempty(peaksInFile.Peaks{J}.Train)==0)

                peaks1=  PickCols(allColNames, peaksInFile.Peaks{I}.Train, cols);
                %Only using the variance of one of the things.  this should probably be done differently
                if (I==J && isempty(peaksInFile.Peaks{I}.Test)==0)
                   peaks2 = PickCols(allColNames, peaksInFile.Peaks{I}.Test,cols);
                else 
                   peaks2=  PickCols(allColNames, peaksInFile.Peaks{J}.Train, cols);
                end
                
                if ( isempty(peaksInFile.Peaks{I}.Test)==0)
                    peaks3 = PickCols(allColNames, peaksInFile.Peaks{I}.Test,cols);
                else 
                    peaks3 =[];
                end
                
                crossAccuracy= ChiSquaredTest(peaks1,peaks2,peaks3, variance,(I==J),peaksInFile.Peaks{I}.GroupName); 
                      
                accuracies(I,J)=crossAccuracy;
                accuracies(J,I)=crossAccuracy;
            end
        end
    end

    
    %handle the contrl information
    cnamesSim{1} ='GroupName';
    %plot out cross overlaps
    for K=1:length(peaksInFile.Peaks)
        cnamesSim{K+1} = peaksInFile.Peaks{K}.GroupName; %#ok<AGROW>
        tableValuesSim{K,1} = peaksInFile.Peaks{K}.GroupName; %#ok<AGROW>
        for L=1:length(accuracies)
            tableValuesSim{L,K+1}=accuracies(L,K);
        end    
    end
    
    figure;
    uitable('Data',tableValuesSim,'ColumnName',cnamesSim,'Units','normalized','position',[0,0,1,1]);
    title('Similarity matrix');
    
    clear cnamesSim;
    clear tableValuesSim;
    disp('===============================')
end

