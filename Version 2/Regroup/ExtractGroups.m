function [Training, Testing]= ExtractGroups( reorganizedPeaksInFile, runParams , colNumbers )

           %pull out these cols and normalized them for all the groups
           nPoints =zeros([length(reorganizedPeaksInFile) 1]);
         
           for K=1:length(reorganizedPeaksInFile)
                temp= reorganizedPeaksInFile{K}.Table;
                s=size(temp);
                
                if (s(2)>1000)
                   indexs  =random('unid',s(2), 1, 1000); 
                   temp = temp(indexs,:); 
                end
              
                now check the test points
                
                temps{K}=temp;
                nPoints(K)=s(1);
           end 
           
           %find the minimum number of points
           minPoints =floor( min(nPoints)/2-2);
           if minPoints<200
                minPoints = 200;
           end
           
           if minPoints>800
               minPoints=800;
           end
           
           %if the dataset has more points than this, cut it off to avoid
           %unbalanced training
           for K=1:length(peaksInFile)
               if (nPoints(K)>minPoints)
                   nPoints(K)=minPoints;
               end
           end
           
           totalPoints = sum(nPoints);
           %now put the points in the correct format
           Training = zeros([totalPoints length(SelectedParams)]);
           Testing = zeros([totalPoints length(SelectedParams)]);
           Grouping = zeros([totalPoints 1]);
           
           Mapping = cell([3 length(peaksInFile)]);
           BackMap = zeros([length(peaksInFile) 1]);
           cc=1;
           GroupNumber = 1;
           for K=1:length(peaksInFile)
               temp=temps{K};
               if (nPoints(K)>0)
                   for L=1:nPoints(K)
                        Training(L+cc,:)=temp(L,:);
                        Testing(L+cc,:)=temp(L+minPoints,:);
                   end     
                   Grouping (cc:(nPoints(K)+cc))=GroupNumber;
                   cc=cc+nPoints(K);
                   
                   Mapping{1,K}=peaksInFile{K}.GroupName;
                   Mapping{2,K}=GroupNumber;
                   BackMap(GroupNumber)=K;
                   GroupNumber = GroupNumber+1;
               end
           end
           
end