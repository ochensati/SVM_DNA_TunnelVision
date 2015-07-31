
function []=PlotDiffs2_2( colNames,  dataTable,  runParams,analyteNames)


figure(1);
%    set(1, 'DefaultFigurePosition', [-1919 1 250 250]);

saveDir = [runParams.outputPath '\hist_2D'];
try
    rmdir(saveDir,'s');
    
catch
end
mkdir(saveDir);
for groupIndex = 1:length(runParams.plot_Analytes)
    
    analyte1Name = analyteNames{1,1};
    analyte2Name = analyteNames{2,1};
    analyte3Name = analyteNames{3,1};
    if length(runParams.plot_Analytes{groupIndex})==4
        analyte4Name = runParams.plot_Analytes{groupIndex}{4};
        analytePair = sprintf('%s - %s - %s - %s',analyte1Name,analyte2Name,analyte3Name,analyte4Name );
    else
        analytePair = sprintf('%s - %s - %s',analyte1Name,analyte2Name,analyte3Name);
    end
    
    analyte1=analyteNames{ find(strcmp(analyteNames,analyte1Name)) , 2};
    analyte2=analyteNames{ find(strcmp(analyteNames,analyte2Name)) , 2};
    analyte3=analyteNames{ find(strcmp(analyteNames,analyte3Name)) , 2};
    
    if length(runParams.plot_Analytes{groupIndex})==4
        analyte4=analyteNames{ find(strcmp(analyteNames,analyte4Name)) , 2};
    else 
        analyte4=0;
    end
    
    %first select the data that corresponds to each analyte
    analyteList = dataTable(:,1);
    indX= find(analyteList == analyte1);
    indY= find(analyteList == analyte2);
    indZ= find(analyteList == analyte3);
    indW= find(analyteList == analyte4);
    
    if false 
        tdataTable = dataTable(:,9:end);
        
        w = 1./var(tdataTable);
        
        idx = find(isnan(w));
        idx2 = find(isinf(w));
        w(idx)=[];
        w(idx2)=[];
        tdataTable(:,idx)=[];
        tdataTable(:,idx2)=[];
        
        [wcoeff,score,latent,tsquared,explained] = pca(tdataTable,...
            'VariableWeights',w);
        
        params1=score(indX,:);
        params2=score(indY,:);
        params3=score(indZ,:);
        params4=score(indW,:);
        
    else
        params1=dataTable(indX,9:end);
        params2=dataTable(indY,9:end);
        params3=dataTable(indZ,9:end);
        params4=dataTable(indW,9:end);
    end
    
%     clusterList = dataTable(indX,3);
%     [~, clusterIDX1, ~]=  unique(clusterList);
%     
%     clusterList = dataTable(indY,3);
%     [~, clusterIDX2, ~]=  unique(clusterList);
%     
%     clusterList = dataTable(indZ,3);
%     [~, clusterIDX3, ~]=  unique(clusterList);
%     
%     clusterList = dataTable(indW,3);
%     [~, clusterIDX4, ~]=  unique(clusterList);
    
    colNames=colNames(9:end);
    
    %selected are the colums that will be searched through, by default this is
    %all of them.  Despite it all, this works pretty well
    selected=(1:size(params1,2))';
    
    cc=1;
    for I=1:length(selected)
        for J=I+1:length(selected)
            try
                
                V1_x=params1(:,selected(I));
                V1_y=params1(:,selected(J));
                
                V2_x=params2(:,selected(I));
                V2_y=params2(:,selected(J));
                
                V3_x=params3(:,selected(I));
                V3_y=params3(:,selected(J));
                
                V4_x=params4(:,selected(I));
                V4_y=params4(:,selected(J));
                
%                 V1_x=params1(:,selected(I))/3;
%                 V1_y=params1(:,selected(J))/3;
%                 V1_x=V1_x+1.5*mean(V1_x);
%                 
%                 V2_x=params2(:,selected(I))/3;
%                 V2_y=params2(:,selected(J))/3;
%                 V2_x=V2_x+1.5*mean(V2_x);
%                 
%                 V3_x=params3(:,selected(I))*2;
%                 V3_y=params3(:,selected(J));
%                 
%                 V4_x=params4(:,selected(I))*2;
%                 V4_y=params4(:,selected(J));
                
                
                
                %if one of the parameters is a cluster, then only plot the
                %unique values
                if isempty( strfind( colNames{selected(I)}, 'C_') ) ==false ...
                        || isempty( strfind( colNames{selected(J)}, 'C_') ) ==false
                    V1_x = V1_x(clusterIDX1,:);
                    V1_y = V1_y(clusterIDX1,:);
                    
                    V2_x = V2_x(clusterIDX2,:);
                    V2_y = V2_y(clusterIDX2,:);
                    
                    V3_x = V3_x(clusterIDX3,:);
                    V3_y = V3_y(clusterIDX3,:);
                    
                    
                    V4_x = V4_x(clusterIDX4,:);
                    V4_y = V4_y(clusterIDX4,:);
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % do a little normalization
                joinX= vertcat(V1_x(:), V2_x(:), V3_x(:) , V4_x(:));
                joinY= vertcat(V1_y(:), V2_y(:), V3_y(:) , V4_y(:));
                
                
                mX=mean(joinX);
                sX=4* median(abs(joinX-mX)); %(sum(abs(joinX-mX))/length(joinX));
                
                mY=mean(joinY);
                sY=4* median(abs(joinY-mY));%(sum(abs(joinY-mY) )/length(joinY));
                
                mnX= max([ mX-sX min(joinX)]);
                mxX= min([ mX+sX max(joinX)]);
                
                mnY= max([ mY-sY min(joinY)]);
                mxY= min([ mY+sY max(joinY)]);
                
                
                %finish the normalization
                V1_x=(V1_x-mnX)/(mxX-mnX);
                V1_y=(V1_y-mnY)/(mxY-mnY);
                 
                V2_x=(V2_x-mnX)/(mxX-mnX);
                V2_y=(V2_y-mnY)/(mxY-mnY);
                
                V3_x=(V3_x-mnX)/(mxX-mnX);
                V3_y=(V3_y-mnY)/(mxY-mnY);
                
                V4_x=(V4_x-mnX)/(mxX-mnX);
                V4_y=(V4_y-mnY)/(mxY-mnY);
                
                %put all the numbers into a pixel grid for plotting
                sizeI=500;
                ypred1 =zeros([sizeI,sizeI]);
                ypred2 =zeros([sizeI,sizeI]);
                ypred3 =zeros([sizeI,sizeI]);
                ypred4 =zeros([sizeI,sizeI]);
                
                idxX=round(V1_x*sizeI);
                idxY=round(V1_y*sizeI);
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
                
                idxX=round(V2_x*sizeI);
                idxY=round(V2_y*sizeI);
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
                
                idxX=round(V3_x*sizeI);
                idxY=round(V3_y*sizeI);
                idxX(idxX>sizeI)=sizeI;
                idxY(idxY>sizeI)=sizeI;
                idxX(idxX<1)=sizeI;
                idxY(idxY<1)=sizeI;
                
                for K=1:length(idxX)
                    if idxX(K)~=sizeI && idxY(K)~=sizeI
                        ypred3(idxX(K),idxY(K))=ypred3(idxX(K),idxY(K))+1;
                        pCount=pCount+1;
                    end
                end
                
                idxX=round(V4_x*sizeI);
                idxY=round(V4_y*sizeI);
                idxX(idxX>sizeI)=sizeI;
                idxY(idxY>sizeI)=sizeI;
                idxX(idxX<1)=sizeI;
                idxY(idxY<1)=sizeI;
                
                for K=1:length(idxX)
                    if idxX(K)~=sizeI && idxY(K)~=sizeI
                        ypred4(idxX(K),idxY(K))=ypred4(idxX(K),idxY(K))+1;
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
                ypred3=imfilter(ypred3,h);
                ypred4=imfilter(ypred4,h);
                
                
                ypred1=1000*ypred1/(1+sum(ypred1(:)));
                ypred2=1000*ypred2/(1+sum(ypred2(:)));
                ypred3=1000*ypred3/(1+sum(ypred3(:)));
                ypred4=1000*ypred4/(1+sum(ypred4(:)));
                
                im=zeros([size(ypred1,1) size(ypred1,2) 4]);
                im(:,:,1)=ypred1;
                im(:,:,2)=ypred2;
                im(:,:,3)=ypred3;
                im(:,:,4)=ypred4;
                imM=max(im,[],3);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % now calculate the probability by finding which one is the
                % max, and dividing by the sum of the two
                
                denom= (ypred1+ypred2 + ypred3 + ypred4);
                accurMap = ( imM );
                totalAccur=sum( accurMap(:) ) / sum(denom(:)) *100
                drawnow;
                
                
                if (totalAccur>85)
                    
                    %normalize the values from 0 to 255, and do the square root
                    %for visibility
                    ypred1=  (ypred1-min(ypred1(:)) ).^.5;
                    ypred1=round(  (ypred1/(max(ypred1(:))))*254);
                    %
                    ypred2= ( ypred2-min(ypred2(:))  ).^.5;
                    ypred2=round( (ypred2/(max(ypred2(:))))*254);
                    %
                    ypred3= ( ypred3-min(ypred3(:))  ).^.5;
                    ypred3=round( (ypred3/(max(ypred3(:))))*254);
                    %
                    ypred4= ( ypred4-min(ypred4(:))  ).^.5;
                    ypred4=round( (ypred4/(max(ypred4(:))))*254);
                    %
                    
                    % make a nice image
                    im=zeros([size(ypred1,1) size(ypred1,2) 3]);
                    im(:,:,1)=round(ypred1);
                    im(:,:,2)=round(ypred2);
                    
                    
                    im(:,:,3)=round(ypred3);
%                      im(:,:,1)=im(:,:,1)+ (round(ypred4));
%                      im(:,:,2)=im(:,:,2)+ (round(ypred4));
%                      
                    im(im>254)=254;
%                     m=max(squeeze(im(:,:,1)));
%                     m=max(m(:));
%                     im(:,:,1)=im(:,:,1)/m*254;
%                     
%                     m=max(squeeze(im(:,:,2)));
%                     m=max(m(:));
%                     im(:,:,2)=im(:,:,2)/m*254;

                    im=uint8(im);
                    imshow(im);
                    title([colNames{selected(I)} ' '  colNames{selected(J)}]);
                    drawnow;
                    
                    saveas(1,[ saveDir '\____A' num2str(round(totalAccur)) '_' ...
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