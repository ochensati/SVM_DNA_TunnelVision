
function []=PlotDiffs2SVM(groupsInFiles)

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

colNames = groupsInFiles.ColNames;
selected=[ 4:length(colNames)-20]';

cc=1;
for I=1:length(selected)
    for J=I+1:length(selected)
        try
            V1x=params1(:,selected(I));
            V1y=params1(:,selected(J));
            V2x=params2(:,selected(I));
            V2y=params2(:,selected(J));
            
            mX=mean(vertcat(V1x(:), V2x(:)));
            sX=3*std(vertcat(V1x(:), V2x(:)));
            
            mY=mean(vertcat(V1y(:), V2y(:)));
            sY=3*std(vertcat(V1y(:), V2y(:)));
            
            mnX=mX-sX;
            mxX=mX+sX;
            
            mnY=mY-sY;
            mxY=mY+sY;
            
            mnX=max([ mnX min(V1x) min(V2x)]);
            mxX=min([ mxX max(V1x) max(V2x)]);
            
            
            mnY=max([ mnY min(V1y) min(V2y)]);
            mxY=min([ mxY max(V1y) max(V2y)]);
            
            V1x=round(((V1x-mnX)/(mxX-mnX))*1000);
            V1y=round(((V1y-mnY)/(mxY-mnY))*1000);
            
            V2x=round(((V2x-mnX)/(mxX-mnX))*1000);
            V2y=round(((V2y-mnY)/(mxY-mnY))*1000);
            
            idx=randperm(size(V1x,1),min([1000 size(V1x,1)]));
            V1x=V1x(idx);
            V1y=V1y(idx);
            
            [V1x ia ic]=  unique(V1x);
            V1y=V1y(ia);
            
            idx=randperm(size(V2x,1),min([1000 size(V2x,1)]));
            V2x=V2x(idx);
            V2y=V2y(idx);
            
            [V2x ia ic]=  unique(V2x);
            V2y=V2y(ia);
            
            
            
            xappt1 = horzcat(V1x,V1y);
            xappt2=horzcat(V2x,V2y);
            xapp=vertcat(xappt1,xappt2);
            Yapp=vertcat(ones( [ length(V1x) 1]),-1* ones([length(V2x) 1]));
            
            lambda = 1e-7;
C = 10;
kernel='htrbf';
verbose=0;

            if (cc==1)
               bestKernalOptions =  OptimizeSVM(Yapp,xapp);
               cc=2;
            end
            
            idx=randperm(length(Yapp));
idx1 = idx(1:100);
idx2 = idx(200:300);

yapp=Yapp(idx1);
yappT=Yapp(idx2);

Xapp=xapp(idx1,:);
XappT=xapp(idx2,:);

            %keyboard
        [xsup,w,w0,pos,tps,alpha] = svmclass(Xapp,yapp,C,lambda,kernel,bestKernalOptions,verbose);
        %[xsup,w,w0,pos,tps,alpha] = svmclassLS(Xapp,yapp,C,lambda,kernel,kerneloption,1,1,100);
        
        ypred = svmval(XappT,xsup,w,w0,kernel,bestKernalOptions,1)     ;
        ypred(ypred>0)=1;
        ypred(ypred<=0)=-1;
        
        acc=        100*sum(ypred==yappT)/length(yappT);
            
            
            
            V1x=V1x/1000;
            V1y=V1y/1000;
            V2x=V2x/1000;
            V2y=V2y/1000;
            
            sizeI=500;
            ypred1 =zeros([sizeI,sizeI]);
            ypred2 =zeros([sizeI,sizeI]);
            
            idxX=round(V1x*sizeI);
            idxY=round(V1y*sizeI);
            idxX(idxX>sizeI)=sizeI;
            idxY(idxY>sizeI)=sizeI;
            idxX(idxX<1)=sizeI;
            idxY(idxY<1)=sizeI;
            
            for K=1:length(idxX)
                if idxX(K)~=sizeI && idxY(K)~=sizeI
                    ypred1(idxX(K),idxY(K))=ypred1(idxX(K),idxY(K))+1;
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
                end
            end
            
            % figure(1);
            
            
            h = fspecial('gaussian', 111, 17);
            % imshow(h);
            ypred1=imfilter(ypred1,h);
            ypred2=imfilter(ypred2,h);
            
            
            %         xapp1=horzcat(V1,V2);
            %         xapp2=horzcat(V3,V4);
            
            %         kernel='gaussian';
            %         nu=0.9;
            %         kerneloption=1;
            %         verbose=0;
            %         [xsup,alpha,rho,pos]=svmoneclass(xapp1,kernel,kerneloption,nu,verbose);
            %          [xtest,xtest1,xtest2,nn]=DataGrid2D([0:0.005:1],[0:.005:1]);
            %
            %
            %         steps =100;
            %         chunkSZ=round(size(xtest,1)/steps);
            %         ypred1=[]
            %         for K=0:steps-1
            %             idx=1+chunkSZ*K;
            %             if (idx+chunkSZ<size(xtest,1))
            %                 chunk=xtest(idx:idx+chunkSZ-1,:);
            %             else
            %                 chunk=xtest(idx:end,:);
            %             end
            %             ypredC=svmoneclassval(chunk,xsup,alpha,rho,kernel,kerneloption);
            %             ypred1=vertcat(ypred1, ypredC);
            %         end
            %
            %         ypred1=reshape(ypred1,nn,nn);
            %
            %
            %         [xsup,alpha,rho,pos]=svmoneclass(xapp1,kernel,kerneloption,nu,verbose);
            %
            %         ypred2=[]
            %         for K=0:steps-1
            %             idx=1+chunkSZ*K;
            %             if (idx+chunkSZ<size(xtest,1))
            %                 chunk=xtest(idx:idx+chunkSZ-1,:);
            %             else
            %                 chunk=xtest(idx:end,:);
            %             end
            %             ypredC=svmoneclassval(chunk,xsup,alpha,rho,kernel,kerneloption);
            %             ypred2=vertcat(ypred2, ypredC);
            %         end
            %         ypred2=reshape(ypred2,nn,nn);
            
            %         ypred2=svmoneclassval(xtest,xsup,alpha,rho,kernel,kerneloption);
            %         ypred2=reshape(ypred2,nn,nn);
            
            
            im=zeros([size(ypred1,1) size(ypred1,2) 3]);
            im(:,:,1)=(ypred1);
            im(:,:,2)=(ypred2);
            imM=max(im,[],3);
            denom= (ypred1+ypred2);
            accur = ( imM ./ (denom + .001));% .* denom;
            
            denom = denom ./ sum(denom(:));
            
            accur = sum(sum(accur.*denom))/ sum(denom(:))*100
            
            
            
            if (accur>40)
               
                ypred1=  (ypred1-min(ypred1(:)) ).^.5;
                ypred1=round(  (ypred1/(max(ypred1(:))))*254);
                %
                ypred2= ( ypred2-min(ypred2(:))  ).^.5;
                ypred2=round( (ypred2/(max(ypred2(:))))*254);
                %
                %
                %         im1=(255*ones([size(ypred1,1) size(ypred1,2) 3]));
                %         im1(:,:,2)=ypred1;
                %         im1(:,:,3)=ypred1;
                %
                %
                %         im2=(255*ones([size(ypred1,1) size(ypred1,2) 3]));
                %         im2(:,:,1)=ypred2;
                %         im2(:,:,3)=ypred2;
                %
                %         im=uint8( round( (im1 + im2)/2) );
                im=uint8(zeros([size(ypred1,1) size(ypred1,2) 3]));
                
                im(:,:,1)=round(ypred1);
                im(:,:,2)=round(ypred2);
                figure(1);
                imshow(im);
                
                title([groupsInFiles.ColNames{selected(I)} ' '  groupsInFiles.ColNames{selected(J)}]);
                drawnow;
                
                saveas(1,[ 'C:\temp\data_PaperRetest2\2D hist 3\A' num2str(acc ) '_' num2str(accur) '_' ...
                    groupsInFiles.ColNames{selected(I)} '-'  groupsInFiles.ColNames{selected(J)} '.png']);
                disp('=====');
                cc=cc+1;
            end
            %
            %                 h=figure(2);
            %                 clf;
            % %                 contourf(xtest1,xtest2,ypred,50);shading flat;
            % %                 hold on
            % %                 [cc,hh]=contour(xtest1,xtest2,ypred,[0 0],'k');
            %
            %
            %         figure(2)
            %         clf;
            %         h=2;
            %         scatter(V1,V2,2,'fill');
            %         xlabel (groupsInFiles.ColNames{selected(I)});
            %         ylabel (groupsInFiles.ColNames{selected(J)});
            %         axis([0 1 0 1])
            %         hold all;
            %         scatter(V3,V4,2,'fill');
            %         hold off;
            %         set(h, 'color', 'white');
            %         set(gca, 'Box', 'off');
            %         set(gca, 'TickDir', 'out');
            %         saveas(2,[ 'C:\temp\data_PaperRetest2\2D hist\' ...
            %             groupsInFiles.ColNames{selected(I)} '-'  groupsInFiles.ColNames{selected(J)} 'AX.png']);
            
        catch mex
            dispError(mex);
        end
    end
end


