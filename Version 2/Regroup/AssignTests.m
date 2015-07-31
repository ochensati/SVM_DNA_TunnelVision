function [peaksInFile]= AssignTests( peaksInFile, runParams )
    cc=1;
    testIndexs=[];
    for I=1:length(peaksInFile)
        k=strfind(peaksInFile{I}.GroupName, '_Test');
        if isempty( k )==0
            uniqueNames{cc}=peaksInFile{I}.GroupName(1:(k(1)-1)); %#ok<AGROW>
            testIndexs(cc)=I; %#ok<AGROW>
            cc=cc+1;
        end
    end

 
    for I=1:length(uniqueNames)
       for J=1:length(peaksInFile)
           if (strcmp( peaksInFile{J}.GroupName, uniqueNames{I}) )
               peaksInFile{J}.Test = peaksInFile{testIndexs(I)};
               break;
           end
       end
    end

    peaksInFile(testIndexs)=[];
end