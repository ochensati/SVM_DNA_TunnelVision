function [oneClassParameters]=CreateOneClass(data,kernalProperties)

    [xsup,alpha,rho,~]=svmoneclass(data,kernalProperties.kernel,kernalProperties.kerneloption,kernalProperties.nu,kernalProperties.verbose);
    threshold = rho/kernalProperties.rhoReduction;
    
    oneClassParameters.xsup=xsup;
    oneClassParameters.alpha=alpha;
    oneClassParameters.rho=rho;
    oneClassParameters.kernel=kernalProperties.kernel;
    oneClassParameters.kerneloption=kernalProperties.kerneloption;
    oneClassParameters.threshold=threshold;
  
end