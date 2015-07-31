function [newTraces]= resampleAndTemplateMatch(traces, template)
newTraces = cell(size(traces));
minSize=100000000000;
maxSize = 0;
minI=0;
maxI=0;
%find the minimum size and max
for I=1:length(traces)
    t=traces{I}.trace;
    c=length(t)/std(t);
    if (minSize>c)
        minSize = c;
        minI=I;
    end
    if (maxSize<c)
        maxSize = c;
        maxI=I;
    end
end

if (nargin >1)
    minI=template;
end

%reduce the size of each
for I=1:length(traces)
    t=length(traces{I}.trace)/minSize;
    
    if (t<1)
        t2= 1e3;
        t1= round(1/t*1e3);
        
    else
        t1= 1e3;
        t2= round(t*1e3);
    end
    
    newTraces{I}.trace=resample(traces{I}.trace,t1,t2)';
    
    s=size(newTraces{I}.trace);
    if (s(1)>s(2))
        newTraces{I}.trace=newTraces{I}.trace';
    end
end



targetSize=minSize + 10;

template = fft([newTraces{minI}.trace   zeros([1 (targetSize-length(newTraces{minI}.trace)) ])]);
template =conj( template(1:floor(end/2)) );
template = template / std(newTraces{minI}.trace);


for I=1:length(traces)
    if (I~=minI)
        t = fft([newTraces{I}.trace  zeros([1 (targetSize-length(newTraces{minI}.trace)) ])])/ std(newTraces{I}.trace);
        
        m = sum(real(abs( t(1:length(template)) .*template)));
        t2 = fft([newTraces{I}.trace(end:-1:1) zeros([1 (targetSize-length(newTraces{minI}.trace)) ])])/ std(newTraces{I}.trace);
        m2 = sum(real(abs( t2(1:length(template)) .*template)));
        if (m2>m)
            newTraces{I}.reverse = true;
            newTraces{I}.bestTrace= traces{I}.trace(end:-1:1);
            newTraces{I}.trace = newTraces{I}.trace(end:-1:1);
            newTraces{I}.matchCoef = m2/length(t2)/length(t2);
        else
            newTraces{I}.reverse = false;
            newTraces{I}.bestTrace= traces{I}.trace;
            newTraces{I}.matchCoef = m/length(t2)/length(t2);
        end
    else
        newTraces{I}.reverse = false;
        newTraces{I}.bestTrace= traces{I}.trace;
        newTraces{I}.matchCoef = 1;
    end
end


end