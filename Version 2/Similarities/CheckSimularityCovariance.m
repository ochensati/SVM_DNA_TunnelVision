function [ bestParameters,stdCovars,stdMeans ] = CheckSimularityCovariance( sameGroups, runParams )
%CheckSimularityCovariance compares similar groups (i.e. ASP from different
%days to determine if they are the same or what variables change.

%   Detailed explanation goes here
    colNames = runParams.Simularity_Cols ;

   % use the first peaks to get the normalization factors
    cols = strtrim(regexp(colNames,'\|','split'));
    if ( strcmp( cols(1) , 'All') )
       cols =  AllColumnNames( sameGroups, runParams  );
    end
    
  
   covars = cell([length(sameGroups) 1]);
    
   centerMeans = zeros([1 length(cols)]);
   
    for I=1:length(sameGroups)
        if (isempty(sameGroups{I}.Experiment.PeaksInCluster)==0 )

                temp=UnwrapParameters(cols,sameGroups{I}.Experiment.PeaksInCluster);

                %determine the mean and std deviation of each col
                s = size(temp);
                nCols=s(2);
              
                covar = zeros([nCols nCols]);
                for J=1:nCols
                    mean(J) = median(temp(:,J));
                    %sd(J)= ( sum( (temp(:,J)- mean(J)).^2 ) / (s(1)-1))^.5;
                end
                
                for J=1:nCols
                    for K=1:nCols
                       covar(J,K) = sum( (temp(:,J) - mean(J) ).*( temp(:,K)-mean(K))  );
                    end
                end
                
                means{I}=mean;
                centerMeans = centerMeans + mean;
                
                covars{I}=covar./s(1);
                if (I==1)
                    meanCovars = covars{I};
                else 
                    meanCovars = meanCovars + covars{I};
                end
                
              %  figure; 
              %  clf; 
              %  contourf(covar);
              %  shading flat;
        end
    end
    
    centerMeans =centerMeans ./length(sameGroups);
    
    
    meanCovars = meanCovars ./length(sameGroups);
    stdCovars = zeros(size(meanCovars));
    stdMeans = zeros([1 length(centerMeans)]);
    for I=1:length(sameGroups)
       stdCovars = stdCovars + (covars{I}-meanCovars).^2;
       stdMeans = stdMeans + (means{I}-centerMeans).^2;
    end
    
    stdCovars = ((stdCovars./length(sameGroups)).^0.5);% ./ abs(meanCovars);
    stdMeans = ((stdMeans./length(sameGroups)).^0.5) ;
    
    difParam = diag(stdCovars);

    [N idx] = sort(difParam);
    
    bestParameters=difParam;% cols(idx)';
    

end