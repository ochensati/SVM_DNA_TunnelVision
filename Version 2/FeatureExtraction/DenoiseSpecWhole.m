function [maxFreq,TotalPower,powerspec,misMatch,tilt]=DenoiseSpecWhole(chunk,traceEmpty, FFTSize)


l=length(chunk);
if l<FFTSize
    l=FFTSize;
end

sTE = std(traceEmpty);

traceEmpty2=traceEmpty(1:min([length(traceEmpty) l*150]))/sTE;
cEFFT= zeros([l 1]);
%get a nice bit of the empty signal to call the noise
cc=1;
for I=1:100
    if (I+1)*l-1<length(traceEmpty2)
        cE=traceEmpty2(I*l:(I+1)*l-1);
        if (length(chunk)<FFTSize)
            cE = vertcat(cE, ones([FFTSize - length(cE),1])*cE(end));     %#ok<AGROW>
        end
        
        cEFFT =cEFFT + abs(fft(cE));
        cc=cc+1;
    end
end

sigma =cEFFT / cc;

if (length(chunk)<FFTSize)
    chunk2 = vertcat(chunk, ones([FFTSize - length(chunk),1])*chunk(end));
    sC= std(chunk2);
    chunk2 =chunk2/ sC;
else 
    
    sC= std(chunk);
    chunk2 =chunk/ sC;
end


%weinter filter the signal
alpha=.3;
N = size(chunk2,1);
Yf = fft(chunk2)/N;
Pyf = abs(Yf).^2;

sigma=abs(sigma).^2/N^2;
W=((1-alpha)*Pyf-alpha*sigma)./Pyf;
%W(W<0)=0;
spec = (W.*Yf);

%
tilt= real(spec(2))/(.00000001 + imag(spec(2)));
spec=real(abs(spec(1:round(end/2))));
misMatch=spec(1)-min(chunk2);

TotalPower=sC/ sTE;
%remove the average 
spec(1)=[];
%space out the bins equally
indxs =1+ round( length(spec)/3*((0: (1/FFTSize) :1).^2 + (0: (1/FFTSize) :1).^8 + (0: (1/FFTSize) :1).^3));
indxs(indxs>length(spec))=length(spec);
powerspec=zeros([FFTSize 1]);

cc3=1;
for k=1:FFTSize
    try
        powerspec(cc3) =mean(  spec(indxs(k):indxs(k+1) )) ;
    catch mex
        disp (mex);
    end
    cc3=cc3+1;
end

t=smooth(powerspec,20);
t=t(50:200);
[~, t] =max(t);
maxFreq=t/FFTSize;


FFTSize=51;
indxs =1+ round( length(spec)/3*((0: (1/FFTSize) :1).^2 + (0: (1/FFTSize) :1).^8 + (0: (1/FFTSize) :1).^3));
indxs(indxs>length(spec))=length(spec);
powerspec=zeros([FFTSize 1]);
%space outt he bins biased to the lower frequencies
cc3=1;
for k=1:FFTSize
    try
        powerspec(cc3) =mean(  spec(indxs(k):indxs(k+1) )) ;
    catch mex
        disp (mex);
    end
    cc3=cc3+1;
end


end