function commonSVM=DetermineCommon(analytes,reducedData,runParams, SVMParams)

%removal all points that are listed as mixed or test
idx=find(reducedData(:,5)==0);
reducedData = reducedData(idx,:); %#ok<FNDSB>

%create a class for each analyte 
repIDX =[];
cc=1;
for K=1:length(analytes)
    idx =find( reducedData(:,1)==analytes(K) );
    %reduce the number of points to a managable amount
    if isempty(idx)==false
        idx2 = idx( randperm(length(idx), min([ length(idx) 300])));
        repIDX = [repIDX idx2']; %#ok<AGROW>
        tSingleGroup= reducedData(idx2,runParams.dataColStart:end);
        try
            oneSVM{cc}=CreateOneClass(tSingleGroup,CopyKernalParameters(SVMParams)) ; %#ok<AGROW>
        catch mex
            dispError(mex)
        end
        idx2 = idx( randperm(length(idx), min([ length(idx) 300])));
        repIDX = [repIDX idx2']; %#ok<AGROW>
        tSingleGroup= reducedData(idx2,runParams.dataColStart:end);
        
        predictedGroups = svmoneclassval(tSingleGroup,oneSVM{cc}.xsup,oneSVM{cc}.alpha,oneSVM{cc}.rho,oneSVM{cc}.kernel,oneSVM{cc}.kerneloption);
        t=sort(predictedGroups);
        clf;plot(t);
        if (length(t)<2)
            oneSVM{cc}.threshold = mean(t(:)); %#ok<AGROW>
        else
            oneSVM{cc}.threshold = t(round(length(t)*(1-runParams.Common_Strictness_filter))); %#ok<AGROW>
        end
        cc=cc+1;
    end
end

% randomize the data so that the stop when full does not bias the data
idx = randperm( size(reducedData,1),min([500*length(analytes) size(reducedData,1)]) ) ;

tSingleGroup= reducedData(idx,runParams.dataColStart:end);
votes =zeros([length(idx) 1]);
rvotes =zeros([length(idx) 1]);
%determine the peaks that fall into all the one classes
for K=1:length(oneSVM)
    tvotes =zeros([length(idx) 1]);
    rtvotes =zeros([length(idx) 1]);
    for I=1:500:size(tSingleGroup,1)-4
        top = min([ size(tSingleGroup,1) (I+500)]);
        temp= tSingleGroup((I+1):top,:);
        predictedGroups = svmoneclassval(temp,oneSVM{K}.xsup,oneSVM{K}.alpha,oneSVM{K}.rho,oneSVM{K}.kernel,oneSVM{K}.kerneloption);
        predictedGroups2= predictedGroups>oneSVM{K}.threshold;
        tvotes((I+1):top)=tvotes((I+1):top)+predictedGroups2;
        rtvotes((I+1):top)=rtvotes((I+1):top)+predictedGroups;
    end
    
    votes=votes + tvotes;
    rvotes=rvotes+rtvotes;
    
    if K==1
        [t, idx]=sort(votes);
        tSingleGroup=tSingleGroup(idx,:);
        votes = votes(idx);
    end
    drawnow;
end

aThresh=0;
for K=1:length(oneSVM)
    aThresh=aThresh + oneSVM{K}.threshold;
end
aThresh=aThresh/length(oneSVM)*.7;
rvotes=rvotes/length(oneSVM);
[v,idx]=sort(rvotes);
tSingleGroup=tSingleGroup(idx,:);
idx = find(rvotes>aThresh);

if length(idx)/length(rvotes)>.4
   idx = find(rvotes>v(floor(length(v)*.6)));
end

%all the peaks that fall into all the classes
commonPeaks = tSingleGroup(idx ,: );
%if there are common peaks, create a class and then set a useful threshold
%for peaks that are in the group.
if isempty(commonPeaks)==false
    commonSVM=CreateOneClass(commonPeaks,SVMParams);
    predictedGroups = svmoneclassval(commonPeaks,commonSVM.xsup,commonSVM.alpha,commonSVM.rho,commonSVM.kernel,commonSVM.kerneloption);
    [t idx]=sort(predictedGroups);
    
    idxT=round(length(t)*(1-runParams.Common_Strictness_filter));
    if (idxT==0)
        idxT=1;
    end
    commonSVM.threshold =t(idxT);
else
    commonSVM=[];
end
end