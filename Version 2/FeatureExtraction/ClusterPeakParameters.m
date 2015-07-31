function [numPeaks numClusters]= ClusterPeakParameters(conn,assignmentNames, folder_index,file_index,trace, startIndexs, endIndexs,runParams )
%PEAKASSIGNMENT Summary of this function goes here

nComponents=runParams.num_ClusterFFT_coef;

clusterParams=struct('C_peaksInCluster',0,'C_frequency',0, ...
    'C_averageAmplitude',0,'C_topAverage',0,'C_clusterWidth', 0 , 'C_roughness', 0,...
    'C_maxAmplitude',0,'C_totalPower',0,'C_iFFTLow',0,'C_iFFTMedium',0,'C_iFFTHigh',0, ...
    'C_clusterFFT',zeros([1 nComponents]),'C_highLow',0, 'C_freq_Maximum_Peaks',zeros([1 4]), ...
    'C_clusterCepstrum',zeros([1 nComponents]));



minFFTSize=runParams.minimum_cluster_FFT_Size;
%make a frequncy window to help identify where the clusters are located
halfWindow = runParams.clusterSize;
sigma =  halfWindow/2;
slidingFreqTrace = zeros([length(trace) 1]);
midPeak =round( (startIndexs+endIndexs)/2);

%mark the position of each peaks
for I=1:length(startIndexs)
    slidingFreqTrace(startIndexs(I):endIndexs(I))=1;
end
slidingFreqTrace(midPeak)=2;
%add a guassian peaks at the minimun width of a cluster
impulse =exp(-1*( (-halfWindow:halfWindow) ./sigma).^2);
slidingFreqTrace=conv(slidingFreqTrace,impulse,'same');
assignmentTrace = zeros(size(slidingFreqTrace));

clusterStartI=zeros(size(startIndexs));
clusterEndI=zeros(size(startIndexs));
%now number the clusters
clusterIndex= 1 ;
idx= find(slidingFreqTrace>.1);
clusterStartI(clusterIndex)=idx(1);
%walk through the indexs to mark the start and end
for I=1:length(idx)-1
    if idx(I)+1 ~= idx(I+1)
        clusterEndI(clusterIndex)=idx(I);
        clusterIndex=clusterIndex +1;
        clusterStartI(clusterIndex)=idx(I+1);
    end
end
%clean off any extras
if length(clusterEndI)~=length(clusterStartI)
    clusterEndI(length(clusterStartI))=length(trace);
end

try
    
    clusterStartI=clusterStartI(1:clusterIndex);
    clusterEndI=clusterEndI(1:clusterIndex);
catch mex
    dispError(mex)
end

if (clusterEndI(clusterIndex)==0)
    clusterEndI(clusterIndex)=length(trace);
end

for I=1:clusterIndex
    assignmentTrace(clusterStartI(I):clusterEndI(I))=I;
end

%assign the peaks and put in the frequency stuff
clusterAssignment = assignmentTrace(midPeak);
slidingFreqTrace=slidingFreqTrace(midPeak);
clusterOccupancy=histc(clusterAssignment,1:max(clusterAssignment));

assignmentTrace(assignmentTrace~=0)=1;

impulse =exp(-1*( ((-2*halfWindow):(2*halfWindow)) ./(.25*sigma)).^2);
assignmentTrace=conv(assignmentTrace,impulse,'same');
%find the traces sections that do not have peaks and used a the noise
%control
emptyTrace = trace(assignmentTrace==0);
clear assignmentTrace;

%now refine the start and end of the table
newClusterStart=clusterEndI(:);
newClusterEnd=clusterStartI(:);

clear clusterEndI;
clear clusterStartI;
%make sure that the peaks and clusters match on the ends and starts
for I=1:length(startIndexs)
    
    if startIndexs(I)<newClusterStart(clusterAssignment(I))
        newClusterStart(clusterAssignment(I))=startIndexs(I);
    end
    if endIndexs(I)>newClusterEnd(clusterAssignment(I))
        newClusterEnd(clusterAssignment(I))=endIndexs(I);
    end
end
%make srue that the minum sizes are maintainted
for I=1:length(newClusterStart)
    if abs(newClusterStart(I)-newClusterEnd(I))<minFFTSize
        gap = round( (minFFTSize-abs( newClusterStart(I)-newClusterEnd(I)))/2);
        newClusterStart(I)=newClusterStart(I)-gap;
        newClusterEnd(I)=newClusterStart(I)+minFFTSize-1;
    end
end
%pad it all out
newClusterStart=newClusterStart-100;
newClusterEnd=newClusterEnd+100;

newClusterStart(newClusterStart<1)=1;
newClusterEnd(newClusterEnd>length(trace)-1)=length(trace)-1;


try
    sql ='SELECT max(Cluster_Index) as maxC from clusters';
    ret =fetch(exec(conn,sql));
    startClusterIndex =ret.Data.maxC +1;
    if isnan(startClusterIndex)
        startClusterIndex =0;
    end
catch %#ok<CTCH>
    startClusterIndex =0;
end

try 

sql ='INSERT INTO clusters VALUES ' ;
aIndex =[  num2str(folder_index) ','  num2str(file_index)];

catch mex
    dispError(mex);
end


numClusters=length(newClusterStart);
%get the parameters for the whole cluster
valueList=cell([1 500]);
cc=1;
for I=1:length(newClusterStart)
    try
        %cut out the cluster
        chunk =trace(newClusterStart(I):newClusterEnd(I));
        amplitude = max(chunk);
        if isempty(amplitude)==false
            
            %convert it into parameters
            clusterParams=ClusterFeatures(minFFTSize,nComponents,chunk, ...
                emptyTrace,clusterOccupancy(I), clusterParams,runParams);
            
            if (I==1)
                [names, values ] =linearizeParameters_SQL(clusterParams,'');
                sql='insert into clusters (Folder_Index,File_Index,C_startIndex,C_endIndex,C_SVM_Rating';
                sql =[sql sprintf(',%s',names{:})]; %#ok<AGROW>
                sql =[sql ') VALUES ']; %#ok<AGROW>
            end
            
            %write it all into sql friendly values
            [values] = linearizeValues_SQL( clusterParams  );
            values(isinf(values))=0;
            
            b=sprintf(',%4.8f',values);
            
            tableValues =['('  aIndex ',' ...
                num2str(newClusterStart(I)) ',' num2str(newClusterEnd(I)) ',-1' b ')' ];
            
            valueList{cc} =tableValues;
            
            if mod(cc,400)==0 || I>length(newClusterStart)-2
                sql2=[sql valueList{1} ];
                for J=2:cc
                    sql2=[sql2 ',' valueList{J}];
                end
                
                ret= exec(conn,[sql2 ';']);
                
                if isempty(ret.Message)==false
                    disp(ret.Message);
                    disp('error in cluster save clusterpeakparameters');
                end
                
                clear sql2
                cc=0;
            end
            cc=cc+1;
            
            
        end
    catch me
        disp( me);
        disp( me.stack(1,1));
    end
end

sql = ['select Cluster_Index from clusters where File_Index = ' num2str(file_index) ];
ret = exec(conn,sql);
ret = fetch(ret);
clusterIndexs =ret.Data.Cluster_Index;

dbClusterAssignment=zeros(size(clusterAssignment));
for I=1:max(clusterAssignment)
   idx = find(clusterAssignment==I); 
   dbClusterAssignment(idx)=clusterIndexs(I);
end

%now get all the peaks that are assigned to each cluster
numPeaks=SinglePeakParameters(conn,assignmentNames,trace,emptyTrace,folder_index,file_index,slidingFreqTrace,  startIndexs, endIndexs,dbClusterAssignment,runParams );

end