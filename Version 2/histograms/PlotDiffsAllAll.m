
function []=PlotDiffsAll(groupsInFiles,extraInfo)

uniqueNames {1}= groupsInFiles.Peaks{1}.GroupName;

for I=1:length(groupsInFiles.Peaks)
    uniqueNames{I}=groupsInFiles.Peaks{I}.GroupName;
end

uniqueNames=unique(uniqueNames);

groupParams = cell([1 length(uniqueNames)]);
groupAverages = zeros([length(uniqueNames) length(groupsInFiles.ColNames)]);
for I=1:length(uniqueNames)
    groupIndexs =[];
    for J=1:length(groupsInFiles.Peaks)
        if (  (strcmp( groupsInFiles.Peaks{J}.GroupName, uniqueNames{I}) || strcmp( groupsInFiles.Peaks{J}.GroupName, [uniqueNames{I} '_Test'])) )
            groupIndexs = [groupIndexs J]; %#ok<AGROW>
        end
    end
    if (length(groupIndexs)>1)
        params=[];
        for KK=groupIndexs
            params = vertcat(params, groupsInFiles.Peaks{KK}.Train);
        end
        groupAverages(I,:) =  mean(params);
        groupParams{I}=params;
    end
end

groupAverages(:,1:3)=[];

distances =zeros([length(uniqueNames) length(uniqueNames)]);
for I=1:length(uniqueNames)
    for J=I+1:length(uniqueNames)
        distances(I,J)= sum(  (groupAverages(I,:)-groupAverages(J,:)).^2);
    end
end

[value idx]=max(distances);

[value2 idx2]=max(value);

furthest = [idx(idx2) idx2];

furthest(1)=1;
furthest(2)=2;

params1=groupParams{furthest(1)};
params2=groupParams{furthest(2)};

desired = [1,2,4,5,11,12,17,21,33,34,37,38];

colNames = groupsInFiles.ColNames';
params1=params1;%(:,desired);

disp(uniqueNames)

for I=4:size(params1,2)%-30
    clf;
    for K=1:length(groupParams)
        params1=groupParams{K};
        d1 = params1(:,I);
        
        if (I>=9)
            d1=unique(d1);
            
        end
        
        d1(isnan(d1))=[];
        
        
        fI=1;
        figure(fI);
        m=mean(d1);
        
        s=3*mean( abs(d1-m));
        %s=4*std(d1);
        mn=max([ min(d1) m-s 0]);
        mx=min([ max(d1) m+s]);
        
        try
            mn=min(d1);
            mx=max(d1);
            
            if (mx> m+s)
                mx=m+s;
            end
            
            step = s/30;
            
            if K==1
                step = s/30;
                if (findstr( groupsInFiles.ColNames{I},'Maximum'))
                    step = s/35;
                end
                
                if (findstr( groupsInFiles.ColNames{I},'Cepstrum'))
                    step = s/30;
                end
                
                if (findstr( groupsInFiles.ColNames{I},'Width'))
                    step = s/25;
                end
                %
                xCenters1 = mn:step:mx;
            end
            xCenters = xCenters1';
            V1=hist(d1,xCenters);
            
            xCenters(end)=[];
            V1(end)=[];
            
            V1=V1/sum(V1);
            
            h=plot(xCenters,V1);
            hold all;
            set(h(1),'linewidth',1);
            
            set(fI, 'color', 'white');
            set(gca, 'Box', 'off');
            set(gca, 'TickDir', 'out');
            
            
            drawnow;
            
            
            
            
        catch mex
            dispError(mex)
            disp(mex.stack(1,1));
        end
        
        
    end
    
    
    unit = 'pA';
    
    if (findstr( groupsInFiles.ColNames{I},'Freq'))
        unit = 'Normalized Amplitude';
    end
    
    if (strcmp( groupsInFiles.ColNames{I},'Frequency'))
        groupsInFiles.ColNames{I}='ClusterInfo.Frequency';
        unit = 'kHz';
    end
    
    if (strcmp( groupsInFiles.ColNames{I},'P-Freq'))
        groupsInFiles.ColNames{I}='Peak.Frequency';
        unit = 'kHz';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'iFFT'))
        unit = 'Normalized Amplitude';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'Width'))
        unit = 'ms';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'FFT'))
        unit = 'Normalized Amplitude';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'Cepstrum'))
        unit = 'Normalized Amplitude';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'Maximum'))
        unit = 'kHz';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'Odd'))
        unit = 'Normalized Amplitude';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'Even'))
        unit = 'Normalized Amplitude';
    end
    
    if (findstr( groupsInFiles.ColNames{I},'Ratio'))
        unit = 'Normalized Amplitude';
    end
    
    ylabel( 'Probability Density', 'FontSize', 16, 'Rotation', 90);
    xlabel(unit , 'FontSize', 16 );
    colNames(I)
    
    hleg1 = legend('ARG_L','ASN_D','ASN_L','GLY','ILE','LEU','mGLY');
    set(hleg1,'Location','NorthEast')
    set(hleg1,'Interpreter','none')
    % title( groupsInFiles.ColNames{I});
    set(gcf,'name', groupsInFiles.ColNames{I},'numbertitle','off') ;
    
    filename =['c:\temp\graphsAll\' groupsInFiles.ColNames{I} '.png'];
    saveas(fI,filename);
    
    
end


