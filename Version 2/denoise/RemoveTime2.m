function [dataTable]= RemoveTime2(dataTable, runParams,analyteNames)

arg1= analyteNames{1,2};

analytes =dataTable(:,1);

anaIDX =arg1;% unique(analytes);

for I=1:length(anaIDX)
    idxA{I}=find(analytes == anaIDX(I));
end

m=max(dataTable(:,7));
xA = dataTable(:,7)/m;


% figure(5);clf;
for I=runParams.dataColStart:size(dataTable,2)
    
%     clf;hold all;
    
    for J=1:length(idxA)
        
        time= dataTable(idxA{J},7);
        idx=idxA{J};
        didx=idx(2:end)-idx(1:end-1);
        idxB = find(didx~=1);
        
        col=11;
%         figure(10);clf;hold all
                
        allStats = zeros([22 3]);
        for col=12:22
            idx1=idx(1:idxB(1));
            t1= dataTable(idx1,col);
            [v,bins]=hist(t1,50);
            
            f=fit(bins',v','exp1');
%             plot(f)
%             hold all
%             plot(bins,v)
            
            v=v'-feval(f  ,bins' );
            mm(1)=exp(mean(log(t1)));
            ss(1)=std(t1);
            
            idx2=idx((idxB(1)+1):idxB(2));
            t1= dataTable(idx2,col);
            [v2] = hist(t1,bins);
            mm(2)=mean(t1);
            ss(2)=std(t1);
            
            idx3=idx((idxB(2)+1):end);
            t1= dataTable(idx3,col);
            [v3]=hist(t1,bins);
            mm(3)=mean(t1);
            ss(3)=std(t1);
            
            try
                v=horzcat(v',v2',v3');
%                 bar(v);
            catch mex
                try
                    v=horzcat(v,v2',v3');
%                     bar(v);
                catch mex
                end
            end
            
            times(1) = mean( time((1:idxB(1)))) ;
            times(2) = mean( time((idxB(1):idxB(2))) );
            times(3) = mean( time((idxB(2):end)) );
            
            figure(11)
            plot(times,mm)
            figure(12)
            plot(times,ss)
            
            allStats(col,:)=mm;
            
        end
        x1 = dataTable(idx3,7)/m;
        
        plot(x1,t1);
        t = polyfit(x1,t1,1);
        p(J)=t(1);
        X(J)=( max(x1)-min(x1)) * length(x1);
        xt=min(x1):( (max(x1)-min(x1))/1000):max(x1);
        plot(xt,polyval(t,xt));
    end
    X(1)=X(1)*10;
    p1=0;
    for J=1:length(p)
        p1 = p1+ p(J)*X(J);
    end
    p1 =p1/sum(X);
    
    disp(p1);
    if (abs(p1)>.5)
        disp('too big_removetime');
        
        clf;hold all;
        for J=1:length(idxA)
            x1 = dataTable(idxA{J},7)/m;
            t1= dataTable(idxA{J},I);
            
            idx = find(abs(t1)>2);
            x1(idx)=[];
            t1(idx)=[];
            
            plot(x1,t1);
            t = polyfit(x1,t1,1);
            p(J)=t(1);
            X(J)=( max(x1)-min(x1)) * length(x1);
        end
        X(1)=X(1)*10;
        p1=0;
        for J=1:length(p)
            p1 = p1+ p(J)*X(J);
        end
        p1 =p1/sum(X);
    end
    
    dataTable(:,I)=dataTable(:,I)-polyval(p1,xA);

    plot(xA,dataTable(:,I));
    
    drawnow;
end

end