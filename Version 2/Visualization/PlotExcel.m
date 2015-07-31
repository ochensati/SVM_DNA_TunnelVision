
filename = 'C:\Data\weisi\T20YKKK_0706.csv';
saveDir = ['c:\data\excelhist'];

xAxis = 'Duration (uS)';
yAxis = 'nA';


autorange = 5; % change auto size or set to -1;
intensityFix =.5 ; % smaller number means that dimmer spots get less dim
sizeI=500;  % resolution of image
pixelBlur = 5 ; % size of spot circle
blackBackground = true;

logX=true;
logY=false;


try
    [~,~,raw]=xlsread(filename);
catch
    [~,~,raw]=xlsread(filename);
end

emptyCells=cellfun(@isempty,raw);
raw(emptyCells)=[];



Dataset1= raw{1,2};
Dataset2= raw{1,4};

disp( ['red = ' Dataset1]);
disp( ['green = ' Dataset2]);

idx=find( cellfun(@(x) strcmp(x,'--'),raw) ==0);

raw2=cell(size(raw));
raw2(:)={-1000};
raw2(idx)=raw(idx);


% fid = fopen(filename,'r');
% tline = fgets(fid);
% tline = fgets(fid);
% tline = fgets(fid);
% C_data0 = textscan(fid,'%f,%f,%f,%f\n');
%
% fclose(fid);
%
% shortData =C_data0{1};

figure(1);

try
    rmdir(saveDir,'s');
    
catch
end
mkdir(saveDir);


if (logX)
    V1x=log(cell2mat(raw2(3:end,1)));
else
    V1x=(cell2mat(raw2(3:end,1)));
end

if (logY)
    V1y=log(cell2mat(raw2(3:end,2)));
else
    V1y=(cell2mat(raw2(3:end,2)));
end

if (logX)
    V2x=log(cell2mat(raw2(3:end,3)));
else
    V2x=(cell2mat(raw2(3:end,3)));
end

if (logY)
    V2y=log(cell2mat(raw2(3:end,4)));
else
    V2y=(cell2mat(raw2(3:end,4)));
end
idx=find(V1x==-1000);
V1x(idx)=[];
V1y(idx)=[];

idx=find(isnan(V1x));
V1x(idx)=[];
V1y(idx)=[];

idx=find(V2x==-1000);
V2x(idx)=[];
V2y(idx)=[];

idx=find(isnan(V2x));
V2x(idx)=[];
V2y(idx)=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do a little normalization
joinX= vertcat(V1x(:), V2x(:));
joinY= vertcat(V1y(:), V2y(:));

if (autorange==-1)
    autorange=10000;
end

mX=median(joinX);
sX = (joinX-mX);
pos = sX(sX>0);
neg = sX(sX<0);
mnX =mX - autorange*mean(abs(neg));
mxX = mX + autorange*mean(abs(pos));

mY=median(joinY);

sY = (joinY-mY);
pos = sY(sY>0);
neg = sY(sY<0);
mnY =mY - autorange*mean(abs(neg));
mxY = mY + autorange*mean(abs(pos));

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
h = fspecial('gaussian', 111, pixelBlur);
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
    
    if (blackBackground)
        %normalize the values from 0 to 255, and do the square root
        %for visibility
        ypred1=  (ypred1-min(ypred1(:)) ).^intensityFix;
        ypred1=round(  (ypred1/(max(ypred1(:))))*254);
        %
        ypred2= ( ypred2-min(ypred2(:))  ).^intensityFix;
        ypred2=round( (ypred2/(max(ypred2(:))))*254);
        %
        
        % make a nice image
        im=uint8(zeros([size(ypred1,1) size(ypred1,2) 3]));
        im(:,:,1)=round(ypred1);
        im(:,:,2)=round(ypred2);
        
    else
        %normalize the values from 0 to 255, and do the square root
        %for visibility
        ypred1=  (ypred1-min(ypred1(:)) ).^intensityFix;
        idx1=(254-round(  (ypred1/(max(ypred1(:))))*254))/254;
        %
        ypred2= ( ypred2-min(ypred2(:))  ).^intensityFix;
        idx2=(254-round( (ypred2/(max(ypred2(:))))*254))/254;
        %
        
        ypred1=254+zeros([size(ypred1,1) size(ypred1,2)]);
        ypred2=254+zeros([size(ypred1,1) size(ypred1,2)]);
        ypred3=254+zeros([size(ypred1,1) size(ypred1,2)]);
        
        ypred1=(ypred1.*idx2);
        ypred2=(ypred2.*idx1);
        ypred3=(ypred3.*idx1+ ypred3.*idx2)/2;
        
        
        ypred1 = ypred1 + (2-(idx1+idx2))/2*220;
        ypred2 = ypred2 + (2-(idx1+idx2))/2*220;
        
        % make a nice image
        im=uint8(zeros([size(ypred1,1) size(ypred1,2) 3]));
        im(:,:,1)=round(ypred1);
        im(:,:,2)=round(ypred2);
        im(:,:,3)=round(ypred3);
    end
    
    iptsetpref('ImshowAxesVisible','on');
    
    %imshow(im ,'XData', [0 100], 'YData', [0 100])
    imshow(im ,'XData',[mxY mnY ] , 'YData', [mnX mxX])
    axis square
    %  set (gca, 'xaxislocation', 'top');
    set(gca,'YDir','normal')
    ylabel(xAxis);
    xlabel(yAxis);
    legend(Dataset1,Dataset2,'Location','southoutside','Orientation','horizontal')
    %     title([colNames{selected(I)} ' '  colNames{selected(J)}]);
    %     drawnow;
    %
    %     saveas(1,[ saveDir '\A' num2str(round(totalAccur)) '_' ...
    %         colNames{selected(I)} '-'  colNames{selected(J)} '-' ...
    %         num2str(I) '_' num2str(J) '_' num2str(pCount) '_' ...
    %         analytePair '.png']);
    disp('=====');
    
    
end

