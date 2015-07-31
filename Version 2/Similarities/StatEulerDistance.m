function  [distances] = StatEulerDistance( analyteData )
%StatEulerDistance: computes the statistical distance between groups
folders = unique(analyteData(:,4));

s = size( analyteData) -[0,4];
DistTable=cell([length(folders) 1]);
for I=1:length(folders)
    data =analyteData( analyteData(:,4)==folders(I) , 5:end);
    vectors=zeros(4,s(2));
    vectors(1,:) = mean(data);
    vectors(2,:) = std(data);
    vectors(3,:) = skewness(data);
    vectors(4,:) = kurtosis(data);
    
    d1=vectors(4,:);
    vectors(:,isnan(d1))=1;
    
    DistTable{I} = vectors;
end

norms = [1,1,3,10]';
distances = zeros([s(2) 1]);
for I=1:s(2) %get the variance in each parameter
    vals =cell([1 length(folders)]);
    for K=1:length(folders)%get the points from each group
        table = DistTable{K};
        vec = table(:,I);
        vals{K}=vec;
    end
    means =zeros([4 1]);
    for K=1:length(vals)
        means =means + vals{K};
    end
    means = means./length(vals);
    dif =zeros(size(means));
    for K=1:length(vals)
        dif  = dif + abs( vals{K} -  means);
    end
    
    distances(I)= sum(dif./norms)/length(folders);
end


end