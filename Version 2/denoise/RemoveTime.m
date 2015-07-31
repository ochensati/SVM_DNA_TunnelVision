function [dataTable]= RemoveTime(dataTable, runParams,analyteNames)

arg1= analyteNames{1,2};
arg2 =[1];%analyteNames{3,2};

phe1 =analyteNames{2,2};
phe2= [1];%analyteNames{4,2};

idx =dataTable(:,1); 
idx1=[find(idx == arg1)' find(idx == arg2)'];
idx2=[find(idx == phe1)' find(idx == phe2)'];

x1 = dataTable(idx1,7);
x2= dataTable(idx2,7);
xA = dataTable(:,7);

[x1, idx]=sort(x1);
idx1=idx1(idx);
[x2, idx]=sort(x2);
idx2=idx2(idx);

figure(5);clf;
for I=runParams.dataColStart:size(dataTable,2)
    t1= dataTable(idx1,I);
    t2= dataTable(idx2,I);
    p1 = polyfit(x1,t1,1);
    p2 = polyfit(x2,t2,1);
    
    p = (p1+p2)/2;
    
    clf;
    %plot(dataTable(:,I));hold all;
    dataTable(:,I)=dataTable(:,I)-polyval(p,xA);
    %plot(dataTable(:,I));
    plot(x2/60,t2);hold all;plot(x2/60,dataTable(idx2,I));
    
    drawnow;
end

end