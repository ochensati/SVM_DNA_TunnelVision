function [ colNames,data ] = ScaleData3(colNames,data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
for I=1: size(data,2)
    
    t2=data(:,I);
    m=min(t2);
    if (m>0)
        
        pd1 =fitdist(t2,'normal');
        pd2 =fitdist(t2,'lognormal');
        pd1=pd1.NLogL;
        pd2=pd2.NLogL;
        if (pd2<pd1)
            disp(['changing the value of ' colNames{I} ' to a log distribution']);
            m=min(data(:,I));
            if (m==0)
                tttt=log( data(:,I)+ .0001);
                ttt =abs( sum(abs(imag(data(:)))));
                data(:,I)=tttt;
                if (ttt>0)
                    disp('complex');
                end
            else
                tttt=log( data(:,I) );
                ttt = sum(abs(imag(data(:))));
                data(:,I)=tttt;
                if (ttt>0)
                    disp('complex');
                end
                
            end
        end
    end
end

data=double(real(data));


means = median(data);
deviations = median(abs( bsxfun(@minus, data, means) ));

nCols=size(data,2);
for L=1:nCols
    data(:,L)=(data(:,L)-means(L))/deviations(L);
end


covar = corrcoef(data);
cols = find( isnan(covar(:,1)) );
data(:,cols)=[];
colNames(cols)=[];

for I=1:size(covar,1)
    
    covar = corrcoef(data);
    
    for K=1:size(covar,1)
        for L=K:size(covar,2)
            covar(K,L)=0;
        end
    end
    
    idx = find( abs(covar)>.8 );
    cols = ( mod(idx-1 , size(covar,1))+1 );
    rows = floor ( ((idx-1) / size(covar,1))+1 );
    if (length(cols)>0)
        cols =cols(1);
        rows=rows(1);
        
        data(:,rows)=data(:,rows)+ data(:,cols);
        colNames{rows}=[colNames{rows} '_' colNames{cols}];
        
        data(:,cols)=[];
        colNames(cols)=[];
    else
        break;
    end
end

means = median(data);
deviations = median(abs( bsxfun(@minus, data, means) ));

nCols=size(data,2);
for L=1:nCols
    data(:,L)=(data(:,L)-means(L))/deviations(L);
end


covar = corrcoef(data);
surf(covar);


% ampCols=[];
% for I=1:length(colNames)
%     if isempty(findstr(colNames{I},'Amp'))==false %#ok<FSTR>
%         ampCols=[ampCols I]; %#ok<AGROW>
%     end
% end
% colNames(ampCols)=[];
% data(:,ampCols)=[];

end

