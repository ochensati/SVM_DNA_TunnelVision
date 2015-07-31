function  [allStarts, allEnds , trace] = EPFLPeakFinder(trace,runParams ,dname,k )

%Get a good estimate of the baseline
bestline= mean(trace);
trace2=trace - bestline;
trace2=trace2- smooth(trace2,420);
noise=trace2(trace2>0);
ult_baseline=2*median(noise);
%find all the peaks
position = trace2>ult_baseline;
position= (smooth(position,50))>0;
didx= position(2:end)-position(1:end-1);

%mark the beginning and end of the peaks
allStarts = find(didx==1);
allEnds= find(didx==-1);

%clean up the peaks
if isempty(allStarts)==false
    try
        if (allEnds(1)<allStarts(1))
            allEnds(1)=[];
            disp('problem EPFLPeakFinder');
        end
    catch mex
        dispError(mex)
    end
    
    %clear off the too short ones
    t=allEnds-allStarts;
    idx = find(t<50);
    allEnds(idx)=[];
    allStarts(idx)=[];
    
    %expand it out to get baseline
    allStarts=allStarts-1000;
    allEnds=allEnds+1000;
    
    allStarts(allStarts<1)=1;
    allEnds(allEnds>length(trace)) = length(trace);
    
    if (length(allEnds)~=length(allStarts))
        allStarts=allStarts(1:length(allEnds));
    end
    
    trace=trace-bestline;
    
    test= min( allEnds-allStarts);
    if (test<0)
        disp('backwards peaks allends < allstarts  epflPeakFinder.m');
    end
    
else
    
    trace=trace-bestline;
end
end