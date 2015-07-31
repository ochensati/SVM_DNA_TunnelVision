function  [allStarts, allEnds , trace] = WPeakFinder(trace,runParams ,dname,k )

%remove baseline
t=zeros(size(trace));
t(abs(trace)>3)=10;
t=smooth(t,5000);
trace(t>0)=[];

test = smooth(trace,55);
baseline = mode(test);
[t, bins]=hist(test,100);
[~,idx]=max(t);
baseline2=bins(idx);
baseline3=median(test);
baseline4=mean(test);


bestline= median([baseline baseline2 baseline3 baseline4]);
trace2=test - bestline;
%estimate noise
e=length(trace2);
s=floor(e/205);
for I=1:200
    t=trace2(s*I:s*I +500);
    noise(I) =max(t)-min(t);
end

ult_baseline=2*median(noise);
ult_baseline=.2; %this one is the requested baseline from wanunu lab
position = trace2>ult_baseline;

didx= position(2:end)-position(1:end-1);

allStarts = find(didx==1); %get start and ends
allEnds= find(didx==-1);


if isempty(allStarts)==false
    try
        if (allEnds(1)<allStarts(1))
            allEnds(1)=[];
            disp('too few ends. WPeakFinder');
        end
    catch mex
        dispError(mex)
    end
    
    %make sure that all starts have ends
    allStarts=allStarts-15;
    allEnds=allEnds+15;
    
    if (length(allEnds)~=length(allStarts))
        allStarts=allStarts(1:length(allEnds));
    end
    
    %cut out the ones that are too short
    t=allEnds-allStarts;
    idx = find(t<100);
    allEnds(idx)=[];
    allStarts(idx)=[];
    
    trace=trace-bestline;
    
    cuts=[];
    for I=1: length(allStarts)
        t=min([ trace2(allStarts(I)) trace2(allStarts(I)+2) trace2(allEnds(I)) trace2(allEnds(I)-2)]);
        if (t>.1)
            cuts =[cuts I];  %#ok<AGROW>
        end
        
        t=max(abs(trace2(allStarts(I):allEnds(I)) ));
        if (t>2)
            cuts =[cuts I];  %#ok<AGROW>
        end
        
    end
    
    allStarts(cuts)=[];
    allEnds(cuts)=[];
    
    test= min( allEnds-allStarts);
    if (test<0)
        disp('last allends less than last allstarts   wPeakFinder.m');
    end
    
    
else
    
    trace=trace-bestline;
end
end