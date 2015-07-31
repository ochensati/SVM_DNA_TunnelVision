function [src,levels]=Removeback3(src, iterations)
srcS= smooth(src,101);
x=1:400:length(src);
srcS = srcS(x);
brob = robustfit(x,srcS);
m=brob(2);
m2=0;
m3=0;

idx=randperm(length(src));
x=(idx(1:5000))';
x2=x.^2;
x3=x.^3;

samp = src(x);
% srcF1=src-(m*x);
dm=m*.01;
dm2=abs(dm)^.5/x2(end);
dm3=abs(dm)^.5/x3(end);
for I=1:iterations
    tm=m+dm;
    tm2=m2+dm2;
    tm3=m3+dm3;
    
    cVal =samp-m*x-m2* x2-m3*x3;
    cVal_m = samp-tm*x-m2*x2-m3*x3;
    cVal_m2 = samp-m*x-tm2*x2-m3*x3;
    cVal_m3 = samp-m*x-m2*x2-tm3*x3;
    
    J=getCost(cVal) + std(cVal);
    Jm=getCost(cVal_m)+ std(cVal_m);
    Jm2=getCost(cVal_m2)+ std(cVal_m2);
    Jm3=getCost(cVal_m3)+ std(cVal_m3);
    
    dJm=(Jm-J)/dm;
    dJm2=(Jm2-J)/dm2;
    dJm3=(Jm3-J)/dm3;
    
    m=m-J/dJm*1e-3;
    m2=m2-J/dJm2*10e-4;
    m3=m3-J/dJm3*10e-6;
    
end
x=(1:length(src))';

figure(1);clf;plot(src);hold all

src=src-m*x-m2* x.^2 -m3*x.^3;


plot(src)
m*x(end)
m2* x(end).^2
m3* x(end).^3
idx=randperm(length(src));
x=(idx(1:10000))';
samp = src(x);
[J,labels]=getCost(samp);

figure(30);clf;hold all;

levels=cell([1 max(labels)]);
for J=1:max(labels)
    idx=find(J==labels);
    s=samp(idx);
    plot(idx,s);
    t.s=std(s);
    t.m=mean(s);
    levels{J}=t;
end


end

function [cost, label]=getCost(cVal)
    label=vbgm(cVal',20);
    su=zeros([1 max(label)]);
    wu=zeros([1 max(label)]);
    for J=1:max(label)
        idx=find(J==label);
        su(J)=std(cVal(idx));
        wu(J)=length(idx);
    end
    cost=sum(su.*wu)/sum(wu);
end