function [filteredData] = FilterData(conn,experiment_Index,parameterSet_Index,analytes,analyteNames,reducedData, anomalySVM, commonSVM,runParams )

%This is a little inefficent, because of the optional requirement that the
%data can be limited to clusters only.  So the data must be filtered into
%clusters and the extracted afterwards.
allIDX=1;
allGoods=0;
allBads =0;
allCommon=0;
allAnomaly=0;
for K=1:length(analytes)
    
    idx = find(reducedData(:,1)==analytes(K));
    
    if  runParams.Maintain_Clusters
        %This is really a pain. the data has to be interleaved between the
        %folders to keep all the available data represented, but the
        %clusters also have to be kept together. So one cluster is pulled
        %from each folder and then combined
        folders =unique(reducedData(idx,4));
        idx2=zeros(size(idx));
        
        for I=1:length(folders)
            cluster_indexs{I}.Indexs=unique( reducedData(reducedData(:,4)==folders(I),3) ) ;
            cluster_indexs{I}.count =1;
        end
        
        cc=1;
        while cc<length(idx)
            for I=1:length(folders)
                if cluster_indexs{I}.count<=length(cluster_indexs{I}.Indexs)
                    cI= cluster_indexs{I}.Indexs(cluster_indexs{I}.count);
                    
                    idxC =find( reducedData(idx,3)==cI );
                    for J=1:length(idxC)
                        idx2(cc)=idx(idxC(J));
                        cc=cc+1;
                    end
                end
                cluster_indexs{I}.count=cluster_indexs{I}.count+1;
            end
        end
        idx=idx2;
        idx(idx==0)=[];
    else
        idx = idx(randperm(length(idx)));
    end
    
    testData = reducedData(idx,:);
    
    if runParams.Clusters_Only
        cluster_Index=unique( testData(:,3) ) ;
        temp = zeros(length(cluster_Index), size(testData,2));
        for I=1:length(cluster_Index)
            clusterValues = mean( testData( testData(:,3)==cluster_Index(I),:),1);
            clusterValues(2)=round(clusterValues(2));
            temp(I,:)=clusterValues(:);
        end
        testData=temp;
        clear temp;
        idx = 1:size(testData,1);
    end
    
    goods=0;
    
    goodIndexs =[];
    localGoods =0;
    localBads =0;
    commonBad=0;
    anomalyBad=0;
    for I=1:500:size(idx,1)
        outs =1+ zeros([500 1]);
        top = min([ length(idx) I+500]);
        i2=(I:top);
        temp= testData(i2,5:end);
        ABad=0;
        CBad=0;
        if isempty(anomalySVM )==false
            predictedGroupsA = svmoneclassval(temp,anomalySVM.xsup,anomalySVM.alpha,anomalySVM.rho,anomalySVM.kernel,anomalySVM.kerneloption);
            outs(predictedGroupsA<anomalySVM.threshold)=0;
            ABad =length(outs)- sum(outs);
        end
        
        if isempty(commonSVM )==false
            predictedGroupsB = svmoneclassval(temp,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
            outs(predictedGroupsB>=commonSVM.threshold)=0;
            CBad =length(outs)-sum(outs);
        end
        
        commonBad = commonBad + CBad-ABad;
        anomalyBad=anomalyBad+ABad;
        
        
        allCommon=allCommon+CBad-ABad;
        allAnomaly=allAnomaly+ABad;
        
        i3=i2(outs==1);
        goodIndexs=[goodIndexs i3]; %#ok<AGROW>
        goods = goods + length(i3);
        allGoods=allGoods + length(i3);
        allBads = allBads + abs(length(i3) -500);
        
        localGoods=localGoods + length(i3);
        localBads = localBads + abs(length(i3) -500);
        
        
        if goods >runParams.maxSVMPoints*2
            break;
        end
    end
    filtered{K} = testData(goodIndexs,:); %#ok<AGROW>
    allIDX=allIDX+length(goodIndexs);
    %conn,experiment_Index,
    sql = ['insert into SVM_Filtering VALUES (' num2str(parameterSet_Index) ',' ...
        '''' analyteNames{K,1} ''',' ...
        num2str(localBads) ',' ...
        num2str(commonBad) ',' ...
        num2str(anomalyBad) ',' ...
        num2str(localBads /(localGoods + localBads)*100) ',' ...
        num2str(commonBad /(localGoods + localBads)*100) ',' ...
        num2str(anomalyBad /(localGoods + localBads)*100) ',' ...
        num2str(localGoods)        ');'        ];
    
    exec(conn,sql);
    
end


filteredData=zeros(allIDX-1, size(reducedData,2));
cc=1;
for I=1:length(filtered)
    t=filtered{I};
    filteredData(cc:cc+size(t,1)-1,:) = t(1:end,:);
    cc=cc+size(t,1);
end

lostPercent = allBads /(allGoods + allBads)*100;

sql = ['insert into SVM_Filtering VALUES (' num2str(parameterSet_Index) ',' ...
    '''All'',' ...
    num2str(allBads) ',' ...
    num2str(allCommon) ',' ...
    num2str(allAnomaly) ',' ...
    num2str(lostPercent) ',' ...
    num2str(allCommon /(allGoods + allBads)*100) ',' ...
    num2str(allAnomaly /(allGoods + allBads)*100) ',' ...
    num2str(allGoods) ');'        ];

exec(conn,sql);
end