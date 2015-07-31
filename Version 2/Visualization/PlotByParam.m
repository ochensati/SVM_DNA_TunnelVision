
  figure(1)
  
saveDir = [runParams.outputPath '\hist_par_1D'];
try
    rmdir(saveDir,'s');
    
catch
end
mkdir(saveDir);

analyteList = dataTable(:,1);
analytesN = unique(analyteList);

for pName = 7:size(dataTable,1)
    try
        traces={};
        longTrace=[];
        for nAnalytes=1:length(analytesN)
            
            indX= find(analyteList == analytesN(nAnalytes));
            params1=dataTable(indX,:);
            
            d1 = params1(:,pName);
            
            
            if isempty( strfind( colNames{pName}, 'C_') ) ==false
                clusterList = dataTable(indX,3);
                [~, clusterIDX1, ~]=  unique(clusterList);
                d1 = d1(clusterIDX1,:);
            end
            
            d1(isnan(d1))=[];
            
            if isempty( strfind( colNames{pName}, 'FFT') ) ==false
                d1 = log(d1);
            end
            
            traces{nAnalytes}=d1;
            longTrace=[longTrace d1'];
        end
        
        [v, bins]=  histx(longTrace,'fd');
        fprintf('%s\n', colNames{pName});
        if isempty( strfind( colNames{pName}, 'peakWidth') ) ==false
            v(1:3:end)=[];
            bins(1:3:end)=[];
        end
        
        v(1)=0;
        v(end)=0;
        idx=find(v>  50);
        m = max([1 min(idx)-5]);
        M= min([length(bins) max(idx)+5]);
        bins=bins(m:M);
        
        
        if (length(bins)>10)
          
           
            for I=1:length(traces)
                [v]=histx(traces{I},bins);
                v=v/sum(v);
                plot(bins(2:end-1),v(2:end-1));
                hold all;
            end
            hold off;
            ylabel( 'Probability Density', 'FontSize', 16, 'Rotation', 90);
            xlabel('Bins', 'FontSize', 16 );
            
            hleg1 = legend(analyteNames{:});
            set(hleg1,'Location','NorthEast')
            set(hleg1,'Interpreter','none')
            title( colNames{pName} );
            
            name = colNames{pName} ;
            disp(name)
            filename =[saveDir '\P_' name '.png'];
            saveas(1,filename);
        end
    catch mex
    end
end

