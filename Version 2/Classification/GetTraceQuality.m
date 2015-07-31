function [ Hz60 baseLine  ] = GetTraceQuality( trace )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Fp1=50/50000;
Fp2=70/50000;
Fst1=45/50000;
Fst2=75/50000;
%D = fdesign.lowpass('Fp,Fst,Ap,Ast',FpV,FstV,1,60);
%Hd = design(D,'equiripple','StopBandShape','linear','StopBandDecay',20);

% ------------------------------------------
% Filter and decimate:
% ------------------------------------------
f1 = 50000; % initial rate
f2 = 300; % final rate

% Remove common factors:
c = gcd(f1,f2);
p = f2/c; % Upsample
q = f1/c; % Downsample

% Simplest approach - use single stage resampling
% Resample signal from f1 to f2 Hz:
xr = resample(trace,p,q);

% 60Hz LPF filter
b = fir1(32,[50*2/f2 70*2/f2]); % Or whatever you'd like
y =  filter(b,1,xr);

b = fir1(32,[90*2/f2 105*2/f2]); % Or whatever you'd like
y2 =  filter(b,1,xr);

y=abs(resample(y,1,500));
y2=abs(resample(y2,1,500));

filtered=y./y2;
filtered=filtered(10:end-10);
%plot(filtered)


m=mean(filtered);
s=filtered(filtered>m);
Hz60 = std(s);


clear filtered;
clear xr;
clear y;
clear y2;

step = length(trace)/100;
rTrace=zeros([1 100]);
for I=1:100-1
    rTrace(I)=min(trace(round(I*step):round((I+1)*step)));
end
rTrace=rTrace(5:end-5);

baseLine = std(rTrace);
end

