
function [chosenFiles]=FindAllAnalytes(masterPath,conc,name,volt, ref)

chosenFiles={};
cFiles=1;

conc=lower(conc);
name = lower(name);
volt=lower(volt);
ref=lower(ref);
%masterPath ='S:\Research\BrianAnalysis\Stacked Junctions';

files=GetRecursiveFiles(masterPath);

for J=1:length(files)
    
    fn=lower(files{J}.name);
    
    if isempty(findstr(fn,'rinse'))==true
        if isempty(findstr(fn,name))==false
            if isempty(findstr(fn,ref))==false
                if isempty(findstr(fn,volt))==false
                    for I=1:length(conc)
                        if isempty(findstr(fn,conc{I}))==false
                            t=files{J};
                            t.conc=conc{I};
                            chosenFiles{cFiles}=t;
                            cFiles=cFiles+1;
                        end
                    end
                end
            end
        end
    end
    
end