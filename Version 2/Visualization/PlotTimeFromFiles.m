
sql =['select files.File_Index, files.FileName\n'...
    ' from files \n' ...
    '   join folders \n' ...
    '     on folders.Folder_Index = files.Folder_Index \n' ...
    '   join analytefolders \n' ...
    '     on analytefolders.Folder_Index = folders.Folder_Index \n' ...
    '   join analytes \n' ...
    '     on analytes.Analyte_Index = analytefolders.Analyte_Index \n' ...
    ' WHERE analytes.Analyte_Experiment_Index=' num2str(experiment_Index) ' AND analytefolders.Control=0' ];

sql=sprintf(sql);

ret = exec(conn,sql);
ret.Message
ret = fetch(ret);

d=ret.Data;
File_Index= d.File_Index;
FileName = d.FileName;

File_Time=zeros(size(File_Index));
for I=1:length(FileName)
    try
        f=FileName{I};
        C=strsplit(f,'_')
        t=  str2num(C{end-1});%#ok<ST2NM> %str2num( C{end-2} ) * 100000 +
        File_Time(I)=t;
    catch
        File_Time(I)=I;
    end
end

[File_Time, idx]=sort(File_Time);
File_Index=File_Index(idx);

colors={'k' 'r' 'g' 'b' 'y' 'm' 'k'};


ana = unique(dataTable(:,1));



for J=7:size(dataTable,2)
    figure(3);clf;hold all;
    figure(4);clf;hold all;
    figure(2);clf;hold all;
    figure(1);clf;hold all;
    tY =[];
    tStart=0;
    for I=1:length(File_Index)
        idx = find(dataTable(:,4)==File_Index(I));
        if (isempty(idx)==false)
            
            t1 = dataTable(idx(1),2);
            X=dataTable(idx,2)-t1+tStart;
            tStart = X(end)+1;
            
            colI=find(ana==dataTable(idx(1),1));
            
            Y=dataTable(idx,J);
            
            try
                figure(1)
                plot(X,Y, colors{colI});
                ylabel(colNames{J});
                xlabel('timish (order)');
                
                Y=smooth(Y,40);
                figure(2)
                plot(X,Y, colors{colI});
                ylabel(colNames{J});
                xlabel('timish (order)');
                
                
                tY = [tY Y'];
                figure(4)
                plot(X,Y, colors{colI});
                
                ym= max([ min(tY) mean(tY)-3*std(tY)]);
                yM = min([max(tY) mean(tY)+3*std(tY)]);
                
                ylim([ ym yM ]);
                ylabel(colNames{J});
                xlabel('timish (order)');
                
                figure(3)
                plot(X,log(abs(Y)+1), colors{colI});
                ylabel(['log( ' colNames{J} ' )']);
                xlabel('timish (order)');
                
               
            catch
            end
            
            
        end
        
    end
    JJ=1;
    drawnow;
    saveas(1,[ 'C:\temp\time plots\_' colNames{J} '_' num2str(experiment_Index) '_' num2str(JJ)  '.png']);
    saveas(2,[ 'C:\temp\time plots\_' colNames{J} '_smooth_' num2str(experiment_Index) '_' num2str(JJ) '.png']);
    saveas(3,[ 'C:\temp\time plots\_' colNames{J} '_slog_' num2str(experiment_Index) '_' num2str(JJ) '.png']);
    saveas(4,[ 'C:\temp\time plots\_' colNames{J} '_limit_' num2str(experiment_Index) '_' num2str(JJ) '.png']);
    
   
end




