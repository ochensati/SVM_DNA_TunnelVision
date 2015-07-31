function [reorganizedPeaksInFile]= TableAndNormalize( peaksInFile, runParams  )
%TableAndNormalize puts all the parameters in the form of a table, and then
%scales the data by the mean and stddev of the first dataset

    colNames = AllColumnNames( peaksInFile{1}.WorkingDataset{1}, runParams  );
    % use the first peaks to get the normalization factors
    temp=UnwrapParameters(colNames,peaksInFile{1}.WorkingDataset(1:1000));

    %determine the mean and std deviation of each col
    s = size(temp);
    nCols=s(2);
    means = zeros([nCols 1]);
    stdev=zeros([nCols 1]);
    for I=1:nCols
        means(I) = mean(temp(:,I));
        stdev(I) = std(temp(:,I));
    end

    maxSamplePoints =runParams.maxSVMPoints;
    
    cc=0;
    for I=1:length(peaksInFile)
       hasTestData = isfield(peaksInFile{I},'Test') ;
       %put the data into the format of a table 
       temp=UnwrapParameters(colNames,peaksInFile{I}.WorkingDataset );
       
       %1000 points is about all the svm can handle.  
       %maybe make this into a run param
       s=size(temp);           
       if (s(1)>maxSamplePoints)
           if hasTestData==false
                wholeIndexs  =randperm(s(1), s(1)); 
                
                if (s(1)>maxSamplePoints*2)
                    maxCount = maxSamplePoints;
                else 
                    maxCount = s(1)/2;
                end
                
                tempCut = temp(wholeIndexs(1:maxCount)); 
           else 
                maxPoints = maxSamplePoints;
                if s(1)<maxSamplePoints
                    maxPoints = s(1)/2;
                end
                
                indexs  =randperm(s(1), maxPoints); 
                tempCut = temp(indexs,:); 
           end     
       else 
           tempCut = temp;
       end
       
       s2 = size(tempCut);
       if (s2(1)>300)
           
          %scale the data to keep the weights correct
           for L=1:s(2)
              tempCut(:,L)=(tempCut(:,L)-means(L))./stdev(L) + means(L);
           end

           cc=cc+1;
           newPeaksInFile{cc}.Train=tempCut; %#ok<*AGROW>
           newPeaksInFile{cc}.GroupName = peaksInFile{I}.GroupName;
           

           if hasTestData ==false 
               if (s(1)>maxSamplePoints*2)
                    maxCount = maxSamplePoints;
               else 
                    maxCount = s(1)/2;
               end
               newPeaksInFile{cc}.Test = temp(maxCount:2*maxCount );     
           else    
               %put the data into the format of a table 
               temp=UnwrapParameters(colNames,peaksInFile{I}.Test.WorkingDataset );

                s=size(temp);           
                if (s(1)>maxSamplePoints)
                    maxPoints = maxSamplePoints;
                    if (s(1)<maxSamplePoints)
                        maxPoints = s(1)/2;
                    end

                    indexs  =randperm(s(1)/2, maxPoints); 
                    tempCut = temp(indexs,:); 
               else 
                   tempCut = temp;
               end
               
               s=size(tempCut);           
               for L=1:s(2)
                  tempCut(:,L)=(tempCut(:,L)-means(L))./stdev(L) + means(L);
               end

               newPeaksInFile{cc}.Test = tempCut;
           end 
       end
    end
    
    reorganizedPeaksInFile.ColNames = colNames;
    reorganizedPeaksInFile.Peaks = newPeaksInFile;
end