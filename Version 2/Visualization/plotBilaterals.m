
figure(30);clf;

for I=1:5
   
    longData=[];
    for J=1:3
        if isempty(FileDatas2{I,J})==false
            longData=[longData FileDatas2{I,J}];
        end
    end
    
    [v, bins]=hist(longData,1:300);
    v(1)=0;
    v(end)=0;
    plot(bins,v);
    alls(I,:)=v;
    hold all
end