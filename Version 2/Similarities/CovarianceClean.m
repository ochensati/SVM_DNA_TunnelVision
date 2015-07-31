function [refinedData] = CovarianceClean(refinedData,  badCutoff,runParams)




analytes = unique( refinedData.dataTable(:,1) );


[~, A]=unique(refinedData.dataTable(:,3));
trainTable=refinedData.dataTable(A,:);

trainableIDX = find(trainTable(:,5)==0);
trainTable=trainTable(trainableIDX,runParams.dataColStart:end);



colNames = refinedData.colNames ;
covar = corrcoef(trainTable);



figure(1);
surf(covar,'DisplayName','covar');figure(gcf)
shading interp
%contourf(xtest1,xtest2,ypred,50);shading flat;
xlabel('Parameter Number');
ylabel('Parameter Number');
zlabel('Correlation');

%slice off those parameters that show a high correlation

ccB=1;
badParams=[];
disp('============================================');
disp('================bad Params==================');


idx = find( isnan(covar) );
cols = ( mod(idx-1 , size(covar,1))+1 );

badParams=unique(cols);

colNumbers = 1:size(covar,1);

colNumbers(badParams)=[];
trainTable(:,badParams)=[];

for I=1:100
    pBad =[];
    
    covar = corrcoef(trainTable);
    surf(covar,'DisplayName','covar');figure(gcf)
    shading interp
    %contourf(xtest1,xtest2,ypred,50);shading flat;
    xlabel('Parameter Number');
    ylabel('Parameter Number');
    zlabel('Correlation');
    for K=1:size(covar,1)
        for L=K:size(covar,2)
            covar(K,L)=0;
        end
    end
    
    idx = find( abs(covar)>badCutoff );
    %idx = idx( randperm(length(idx)));
    
    cols = ( mod(idx-1 , size(covar,1))+1 );
    rows = ( floor ((idx-1) /size(covar,1))+1 );
    
    for J=1:length(cols)
        if (randi(10)>5)
            pBad =[pBad  cols(J)];
        else
            pBad =[pBad rows(J)];
        end
    end
    pBad = unique(pBad);
    pBad = pBad( randperm(length(pBad)));
    pBad= sort( pBad(  1:floor(length(pBad)/6)  )  );
    
    badParams = [badParams colNumbers(pBad)];
    colNumbers(pBad)=[];
    trainTable(:,pBad)=[];
    drawnow;
end

badParams = unique(badParams)+runParams.dataColStart-1;
% dataAddCol=runParams.dataColStart-1;
% %these tend to domino, results in all the cluster and peak parameters being
% %decimated.  So this section attempts to space out the attempts, then do
% %the complete run.
%
% I=1;
% while ( I<=size(covar,1))
%     for J=(I+1):size(covar,1)
%         if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
%             disp([num2str(I+dataAddCol) '   ' num2str(J+dataAddCol)]);
%             badParams(ccB)=I+dataAddCol; %#ok<AGROW>
%             ccB=ccB+1;
%             I=I+4;
%             break;
%         end
%     end
%     I=I+1;
% end
%
% badParams=unique(badParams);
% I=1;
% while ( I<=size(covar,1))
%     bad=0;
%     for K=1:length(badParams)
%         if (I==badParams(K))
%             bad=bad+1;
%         end
%     end
%
%     if (bad==false)
%         for J=(I+1):size(covar,1)
%             if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
%                 disp([num2str(I+dataAddCol) '   ' num2str(J+dataAddCol)]);
%                 badParams(ccB)=I+dataAddCol; %#ok<AGROW>
%                 ccB=ccB+1;
%                 I=I+4;
%                 break;
%             end
%         end
%     end
%     I=I+1;
% end
%
% badParams=unique(badParams);
% I=1;
% while ( I<=size(covar,1))
%     bad=0;
%     for K=1:length(badParams)
%         if (I==badParams(K))
%             bad=bad+1;
%         end
%     end
%
%     if (bad==false)
%         for J=(I+1):size(covar,1)
%             if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
%                 disp([num2str(I+dataAddCol) '   ' num2str(J+dataAddCol)]);
%                 badParams(ccB)=I+dataAddCol; %#ok<AGROW>
%                 ccB=ccB+1;
%                 I=I+4;
%                 break;
%             end
%         end
%     end
%     I=I+1;
% end
%
% badParams=unique(badParams);
% I=1;
% while ( I<=size(covar,1))
%     bad=0;
%     for K=1:length(badParams)
%         if (I==badParams(K))
%             bad=bad+1;
%         end
%     end
%
%     if (bad==false)
%         for J=(I+1):size(covar,1)
%             if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
%                 disp([num2str(I+dataAddCol) '   ' num2str(J+dataAddCol)]);
%                 badParams(ccB)=I+dataAddCol; %#ok<AGROW>
%                 ccB=ccB+1;
%                 I=I+4;
%                 break;
%             end
%         end
%     end
%     I=I+1;
% end
%
% %now for the full cleanup to see what is totally overlapping
% badParams=unique(badParams);
% I=1;
% while ( I<=size(covar,1))
%     bad=0;
%     for K=1:length(badParams)
%         if (I==badParams(K))
%             bad=bad+1;
%         end
%     end
%
%     if (bad==false)
%         for J=(I+1):size(covar,1)
%             if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
%                 disp([num2str(I+dataAddCol) '   ' num2str(J+dataAddCol)]);
%                 badParams(ccB)=I+dataAddCol; %#ok<AGROW>
%                 ccB=ccB+1;
%                 I=I+1;
%                 break;
%             end
%         end
%     end
%     I=I+1;
% end
%
% badParams = [badParams size(covar,1) ];

if (isempty(badParams)==false)
    
    %find the only values
    badParams = unique(badParams);
    
   % badParams=badParams(2:end);
    
    disp('=====================bad Params===================');
  
    fprintf( '%s\n', colNames{badParams});
    
    cols=1:size(refinedData.dataTable,2);
    cols(badParams)=[];
    refinedData.dataTable=horzcat(refinedData.dataTable(:,cols), sum(abs(refinedData.dataTable(:,badParams)),2 )) ;
    
    colNames=[colNames(cols) 'trash'];
    
end

refinedData.colNames=colNames;

covar = corrcoef(refinedData.dataTable(:,runParams.dataColStart:end));

figure(2);
surf(covar,'DisplayName','covar');figure(gcf)
shading interp
%contourf(xtest1,xtest2,ypred,50);shading flat;
xlabel('Parameter Number');
ylabel('Parameter Number');
zlabel('Correlation');

end