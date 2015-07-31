
function []=PlotDiffs2( colNames,  dataTable,  runParams,analyteNames)


figure(1);
%    set(1, 'DefaultFigurePosition', [-1919 1 250 250]);

saveDir = [runParams.outputPath '\hist_2D'];
try
    rmdir(saveDir,'s');
    
catch
end
mkdir(saveDir);
for groupIndex = 1:length(runParams.plot_Analytes)
    
    analyte1Name = runParams.plot_Analytes{groupIndex}{1};
    analyte2Name = runParams.plot_Analytes{groupIndex}{2};
     analyte1Name = 'arg';
     analyte2Name = 'pro'
    analytePair = sprintf('%s - %s',analyte1Name,analyte2Name );
    
    analyte1=analyteNames{ find(strcmp(analyteNames,analyte1Name)) , 2};
    analyte2=analyteNames{ find(strcmp(analyteNames,analyte2Name)) , 2};
    %first select the data that corresponds to each analyte
    analyteList = dataTable(:,1);
    indX= find(analyteList == analyte1);
    indY= find(analyteList == analyte2);
    
    params1=dataTable(indX,7:end);
    params2=dataTable(indY,7:end);
    
    clusterList = dataTable(indX,3);
    [~, clusterIDX1, ~]=  unique(clusterList);
    
    clusterList = dataTable(indY,3);
    [~, clusterIDX2, ~]=  unique(clusterList);
    
    colNames=colNames(7:end);
    
    %selected are the colums that will be searched through, by default this is
    %all of them.  Despite it all, this works pretty well
    
    pNames ={ 'P_averageAmplitude','P_peakWidth','P_iFFTLow','P_frequency','P_Odd_FFT','P_peakFFT_Whole6','P_peakFFT_Whole8','P_peakFFT_Whole13','P_peakFFT_Whole20','P_peakFFT_Whole21','P_peakFFT_Whole48','trash' };
    selected=[];
    for I=1:length(pNames)
        for J=1:size(params1,2)
            t1= colNames{J};
            t2= pNames{I}
            if (strcmp( t1,t2))
                selected = [selected J]; %#ok<AGROW>
            end
        end
    end
%     selected=(1:size(params1,2))';
    
    cc=1;
    for I=1:length(selected)
        for J=I+1:length(selected)
            try
                
                V1x=params1(:,selected(I));
                V1y=params1(:,selected(J));
                V2x=params2(:,selected(I));
                V2y=params2(:,selected(J));
                
                %if one of the parameters is a cluster, then only plot the
                %unique values
                if isempty( strfind( colNames{selected(I)}, 'C_') ) ==false ...
                        || isempty( strfind( colNames{selected(J)}, 'C_') ) ==false
                    V1x = V1x(clusterIDX1,:);
                    V1y = V1y(clusterIDX1,:);
                    
                    V2x = V2x(clusterIDX2,:);
                    V2y = V2y(clusterIDX2,:);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % do a little normalization
                joinX= vertcat(V1x(:), V2x(:));
                joinY= vertcat(V1y(:), V2y(:));
                
                
                mX=median(joinX);
                sX = (joinX-mX);
                pos = sX(sX>0);
                neg = sX(sX<0);
                mnX =mX - 2.5*mean(abs(neg));
                mxX = mX + 2.5*mean(abs(pos));
                
                sX=6* median(abs(joinX-mX)); %(sum(abs(joinX-mX))/length(joinX));
                
                mY=median(joinY);
                
                sY = (joinY-mY);
                pos = sY(sY>0);
                neg = sY(sY<0);
                mnY =mY - 2.5*mean(abs(neg));
                mxY = mY + 2.5*mean(abs(pos));

                
                sY=6* median(abs(joinY-mY));%(sum(abs(joinY-mY) )/length(joinY));
                
                 mnX= max([ mnX min(joinX)]);
                 mxX= min([ mxX max(joinX)]);
%                 
                 mnY= max([ mnY min(joinY)]);
                 mxY= min([ mxY max(joinY)]);
%                 
                
                %finish the normalization
                V1x=(V1x-mnX)/(mxX-mnX);
                V2x=(V2x-mnX)/(mxX-mnX);
                
                V1y=(V1y-mnY)/(mxY-mnY);
                V2y=(V2y-mnY)/(mxY-mnY);
                
                %put all the numbers into a pixel grid for plotting
                sizeI=500;
                ypred1 =zeros([sizeI,sizeI]);
                ypred2 =zeros([sizeI,sizeI]);
                
                idxX=round(V1x*sizeI);
                idxY=round(V1y*sizeI);
                idxX(idxX>sizeI)=sizeI;
                idxY(idxY>sizeI)=sizeI;
                idxX(idxX<1)=sizeI;
                idxY(idxY<1)=sizeI;
                
                pCount =0;
                for K=1:length(idxX)
                    if idxX(K)~=sizeI && idxY(K)~=sizeI
                        ypred1(idxX(K),idxY(K))=ypred1(idxX(K),idxY(K))+1;
                        pCount=pCount+1;
                    end
                end
                
                idxX=round(V2x*sizeI);
                idxY=round(V2y*sizeI);
                idxX(idxX>sizeI)=sizeI;
                idxY(idxY>sizeI)=sizeI;
                idxX(idxX<1)=sizeI;
                idxY(idxY<1)=sizeI;
                
                for K=1:length(idxX)
                    if idxX(K)~=sizeI && idxY(K)~=sizeI
                        ypred2(idxX(K),idxY(K))=ypred2(idxX(K),idxY(K))+1;
                        pCount=pCount+1;
                    end
                end
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % now take the matrix and blur the values to give it a little
                % bit of a histogram feel (the same effect can be produced by
                % just reducing the number of pixels on the image)
                h = fspecial('gaussian', 111, 5);
                ypred1=imfilter(ypred1,h);
                ypred2=imfilter(ypred2,h);
                
                
                ypred1=1000*ypred1/(sum(ypred1(:)));
                ypred2=1000*ypred2/(sum(ypred2(:)));
                
                im=zeros([size(ypred1,1) size(ypred1,2) 3]);
                im(:,:,1)=ypred1;
                im(:,:,2)=ypred2;
                imM=max(im,[],3);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % now calculate the probability by finding which one is the
                % max, and dividing by the sum of the two
                
                denom= (ypred1+ypred2);
                accurMap = ( imM );
                totalAccur=sum( accurMap(:) ) / sum(denom(:)) *100
                drawnow;
                
                
                if (totalAccur>0)
                    
                    %normalize the values from 0 to 255, and do the square root
                    %for visibility
                    ypred1=  (ypred1-min(ypred1(:)) ).^.35;
                    ypred1=round(  (ypred1/(max(ypred1(:))))*254);
                    %
                    ypred2= ( ypred2-min(ypred2(:))  ).^.35;
                    ypred2=round( (ypred2/(max(ypred2(:))))*254);
                    %
                    
                    % make a nice image
                    im=uint8(zeros([size(ypred1,1) size(ypred1,2) 3]));
                    im(:,:,1)=round(ypred1);
                    im(:,:,2)=round(ypred2);
                    
                    imshow(im);
                    title([colNames{selected(I)} ' '  colNames{selected(J)}]);
                    drawnow;
                    
                    saveas(1,[ saveDir '\A' num2str(round(totalAccur)) '_' ...
                        colNames{selected(I)} '-'  colNames{selected(J)} '-' ...
                        num2str(I) '_' num2str(J) '_' num2str(pCount) '_' ...
                        analytePair '.png']);
                    disp('=====');
                    cc=cc+1;
                    
                end
                
            catch mex
                dispError(mex)
                
            end
        end
        
    end
    
    
end