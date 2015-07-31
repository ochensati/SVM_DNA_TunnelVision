function [ reformatedDataTable ] = PickCols(allColNames,  dataSet, colNames )
%PickCols produces a reformated table with only the desired columns
%   Detailed explanation goes here

    cols = strtrim(regexp(colNames,'\|','split'));
    if ( strcmp( cols(1) , 'All') )
       cols =  allColNames;
    end

    colNumbers =[];
    for I=1:length(cols)
         colNumbers = [colNumbers   find( strcmp(allColNames,cols{I}) ==1)];
    end
    
    reformatedDataTable = dataSet(:,colNumbers);
end