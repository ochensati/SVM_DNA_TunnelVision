function [dataTable,colNames] = PCA_PrefilterAfter(dataTable,colNames,runParams,analyteNames)


analytes = unique( dataTable(:,1) );

names = {};
for I=1:length(analytes)
    for J=1:size(analyteNames,1)
        if analytes(I) == analyteNames{J,2}
            names{I}=analyteNames{J,1}; %#ok<AGROW>
            break;
        end
   end
end

trainableIDX = find(dataTable(:,5)==0);
ratings= dataTable(trainableIDX,runParams.dataColStart:end);


w = 1./var(ratings);
[wcoeff,score,latent,tsquared,explained] = pca(ratings,...
'VariableWeights',w);

coefforth = diag(sqrt(w))*wcoeff;

idxs =  dataTable(:,1:runParams.dataColStart-1);
ratings= dataTable(:,runParams.dataColStart:end);
[z mu s]=zscore(ratings);

score = z*coefforth;


figure(51);clf;
hold all;
for I=1:length(analytes)
    idx=find(idxs(:,1)==analytes(I));
    step = ceil(length(idx)/1000);
    plot(score(idx(1:step:end),1),score(idx(1:step:end),2),'+')
end
hold off;
xlabel('1st Principal Component')
ylabel('2nd Principal Component')
legend(names);


means = median(score);
deviations = mean(abs( bsxfun(@minus, score, means) ));

nCols=size(score,2);
for L=1:nCols
    scoreD(:,L)=(score(:,L)-means(L))/deviations(L);
end

try
    figure(53);clf;
    hold all;
    for I=1:length(analytes)
        idx=find(idxs(:,1)==analytes(I));
        step = ceil(length(idx)/1000);
        X=scoreD(idx(1:step:end),1);
        Y=scoreD(idx(1:step:end),2);
        Z=scoreD(idx(1:step:end),3);
        
        scatter3(X,Y,Z);
    end
    hold off;
    xlabel('1st Principal Component')
    ylabel('2nd Principal Component')
    zlabel('3nd Principal Component')
    legend(names);
catch mex
end

w=size(ratings,2):-1:1;
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

fprintf('%s\n ',  colNames{runParams.dataColStart-1+idx});
fprintf('\n\n\n');

% 
% latent = latent.^.5;
% latent(1)=latent(1).^.1;
latent=(cumsum(latent) + .0001)./(.0001+ sum(latent));

figure(52);
plot(latent);
xlabel('column Number');
ylabel('descriptive power');

cutoff = find(latent>.99);
cutoff = cutoff(1);


%this has to be rescaled, as it goes crazy inside the PCA
means = median(score);
deviations = median(abs( bsxfun(@minus, score, means) ));

nCols=size(score,2);
for L=1:nCols
    score(:,L)=(score(:,L)-means(L))/deviations(L);
end

 dataTable =horzcat( idxs, score(:,1:cutoff));

 colNames= colNames(1:runParams.dataColStart);
cc=1;
for I=runParams.dataColStart:size( dataTable,2)
     colNames{I}=['PCA_Component' num2str(cc)];
    cc=cc+1;
end


end