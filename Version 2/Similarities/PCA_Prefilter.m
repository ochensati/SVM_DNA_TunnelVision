function [refinedData] = PCA_Prefilter(refinedData,runParams,analyteNames)


analytes = unique( refinedData.dataTable(:,1) );

names = {};
for I=1:length(analytes)
    for J=1:size(analyteNames,1)
        if analytes(I) == analyteNames{J,2}
            names{I}=analyteNames{J,1};
            break;
        end
   end
end

%get the clean (not testing or mix) peaks
[~, A]=unique(refinedData.dataTable(:,3));
trainTable=refinedData.dataTable(A,:);

trainableIDX = find(trainTable(:,5)==0);
ratings=trainTable(trainableIDX,runParams.dataColStart:end);

%determine the PCA weighted by the variance
w = 1./var(ratings);
idx=find(isinf(w));
w(idx)=[];
ratings(:,idx)=[];

[wcoeff,score,latent,tsquared,explained] = pca(ratings,...
'VariableWeights',w);

coefforth = diag(sqrt(w))*wcoeff;

%apply the transform to the whole sample
idxs = refinedData.dataTable(:,1:runParams.dataColStart-1);
ratings=refinedData.dataTable(:,runParams.dataColStart:end);
ratings(:,idx)=[];
[z mu s]=zscore(ratings);

score = z*coefforth;

%plot out the relative importance
w=size(coefforth,2):-1:1;
for I=1:size(ratings,2)
    vec=zeros([1 size(ratings,2)]);
    vec(I)=1;
    vec=(vec-mu)./s;
    cscore = vec*coefforth;   
    importance(I) = sum( (w.*cscore));
end

importance=(importance-min(importance))./(max(importance)-min(importance));


[t idx]=sort(abs(importance));
fprintf('relative importance of features');

fprintf('%s\n ', refinedData.colNames{runParams.dataColStart-1+idx});
fprintf('\n\n\n');

%determine which parameters just do not vary
latent=(cumsum(latent) + .0001)./(.0001+ sum(latent));
cutoff = find(latent>.97);
cutoff = cutoff(1);


%this has to be rescaled, as it goes crazy inside the PCA
means = median(score);
deviations = median(abs( bsxfun(@minus, score, means) ));

nCols=size(score,2);
for L=1:nCols
    score(:,L)=(score(:,L)-means(L))/deviations(L);
end

%reform table and rename the columns
refinedData.dataTable =horzcat( idxs, score(:,1:cutoff));
refinedData.colNames=refinedData.colNames(1:runParams.dataColStart);
cc=1;
for I=runParams.dataColStart:size(refinedData.dataTable,2)
    refinedData.colNames{I}=['PCA_Component' num2str(cc)];
    cc=cc+1;
end

end