function  [comboGroup] = CombineThings(baseGroup,   otherGroups)

    baseGroup = baseGroup{1};
    comboGroup=baseGroup;
    
   
    for I=1:length(otherGroups)
        temp =  otherGroups{I};
        baseGroup.Control =  CombineData(baseGroup.Control, temp.Control);
        baseGroup.Experiment =  CombineData(baseGroup.Experiment,temp.Experiment);
    end
  
    
     baseGroup.Experiment.AllPeaks =RandomizeAndReduce(comboGroup.Experiment.AllPeaks ,  baseGroup.Experiment.AllPeaks );
     baseGroup.Experiment.PeaksWithoutCluster =RandomizeAndReduce(comboGroup.Experiment.PeaksWithoutCluster ,  baseGroup.Experiment.PeaksWithoutCluster );
     baseGroup.Experiment.PeaksInCluster =RandomizeAndReduce(comboGroup.Experiment.PeaksInCluster ,  baseGroup.Experiment.PeaksInCluster );
     baseGroup.Experiment.Clusters =RandomizeAndReduce(comboGroup.Experiment.Clusters ,  baseGroup.Experiment.Clusters );
  
     comboGroup=baseGroup;
end


function [DataBase] = CombineData(DataBase,AddData)

    DataBase.Samples  = DataBase.Samples  +  AddData.Samples ;
    DataBase.AllPeaks =[ DataBase.AllPeaks AddData.AllPeaks];
    DataBase.PeaksWithoutCluster =[ DataBase.PeaksWithoutCluster AddData.PeaksWithoutCluster ];
    DataBase.PeaksInCluster =[ DataBase.PeaksInCluster AddData.PeaksInCluster ];
    DataBase.Clusters =[ DataBase.Clusters AddData.Clusters ];
    DataBase.NumberOfClusters =DataBase.NumberOfClusters+ AddData.NumberOfClusters;
end

function [newArray]= RandomizeAndReduce(compareArray, sampleArray)

%cut off the number of points that can be in the samples to limit overload
    maxNum =3* length(compareArray);
    curNum =length(sampleArray);
    if (curNum>maxNum) 
        curNum = maxNum;
    end
        
    %now randomize and sample the original array
    r=randi(length(sampleArray ),[1 curNum]);
    newArray = sampleArray(r);
end