function  [ refinedData] = GoodParameters2( refinedData,  runParams )
%GoodParameters: uses standard statistical tools to remove bad parameters

%This runs through the data to determine how close the parameters are to
%the other groups


trainableIDX = find(refinedData.dataTable(:,5)==0);
trainTable=refinedData.dataTable(trainableIDX,:);


analytes = unique( trainTable(:,1) );

%combine each of the unique names with their test data to determine
%which parameters just do not behave within their own groups
for I=1:length(analytes)
    aData =trainTable( trainTable(:,1)==analytes(I), [1:4 runParams.dataColStart:end]);
    %get the distance between the distributions for each feature
    t = StatEulerDistance(aData );
    if (I==1)
        parameterRates = zeros([length(analytes) length(t)]);
    end
    parameterRates(I,:) =  t;
end


intraGroup = mean(parameterRates);
%put together to table with the index
aData = horzcat(trainTable(:,4), trainTable(:,2:3), trainTable(:,1), trainTable(:,runParams.dataColStart:end));

%now get the difference over the whole group
interGroup = StatEulerDistance(aData )';

%difference within the group over difference over the whole experiment
rating = intraGroup.^.5./interGroup.^.5;

[v idx]=sort(rating,'descend');

plot(v);

try
    disp('Columns in order of usefulness (first is least useful)');
    ratedCols = refinedData.colNames(idx+runParams.dataColStart-1)';
    fprintf('%s, \n ', ratedCols{:});
    
catch mex
    dispError(mex);
end

%cut out the ones that fail to be significant
badCols = find( rating>runParams.In_Vs_Out_Cutoff);

refinedData.dataTable(:,badCols+runParams.dataColStart-1)=[];
refinedData.colNames(badCols+runParams.dataColStart-1)=[];

end
