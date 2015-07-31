


    colNames = AllColumnNames( PeaksInFile, runParams  );
   % use the first peaks to get the normalization factors
    temp=UnwrapParameters(colNames,PeaksInFile{1}.Experiment.PeaksInCluster(1:500));
   
    %determine the mean and std deviation of each col
    s = size(temp);
    nCols=s(2);
    means = zeros([nCols 1]);
    stdev=zeros([nCols 1]);
    for I=1:nCols
        means(I) = median(temp(:,I));
        stdev(I) = std(temp(:,I));
    end
nIterations=1;
    Accuracy = cell([nIterations (4 + 4*length(PeaksInFile))]);

    %set the basic parameters of the svm training
    nbclass=length(PeaksInFile);
    c = 1000;
    lambda = 1e-7;
    %kerneloption= 1;
    %kernel='gaussian';
    verbose = 0;
    
     kernel='htrbf';
     kerneloption=[.5 .5];
     nu=.95;
    
   for iteration=1:550
       fileID = fopen('c:\\temp\\accurlog4.txt','a');
        %randomly select cols
           nParams =random('unid',length(colNames));
           colNumbers =random('unid',length(colNames), 1, nParams);
           SelectedParams = colNames(colNumbers );
           
           nSamples =500;
           %pull out these cols and normalized them
           nPoints =zeros([length(PeaksInFile) 1]);
           
           testASPD=PeaksInFile{1}.Experiment.PeaksInCluster(end-nSamples:end);
           
           reduced = cell([length(PeaksInFile) 1]);
           for K=1:length(PeaksInFile)
                if (length(PeaksInFile{K}.Experiment.PeaksInCluster)<500)
                    reduced{K}=PeaksInFile{K}.Experiment.PeaksInCluster;
                else 
                    r=randi(length( PeaksInFile{K}.Experiment.PeaksInCluster ),[1 nSamples]);
                    reduced{K}=PeaksInFile{K}.Experiment.PeaksInCluster(r);
                end    
           end
           
           
           
           temps= cell([length(PeaksInFile) 1]);
          
           for K=1:length(PeaksInFile)
                temp=UnwrapParameters(SelectedParams,reduced{K});
                s=size(temp);            
                for L=1:s(2)
                  temp(:,L)=(temp(:,L)-means(colNumbers(L)))./stdev(colNumbers(L)) + means(colNumbers(L));
                end
                temps{K}=temp;
                nPoints(K)=s(1);
           end 
           
            
                tempASP=UnwrapParameters(SelectedParams,reduced{K});
                s=size(tempASP);            
                for L=1:s(2)
                  tempASP(:,L)=(tempASP(:,L)-means(colNumbers(L)))./stdev(colNumbers(L)) + means(colNumbers(L));
                end
               
           
           %find the minimum points
           minPoints = min(nPoints)-2;
                     
           %if the dataset has more points than this, cut it off to avoid
           %unbalanced training
           for K=1:length(temps)
               if (nPoints(K)>minPoints)
                   nPoints (K)=minPoints;
               end
           end
           totalPoints = sum(nPoints);
           %now put the points in the correct format
           Training =[];
           Testing = [];
           Grouping = [];
           testGrouping=[];
           cc=1;
           tTraining = temps([1 3 4 5]);
           tTesting = temps([2 6 3]);
           for K=1:length(tTraining)
               temp=tTraining{K};
               for L=1:nPoints(K)
                    Training (cc,:)=temp(L,:);
                    Grouping (cc)=K;
                    cc=cc+1;
               end     
           end
           
           cc=1;
           temp=tTesting{1};
           for L=1:nPoints(K)
               Testing (cc,:)=temp(L,:);
               testGrouping (cc)=1;
               cc=cc+1;
           end     
               
           temp=tTesting{2};
           for L=1:nPoints(K)
               Testing (cc,:)=temp(L,:);
               testGrouping (cc)=3;
               cc=cc+1;
           end
           
           for L=1:nPoints(K)
                Testing (cc,:)=tempASP(L,:);
                testGrouping (cc)=1;
                cc=cc+1;
           end    
      
           temp=tTraining{4};
           for L=1:nPoints(K)
               Testing (cc,:)=temp(L,:);
               testGrouping (cc)=3;
               cc=cc+1;
           end
           
          % svmModel=svmtrain(Training,Grouping,'kernel_function','rbf','showplot',false,'autoscale',true);
          % trainGrouping=  svmclassify(svmModel,Training,'showplot',false);
          % testGrouping = svmclassify(svmModel,Testing,'showplot',false);
          
          [xsup,w,b,nbsv,classifier]=svmmulticlassoneagainstone(Training,Grouping,4,c,lambda,kernel,kerneloption,verbose); %#ok<NASGU>
          [trainGrouping ] = svmmultivaloneagainstone(Training,xsup,w,b,nbsv,kernel,kerneloption); %#ok<NASGU>
          [testPGrouping] = svmmultivaloneagainstone(Testing,xsup,w,b,nbsv,kernel,kerneloption); %#ok<NASGU>
    
          
          posSame =find(Grouping == trainGrouping');
          trainingAccuracy = length(posSame)/length(Grouping)*100
          
         
          try 
             posSame = find(testPGrouping == testGrouping);
             testingAccuracy = length(posSame)/length(testPGrouping)*100
          catch 
             posSame = find(testPGrouping == testGrouping');
             testingAccuracy = length(posSame)/length(testPGrouping)*100
          end 
          
          accurARG_D = find(testPGrouping(1:nSamples) == 1);
          tAccurARG_D = length(accurARG_D)/nSamples*100 ;
             
          accurILE = find(testPGrouping(nSamples:2*nSamples) == 3);
          tAccurILE = length(accurILE)/nSamples*100 ;
                    
          accurARG_L = find(testPGrouping(2*nSamples:3*nSamples) == 1);
          tAccurARG_L = length(accurARG_L)/nSamples*100 ;
             
          accurLEU = find(testPGrouping(3*nSamples:end) == 3);
          tAccurLEU = length(accurLEU)/nSamples*100 ;
          
              
          tableAccuracy{iteration}=struct('training',trainingAccuracy,'testing',testingAccuracy,'params',{SelectedParams});
         
          
           simpleTable{iteration,1}= trainingAccuracy;
           simpleTable{iteration,2}= testingAccuracy;
           
           simpleTable{iteration,3}= tAccurARG_D;
           simpleTable{iteration,4}= tAccurILE;
           simpleTable{iteration,5}= tAccurARG_L;
           simpleTable{iteration,6}= tAccurLEU;
           
           for I=1:length(SelectedParams)
               simpleTable{iteration,6+I}= SelectedParams(I);
           end
           
           
           fprintf(fileID,'%6.2f, %6.2f, %6.2f, %6.2f, %6.2f, %6.2f, ',trainingAccuracy,testingAccuracy,tAccurARG_D,tAccurILE,...
               tAccurARG_L,tAccurLEU);
           
           for I=1:length(SelectedParams)
              fprintf(fileID,'%14s , ', SelectedParams{I});
           end

           fprintf(fileID,'\n ');
           fclose(fileID);
           continue;
   end


