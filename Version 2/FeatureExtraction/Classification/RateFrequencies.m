function [frequencies, singleFilled] = RateFrequencies(predictedGroups,highestN)

calledCorrectly=zeros([highestN 1]);
filledFrequencies=zeros([highestN 1]);
nCalled = zeros(size(calledCorrectly));
bins =0:length(predictedGroups);


for I=1:length(predictedGroups)
    predictedGroup = predictedGroups{I};
    predictedGroup = predictedGroup( randperm(length(predictedGroup)));
   % idx = find(predictedGroup==0);
    predictedGroup(predictedGroup==0)=[];
    calledCorrectlyI=zeros([highestN 1]);
    filledFrequenciesI=zeros([highestN 1]);
    nCalledI = zeros(size(calledCorrectly));
    uncallable=0;
    for J=1:highestN
        correct=0;
        filled =0;
        tried =0;
        %for K=1:size(predictedGroup,1)-J
        K=1;
        while K<size(predictedGroup,1)-J
            clusterCalls = predictedGroup(K:K+J-1);
            B=  histc(clusterCalls,bins);
            B(1)=0;
            [m newCall]=max(B);
            
            B(newCall)=0;
            [m2] =max(B);
            
            if (m==m2)
                uncallable =uncallable+1;
                
            else
                newCall=newCall-1;
                
                if (newCall==I)
                    corr=1;
                else
                    corr=0;
                end
                
                correct =correct +corr;
                tried = tried +1;
                
                if (m==J+1)
                    filled=filled+1;
                end
            end
            K=K+J;
        end
        
        filledFrequenciesI(J)=filledFrequenciesI(J) + filled;
        calledCorrectlyI(J)=calledCorrectlyI(J) + correct;
        nCalledI(J) = nCalledI(J)+ tried;
    end
    
    for J=1:highestN
        singleFilled{I*3+1,J}=filledFrequenciesI(J)/nCalledI(J); %#ok<AGROW>
        singleFilled{I*3,J}=calledCorrectlyI(J)/nCalledI(J)*100; %#ok<AGROW>
    end
    
    filledFrequencies=filledFrequenciesI + filledFrequencies;
    calledCorrectly=calledCorrectlyI + calledCorrectly;
    nCalled = nCalledI+ nCalled;
end

frequencies=calledCorrectly./nCalled;
filledFrequencies=filledFrequencies./nCalled;

for J=1:highestN
    singleFilled{1,J}=frequencies(J)*100; %#ok<AGROW>
end
end
