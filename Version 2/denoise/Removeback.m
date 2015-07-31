function [src,levels]=Removeback(src, iterations)
srcS= smooth(src,101);
x=1:400:length(src);
srcS = srcS(x);
brob = robustfit(x,srcS);
m=brob(2);

dm=.1/500000;
if abs(m*x(end))>10
    m=0;
end
m2=0;
dm2=dm^2/100;

idx=randperm(length(src));
x=(idx(1:min([50000 length(src)])))';
x=sort(x);
x2=x.^2;

srcS= smooth(src,3);
figure(1);clf
plot(srcS);

samp = srcS(x);
% srcF1=src-(m*x);
 figure(1);clf;
for I=1:iterations
    tm=m+dm/I^.3;
    tm2=m2+dm2/I^.3;
    
    cVal =samp-m*x-m2* x2;
    cVal_m = samp-tm*x-m2*x2;
   % cVal_m2 = samp-m*x-tm2*x2;
   % plot(cVal);hold all;plot(cVal_m);plot(cVal_m2);hold off;drawnow;
    J=getCost(cVal) + std(cVal);
    Jm=getCost(cVal_m)+ std(cVal_m);
   % Jm2=getCost(cVal_m2)+ std(cVal_m2);
    dJm=(Jm-J)/dm;
   % dJm2=(Jm2-J)/dm2;
    
    m=m-J/dJm*1e-4/(I^.25);
    %m2=m2-J/dJm2*10e-4/(I^.25);
    
    if abs(m*x(end) )>30
        m=m/2;
    end
    if abs(m2*x2(end) )>30
        m2=m2/4;
    end
    
    if isnan(m)
        disp(m);
    end
    if isnan(m2)
        disp(m);
    end
end
x=(1:length(src))';
std(src)

figure(1);clf;plot(src);hold all


src=src-m*x-m2* x.^2;
std(src)
plot(src)
% m*x(end)
% m2* x(end).^2


% idx=randperm(length(src));
% x=(idx(1:10000))';
% samp = src(x);
% [J,labels]=getCost(samp);
%
% figure(30);clf;hold all;
%
% levels=cell([1 max(labels)]);
% for J=1:max(labels)
%     idx=find(J==labels);
%     s=samp(idx);
%     plot(idx,s);
%     t.s=std(s);
%     t.m=mean(s);
%     levels{J}=t;
% end
t.m=0;
t.s=0;
levels{1}=t;

end

function [cost, label]=getCost(cVal)
label=vbgm(cVal',10,1e-5);
su=zeros([1 max(label)]);
wu=zeros([1 max(label)]);
for J=1:max(label)
    idx=find(J==label);
    su(J)=std(cVal(idx));
    wu(J)=length(idx);
end
cost=log(max(label)) + sum(su.*wu)/sum(wu);
if isnan(cost)
    disp(cost);
    
end
end