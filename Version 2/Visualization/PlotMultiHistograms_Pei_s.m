I=2;
for J=1:size(features{I}.features,1)
    figure(J)
    clf
    for I=2:length(features)
        
        d=log(abs(features{I}.features(J,:)./features{I}.pks));
       % d=log(d);
        if  I==2
            [v, bins]=hist(d,45);
           % d=bins(2)-bins(1);
           % bins=[ (d*(-100:-1) + bins(1)) bins (d*(1:100) + bins(end))];
        end
        
        v =hist(d,bins);
        v(1)=0;
        v(end)=0;
        
        v=v/sum(v);
        
        plot(bins,v,colors{ 1+mod(I-2, length(colors))});
        hold all;
        drawnow
        
        
    end
end
