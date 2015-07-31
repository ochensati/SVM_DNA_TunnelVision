
function []=PlotDiffs(groupsInFiles,uniqueNames)

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


params1=groupParams{furthest(1)};
params2=groupParams{furthest(2)};

idx1=randperm(size(params1,1),1200);
idx2=randperm(size(params2,1),1200);

params1=params1(idx1,4:end);
params2=params2(idx2,4:end);

buffer =.08;


bestParamsL ={};

for iteration = 1:5
    
    %     buffer = bufferO/iteration^1.5;
    
    distGrid=zeros(size(params1,2),size(params1,2));
    % distGrid=zeros(15,15);
    for I=1:size(params1,2)
        for J=I:size(params1,2)
            
            if I>=15 && J>=15
                x1=params1(:,I);
                [x1,ia]=unique(x1);
                y1=params1(ia,J);
                
                x2=params2(:,I);
                [x2,ia]=unique(x2);
                y2=params2(ia,J);
            else
                x1=params1(:,I);
                y1=params1(:,J);
                
                x2=params2(:,I);
                y2=params2(:,J);
            end
            
            if I==J
                distGrid(I,J)=10000000;
            else
                dist=0;
                for x=1:length(x1)
                    for y=1:length(x2)
                        r=(abs(x1(x)-x2(y)) + abs(y1(x)-y2(y)));
                        if ( r<buffer)
                            dist = dist + r ;
                        end
                    end
                end
                distGrid(I,J)=dist;%/length(x1)/length(x2);
                distGrid(J,I)=dist;
            end
        end
    end
    
    
    for KK=1:length(bestParamsL)
        idx=bestParamsL{KK};
        distGrid(idx(1),idx(2))=10000000;
        distGrid(idx(2),idx(1))=10000000;
    end
    
    [v idx]=min(distGrid);
    [v idx2]=min(v);
    bestParams = [idx2 idx(idx2)];
    bestParamsL{iteration}=bestParams;
    
    I=bestParams(1);
    J=bestParams(2);
    
    x1=params1(:,I);
    y1=params1(:,J);
    x2=params2(:,I);
    y2=params2(:,J);
    
    % overLapped1=[];
    % overLapped2=[];
    %
    %     for x=1:length(x1)
    %         for y=1:length(x2)
    %     %        if ( (abs(x1(x)-x2(y)) + abs(y1(x)-y2(y)))<buffer)
    %                 overLapped1 = [overLapped1 x];
    %                 overLapped2 = [overLapped2 y];
    %      %       end
    %         end
    %     end
    c1=vertcat(x1,x2);
    c2=vertcat(y1,y2);
    xapp=horzcat(c1, c2);
    
    
    yapp=vertcat(ones(size(x1))*1,ones(size(x2))*-1);
    clear c1;
    clear c2;
    
    
    hh=figure(iteration);
    mnX=min([x1 x2]);
    mxX=max([x1 x2]);
    mnY=min([y1 y2]);
    mxY=max([y1 y2]);
    
    [xtest1 xtest2]  = meshgrid([mnX:(mxX-mnX)/25:mxX],[mnY:(mxY-mnY)/25:mxY]);
    nn = length(xtest1);
    xtest = [reshape(xtest1 ,nn*nn,1) reshape(xtest2 ,nn*nn,1)];
    
    lambda = 1e-7;
    C = 1000;
    sigmakernel=.85;
    K=svmkernel(xapp,'gaussian',sigmakernel);
    kerneloption.matrix=K;
    kernel='numerical';
    [xsup,w,w0,pos,tps,alpha] = svmclass(xapp,yapp,C,lambda,kernel,kerneloption,1);
    %--------------  Evaluating the decision function
    kerneloption.matrix=svmkernel(xtest,'gaussian',sigmakernel,xsup);
    ypred = svmval(xtest,xapp,w,w0,kernel,kerneloption,[ones(length(xtest),1)]);
    %--------------- plotting
    ypred = reshape(ypred,nn,nn);
    clf;
    contourf(xtest1,xtest2,ypred,50);shading flat;
    hold on
    [cc,hh]=contour(xtest1,xtest2,ypred,[-1000 0 1000],'k');
    clabel(cc,hh);
    set(hh,'LineWidth',1);
    h1=plot(xapp(yapp==1,1),xapp(yapp==1,2),'*w');
    set(h1,'LineWidth',2);
    
    h2=plot(xapp(yapp==-1,1),xapp(yapp==-1,2),'*k');
    set(h2,'LineWidth',2);
    
    xlabel (groupsInFiles.ColNames{bestParams(1)+3});
    ylabel (groupsInFiles.ColNames{bestParams(2)+3});
    set(iteration, 'color', 'white');
    set(gca, 'Box', 'off');
    set(gca, 'TickDir', 'out');
    
    hh=figure(iteration+10);
    scatter(params1(:,bestParams(1)),params1(:,bestParams(2)),3,'fill');
    xlabel (groupsInFiles.ColNames{bestParams(1)+3});
    ylabel (groupsInFiles.ColNames{bestParams(2)+3});
    hold all;
    scatter(params2(:,bestParams(1)),params2(:,bestParams(2)),3,'fill');
    hold off;
    set(iteration+10, 'color', 'white');
    set(gca, 'Box', 'off');
    set(gca, 'TickDir', 'out');
    drawnow;
    %     figure(iteration+5);
    %
    %     [p1 xCenters]=hist(params1(:,bestParams(1)),20);
    %     [p2 xCenters]=hist( params2(:,bestParams(1)), xCenters);
    %
    %     data = horzcat(p1',p2');
    %     %bar(xCenters,data);
    %     xlabel (groupsInFiles.ColNames{bestParams(1)+3});
    %
    %     figure (iteration +10);
    %     [p1 xCenters]=hist(params1(:,bestParams(2)),20);
    %     [p2 xCenters]=hist( params2(:,bestParams(2)), xCenters);
    %
    %     data = horzcat(p1',p2');
    %     %bar(xCenters,data);
    %     xlabel (groupsInFiles.ColNames{bestParams(2)+3});
    %
    %
    %     overLapped1=unique(overLapped1);
    %     overLapped2=unique(overLapped2);
    %
    %     params1=params1(overLapped1,:);
    %     params2=params2(overLapped2,:);
    
    if length(params1)==0
        break
    end
end
end