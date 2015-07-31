function savedatatable(filename,colnames,data)

for I=1:size(data,1)
    for J=1:size(data,2)
        d{I,J}=data(I,J);
    end
end
%d=mat2cell(data);
values=vertcat(colnames,d);

 cell2csv(filename , values);
      



end