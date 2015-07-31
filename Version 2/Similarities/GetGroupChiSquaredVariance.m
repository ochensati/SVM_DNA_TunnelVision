function [variance]=GetGroupChiSquaredVariance(peaks1)


 %define kernal
    kernel='htrbf';
    kerneloption=[.5 .5];
    verbose=0;
    nu=.95;
    
    
                    %use three samples from the dataset to determine how
                    %similar the dataset is to itself as well as getting an
                    %idea of the error in the pdf
                    ss=size(peaks1);
                    Ind = randperm(ss(1),floor(ss(1)/3));
                    t1=peaks1(Ind,:);
                    Ind = randperm(ss(1),floor(ss(1)/3));
                    t2=peaks1(Ind,:);
                    Ind = randperm(ss(1),floor(ss(1)/3));%randi
                    t3=peaks1(Ind,:);
                      
                    %build a pdf for each
                    [xsup,alpha,rho,~]=svmoneclass(t1,kernel,kerneloption,nu,verbose);
                    [xsup2,alpha2,rho2,~]=svmoneclass(t2,kernel,kerneloption,nu,verbose);
                    [xsup3,alpha3,rho3,~]=svmoneclass(t3,kernel,kerneloption,nu,verbose);
                    
                    %get the reaction for each pdf to the first dataset
                    spred = svmoneclassval(t1,xsup,alpha,rho,kernel,kerneloption);
                    ypred = svmoneclassval(t1,xsup2,alpha2,rho2,kernel,kerneloption);
                    xpred = svmoneclassval(t1,xsup3,alpha3,rho3,kernel,kerneloption);
                    
                    %check the variance
                    variance =sum(abs(spred-ypred)) + sum(abs(ypred-xpred)) + sum(abs(xpred-spred));
                    
                    %rinse and repeat
                    spred = svmoneclassval(t2,xsup,alpha,rho,kernel,kerneloption);
                    ypred = svmoneclassval(t2,xsup2,alpha2,rho2,kernel,kerneloption);
                    xpred = svmoneclassval(t2,xsup3,alpha3,rho3,kernel,kerneloption);
                    variance =variance + sum(abs(spred-ypred)) + sum(abs(ypred-xpred)) + sum(abs(xpred-spred));
                    
                    %rinse and repeat
                    spred = svmoneclassval(t3,xsup,alpha,rho,kernel,kerneloption);
                    ypred = svmoneclassval(t3,xsup2,alpha2,rho2,kernel,kerneloption);
                    xpred = svmoneclassval(t3,xsup3,alpha3,rho3,kernel,kerneloption);
                    variance =variance + sum(abs(spred-ypred)) + sum(abs(ypred-xpred)) + sum(abs(xpred-spred));
                    
                    %now use this variance for comparisons to the other
                    %data
                    variance = variance / (9*length(spred));
                    variance=variance^2;
end 