function  [combinedGroups,badGroups] = CombineSimilarGroups(groupsInFiles,runParams,badGroups,keepOrdered)

uniqueNames =cell([length(groupsInFiles.Peaks) 1]); % {1}= groupsInFiles.Peaks{1}.GroupName;

for I=1:length(groupsInFiles.Peaks)
    %found =false;
    
    %isTest=groupsInFiles.Peaks{I}.Test;
   % if ( isTest==false  )
%         for J=1:length(uniqueNames)
%             if (strcmp(uniqueNames{J},groupsInFiles.Peaks{I}.GroupName)  )
%                 found =true;
%                 break;
%             end
%         end
%         if (found==false)
            %uniqueNames{length(uniqueNames)+1}=groupsInFiles.Peaks{I}.GroupName; %#ok<AGROW>
       % end
   % end
   
   uniqueNames{I}=groupsInFiles.Peaks{I}.GroupName;
end

uniqueNames = unique(uniqueNames);

maxSVMPoints =runParams.maxSVMPoints;
combinedGroups.ColNames = groupsInFiles.ColNames;

cc=1;
ccB =length(badGroups);
if ccB==0
    ccB=1;
end

testOnly =zeros([length(uniqueNames) 1]);

for I=1:length(uniqueNames)
    groupIndexs =[];
    testGroupIndexs =[];
    for J=1:length(groupsInFiles.Peaks)
        if (  strcmp( groupsInFiles.Peaks{J}.GroupName, uniqueNames{I})  )
            if  groupsInFiles.Peaks{J}.Test ==false 
                groupIndexs = [groupIndexs J]; %#ok<AGROW>
            else
                testGroupIndexs = [testGroupIndexs J];
            end
        end
    end
    
    %
    %        for J=1:length(groupsInFiles.Peaks)
    %           if (  groupsInFiles.Peaks{J}.Test ==true  )
    %              testGroupIndexs = [testGroupIndexs J]; %#ok<AGROW>
    %           end
    %        end
    
    %now put all the data into one table, it will be reduced as needed
    %by the end of the function
    Train=[];
    for J=1:length(groupIndexs)
        Train=vertcat( Train , groupsInFiles.Peaks{groupIndexs(J)}.Train);
    end
    
    
    if (isempty(Train)==true)
        testOnly (cc)=1;
    end
    %the svm chokes on huge datasets, so just cut it down to manageable
    %sizes
    s = size(Train);
    if s(1)>300 || isempty(Train)==true
        if isempty(testGroupIndexs)==0
            if keepOrdered==false
                if s(1)>maxSVMPoints
                    indexs=randperm(s(1),maxSVMPoints);
                    Train = Train(indexs,:);
                end
                
                Test=[];
                for J=1:length(testGroupIndexs)
                    Test=vertcat( Test , groupsInFiles.Peaks{testGroupIndexs(J)}.Train);
                end
                
                %the svm chokes on huge datasets, so just cut it down to manageable
                %sizes
                
                s = size(Test);
                if s(1)>maxSVMPoints
                    
                    indexs=randperm(s(1),maxSVMPoints);
                    Test =Test(indexs,:);
                    
                end
            else
                s = size(Train);
                if s(1)>maxSVMPoints
                    indexs=randperm(s(1),maxSVMPoints);
                    Train = Train(indexs,:);
                end
                
                Test=[];
                for J=1:length(testGroupIndexs)
                    t=groupsInFiles.Peaks{testGroupIndexs(J)}.Train;
                    mPoints = maxSVMPoints;
                    if mPoints>size(t,1)
                        mPoints = size(t,1);
                    end
                    
                    Test=vertcat(Test, t(1:mPoints,:));
                end
                
            end
            
        else
            %if the user does not specify a test file, then create one
            %by pulling the data from the training set, without
            %overlapping the datapoints.  limit the dataset size to 1000
            halfCount = floor(s(1)/2);
            if (halfCount>maxSVMPoints)
                halfCount =maxSVMPoints;
            end
            indexs=randperm(s(1));
            
            if keepOrdered==true
                Test = Train(1:halfCount*2,: );
               
                Train =  Train(indexs(1:halfCount),:);
            else
                Test = Train(indexs(halfCount:2*halfCount-2),: );
                Train =  Train(indexs(1:halfCount),:);
            end
            
        end
        
        combinedGroups.Peaks{cc}.GroupName = uniqueNames{I};
        combinedGroups.Peaks{cc}.Train=Train;
        combinedGroups.Peaks{cc}.Test=Test;
        
        cc=cc+1;
    else
        badGroups{ccB}=uniqueNames{I};
        ccB=ccB+1;
    end
    
end

[m idx]=sort(testOnly);
combinedGroups.Peaks = combinedGroups.Peaks(idx);

end


