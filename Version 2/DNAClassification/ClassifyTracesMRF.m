function [class, smoothData, levels]=ClassifyTracesMRF(shortData,Nclasses)

figure(25)
clf;

%   shortData=shortData(1:5000);
class=kmeans(shortData,Nclasses);

classData = zeros(size(shortData));
levels=zeros([Nclasses length(shortData)]);
smoothData=zeros(size(shortData));
origLevels=zeros([1 Nclasses]);
for I=1:Nclasses
    idx1=find(class==I);
    v=mean(shortData(idx1));
    classData(idx1) =I;
    levels(I,1:length(shortData))=v;
    smoothData(idx1)=v;
    origLevels(I)=v;
end


%now determine the correct gap size
for M=1:Nclasses
    lv=0;
    for I=1:length(shortData)
        if levels(M,I)==0 && lv~=0
            levels(M,I)=lv;
        else
            lv=levels(M,I);
        end
    end
end
baseline = mean(levels);

for I=1:Nclasses
    gapSize(I)=mean(levels(I,:)-baseline);
end


stdL =mean(abs( levels(1:end-1)-levels(2:end)));

stdT=std(shortData-smoothData);

window=500;
for iter=1:50
    if mod(iter,105)==0
        flatData = shortData - baseline';
        class=kmeans(flatData,Nclasses);
        torigLevels=zeros([1 Nclasses]);
        tlevels=[];
        for I=1:Nclasses
            idx1=find(class==I);
            v=mean(shortData(idx1));
            classData(idx1) =I;
            tlevels(I,1:length(shortData))=v;
            torigLevels(I)=v;
        end
        
        origLevels=torigLevels;
        
        %now determine the correct gap size
        for M=1:Nclasses
            lv=0;
            for I=1:length(shortData)
                if tlevels(M,I)==0 && lv~=0
                    tlevels(M,I)=lv;
                else
                    lv=tlevels(M,I);
                end
            end
        end
        baseline = mean(tlevels);
        
        for I=1:Nclasses
            gapSize(I)=mean(tlevels(I,:)-baseline);
        end
        
        levels=tlevels;
    end
    
    
    
    levels=zeros([Nclasses length(shortData)]);
    
    for I=1:Nclasses
        idx=find(classData==I);
        t=shortData(idx);
        t=smooth(t,window);
        smoothData(idx)=t;
        levels(I,idx)=t;
    end
    
    for M=1:Nclasses
        lv=0;
        for I=1:length(shortData)
            if levels(M,I)==0 && lv~=0
                levels(M,I)=lv;
            else
                lv=levels(M,I);
            end
        end
    end
    
    for M=1:Nclasses
        lv=0;
        for I=length(shortData):-1:1
            if levels(M,I)==0 && lv~=0
                levels(M,I)=lv;
            else
                lv=levels(M,I);
            end
        end
    end
    
    levelLambda =.3;
    baseline = mean(levels);
    baseline=smooth(baseline,1.5*window);
    
    for M=1:Nclasses
        levels(M,:)=levelLambda*origLevels(M) + (1-levelLambda)*(baseline+gapSize(M));
    end
    
    
    
    
    %                 for I=1:n
    %                     idx=find(classData==I);
    %                     smoothData(idx)=levels(I,idx);
    %                 end
    
    figure(25)
    plot(shortData);
    hold all;
    plot(smoothData,'k');
    for I=1:Nclasses
        plot(levels(I,:))
    end
    
    drawnow;
    
    lambda=.6;
    cost=zeros([Nclasses length(shortData)]);
    for M=1:Nclasses
        L=levels(M,:);
        V =abs([(smoothData(2:end)-L(1:end-1)) 0] )/stdL;
        E= .5* (abs(shortData-L)/stdL).^2;
        
        cost(M,:)=E+lambda * V;
    end
    hold off;
    c=cost(:,400:430);
    
    [d, classData]=min(cost);
    c2=classData(400:430);
    
end
baseline =smooth(baseline,400);

flatData =shortData-baseline';
figure(26)
plot(flatData)
figure(27)
[v, bins]=hist(flatData,100);

plot(bins,v/max(v));    hold all;


obj = gmdistribution.fit(flatData',Nclasses);
gs=pdf(obj,bins');
norm =1/max(gs);
plot(bins,norm*gs);


for M=1:Nclasses
    plot(bins,obj.PComponents(M).*exp(-1*( (bins-obj.mu(M)).^2/ (2*obj.Sigma(M)))));
end

hold off;
end