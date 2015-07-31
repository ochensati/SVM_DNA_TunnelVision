
function []=PlotDiffsAll(colNames, dataTable,  runParams,analyteNames)

 fI=1;
        figure(fI);
       %   set(fI, 'DefaultFigurePosition', [-1919 1 250 250]);
colNames=colNames(5:end);
saveDir = [runParams.outputPath '\hist_1D'];
try 
 rmdir(saveDir,'s');
 
catch
end
mkdir(saveDir);

for groupIndex = 1:length(runParams.plot_Analytes)
    
    analyte1Name = runParams.plot_Analytes{groupIndex}{1};
    analyte2Name = runParams.plot_Analytes{groupIndex}{2};
    analytePair = sprintf('%s - %s',analyte1Name,analyte2Name );
    
    analyte1=analyteNames{ find(strcmp(analyteNames,analyte1Name)) , 2};
    analyte2=analyteNames{ find(strcmp(analyteNames,analyte2Name)) , 2};
    
    analyteList = dataTable(:,1);
    indX= find(analyteList == analyte1);
    indY= find(analyteList == analyte2);
    
    params1=dataTable(indX,5:end);
    params2=dataTable(indY,5:end);
    
    clusterList = dataTable(indX,3);
    [~, clusterIDX1, ~]=  unique(clusterList);
    
    clusterList = dataTable(indY,3);
    [~, clusterIDX2, ~]=  unique(clusterList);
    
    selected=(1:size(params1,2))';
    try 
    for I=1:length(selected)
        d1 = params1(:,selected(I));
        d2 = params2(:,selected(I));
        
        %if one of the parameters is a cluster, then only plot the
        %unique values
        if isempty( strfind( colNames{selected(I)}, 'C_') ) ==false 
            d1 = d1(clusterIDX1,:);
            d2 = d2(clusterIDX2,:);
        end
        
        d1(isnan(d1))=[];
        d2(isnan(d2))=[];
        
       
      
        m=median(d1);
        
        s=2.3*median( abs(d1-m));
        
        try
            mn=max([m-s min(d1)]);
            mx=min([m+s max(d1)]);

            step = s/30;
            xCenters = mn:step:mx;
            V1=hist(d1,xCenters);
            V2=hist(d2,xCenters);
            xCenters(end)=[];
            V1(end)=[];
            V2(end)=[];
            V1=V1/sum(V1);
            V2=V2/sum(V2);
            
            accur =round(100* sum( (max( vertcat(V1,V2)) ./ (V1+V2+.001)) .* (V1+V2) ) /sum((V1+V2)))
            
            
            h=plot(xCenters,V1,'k',xCenters,V2,'--k');
            set(h(1),'linewidth',1);
            set(h(2),'linewidth',2);
            set(fI, 'color', 'white');
            set(gca, 'Box', 'off');
            set(gca, 'TickDir', 'out');
            
            unit = 'pA';
            
            if (findstr( colNames{selected(I)},'Freq'))
                unit = 'Normalized Amplitude';
            end
            
            if (strcmp(  colNames{selected(I)},'Frequency'))
                 colNames{selected(I)}='ClusterInfo.Frequency';
                unit = 'kHz';
            end
            
            if (strcmp(  colNames{selected(I)},'P-Freq'))
                 colNames{selected(I)}='Peak.Frequency';
                unit = 'kHz';
            end
            
            if (findstr(  colNames{selected(I)},'iFFT'))
                unit = 'Normalized Amplitude';
            end
            
            if (findstr(  colNames{selected(I)},'Width'))
                unit = 'ms';
            end
            
            if (findstr(  colNames{selected(I)},'FFT'))
                unit = 'Normalized Amplitude';
            end
            
            if (findstr(  colNames{selected(I)},'Cepstrum'))
                unit = 'Normalized Amplitude';
            end
            
            if (findstr(  colNames{selected(I)},'Maximum'))
                unit = 'kHz';
            end
            
            if (findstr(  colNames{selected(I)},'Odd'))
                unit = 'Normalized Amplitude';
            end
            
            if (findstr(  colNames{selected(I)},'Even'))
                unit = 'Normalized Amplitude';
            end
            
            if (findstr(  colNames{selected(I)},'Ratio'))
                unit = 'Normalized Amplitude';
            end
            
            
            ylabel( 'Probability Density', 'FontSize', 16, 'Rotation', 90);
            xlabel(unit, 'FontSize', 16 );
            
            hleg1 = legend([analyte1Name ': ' colNames{selected(I)}],[ analyte2Name ': ' colNames{selected(I)}]);
            set(hleg1,'Location','NorthEast')
            set(hleg1,'Interpreter','none')
            title( [ colNames{selected(I)} ' A=' num2str(round(accur)) ] );
            set(gcf,'name',  colNames{selected(I)},'numbertitle','off') ;
            drawnow;
            
            if accur>37
                name = [ num2str(round(accur)) '_'    colNames{selected(I)} ];
                disp(name)
                filename =[saveDir '\A_' name '_' analytePair '.png'];
                saveas(fI,filename);
            end
        catch mex
            dispError(mex)
            disp(mex.stack(1,1));
        end
    end
   
    catch 
    end
end
