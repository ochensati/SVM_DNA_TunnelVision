function [bestKernal]= OptimizeSVM(Yapp, xapp)

idx=randperm(length(Yapp));
idx1 = idx(1:100);
idx2 = idx(200:300);

yapp=Yapp(idx1);
yappT=Yapp(idx2);

Xapp=xapp(idx1,:);
XappT=xapp(idx2,:);

lambda = 1e-7;
C = 10;
kernel='htrbf';
verbose=0;

bestKernal=[5 .1];
bestAccur=0;

for a=.01:.05:2
    for b=.1:.1:5
        kerneloption=[b a];
        
        %keyboard
        [xsup,w,w0,pos,tps,alpha] = svmclass(Xapp,yapp,C,lambda,kernel,kerneloption,verbose);
        %[xsup,w,w0,pos,tps,alpha] = svmclassLS(Xapp,yapp,C,lambda,kernel,kerneloption,1,1,100);
        
        ypred = svmval(XappT,xsup,w,w0,kernel,kerneloption,1)     ;
        ypred(ypred>0)=1;
        ypred(ypred<=0)=-1;
        
        acc=        100*sum(ypred==yappT)/length(yappT);
        if acc>bestAccur
            bestAccur=acc;
            bestKernal=[b a];
            disp(acc);
            disp(b)
            disp(a)
            disp('===============');
        end
    end
end


end
