function plotColorCodedPeaks2(Iteration,extraInfo)
h=figure;
for eI=1:1%length(extraInfo)
    targetExtra=extraInfo{eI};
    % figure;
    % d=zeros([length(targetExtra) 1]);
    %
    % try
    %     for II=1:length(extraInfo{1})
    %
    %         d(II)=(targetExtra{II}.Rating);
    %     end
    % catch mex
    % end
    % % catch mex
    % %
    % %     for II=1:length(extraInfo{1})
    % %         d(II)=(targetExtra(II).Rating);
    % %     end
    % % end
    % plot(d);
    
    mV=1000;
    if mV>length(targetExtra)
        mV=length(targetExtra);
    end
    idx=randperm(length(targetExtra),mV);
    idx=[1 idx];
    cc=1;
    for I=1:length(idx)
        try
            val= targetExtra{idx(I)};
            if (isempty(val)==false)
                try
                    filename{cc} = val.Filename;
                    cc=cc+1;
                catch mex
                end
            end
        catch mex
        end
    end
    
    % cc=1;
    % while (length(filename)>2)
    %     filename2{cc}=filename{1};
    %     srcString = filename2{cc};
    %     IDX=[];
    %     for I=1:length(idx)
    %         val= targetExtra{idx(I)};
    %         if (isempty(val)==false)
    %             try
    %                if (strcmp(srcString,filename{I})==true)
    %                    IDX=[IDX I];
    %                end
    %             catch mex
    %             end
    %         end
    %     end
    %     filename(IDX)=[];
    % end
    filename2=unique(filename);
    
    maxN_Clusters = targetExtra{length(targetExtra)}.Cluster;
    clusterMin=zeros([maxN_Clusters 1]);
    clusterMax=zeros([maxN_Clusters 1]);
    for I=1:maxN_Clusters
        clusterMin(I)=10000000;
        clusterMax(I)=-10;
    end
    
    filename =filename2;
    
    for fileI=1:length(filename)
        trace =load(filename{fileI});
        trace=trace.trace;
        X=1:length(trace);
        
        prefilteredX=[];
        prefilteredY=[];
        
        unassignedX=[];
        unassignedY=[];
        
        waterX=[];
        waterY=[];
        
        commonX=[];
        commonY=[];
        
        correctX=[];
        correctY=[];
        
        incorrectX=[];
        incorrectY=[];
        
        trainingX=[];
        trainingY=[];
        
        clipped=zeros(size(trace));
        for I=1:length(targetExtra)
            peak = targetExtra{I};
            if isempty(peak )==false
                try
                    if strcmp(filename(fileI),peak.Filename)==true
                        
                        cluster=peak.Cluster;
                        if peak.StartIndex<clusterMin(cluster)
                            clusterMin(cluster)=peak.StartIndex;
                        end
                        if peak.EndIndex>clusterMax(cluster)
                            clusterMax(cluster)=peak.EndIndex;
                        end
                        
                        if peak.Rating==0 || peak.Rating==1 ||peak.Rating==2 ||peak.Rating==3
                            index = length(prefilteredX)+1;
                            prefilteredY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            prefilteredX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(prefilteredX)+1;
                            prefilteredY( index )=nan;
                            prefilteredX(index)=nan;
                        end
                        if peak.Rating==4
                            index = length(unassignedX)+1;
                            unassignedY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            unassignedX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(unassignedX)+1;
                            unassignedY( index )=nan;
                            unassignedX(index)=nan;
                        end
                        
                        if peak.Rating==6
                            index = length(waterX)+1;
                            waterY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            waterX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(waterX)+1;
                            waterY( index )=nan;
                            waterX(index)=nan;
                        end
                        
                        if peak.Rating==7
                            index = length(commonX)+1;
                            commonY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            commonX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(commonX)+1;
                            commonY( index )=nan;
                            commonX(index)=nan;
                        end
                        
                        if peak.Rating==5
                            index = length(correctX)+1;
                            correctY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            correctX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(correctX)+1;
                            correctY( index )=nan;
                            correctX(index)=nan;
                        end
                        
                        if peak.Rating==9
                            index = length(incorrectX)+1;
                            incorrectY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            incorrectX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(incorrectX)+1;
                            incorrectY( index )=nan;
                            incorrectX(index)=nan;
                        end
                        
                        if peak.Rating==10
                            index = length(trainingX)+1;
                            trainingY( index :index +peak.EndIndex -peak.StartIndex)=trace(peak.StartIndex:peak.EndIndex);
                            trainingX(index:index +peak.EndIndex -peak.StartIndex)=peak.StartIndex:peak.EndIndex;
                            index = length(trainingX)+1;
                            trainingY( index )=nan;
                            trainingX(index)=nan; %#ok<*AGROW>
                        end
                        
                      
                        
                         
                        X(peak.StartIndex)=nan;
                        trace(peak.StartIndex)=nan;
                        
                        clipped(peak.StartIndex+1:peak.EndIndex)=1;
                    end
                catch mex
                end
            end
        end
        if (isempty(incorrectX)==false)
            
            xClusters=[];
            yClusters=[];
            for JJ=1:maxN_Clusters
                if clusterMax(JJ)~=-10
                    xClusters=[xClusters clusterMin(JJ):clusterMax(JJ)];
                    yClusters=[yClusters (zeros([clusterMax(JJ)-clusterMin(JJ)+1 1])-.01)'];
                    xClusters=[xClusters nan];
                    yClusters=[yClusters nan];
                else
                    xClusters=[xClusters nan];
                    yClusters=[yClusters nan];
                end
            end
            
            idx=find(clipped==1);
            X(idx)=[];
            trace(idx)=[];
            
            
            set(0,'DefaultAxesColorOrder',[0.4,0.4,0.4])
            
            plot(X,trace);
            axis([0 length(trace) -.05 .2]);
            hold all;
            plot(prefilteredX,prefilteredY,'k');
            
            plot(xClusters,yClusters,'r');
            
            
            set(0,'DefaultAxesColorOrder',[0.2,0.8,0.1]);
            plot(unassignedX,unassignedY);
            
            plot(waterX,waterY,'b');
            
            plot(commonX,commonY,'y');
            
            plot(correctX,correctY,'g');
            
            set(0,'DefaultAxesColorOrder',[0.9,0.8,0.1]);
            plot(incorrectX,incorrectY);
            
            plot(trainingX,trainingY,'m');
            
            drawnow;
            
            options.Format = 'jpeg';
            hgexport( h,['c:\\temp\\painting_' num2str(eI) '_' num2str(Iteration) '.jpg'],options);
            
        end
    end
end
end