function [refinedData, lostpeaks, analyteLost] = RemoveWater(conn,refinedData,controlTable, runParams,experiment_Index )
%RemoveWater compares control signal and implements a smart filter
%   This will combine the control signals from the peaks to produce a error
%   filter.  Then each point in the dataset is cleaned out
%the problem here is that in its current form, this only works to edit out
%the single peaks, not the whole clusters


waterSignal=GetWaterClass(conn,refinedData.experiment_Index, refinedData.colNames, controlTable,runParams);
totalLost = 0;
totalPossible=0;
%now apply these to each experiment, and use the SVM (one class)to compare the
%datasets
C_Ratings = zeros([size(controlTable ,1) 1]);
nPoints =0;
for J=1:400:size(controlTable,1)
    disp(['   section   ' num2str(J)]);
    J2=J+399;
    if J2>size(controlTable,1)
        J2=size(controlTable,1);
    end
    temp2=controlTable(J:J2,waterSignal.ColNames);
    nPoints=nPoints + size(temp2,1);
    
    ypred = svmoneclassval(temp2,waterSignal.xsup,waterSignal.alpha,waterSignal.rho,waterSignal.kernel,waterSignal.kerneloption);
    
    C_Ratings(J:J+length(ypred)-1) = ypred;
end

t=sort(C_Ratings);
%set the threshold rather high so that we do not over filter.
waterSignal.threshold = t(round(end*(1-runParams.Water_Strictness_filter)));

%now classify all the data so it can be tracked
ratings = zeros([size(refinedData.dataTable ,1) 1]);
WaterPeaks=[];
nPoints =0;
for J=1:400:size(refinedData.dataTable,1)
    disp(['   section   ' num2str(J)]);
    J2=J+399;
    if J2>size(refinedData.dataTable,1)
        J2=size(refinedData.dataTable,1);
    end
    temp2=refinedData.dataTable(J:J2,waterSignal.ColNames);
    nPoints=nPoints + size(temp2,1);
    
    ypred = svmoneclassval(temp2,waterSignal.xsup,waterSignal.alpha,waterSignal.rho,waterSignal.kernel,waterSignal.kerneloption);
    
    ratings(J:J+length(ypred)-1) = ypred<waterSignal.threshold;
end

sql ='';
wheres ='';
for I=1:length(ratings)
    if mod(I,500)==0
        sql =sprintf (['update peaks\n set P_SVM_Rating = \n case \n' sql '\n else P_SVM_Rating  end \n' ...
            ' where Peak_Index in ' wheres ');'] );
        
        exec(conn,sql);
        wheres ='';
        sql='';
    end
    peak_Index=num2str(refinedData.dataTable(I,2));
    sql =[sql ' when Peak_Index=' peak_Index  ' then ' num2str(ratings(I)) '\n'];
    if I==1
        wheres = ['(' peak_Index];
    else
        wheres =[wheres ',' peak_Index];
    end
end



[v idx]=sort(ratings,'descend');
[v2 idxC]=sort(C_Ratings,'descend');
figure(4);
plot(v);
hold all;
plot(v2);
hold off;

idx2=find(ratings==0);
lostpeaks = length(idx2)/length(ratings)*100;

sql=['update experiments set percentWater=' num2str(lostpeaks) ' where Experiment_Index=' num2str(experiment_Index) ';'];
exec(conn,sql);

disp(' ');
disp(' *********************************************** ');
fprintf('Percent peaks lost to water signal  %f3 \n', lostpeaks);


analytes = refinedData.dataTable(:,1);
badAna = analytes(idx2);
uAna= unique(analytes);
for I=1:length(uAna)
    lost =round( length(find(badAna==uAna(I)))/length(find(analytes==uAna(I)))*100);
    fprintf('Percent Lost from analyte: %d = %f3  \n', uAna(I),lost);
    sql = ['update analytes SET Ana_percentWaterPeaks =' num2str(lost) ' where Analyte_Index=' num2str(uAna(I)) ';'];
    exec(conn,sql);
    analyteLost(uAna(I))=lost; %#ok<AGROW>
end

refinedData.dataTable(idx2,:)=[];

end