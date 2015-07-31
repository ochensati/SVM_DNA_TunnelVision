function [colNames,dataTable, controlTable]= ScaleData2(colNames,dataTable, controlTable,runParams)
nCols=size(dataTable,2);

trainableIDX = find(dataTable(:,5)==0);


t=dataTable(trainableIDX,:);
ttt = sum(imag(dataTable(:)));
ana1 = t(1,1);
idx = find(t(:,1)==ana1);
for I=runParams.dataColStart: size(t,2)
    if (I==16)
        disp(I);
    end
    t2=t(idx,I)+.0000001; %#ok<FNDSB>
    m=min(t2);
    if (m>0)
        
        pd1 =fitdist(t2,'normal');
        pd2 =fitdist(t2,'lognormal');
        pd3 = fitdist(t2,'exponential');
        pd1=pd1.NLogL;
        pd2=pd2.NLogL;
        pd3=pd3.NLogL;
        
        if (pd2<pd1 || pd3<pd1) && false
            disp(['changing the value of ' colNames{I} ' to a log distribution']);
            m=min(dataTable(:,I));
            if (m==0)
                tttt=log( dataTable(:,I)+ .0001);
                ttt =abs( sum(abs(imag(dataTable(:)))));
                dataTable(:,I)=tttt;
                if (ttt>0)
                    disp('complex');
                end
            else
                tttt=log( dataTable(:,I) );
                ttt = sum(abs(imag(dataTable(:))));
                dataTable(:,I)=tttt;
                if (ttt>0)
                    disp('complex');
                end
                
            end
        end
    end
end

dataTable=double(real(dataTable));

t=dataTable(trainableIDX,:);

means = median(t );
deviations = median(abs( bsxfun(@minus, t, means) ));

badCols=[];
for L=runParams.dataColStart:nCols
    if isnan(deviations(L))==true || deviations(L)==0
        badCols=[badCols L];
    else
        dataTable(:,L)=(dataTable(:,L)-means(L))/deviations(L);
    end
end

if (isempty( controlTable)==false )
    for L=runParams.dataColStart:nCols
        %     if isnan(cDeviations(L))==true || deviations(L)==0
        %         badCols=[badCols L];
        %     else
        controlTable(:,L)=(controlTable(:,L)-means(L))/deviations(L);
        %     end
    end
end

cols=1:size(dataTable,2);
cols(badCols)=[];
dataTable=dataTable(:,cols);

controlTable=controlTable(:,cols);
colNames =colNames(cols);
end