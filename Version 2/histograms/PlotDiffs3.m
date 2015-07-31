
function []=PlotDiffs3(groupsInFiles)

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
selected=[ 4:length(colNames)]';

cc=1;
for I=1:length(selected)
    for J=I+1:length(selected)
        for L=J+1:length(selected)
        V1x=params1(:,selected(I));
        V1y=params1(:,selected(J));
        V1z=params1(:,selected(L));
        
        V2x=params2(:,selected(I));
        V2y=params2(:,selected(J));
        V2z=params2(:,selected(L));
        
        mX=mean(vertcat(V1x(:), V2x(:)));
        sX=3*std(vertcat(V1x(:), V2x(:)));
        
        mY=mean(vertcat(V1y(:), V2y(:)));
        sY=3*std(vertcat(V1y(:), V2y(:)));
        
        mZ=mean(vertcat(V1z(:), V2z(:)));
        sZ=3*std(vertcat(V1z(:), V2z(:)));

        
        mnX=mX-sX;
        mxX=mX+sX;
        
        mnY=mY-sY;
        mxY=mY+sY;

        
        mnZ=mZ-sZ;
        mxZ=mZ+sZ;

        
        mnX=max([ mnX min(V1x) min(V2x)]);
        mxX=min([ mxX max(V1x) max(V2x)]);
        
        
        mnY=max([ mnY min(V1y) min(V2y)]);
        mxY=min([ mxY max(V1y) max(V2y)]);
        
        mnZ=max([ mnZ min(V1z) min(V2z)]);
        mxZ=min([ mxZ max(V1z) max(V2z)]);
        
        
        
        V1x=round(((V1x-mnX)/(mxX-mnX))*1000);
        V1y=round(((V1y-mnY)/(mxY-mnY))*1000);
                V1z=round(((V1z-mnZ)/(mxZ-mnZ))*1000);

        
        V2x=round(((V2x-mnX)/(mxX-mnX))*1000);
        V2y=round(((V2y-mnY)/(mxY-mnY))*1000);
                V2z=round(((V2z-mnZ)/(mxZ-mnZ))*1000);


        
        idx=randperm(size(V1x,1),min([1000 size(V1x,1)]));
        V1x=V1x(idx);
        V1y=V1y(idx);
        V1z=V1z(idx);
        
        [V1x ia ic]=  unique(V1x);
        V1y=V1y(ia);
        V1z=V1z(ia);
        
        idx=randperm(size(V2x,1),min([1000 size(V2x,1)]));
        V2x=V2x(idx);
        V2y=V2y(idx);
        V2z=V2z(idx);
        
        [V2x ia ic]=  unique(V2x);
        V2y=V2y(ia);
        V2z=V2z(ia);
        
        V1x=V1x/1000;
        V1y=V1y/1000;
        V1z=V1z/1000;
        
        V2x=V2x/1000;
        V2y=V2y/1000;
        V2z=V2z/1000;
        
        sizeI=250;
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
        
        for K=1:length(idxX)
            if idxX(K)~=sizeI && idxY(K)~=sizeI && idxZ(K)~=sizeI
                ypred1(idxX(K),idxY(K),idxZ(K))=ypred1(idxX(K),idxY(K),idxZ(K))+1;
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
        
        for K=1:length(idxX)
            if idxX(K)~=sizeI && idxY(K)~=sizeI
                ypred2(idxX(K),idxY(K),idxZ(K))=ypred2(idxX(K),idxY(K),idxZ(K))+1;
            end
        end
        
        % figure(1);
        
        
        h = fspecial('gaussian', 25, 6);
        h3=ones( [ size(h,1) size(h,1) size(h,1)]);
        mid = round( size(h,1)/2);
        for K=1:size(h,1)
           h3(:,:,K)=h(    mid,K) * h;
        end
        
        % imshow(h);
        ypred1=imfilter(ypred1,h3);
        ypred2=imfilter(ypred2,h3);
        
        
       
        
        
       im=zeros([size(ypred1,1) size(ypred1,2) 2]);
       im(:,:,1)=(ypred1);
       im(:,:,2)=(ypred2);
       imM=max(im,[],3);
       denom= (ypred1+ypred2);
       accur = ( imM ./ (denom + .001)) .* denom;
       accur =round( sum(accur(:))/sum(denom(:))*1000)/10;
       
        end
       
    end
end


