function [ values] = linearizeValues_SQL( paramsF  )

fields = fieldnames(paramsF);
values=[];

cc=1;
for I=1:length(fields)
   
    value =paramsF.( fields{I});
    
    if (isempty(value))
        value =0;
    end
    if isstruct(value)
        [tn tv]= linearizeValues_SQL(value);
        for J=1:length(tn)
            values(cc) =tv(J);
            if isnan(values(cc)) || isinf(values(cc))
                values(cc)=0;
            end
            cc=cc+1;
        end
    else
        if ischar(value)
            
        else
            if (size(value)==1)
                
                values = [values double(value)];
                if isnan(values(end)) || isinf(values(cc))
                    values(end)=0;
                end
                cc=cc+1;
            else
                for J=1:length(value)
                    values = [values double(value(J))];
                    if isnan(values(end)) || isinf(values(cc))
                        values(end)=0;
                    end
                    cc=cc+1;
                end
            end
        end
    end
end
