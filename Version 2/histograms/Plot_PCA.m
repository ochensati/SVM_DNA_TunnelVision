function [] = Plot_PCA(dataTable,runParams, tryIndex)

idxs = dataTable(:,1:runParams.dataColStart-1);
[coeff,newCols, latent] = pca(dataTable(:,runParams.dataColStart:end));

latent = latent.^.5;
latent(1)=latent(1).^.1;
latent=(cumsum(latent) + .0001)./(.0001+ sum(latent));

figure(1);
plot(latent);
xlabel('column Number');
ylabel('descriptive power');

idxAnalyte{1}=find(dataTable(:,1)==1)';
idxAnalyte{2}=find(dataTable(:,1)==2)';
redone = newCols;

sizeI=150;
for J=1:size(redone,2)
    for M=J+1:size(redone,2)
        
        for I=1:2
            layer = mod( I-1,4);
            
            pks=redone(idxAnalyte{I},J);
            d=redone(idxAnalyte{I},M);
            % d=log(d);
            if  I==1
                [v, bins]=hist(d,45);
                dx=bins(2)-bins(1);
                bins=[ (dx*(-10:-1) + bins(1)) bins (dx*(1:10) + bins(end))];
                
                [v, bins2]=hist(pks,45);
                dx=bins2(2)-bins2(1);
                bins2=[ (dx*(-10:-1) + bins2(1)) bins2 (dx*(1:10) + bins2(end))];
                
                mX= bins2(1);
                MX =bins2(end);
                lX=(MX-mX);
                
                mY= bins(1);
                MY =bins(end);
                lY=(MY-mY);
            end
            
            ypred2=zeros([sizeI sizeI ]);
            V2x = (pks-mX)/lX;
            V2y = (d-mY)/lY;
            
            
            idxX=round(V2x*sizeI);
            idxY=round(V2y*sizeI);
            idxX(idxX>sizeI)=sizeI;
            idxY(idxY>sizeI)=sizeI;
            idxX(idxX<1)=sizeI;
            idxY(idxY<1)=sizeI;
            idx=find(isnan(idxX));
            idxX(idx)=sizeI;
            idx=find(isnan(idxY));
            idxY(idx)=sizeI;
            pCount=0;
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
            h = fspecial('gaussian', 111, 3);
            ypred2=imfilter(ypred2,h);
            ypred2=1000*ypred2/(sum(ypred2(:)));
            
            %         im=zeros([size(ypred2,1) size(ypred2,2) 3]);
            %         im(:,:,2)=ypred2;
            
            ypred2= ( ypred2-min(ypred2(:))  ).^.5;
            ypred2=round( (ypred2/(max(ypred2(:))))*(235));
            %
            
            % make a nice image
            if layer<4
                if I==1
                    im=uint8(zeros([size(ypred2,1) size(ypred2,2) 3]));
                end
                
                if layer==3
                    im(:,:,1)=squeeze(im(:,:,1)) + uint8(round(ypred2));
                    im(:,:,2)=squeeze(im(:,:,2)) + uint8(round(ypred2));
                else
                    im(:,:,layer+1)=squeeze(im(:,:,layer+1)) + uint8(round(ypred2));
                end
                
                figure(1);
                imshow(im);
                % title([Fnames{J} ' '  Fnames{M} ' Cycle 1']);
            end
        end
        saveas(1,[ 'c:\data\test_C\_' num2str(M)  '_'  num2str(J) '_Cycle_' num2str(tryIndex) '.png']);
    end
end




end