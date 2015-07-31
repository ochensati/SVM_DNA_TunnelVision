clear filename
h=figure;
for eI=10:10%length(extraInfo)
    clf;
    targetExtra=extraInfo{eI};
    
    cc=1;
    lFile='';
    for I=1:length(targetExtra)
        try
            val= targetExtra{I};
            if (isempty(val)==false && strcmp( val.Filename, lFile)==false)
                try
                    filename{cc} = val.Filename;
                    lFile = val.Filename;
                    cc=cc+1;
                catch mex
                end
            end
        catch mex
        end
    end
    
    maxValue=1;
    
    for fileI=3:3%length(filename)
       clf;
        trace =load(filename{fileI});
        trace=trace.trace;
        
        colorAssignment=zeros(size(trace));
        for I=1:length(targetExtra)
            peak = targetExtra{I};
            if isempty(peak )==false
                try
                    if strcmp(filename(fileI),peak.Filename)==true
                        colorAssignment( peak.StartIndex:peak.EndIndex)=peak.Rating;
                        maxValue = max(maxValue,peak.Rating);
                    end
                catch mex
                end
            end
        end
        
        
        
        
        if sum(colorAssignment)~=0 && length(find(colorAssignment==5))>5 && length(find(colorAssignment==6))>5
            drawnOnce =false;
            
            for I=[1:maxValue 0]
                
                idx=find(colorAssignment==I);
                if isempty(idx)==false
                    drawn=zeros(size(colorAssignment));
                    drawn(idx)=trace(idx);
                    
                    switch I
                        case 0
                            set(0,'DefaultAxesColorOrder',[0.4,0.4,0.4])
                            plot (drawn);
                        case 1
                            plot(drawn,'k');
                        case 2
                            plot(drawn,'r');
                        case 3
                            set(0,'DefaultAxesColorOrder',[0.2,0.8,0.1]);
                            plot(drawn);
                        case 4
                            plot(drawn,'b');
                        case 5
                            plot(drawn,'y');
                        case 6
                            plot(drawn,'m');
                    end
                    if drawnOnce ==false
                        hold all;
                        drawnOnce=true;
                    end
                    drawnow;
                end
            end
            
            options.Format = 'jpeg';
            hgexport( h,['c:\\temp\\painting_' num2str(eI) '_' num2str(fileI) '.jpg'],options);
        end
    end
end
