function [data]=GetCSSQLData(runParams,sql)


 temp= mySQLAdapter.mySQLAdapterClass.GetAllData_mySQL(['DSN=recognition_L_20;UID=' runParams.dbUser ';PASSWORD=' runParams.dbPassword ';'],sql);
   
 
 for I=1:temp.GetLength(1)
     try
%        col = zeros([1 temp.GetLength(0)]);
        for J=2:(temp.GetLength(0)) 
           col(J-1)=double(temp(J,I));
        end
        data.(char(temp(1,I)))    = col; 
     catch mex
        %col2 = cells([1 temp.GetLength(0)]);
        try 
        for J=2:(temp.GetLength(0)) 
           col2{J-1}=char(temp(J,I));
        end
        data.(char(temp(1,I)))= col2; 
        catch mex
             disp('cannot load data.  Please check SQL');
            dispError(mex);
        end
     end
    
 end



end