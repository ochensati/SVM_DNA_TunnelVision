function PlotAccuracies(saveFile,data,figNumber)

methods = unique(data.cSVM_A_Method);
legendText = {'Training'};
for I=1:length(methods)
    legendText{I+1}=methods{I};
    
    idx = find(strcmp( data.cSVM_A_Method(1:end),  methods{I}));
    indexs=data.SVM_A_Result_Index(idx);
    pSet = data.SVM_A_ParameterSet_Index(idx);
    pNames = data.SVM_R_parameters(idx);
    nTested = data.SVM_A_NumberTested(idx);
    trainingAccur = data.SVM_A_Training_Accuracy(idx);
    testingAccur = data.SVM_A_Testing_Accuracy(idx);
    
    [v idx]=sort(indexs);
    
    pSet = pSet(idx);
    pNames =pNames(idx);
    nTested = nTested(idx);
    trainingAccur = trainingAccur(idx);
    testingAccur = testingAccur(idx);
    clear pNumbers
    for J=1:length(pNames)
        pNumbers(J) =length(strsplit(pNames{J},','))-3;
    end
    
    [pNumbers,idx]=  sort(pNumbers);
    trainingAccur=trainingAccur(idx);
    
    figure(figNumber)
   
    if I==1
        plot(pNumbers,trainingAccur,'-o');
    end
    hold all;
    plot(pNumbers,testingAccur,'-o');
    xlabel('Number of parameters');
    ylabel('Accuracy');
    title('Accuracy vs parameters for all analytes');
end

legend(legendText{1:end},'Location','SouthEast');
  
hold off;
  
saveas(figNumber,saveFile);

end