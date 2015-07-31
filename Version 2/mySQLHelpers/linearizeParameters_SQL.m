function [names, values] = linearizeParameters_SQL( paramsF ,heading )

fields = fieldnames(paramsF);
names={};
values={};

cc=1;
for I=1:length(fields)
    tempName = fields{I};
    value =paramsF.( fields{I});
    tempName = [heading tempName];
    if isstruct(value)
        [tn tv]= linearizeParameters_SQL(value,[tempName '_']);
        for J=1:length(tn)
            names{cc}=tn{J};
            values{cc} =tv(J);
            cc=cc+1;
        end
    else
        
        if iscell(value)
           if (size(value)==1)
                names{cc}=tempName; %#ok<*AGROW>
                values{cc}=  value;
                cc=cc+1;
            else
                for J=1:length(value)
                    names{cc}=[tempName num2str(J)];
                    values{cc} =  value{J};
                    cc=cc+1;
                end
            end
        else
        if ischar(value)
               values{cc}=value;
        else
            if (size(value)==1)
                names{cc}=tempName; %#ok<*AGROW>
                values{cc}=  double(value);
                cc=cc+1;
            else
                for J=1:length(value)
                    names{cc}=[tempName num2str(J)];
                    values{cc} =  double(value(J));
                    cc=cc+1;
                end
            end
        end
        end
    end
end
