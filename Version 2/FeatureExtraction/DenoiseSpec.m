function [TotalPower,powerspec]=DenoiseSpec(chunk,traceEmpty, FFTSize)


l=length(chunk);
if l<FFTSize
    l=FFTSize;
end
cEFFT= zeros([l 1]);
%get a nice bit of the empty signal to call the noise
cc=1;
for I=1:100
    if (I+1)*l-1<length(traceEmpty)
        cE=traceEmpty(I*l:(I+1)*l-1);
        if (length(chunk)<FFTSize)
            cE = vertcat(cE, ones([FFTSize - length(cE),1])*cE(end));     %#ok<AGROW>
        end
        
        cEFFT =cEFFT + abs(fft(cE));
        cc=cc+1;
    end
end

sigma =cEFFT / cc;

if (length(chunk)<FFTSize)
    chunk = vertcat(chunk, ones([FFTSize - length(chunk),1])*chunk(end));
end

alpha=.5;
N = size(chunk,1);
Yf = fft(chunk)/N;
Pyf = abs(Yf).^2;
%weiner filter
sigma=abs(sigma).^2/N^2;
W=((1-alpha)*Pyf-alpha*sigma)./Pyf;
W(W<0)=0;
spec = (W.*Yf);

rms =(sum( (chunk- mean(chunk)).^2 )/length(chunk)) ^.5;
spec=abs(spec(1:round(end/2)));
spec=spec.^2;
spec(1)=0;
TotalPower=sum(spec(1:end));
powerspec=(spec./TotalPower);
TotalPower=(TotalPower)^.5;

end