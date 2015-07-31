function [parameters]=CopyKernalParameters(SVMparameters)

parameters.kernel=SVMparameters.kernel;
parameters.kerneloption=SVMparameters.kerneloption;
parameters.verbose=SVMparameters.verbose;
parameters.nu=SVMparameters.nu;
parameters.c =SVMparameters.c;
parameters.lambda = SVMparameters.lambda;
parameters.rhoReduction = SVMparameters.rhoReduction ;
if isfield(SVMparameters,'nbclass')==true
    parameters.nbclass=SVMparameters.nbclass;
end

end