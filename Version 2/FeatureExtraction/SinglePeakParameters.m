function [nPeaks]= SinglePeakParameters(conn,assignmentNames,trace,emptyTrace,folder_index,file_index,slidingFreqTrace, startIndexs, endIndexs,cluster_Indexs,runParams )

minFFTSize=runParams.minimum_FFT_Size;
nComponents=runParams.num_peakFFT_coef;


peakParams=struct('P_maxAmplitude',0, ...
    'P_averageAmplitude',0,'P_topAverage',0,'P_peakWidth', 0 , 'P_roughness', 0,...
    'P_totalPower',0,'P_iFFTLow',0,'P_iFFTMedium',0,'P_iFFTHigh',0, 'P_frequency',0,...
    'P_peakFFT',zeros([1 nComponents]),'P_highLow_Ratio',0, 'P_Odd_FFT',0, 'P_Even_FFT',0, ...
    'P_OddEvenRatio',0);


sql ='INSERT INTO peaks VALUES ';
aIndexs = [  num2str(folder_index) ',' num2str(file_index) ',-1' ];

nPeaks = length(startIndexs);

cc=1;
valueList=cell([1 500]);
for I=1:nPeaks
    try
        %cut out the peaks
        chunk =trace(max([1 startIndexs(I)-2]):min([length(trace) endIndexs(I)+2]));
        peakParams.P_frequency=  slidingFreqTrace(I);
        
        [peakParams]=PeakParameters(chunk, emptyTrace,nComponents, runParams,minFFTSize, peakParams);
        
        %pack it into a sql friendly string
        if (I==1)
            [names ,values ] =linearizeParameters_SQL(peakParams,'');
            
            sql='insert into peaks (Cluster_Index,Folder_Index,File_Index,P_SVM_Rating,P_startIndex,P_endIndex,P_identity';
            sql =[sql sprintf(',%s',names{:})]; %#ok<AGROW>
            sql =[sql ') VALUES ']; %#ok<AGROW>
            
        end
        [values] = linearizeValues_SQL( peakParams  );
        
        values(isinf(values))=0;
        b=sprintf(',%4.8f',values);
        
        if (length(assignmentNames)==1)
            aNames = assignmentNames{1};
            aNames =aNames(1:min([length(aNames) 4]));
            tableValues =['('  num2str( cluster_Indexs(I)) ',' ...
                aIndexs ',' num2str(startIndexs(I)) ',' num2str( endIndexs(I)) ',''' aNames  ''''  ...
                b ')'];
            
        else
            aNames = assignmentNames{ floor((startIndexs(I)+endIndexs(I))/2)} ;
            aNames =aNames(1:min([length(aNames) 4]));
            
            tableValues =['(' num2str( cluster_Indexs(I)) ',' ...
                aIndexs ',' num2str(startIndexs(I)) ',' num2str( endIndexs(I)) ',''' aNames  ''''  ...
                b ')'];
        end
        
        valueList{cc} =[tableValues '\n'];
        if mod(cc,400)==0 || I>nPeaks-2
            sql2=[sql valueList{1} ];
            for J=2:cc
                sql2=[sql2 ',' valueList{J}];
            end
            
            sql2=sprintf(sql2);
            
            ret = exec(conn,[sql2 ';']);
            
            if isempty(ret.Message)==false
                disp(ret.Message);
                disp('error in peak save');
            end
            
            clear sql2
            cc=0;
        end
        cc=cc+1;
    catch me
        disp(me);
        disp(me.stack(1,1));
    end
end


end