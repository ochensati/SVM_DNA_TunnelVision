
function []=PlotDiffs3D( colNames,  dataTable,  runParams,analyteNames)


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
    analyte1Name = analyteNames{1};
    analyte2Name = analyteNames{2};
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
    
%         pNames ={ 'P_peakFFT_Whole7','P_peakFFT_Whole47','C_maxAmplitude' };
%         selected=[];
%         for I=1:length(pNames)
%             for J=1:size(params1,2)
%                 t1= colNames{J};
%                 t2= pNames{I}
%                 if (strcmp( t1,t2))
%                     selected = [selected J]; %#ok<AGROW>
%                 end
%             end
%         end
    selected=(1:size(params1,2))';
    
    cc=1;
    for I=1:length(selected)
        for J=I+1:length(selected)
            for K=J+1:length(selected)
                try
                    
                    V1x=params1(:,selected(I));
                    V1y=params1(:,selected(J));
                    V1z=params1(:,selected(K));
                    
                    V2x=params2(:,selected(I));
                    V2y=params2(:,selected(J));
                    V2z=params2(:,selected(K));
                    
                    
                    
%                     %if one of the parameters is a cluster, then only plot the
%                     %unique values
%                     if isempty( strfind( colNames{selected(I)}, 'C_') ) ==false ...
%                             || isempty( strfind( colNames{selected(J)}, 'C_') ) ==false
%                         V1x = V1x(clusterIDX1,:);
%                         V1y = V1y(clusterIDX1,:);
%                         V1z = V1z(clusterIDX1,:);
%                         
%                         V2x = V2x(clusterIDX2,:);
%                         V2y = V2y(clusterIDX2,:);
%                         V2z = V2z(clusterIDX2,:);
%                     end
                    
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % do a little normalization
                    joinX= vertcat(V1x(:), V2x(:));
                    joinY= vertcat(V1y(:), V2y(:));
                    joinZ= vertcat(V1z(:), V2z(:));
                    
                    mX=median(joinX);
                    sX = (joinX-mX);
                    pos = sX(sX>0);
                    neg = sX(sX<0);
                    mnX =mX - 2.5*mean(abs(neg));
                    mxX = mX + 2.5*mean(abs(pos));
                    
                    sX=6* median(abs(joinX-mX)); %(sum(abs(joinX-mX))/length(joinX));
                    
                    mnX= max([ mnX min(joinX)]);
                    mxX= min([ mxX max(joinX)]);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    mY=median(joinY);
                    
                    sY = (joinY-mY);
                    pos = sY(sY>0);
                    neg = sY(sY<0);
                    mnY =mY - 4*mean(abs(neg));
                    mxY = mY + 4*mean(abs(pos));
                    
                    
                    sY=6* median(abs(joinY-mY));%(sum(abs(joinY-mY) )/length(joinY));
                    
                    
                    %
                    mnY= max([ mnY min(joinY)]);
                    mxY= min([ mxY max(joinY)]);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    mZ=median(joinZ);
                    sZ = (joinZ-mZ);
                    pos = sZ(sZ>0);
                    neg = sZ(sZ<0);
                    mnZ =mZ - 4*mean(abs(neg));
                    mxZ = mZ + 4*mean(abs(pos));
                    sZ=6* median(abs(joinZ-mZ));%(sum(abs(joinY-mY) )/length(joinY));
                    mnZ= max([ mnZ min(joinZ)]);
                    mxZ= min([ mxZ max(joinZ)]);
                    %
                    
                    %finish the normalization
                    V1x=(V1x-mnX)/(mxX-mnX);
                    V1y=(V1y-mnY)/(mxY-mnY);
                    V1z=(V1z-mnZ)/(mxZ-mnZ);
                    
                    V2x=(V2x-mnX)/(mxX-mnX);
                    V2y=(V2y-mnY)/(mxY-mnY);
                    V2z=(V2z-mnZ)/(mxZ-mnZ);
                    
                    
                    
                    %put all the numbers into a pixel grid for plotting
                    sizeI=100;
                    ypred1 =zeros([sizeI,sizeI,sizeI]);
                    ypred2 =zeros([sizeI,sizeI,sizeI]);
                    
                    idxX=round(V1x*sizeI);
                    idxY=round(V1y*sizeI);
                    idxZ=round(V1z*sizeI);
                    
                    idxX(idxX>sizeI)=sizeI;
                    idxY(idxY>sizeI)=sizeI;
                    idxZ(idxZ>sizeI)=sizeI;
                    
                    idxX(idxX<1)=sizeI;
                    idxY(idxY<1)=sizeI;
                    idxZ(idxZ<1)=sizeI;
                    
                    pCount =0;
                    for KK=1:length(idxX)
                        if idxX(KK)~=sizeI && idxY(KK)~=sizeI && idxZ(KK)~=sizeI
                            ypred1(idxX(KK),idxY(KK),idxZ(KK))=ypred1(idxX(KK),idxY(KK),idxZ(KK))+1;
                            pCount=pCount+1;
                        end
                    end
                    
                    idxX=round(V2x*sizeI);
                    idxY=round(V2y*sizeI);
                    idxZ=round(V2z*sizeI);
                    
                    idxX(idxX>sizeI)=sizeI;
                    idxY(idxY>sizeI)=sizeI;
                    idxZ(idxZ>sizeI)=sizeI;
                    
                    idxX(idxX<1)=sizeI;
                    idxY(idxY<1)=sizeI;
                    idxZ(idxZ<1)=sizeI;
                    
                    for KK=1:length(idxX)
                        if idxX(KK)~=sizeI && idxY(KK)~=sizeI && idxZ(KK)~=sizeI
                            ypred2(idxX(KK),idxY(KK),idxZ(KK))=ypred2(idxX(KK),idxY(KK),idxZ(KK))+1;
                            pCount=pCount+1;
                        end
                    end
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % now take the matrix and blur the values to give it a little
                    % bit of a histogram feel (the same effect can be produced by
                    % just reducing the number of pixels on the image)
                    h = fspecial3('gaussian', 9);
                    ypred1=imfilter(ypred1,h);
                    ypred2=imfilter(ypred2,h);
                    
                    
                    ypred1=1000*ypred1/(sum(ypred1(:)));
                    ypred2=1000*ypred2/(sum(ypred2(:)));
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % now calculate the probability by finding which one is the
                    % max, and dividing by the sum of the two
                    
                    d = (8.0000e-08+ypred1+ypred2);
                    denom=sum(sum(sum(abs(ypred1-ypred2)./d)));
                    c=length(find( d>16.0000e-08 ));
                    totalAccur=denom / c  *100
                    
                    
                    
                    if (totalAccur>75)
                        
                        %normalize the values from 0 to 255, and do the square root
                        %for visibility
                        ypred1=  (ypred1-min(ypred1(:)) ).^.35;
                        ypred1=round(  (ypred1/(max(ypred1(:))))*254);
                        %
                        ypred2= ( ypred2-min(ypred2(:))  ).^.35;
                        ypred2=round( (ypred2/(max(ypred2(:))))*254)+300;
                        %
                        
                        
                         fName = [ saveDir '\A' num2str(round(totalAccur)) '_' ...
                            colNames{selected(I)} '-'  colNames{selected(J)} '-' colNames{selected(K)} '-' ...
                            num2str(I) '_' num2str(J) '_' num2str(pCount) '_' ...
                            analytePair '_1.mhd'];
                        disp(fName);
                        disp('=====');
                        
                        
                        
                        imsiz = size(ypred1);
                        imspcg = [0.1,0.1,0.1];
                        imorig = -(imsiz-1)/2.*imspcg;
                        imgorient = eye(3);
                        
                        img = ImageType(imsiz,imorig,imspcg,imgorient);
                        img.data(:,:,:)=ypred1(:,:,:);
                        
                                             
                        % 3. Image IO
                        
                        write_mhd(fName,img); %write image
                        
                        
                         fName = [ saveDir '\A' num2str(round(totalAccur)) '_' ...
                            colNames{selected(I)} '-'  colNames{selected(J)} '-' colNames{selected(K)} '-' ...
                            num2str(I) '_' num2str(J) '_' num2str(pCount) '_' ...
                            analytePair '_2.mhd'];
                        disp(fName);
                        disp('=====');
                        
                        
                        
                        imsiz = size(ypred1);
                        imspcg = [0.1,0.1,0.1];
                        imorig = -(imsiz-1)/2.*imspcg;
                        imgorient = eye(3);
                        
                        img = ImageType(imsiz,imorig,imspcg,imgorient);
                        img.data(:,:,:)=ypred2(:,:,:);
                        
                                             
                        % 3. Image IO
                        
                        write_mhd(fName,img); %write image
                        cc=cc+1;
                        
                    end
                    
                catch mex
                    dispError(mex)
                    
                end
            end
            
        end
    end
    
end