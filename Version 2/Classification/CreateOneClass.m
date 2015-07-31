function [oneClassParameters]=CreateOneClass(data,kernalProperties)
% kernel='gaussian';
% kerneloption=1;
    [xsup,alpha,rho,~]=svmoneclass(data,kernalProperties.kernel,kernalProperties.kerneloption,kernalProperties.nu,kernalProperties.verbose);
%     [xsup,alpha,rho,~]=svmoneclass(data,kernel,kerneloption,kernalProperties.nu,kernalProperties.verbose);
    threshold = rho/kernalProperties.rhoReduction;
    
    oneClassParameters.xsup=xsup;
    oneClassParameters.alpha=alpha;
    oneClassParameters.rho=rho;
    oneClassParameters.kernel=kernalProperties.kernel;
    oneClassParameters.kerneloption=kernalProperties.kerneloption;
    oneClassParameters.threshold=threshold;
    
%     oneClassParameters.xsup=xsup;
%     oneClassParameters.alpha=alpha;
%     oneClassParameters.rho=rho;
%     oneClassParameters.kernel=kernel;
%     oneClassParameters.kerneloption=kerneloption;
%     oneClassParameters.threshold=threshold;
  
end