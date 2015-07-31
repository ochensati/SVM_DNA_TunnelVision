function [parameters]=DefaultKernalParameters()

parameters.kernel='htrbf';
parameters.kerneloption=[.7 .7];
parameters.verbose=0;
parameters.nu=.9;
parameters.c = 1000;
parameters.lambda = 1e-7;
parameters.rhoReduction=3;

end