function [dataTable2, goodIndexs] = QuickWaterFilter(analytes, controlTable, reducedData,runParams, SVMParams )

%pull a sample of the background noise
tSingleGroup= datasample(controlTable,300);

tSingleGroup=tSingleGroup(:,runParams.dataColStart:end);

%create a kernal
waterGroup=CreateOneClass(tSingleGroup,CopyKernalParameters(SVMParams)) ;

dataTable2 = [];
goodIndexs =[];
%only put a few samples into the SVMvalues function at a time or the
%processing time becomes intolerable.
for I=1:length(analytes)
    idx = find(reducedData(:,1)==analytes(I));
    try
        [sample, sampidx] = datasample( reducedData(idx,:), min([1000 length(idx)-1]), 'Replace',false);
        
        sampidx = idx(sampidx);
        %rate how close the sample is to the noise group
        pClass = svmoneclassval(sample(:,runParams.dataColStart:end),waterGroup.xsup,waterGroup.alpha,waterGroup.rho,waterGroup.kernel,waterGroup.kerneloption);
        goodidx = find(pClass<.1);
        goodIndexs=vertcat(goodIndexs, sampidx(goodidx)); %#ok<AGROW>
        dataTable2= vertcat(dataTable2, sample(goodidx,:) ); %#ok<AGROW>
    catch mex
        dispError(mex);
    end
end

end