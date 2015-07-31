function [fixedInFile]= PCA_Decorrelate( peaksInFile, runParams )
%PCA_Decorrelate: samples the peaks, does PCA, and then rotates the
%coordinates
%   Detailed explanation goes here

sampled =[];

%pca requires that the data be mean centered
for I=1:length(peaksInFile.Peaks)
   dataTrain = peaksInFile.Peaks{I}.Train; 
   dataTest = peaksInFile.Peaks{I}.Test;
    
   maxPoints =200;
   s=size(dataTrain);
   if s(1)>maxPoints
       maxPoints =s(1);
   end
   
   indexs = randperm(s(1), maxPoints);
   data = dataTrain(indexs,:);
   
   sampled = vertcat(sampled,data);

   maxPoints =200;
   s=size(dataTest);
   if s(1)>maxPoints
       maxPoints =s(1);
   end
   indexs = randperm(s(1), maxPoints);
   data = dataTest(indexs,:);

   sampled = vertcat(sampled,data);
   
end

means = mean(sampled);

for K=1:length(means)
    sampled(:,K)=sampled(:,K)-means(K);
end    

[pc,score,latent,tsquare] = princomp(sampled);

coefforth=inv(diag(std(sampled)))*pc;

categories = peaksInFile.ColNames;
biplot(coefforth(:,1:2),'scores',score(:,1:2),'varlabels',categories);


varianceExplained =   cumsum(latent)./sum(latent)
figure;
    uitable('Data',varianceExplained,'ColumnName',['PCA Variance'],'Units','normalized','position',[0,0,1,1]);
    title('PCA Variance');
    

figure;
for I=1:length(peaksInFile.Peaks)

   dataTrain = peaksInFile.Peaks{I}.Train; 
   dataTest = peaksInFile.Peaks{I}.Test;

   for K=1:length(means)
       dataTrain(:,K)=dataTrain(:,K)-means(K);
       dataTest(:,K)=dataTest(:,K)-means(K);
   end    
   
    peaksInFile.Peaks{I}.Train=dataTrain * coefforth;
    peaksInFile.Peaks{I}.Test = dataTest * coefforth;
    
    s=size(dataTrain);
    indexs = randperm(s(1), 200);
    if (I==1)
        scatter3( peaksInFile.Peaks{I}.Train(indexs,1),peaksInFile.Peaks{I}.Train(indexs,2), peaksInFile.Peaks{I}.Train(indexs,3),3);
        axis([-1.5 1.5 -1.5 1.5 -1.5 1.5]);
        hold all;
    else 
        scatter3( peaksInFile.Peaks{I}.Train(indexs,1),peaksInFile.Peaks{I}.Train(indexs,2), peaksInFile.Peaks{I}.Train(indexs,3),3);
    end
end

fixedInFile=peaksInFile;
for I=1:length(fixedInFile.ColNames)
    fixedInFile.ColNames{I}= ['component' num2str(I)];
end

end