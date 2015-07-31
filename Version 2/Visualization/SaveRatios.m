
function SaveRatios(runParams,methodName, data2)

saveRatioFile =[runParams.outputPath '\Ratios' methodName '.csv'];
paraIDX = unique(data2.SVM_A_ParameterSet_Index);

idx = find(data2.SVM_A_ParameterSet_Index==paraIDX(1));

analyteRatioCollection= zeros(length(idx));
nCollections =0;
analyteNames = [];
outstring='';
for I=1:length(paraIDX)
    idx = find(data2.SVM_A_ParameterSet_Index==paraIDX(I));
    ratioCollection = zeros(length(idx));
    for J=1:length(idx)
        try
            ratios = char(data2.SVM_A_RatioCallsS(idx(J)));
            values = str2double( strsplit(ratios,'|'));
            values = values(1:end-1);
            if length(idx)==length(values)
                ratioCollection(J,:)=values(1:length(idx));
            else
                ratioCollection(J,1:length(values))=values;
            end
            values = strrep(ratios , '|',',');
            line = [char(data2.SVM_A_Analyte(idx(J))) ',' values '\n'];
            outstring =[outstring line]; %#ok<AGROW>
        catch mex
            dispError(mex);
        end
    end
    analyteNames=data2.SVM_A_Analyte(idx);
    if max(ratioCollection(1,:))>90 && max(ratioCollection(2,:))>90
        
        nCollections=nCollections+1;
        analyteRatioCollection=analyteRatioCollection+ratioCollection;
    end
    
    outstring =[outstring '\n\n'];
end
fid=fopen(saveRatioFile,'w');
fprintf(fid,outstring);
fclose(fid);


saveRatioFile =[runParams.outputPath '\AverageRatios' methodName '.csv'];
analyteRatioCollection=analyteRatioCollection./ nCollections;
fid=fopen(saveRatioFile,'w');

for J=1:length(analyteNames)
    fprintf(fid,[char(analyteNames(J)) ',']);
    fprintf(fid,'%d,', analyteRatioCollection(J,:));
    fprintf(fid,'\n');
end

ratios = analyteRatioCollection(:,1)./analyteRatioCollection(:,2);
for J=1:length(analyteNames)
    fprintf(fid,[char(analyteNames(J)) ',']);
    fprintf(fid,'%d,', ratios(J,:));
    fprintf(fid,'\n');
end
    
fclose(fid);




end