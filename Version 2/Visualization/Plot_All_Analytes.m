InitializeDLLs
clear pathnames;

masterPath ='S:\Research\BrianAnalysis\Stacked Junctions';

clear fileInfos;
clear t;
ampX=-100:500;

for cNames =2:4
    names={'Control','dAMP','dCMP','dGMP','dTMP'};
    colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
    
    files= FindAllAnalytes('S:\Research\BrianAnalysis\Stacked Junctions',{'1nm','10nm'},names{cNames},'p380mv','ref_n100mv');
    
    figure(2);clf;
    figure(1);clf;
    figure(10);clf;
   
    
    for J=1:length(files)
        pathname=files{J}.path;
        fn=files{J}.name;
        
        p=['c:\temp' pathname(3:end)];
        
        if(isdir(p)==0)
            mkdir(p)      %Creates folder containing the plots
        end
        file=[p '\'  fn '_s.mat'];
        d=load(file);
        
        figure(1);
        plot(d.pData );
        hold all;
        
        cWave = d.cWave;
        lWave = d.lWave;
        cc=1;
        pAmplitudes={};
        figure(10);
        
        idx=1;
        idx1=zeros([1 length(lWave)]);
        idx2=zeros([1 length(lWave)]);
        sectionA=cell([1 length(lWave)]);
        for I=1:length(lWave)-1
           idx1(I) = cc;
           idx2(I)=cc+lWave(I)-1;
           sectionA{I}=cWave(idx1(I):idx2(I));
           cc=cc+lWave(I);
        end
        
        pAmplitudes=cell([1 length(lWave)]);
        parfor I=1:4%length(lWave)-1
           section = sectionA{I};
           section = section(floor( length(section)*.75):end);
           [midx,Midx]=peakdet(section,max([3 .3*max(section)]),1:length(section));
           pAmplitudes{I}=[midx(:,2)' Midx(:,2)']
%            hist(pAmplitudes{I},700);
%            drawnow;
        end
        t=struct();
        t.amps=pAmplitudes;
        t.hist=hist(d.pData,ampX);
        t.path=pathname;
        t.file=fn;
%        t=  struct('amps',pAmplitudes,'hist', hist(d.pData,ampX), 'path',pathname,'file',fn);
        fileInfos{cNames,J}=t;
        
    end
end

