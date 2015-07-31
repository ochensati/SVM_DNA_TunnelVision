function [dataTable]= RemoveTime3(dataTable, runParams,analyteNames)

arg1= analyteNames{1,2};



idx =dataTable(:,1); 
idx1=find(idx == arg1)' ;

x1 = dataTable(idx1,7);
xA = dataTable(:,7);

[x1, idx]=sort(x1);
idx1=idx1(idx);


% figure(5);clf;
for I=12:12%runParams.dataColStart:size(dataTable,2)
    t1= dataTable(idx1,I);
%     p = polyfit(x1,t1,2);
%   figure(1);  clf;hold all
%     plot(x1,t1);
%     
%       figure(3);  clf;hold all
%     plot(x1,t1);

      p = polyfitweighted(x1,t1,1,abs(log(abs(1./t1))));
      
      fit2 = fit(x1,t1,'poly1','Weights',abs(log(abs(1./t1))),'Robust', 'Bisquare');
      p2(1)= fit2.p1;p2(2)=fit2.p2;
      
%       figure(1)
%     plot(x1,t1-polyval(p,x1));
%     plot(x1,polyval(p,x1));
%     figure(3)
%     plot(x1,t1-polyval(p2,x1));
%     plot(x1,polyval(p2,x1));
    p=p2;
   
%     figure(2);clf;
%     plot(dataTable(:,I)+10);hold all;
    t=dataTable(:,I);
    t=t-polyval(p,xA);
    if max(abs(t))>10
       S= mean(t.^2); 
       S2=median(t.^2);
       S3= mean(abs(t));
       
       t=t./(S+S2+S3)*3;
    end
   dataTable(:,I)=t;
    %plot(dataTable(:,I));
%     plot(dataTable(:,I));hold all;
%     
%     drawnow;
end

end