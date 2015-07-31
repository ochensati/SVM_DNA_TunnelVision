function  [folderPaths, runParams] = LoadXLSParameters( filename, SheetName )
%LOADXLSPARAMETERS Summary of this function goes here
%   Detailed explanation goes here
try
    [~,~,raw]=xlsread(filename,SheetName);
catch
    [~,~,raw]=xlsread(filename,'Sheet1');
end

emptyCells=cellfun(@isempty,raw);
raw(emptyCells)=[];


gridSize =size(raw);
I=1;
runParams = struct('ParamFile',filename);
foldersFound =false;

nParameters=1;
parmeterGrid={};

nParameters2=1;
parameterGrid2={};
for K=1:gridSize(1)
    colName =raw{K,1};
    if (colName==colName )
        if (  strcmp( strtrim( raw{K,1}),'Group Label'))
            foldersFound =true;
        else
            if (  strcmp( strtrim( raw{K,1}),'SVM Parameters'))
                parList = strtrim( raw{K,2});
                r=regexp(parList,'\|','split');
                for L=1:length(r)
                    r{L}=strtrim(r{L});
                end
                parameterGrid{nParameters}=r;
                nParameters=nParameters+1;
            else
                if (  strcmp( strtrim( raw{K,1}),'plot_Analytes'))
                    try
                        parList = strtrim( raw{K,2});
                        r=regexp(parList,',','split');
                        for L=1:length(r)
                            r{L}=strtrim(r{L});
                        end
                        parameterGrid2{nParameters2}=r;
                        nParameters2=nParameters2+1;
                    catch
                    end
                else
                    if (foldersFound ==false)
                        colName= regexprep(strtrim(colName),' ','_');
                        runParams.(colName)=raw{K,2};
                    else
                        r=raw(K,:);
                        for J=1:length(r)
                            if isnan(r{J})==false
                                t=strtrim(r{J});
                                t=strrep(t,'''','''''');
                                folderPaths{I,J}=t; %#ok<AGROW>
                            end
                        end
                        I=I+1;
                    end
                end
            end
        end
    end
end
runParams.SVM_Parameters=parameterGrid;
runParams.plot_Analytes=parameterGrid2;

delete(['~$' filename]);
end

