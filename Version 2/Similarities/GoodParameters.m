function  [colNames,dataTable, controlTable, runParams] = GoodParameters(colNames, dataTable, controlTable, runParams )


analytes = unique(dataTable(:,1));
halfAnalyte = analytes(round(end/2));
C = 10;

% in order to properly reproduce the results presented in the NIPS paper
% one has to select C and Sigma using a span estimate criterion

positiveIDX = find(dataTable(:,1)>halfAnalyte);
negativeIDX = find(dataTable(:,1)<halfAnalyte);

labels =zeros([1 size(dataTable,1)]);
labels(positiveIDX)=1;
labels(negativeIDX)=-1;

% sigma tuning

option  = 'lupdate'  ; %['wbfixed','wfixed','lbfixed','lfixed','lupdate'].
pow = 1 ;

for i=1:3
    d=size(dataTable,2)-3;
    
    Sigma =0.01*ones(1,d);
    
    idxP=randperm(length(positiveIDX),100);
    idxN=randperm(length(negativeIDX),100);
    
    indapp=[  positiveIDX(idxP)' negativeIDX(idxN)'];
    x=dataTable(indapp,4:end);
    y=labels(indapp)';
    %------------------------------------------------------------------%
    %                       Feature Selection and learning
    %------------------------------------------------------------------%
    [Sigma,Xsup,Alpsup,w0,pos,nflops,crit,SigmaH] = svmfit(x,y,Sigma,C,option,pow,0);
    nsup=size(Xsup,1);
    
    
    badParams=find(Sigma==0)+3;
    
    if (isempty(badParams)==true)
       [v idx]=sort(Sigma); 
        badParams = idx(1:2)+3;
    end
    
    disp('=====================bad Params===================');
    fprintf( '%s\n', colNames{badParams});

    
    cols=1:size(dataTable,2);
    cols(badParams)=[];
    dataTable=dataTable(:,cols);
    controlTable=controlTable(:,cols);
    colNames=colNames(cols);
end

covar = corrcoef(dataTable(:,4:end));
figure(3);
surf(covar,'DisplayName','covar');figure(gcf)
shading interp
%contourf(xtest1,xtest2,ypred,50);shading flat;
xlabel('Parameter Number');
ylabel('Parameter Number');
zlabel('Correlation');


end
