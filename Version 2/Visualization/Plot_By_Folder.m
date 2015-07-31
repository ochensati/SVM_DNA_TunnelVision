InitializeDLLs
clear pathnames;

masterPath ='S:\Research\BrianAnalysis\Stacked Junctions';

for I=1:8
figure(I);clf;
end


target=1;

% ampX=-3:.01:log(50);
% ampX=exp(ampX);
ampX=0:.05:4;
byFolder={};
clear curFolder;
curFolder{1}='20140402_IBM_A_11_RIE_AGCTmC';
curFolder{2}='20140401_IBM_A_11_RIE_APGCmCAb';
curFolder{3}='20140303_IBM_A_17_RIE_ACTG';
curFolder{4}='20140414_IBM_A_13_RIE_AGC_1nM';

for cFolder=1:length(curFolder)
    if cFolder~=3
    curFolder{cFolder}=lower(curFolder{cFolder});
    for cNames =2:4
        names={'Control','dAMP','dCMP','dGMP','dTMP'};
        colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
        col=colors{cNames};
        files= FindAllAnalytes('S:\Research\BrianAnalysis\Stacked Junctions',{'1nm','10nm'},names{cNames},'p380mv','ref_n100mv');
        
        if (cNames==3)
            for J=1:length(files)
                pathname=lower(files{J}.path);
                fn=files{J}.name;
                disp(curFolder{cFolder})
                disp(pathname);
                cf=curFolder{cFolder};
                if isempty(findstr(pathname,lower(cf)))==false
                    byFolder{cNames,J}= fileInfos{cNames,J};
                    t= fileInfos{cNames,J};
                    for K=1:length(t.amps)
                        tt=t.amps{K};
                        tt(tt<0)=[];
                        if (isempty(t)==false)
                            scaleFactor(K)=target/mode(t.amps{K});
                        end
                    end
                    break;
                end
            end
        end
    end
    
    for cNames =2:4
        names={'Control','dAMP','dCMP','dGMP','dTMP'};
        colors={'k' 'r' 'g' 'b' 'y' 'm' 'r' 'k' 'c'  'm' 'r' 'c' 'r'};
        col=colors{cNames};
        files= FindAllAnalytes('S:\Research\BrianAnalysis\Stacked Junctions',{'1nm','10nm'},names{cNames},'p380mv','ref_n100mv');
        
       disp(colors);
        fTests=1;
        for J=1:length(files)
            pathname=lower(files{J}.path);
            fn=files{J}.name;
           
            cf=curFolder{cFolder};
            if isempty(findstr(pathname,lower(cf)))==false
                disp(cNames)
                disp(J)
                disp(fn);
                byFolder{cNames,J}= fileInfos{cNames,J};
                t= fileInfos{cNames,J};
                if (isempty(t)==false)
                    for K=1:length(t.amps)
                        tt=t.amps{K}*scaleFactor(K);
                        tt(tt<0)=[];
                        bins=hist(tt,ampX);
                        bins=bins./sum(bins);
                        figure(K);hold all;
                        plot(ampX,bins+(cFolder-1)*.2,col);
                    end
                    fTests=fTests+1;
                    if fTests==3
                        break;
                    end
                end
            end
        end
    end
    end
end