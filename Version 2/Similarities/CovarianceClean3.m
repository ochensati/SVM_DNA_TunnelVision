function [refinedData] = CovarianceClean3(refinedData,  badCutoff,runParams)
[~, A]=unique(refinedData.dataTable(:,3));
trainTable=refinedData.dataTable(A,:);

trainableIDX = find(trainTable(:,5)==0);
trainTable=trainTable(trainableIDX,runParams.dataColStart:end); %#ok<FNDSB>

colNames = refinedData.colNames ;
covar = corrcoef(trainTable);

%slice off those parameters that show a high correlation

ccB=1;
badParams=[];
disp('============================================');
disp('================bad Params==================');

%remove the null parameters.  no variance
for I=1:size(covar,1)
   covar(1:I,I)=0; 
end
idx = find( isnan(covar) );
cols = ( mod(idx-1 , size(covar,1))+1 );

badParams=unique(cols);

colNumbers = 1:size(covar,1);

colNumbers(badParams)=[];
trainTable(:,badParams)=[];

covar = corrcoef(trainTable);

    
colRows =cell([1 size(covar,1)]);
%now combine all those parameters that are too related
for col=1:size(covar,1)
    if (isempty(colRows{col})==true)
        
        tc= find(abs(covar(:,col)>badCutoff));
        for J=1:length(tc)
            colRows{tc(J)}= [0, 0];
        end
        
        if (length(tc)>3)
           colRows{col}=tc(1:3);
           for J=4:3:length(tc)
              colRows{tc(J)}=[];
              for K=0:2
                  if (J+K)<=length(tc)
                    colRows{tc(J)}= [ colRows{tc(J)}  tc(J+K)];     
                  end
              end
           end
        else 
           colRows{col} = tc;    
        end
        
    end
end

%combine those rows that are highly correlated
colNames=refinedData.colNames(1:runParams.dataColStart-1);
dataTable=refinedData.dataTable(:,1:runParams.dataColStart-1);
cc=runParams.dataColStart;
for col=1:size(covar,1)
    t=colRows{col};
    if (min(t)>0)
        if (isempty(t)==false)
            dataTable(:,cc)=refinedData.dataTable(:,t(1)+runParams.dataColStart-1); %#ok<AGROW>
            colNames{cc}=refinedData.colNames{t(1)+runParams.dataColStart-1}; %#ok<AGROW>
           % badParams=[badParams (t(1) +runParams.dataColStart-1)]; %#ok<AGROW>
            for I=2:length(t)
                dataTable(:,cc)=dataTable(:,cc) + refinedData.dataTable(:,t(I)+runParams.dataColStart-1); %#ok<AGROW>
                badParams=[badParams (t(I) +runParams.dataColStart-1)]; %#ok<AGROW>
                colNames{cc} = [colNames{cc} '-' refinedData.colNames{t(I)+runParams.dataColStart-1}]; %#ok<AGROW>
            end
        else
            dataTable(:,cc)=refinedData.dataTable(:,col+runParams.dataColStart-1); %#ok<AGROW>
            colNames{cc}=refinedData.colNames{col+runParams.dataColStart-1}; %#ok<AGROW>
        end
        cc=cc+1;
        if (cc==9)
            disp('e');
        end
    end
end

if (isempty(badParams)==false)
    
    %find the only values
    badParams = unique(badParams);
    
    % badParams=badParams(2:end);
    
    disp('=====================bad Params===================');
    
    fprintf( '%s\n', refinedData.colNames{badParams});
end

disp('=====================new Params===================');
fprintf( '%s\n', colNames{:});
 
refinedData.colNames=colNames;
refinedData.dataTable=dataTable;


end