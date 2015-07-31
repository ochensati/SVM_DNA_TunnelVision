function [oneClassParameters trainingAccuracy]=CreateMultiClass(Training,Labels, kernalProperties)

try 
    [xsup,w,b,nbsv,~]=svmmulticlassoneagainstone(Training,Labels,kernalProperties.nbclass,kernalProperties.c,kernalProperties.lambda,kernalProperties.kernel,kernalProperties.kerneloption,kernalProperties.verbose);
catch mex
   mex 
end
       
    [trainingPredictedGrouping ] = svmmultivaloneagainstone(Training,xsup,w,b,nbsv,kernalProperties.kernel,kernalProperties.kerneloption);
    trainingAccuracy= length( find(Labels==trainingPredictedGrouping)) / length(trainingPredictedGrouping)*100;

    oneClassParameters.xsup=xsup;
    oneClassParameters.w=w;
    oneClassParameters.b=b;
    oneClassParameters.nbsv =nbsv;
    oneClassParameters.kernel=kernalProperties.kernel;
    oneClassParameters.kerneloption=kernalProperties.kerneloption;
   
  
end

