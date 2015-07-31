function [colNames]= AllColumnNames( examplePeak, runParams  )

   % examplePeak = peaksInFile{1}.WorkingDataset{1};
    colNames = fieldnames(examplePeak ) ;
    fixedClusterNames=[];
    if ( isfield(examplePeak,'ClusterInfo') ==1 )
        clusterNames =  fieldnames( examplePeak.ClusterInfo);
        cc=1;
        for K=1:length(clusterNames)

            if ( (  length(strfind(clusterNames{K},'Trace')) + length(strfind(clusterNames{K},'Index'))  ) ==0)
                s=size(examplePeak.ClusterInfo.(clusterNames{K}));
                if (s(1) >1 || s(2)>1)
                   for J=1:length(  examplePeak.ClusterInfo.(clusterNames{K}))
                    fixedClusterNames{cc}=['ClusterInfo.' clusterNames{K} '+' num2str(J)];   
                    cc=cc+1;
                   end 
                else     
                        fixedClusterNames{cc}=['ClusterInfo.' clusterNames{K}];
                        cc =cc+1;
                end
            end
        end    
    end
    colNames( find(strcmp(colNames,'ClusterInfo')))=[];

    cc=1;
    for K=1:length(colNames)
       if ( (  length(strfind(colNames{K},'Trace')) +  length(strfind(colNames{K},'Index')) )  ==0)
          
           s=size(examplePeak.(colNames{K}));
           if (s(1)>1 || s(2)>1)
               for J=1:length( examplePeak.(colNames{K}) )
                  fixedColNames{cc}=[colNames{K} '+' num2str(J)];   
                  cc=cc+1;
               end 
           else       
                  fixedColNames{cc}=colNames{K};
                  cc=cc+1;
           end
       end 
    end
    colNames = horzcat(fixedColNames, fixedClusterNames);
end