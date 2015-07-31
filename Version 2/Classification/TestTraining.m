experimentName=expName;
controlTable=controlTable2;
extraInfo= extraInfo2;


allColNames=reorganizedGroups.ColNames;

nIterations =  runParams.Number_SVM_Iterations;

%set the basic parameters of the svm training
Pairs {1,1}='ARG_L';
Pairs {1,2}=[];
Pairs {2,1}='ASN_D';
Pairs {2,2}='ASN_L';
Pairs {3,1}='GLY';
Pairs {3,2}='mGLY';
Pairs {4,1}='ILE';
Pairs {4,2}='LEU';

clusterOnly=[];
peakOnly=[];
for I=4:length(reorganizedGroups.ColNames)
    if (strfind(reorganizedGroups.ColNames{I},'ClusterInfo')==true)
        clusterOnly =[clusterOnly I]; %#ok<AGROW>
    else
        peakOnly =[peakOnly I]; %#ok<AGROW>
    end
end

for I=1:size(Pairs,1)
    
    Pairs{I,3}=I;
    for J=1:length(reorganizedGroups.Peaks)
        for K=1:2
            if (strcmp(Pairs{I,K},reorganizedGroups.Peaks{J}.GroupName))
                reorganizedGroups.Peaks{J}.Graph =I;
            end
        end
    end
end

kernalProps=CopyKernalParameters(SVMParams);%DefaultKernalParameters();
kernalProps.nbclass =length(reorganizedGroups.Peaks);
if (strcmp( runParams.SVM_Method, 'Random')~=1)
    nIterations = length(runParams.SVM_Parameters);
end

cc=0;
runTable=[]; %#ok<NASGU>
GeneralStatsTraining=[]; %#ok<NASGU>
allCallsCC=1;
allCalls=[];
for I=1:1
    disp('Running iteration');
    disp(I);
    try
           
                nParams =randi( (length(allColNames)-5))+1;
                colNumbers = randperm(length(allColNames)-3,nParams)+3;
        
        SelectedParams = allColNames(colNumbers );
        for K=1:length(SelectedParams)
            disp(SelectedParams{K});
        end
        
        %write out the parameters used, with a format that can be written to a
        %csv file
        parameterColNames =[];
        for K=1:(length(SelectedParams)-1)
            parameterColNames =[parameterColNames  SelectedParams{K} '| ']; %#ok<AGROW>
        end
        parameterColNames =[parameterColNames  SelectedParams{length(SelectedParams)} ]; %#ok<AGROW>
        
        if (length(colNumbers)==2)
            for K=1:size(Pairs,1)
                figure(Pairs{K,3});
                clf;
            end
        end
        
        generalStats={};
        GeneralStatsTop.ColNames{1}='Param Names';
        GeneralStatsTop.DataTable{1}=parameterColNames;
        
        disp('**********');
        disp('training svm');
        if true
            [commonSVM anomolySVM allPeaksSVM GeneralStatsTraining ]=TrainSVMs(K,reorganizedGroups,runParams, colNumbers, kernalProps);
            
            disp('testing trainging');
            [extraInfo,GeneralStatsTesting, perGroupStatsTesting,wholeTruePositive,runTable, calls]=TestData(reorganizedGroups,runParams, colNumbers, commonSVM ,anomolySVM, allPeaksSVM,extraInfo);
        else
            bars =[]; %#ok<UNRCH>
            for K=1:length(reorganizedGroups.Peaks)
                if (length(colNumbers)==2)
                    tSingleGroup= reorganizedGroups.Peaks{K}.Train(:,colNumbers);
                    % tSingleGroup= reorganizedGroups.Peaks{K}.Train(:,colNumbers);
                    
                    peakN = tSingleGroup(:,1)*(129-3)+3;
                    figure(reorganizedGroups.Peaks{K}.Graph);
                    %   scatter(tSingleGroup(:,1),tSingleGroup(:,2));%,tSingleGroup(:,3));
                    n= histc(peakN,1:5:55);
                    n=n(1:end-1);
                    n=n/sum(n);
                    bars=horzcat(bars,n);
                    %bar(n(1:50));
                    drawnow;
                    hold all;
                    
                    %                     tSingleGroup= reorganizedGroups.Peaks{K}.Train(:,colNumbers);
                    %                     scatter(tSingleGroup(:,1),tSingleGroup(:,2));%,tSingleGroup(:,3));
                    %                     drawnow;
                    
                end
            end
        end
        
         plotColorCodedPeaks2(I,extraInfo)
        
        if (length(colNumbers)==2)
            for K=2:2%size(Pairs,1)
                figure(Pairs{K,3});
                drawnow;
                title([Pairs{K,1} '- ' Pairs{K,2}]);
                xlabel(SelectedParams{1});
                ylabel(SelectedParams{2});
                %zlabel(SelectedParams{3});
                hold off;
                drawnow;
                options.Format = 'jpeg';
                hgexport( K,[runParams.Output_Folder '\\parameterSearch_' num2str(K) '_' num2str(I) '.jpg'],options);
                drawnow;
                
            end
        end
        
        
        if isempty(runTable)==false
            
            cell2csv([runParams.Output_Folder '\acurRuns' num2str(superIteration) '_' num2str(I) '_.csv'],runTable);
        end
        
        if isempty(GeneralStatsTraining)==false
            
            generalStats {1} =GeneralStatsTop;
            generalStats {2} =GeneralStatsTraining;
            
            
            generalStats  =horzcat(generalStats, GeneralStatsTesting); %#ok<AGROW>
            
            
            %        paramSig = zeros([length(allColNames) 1]);
            % paramOcc = zeros(size(paramSig));
            % paramOpt= zeros(size(paramSig));
            %
            % for J=1:length(colNumbers)
            %     paramOcc(colNumbers(J))= paramOcc(colNumbers(J))+1;
            %     paramSig(colNumbers(J))= paramSig(colNumbers(J))+Accuracy{I,3};
            %     paramOpt(colNumbers(J))= paramOpt(colNumbers(J))+Accuracy{I,3}*GoodForTesting;
            % end
            
            cc=cc+1;
            disp('recording data');
            RecordStats(cc,superIteration,experimentName,parameterColNames,runParams,wholeTruePositive,generalStats,perGroupStatsTesting);
            
            if (isempty(calls)==false)
                for JJ=1:size(calls,2)
                    callTable(1,JJ+1)={reorganizedGroups.Peaks{JJ}.GroupName};  %#ok<AGROW>
                    callTable(2+JJ,1)={reorganizedGroups.Peaks{JJ}.GroupName}; %#ok<AGROW>
                end
                
                for KK=1:size(calls,1)
                    for JJ=1:size(calls,2)
                        callTable{KK+1,JJ+1}=calls(KK,JJ); %#ok<AGROW>
                    end
                end
                
                
                cell2csv([runParams.Output_Folder '\calls' num2str(superIteration) '_' num2str(I) '_.csv'],callTable);
                
                if (isempty(allCalls)==true)
                    allCalls=calls;
                else
                    allCalls=allCalls+calls;
                end
                
                for JJ=1:size(allCalls,2)
                    callTable(1,JJ+1)={reorganizedGroups.Peaks{JJ}.GroupName}; %#ok<AGROW>
                    callTable(2+JJ,1)={reorganizedGroups.Peaks{JJ}.GroupName}; %#ok<AGROW>
                end
                
                for KK=1:size(allCalls,1)
                    for JJ=1:size(allCalls,2)
                        callTable{KK+1,JJ+1}=allCalls(KK,JJ)/allCallsCC; %#ok<AGROW>
                    end
                end
                allCallsCC=allCallsCC+1;
                
                cell2csv([runParams.Output_Folder '\allCalls' num2str(superIteration) '_.csv'],callTable);
                
            end
        end
    catch mex
        try
            dispError(mex);
            disp(mex.identifier);
            disp(mex.message);
            disp(mex.stack(1));
            disp(mex.stack(2));
            disp(mex.stack(3));
        catch 
            
        end
    end
end





