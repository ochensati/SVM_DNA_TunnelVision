function [colNames,combinedGroups] = CovarianceClean2(colNames,combinedGroups,  badCutoff)

covar = corrcoef(combinedGroups(:,4:end));

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

%these tend to domino, results in all the cluster and peak parameters being
%decimated.  So this section attempts to space out the attempts, then do
%the complete run.

I=1;
while ( I<=size(covar,1))
    for J=(I+1):size(covar,1)
        if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
            disp([num2str(I+3) '   ' num2str(J+3)]);
            badParams(ccB)=I+3; %#ok<AGROW>
            ccB=ccB+1;
            I=I+4;
            break;
        end
    end
    I=I+1;
end

badParams=unique(badParams);
I=1;
while ( I<=size(covar,1))
    bad=0;
    for K=1:length(badParams)
        if (I==badParams(K))
            bad=bad+1;
        end
    end
    
    if (bad==false)
        for J=(I+1):size(covar,1)
            if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
                disp([num2str(I+3) '   ' num2str(J+3)]);
                badParams(ccB)=I+3; %#ok<AGROW>
                ccB=ccB+1;
                I=I+4;
                break;
            end
        end
    end
    I=I+1;
end

badParams=unique(badParams);
I=1;
while ( I<=size(covar,1))
    bad=0;
    for K=1:length(badParams)
        if (I==badParams(K))
            bad=bad+1;
        end
    end
    
    if (bad==false)
        for J=(I+1):size(covar,1)
            if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
                disp([num2str(I+3) '   ' num2str(J+3)]);
                badParams(ccB)=I+3; %#ok<AGROW>
                ccB=ccB+1;
                I=I+4;
                break;
            end
        end
    end
    I=I+1;
end

badParams=unique(badParams);
I=1;
while ( I<=size(covar,1))
    bad=0;
    for K=1:length(badParams)
        if (I==badParams(K))
            bad=bad+1;
        end
    end
    
    if (bad==false)
        for J=(I+1):size(covar,1)
            if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
                disp([num2str(I+3) '   ' num2str(J+3)]);
                badParams(ccB)=I+3; %#ok<AGROW>
                ccB=ccB+1;
                I=I+4;
                break;
            end
        end
    end
    I=I+1;
end

%now for the full cleanup to see what is totally overlapping
badParams=unique(badParams);
I=1;
while ( I<=size(covar,1))
    bad=0;
    for K=1:length(badParams)
        if (I==badParams(K))
            bad=bad+1;
        end
    end
    
    if (bad==false)
        for J=(I+1):size(covar,1)
            if (  (abs(covar(I,J)))>badCutoff || isnan(covar(I,J)) )
                disp([num2str(I+3) '   ' num2str(J+3)]);
                badParams(ccB)=I+3; %#ok<AGROW>
                ccB=ccB+1;
                I=I+1;
                break;
            end
        end
    end
    I=I+1;
end

badParams = [badParams size(covar,1) ];

if (isempty(badParams)==false)
    
    %find the only values
    badParams = unique(badParams);

    badParams=badParams(2:end);
    
    disp('=====================bad Params===================');
    fprintf( '%s\n', colNames{badParams});
    
    cols=1:size(combinedGroups,2);
    cols(badParams)=[];
    combinedGroups=combinedGroups(:,cols);
    colNames=colNames(cols);
  
end


covar = corrcoef(combinedGroups(:,4:end));

figure(2);
surf(covar,'DisplayName','covar');figure(gcf)
shading interp
%contourf(xtest1,xtest2,ypred,50);shading flat;
xlabel('Parameter Number');
ylabel('Parameter Number');
zlabel('Correlation');

end