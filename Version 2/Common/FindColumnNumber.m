function [colNumber]=FindColumnNumber(colNames, desiredName)

for I=1:length(colNames)
    if  strcmp(colNames{I},desiredName)
        colNumber=I;
    end
end

end