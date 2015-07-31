
function [waterSignal]=GetWaterClass(conn,experiment_Index,colNames, controlTable,runParams)
 
temp = controlTable(:,runParams.dataColStart:end);
sz=size(temp);
mx =200;
if (sz(1)>mx*2)
    idx = randperm(sz(1),mx*2);
    tempTest=temp(idx(mx:end),:);
    tempTrain=temp(idx(1:mx),:);
else
    idx = randperm(sz(1));
    tempTest=temp(idx(mx:end),:);
    tempTrain=temp(idx(1:mx),:);
end
clear temp;

kernel='htrbf';
verbose=0;
nu=.9;

cc=1;
for C=.1:.5:3
    for gamma=.1:.5:3
        
        kerneloption=[C gamma];
        
        %now set up the water signal svm
        [xsup,alpha,rho,~]=svmoneclass(tempTrain,kernel,kerneloption,nu,verbose);
        threshold = rho/2;
        
        waterSignal.xsup=xsup;
        waterSignal.alpha=alpha;
        waterSignal.rho=rho;
        waterSignal.kernel=kernel;
        waterSignal.kerneloption=kerneloption;
        waterSignal.threshold=threshold;
        waterSignal.ColNames=1;
        
        
        ypred = svmoneclassval(tempTest,waterSignal.xsup,waterSignal.alpha,waterSignal.rho,waterSignal.kernel,waterSignal.kerneloption);
        idx= length( find(  ypred>threshold  ) ) /length(ypred) * 100;
        fprintf([num2str(idx) '\n']);
        
        t.all = waterSignal;
        t.C=C;
        t.gamma = gamma;
        t.accur = idx;
        
        test(cc)=t; %#ok<AGROW>
        cc=cc+1;
    end
end

bestAccur=1000000;

for I=1:length(test)
    accur = abs( test(I).accur - 85);
    
    if ( accur< bestAccur)
        waterSignal = test(I);
        bestAccur = accur;
    end
end

C=waterSignal.C;
gamma = waterSignal.gamma;
allPcount = size(tempTrain,2);

train = tempTest;
test = tempTrain;

clear waterSignal;
cc=1;
for I=1:10
        nParams =randi( allPcount );
        %provides a sort, as well as insurance
        colNumbers =unique( randperm(allPcount,nParams));

        tempTrain = train(:,colNumbers);
        tempTest = test(:,colNumbers);
        
        kerneloption=[C gamma];
        
        %now set up the water signal svm
        [xsup,alpha,rho,~]=svmoneclass(tempTrain,kernel,kerneloption,nu,verbose);
        threshold = rho/2;
        
        waterSignal.xsup=xsup;
        waterSignal.alpha=alpha;
        waterSignal.rho=rho;
        waterSignal.kernel=kernel;
        waterSignal.kerneloption=kerneloption;
        waterSignal.threshold=threshold;
        waterSignal.ColNames=colNumbers+4;
        
        
        ypred = svmoneclassval(tempTest,waterSignal.xsup,waterSignal.alpha,waterSignal.rho,waterSignal.kernel,waterSignal.kerneloption);
        idx= length( find(  ypred>threshold  ) ) /length(ypred) * 100;
        fprintf([num2str(idx) '\n']);
        
        t.all = waterSignal;
        t.accur = idx;
        
        testCol(cc)=t; %#ok<AGROW>
        cc=cc+1;

end


bestAccur=0;

for I=1:length(testCol)
    accur = abs( testCol(I).accur );
    testCol(I)
    if ( accur> bestAccur)
        waterSignal = testCol(I).all;
        bestAccur = accur;
    end
end


sql =['insert into SVM_Parameters ' ... 
    '(SVM_Experiment_Index,  SVM_xsup , SVM_role,SVM_alpha , SVM_rho, SVM_kernal, SVM_kernaloption, SVM_threshold , SVM_colNames) '...
    'VALUES (' ...
    num2str(experiment_Index) ',''' sprintf('%f3,',waterSignal.xsup) ''',''WaterParameters'',''' sprintf('%f3,',waterSignal.alpha) ''',' ...
    num2str(waterSignal.rho) ',''' waterSignal.kernel ''',''' sprintf('%f3,',waterSignal.kerneloption) ''',' ...
    num2str(waterSignal.threshold) ',''' sprintf('%s,', colNames{ waterSignal.ColNames}) ''');'];

exec(conn,sql);

disp('done');
end