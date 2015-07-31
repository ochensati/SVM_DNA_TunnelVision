function [peakParams]=PeakParameters(chunk, chunkempty,nComponents, runParams,minFFTSize, peakParams)

max_amplitude = max(chunk);
averageAmplitude = mean(chunk(2:(length(chunk)-2)));
top=find(chunk>averageAmplitude);

bottom = mean( chunk(chunk<averageAmplitude));

topAmp=mean(chunk(top));
peakwidth = length(top );
if (peakwidth>2000)
    disp('peak is super large.   peakparameters.m');
end
roughness = std( chunk(top)/topAmp  );%/averageAmplitude;

peakParams.P_maxAmplitude=max_amplitude-min(chunk(2:end-2));
peakParams.P_averageAmplitude=averageAmplitude-bottom;
peakParams.P_topAverage=topAmp-averageAmplitude;
peakParams.P_peakWidth=peakwidth;
peakParams.P_roughness=roughness;


FFT_Sizen=length(chunk);
if FFT_Sizen<minFFTSize
    FFT_Sizen=minFFTSize;
end

%get the spectrum charactoristics for the logish spectrum
[maxFreq,TotalPowerW,powerspecW,misMatch,tilt]= DenoiseSpecWhole(chunk,chunkempty,256);
%get the spectrum for the linear spectrum
[TotalPower,powerspec]=DenoiseSpec(chunk,chunkempty,FFT_Sizen);

specLength =length(powerspec);

n1=round(specLength/2);
n2=specLength-5;

peakParams.P_totalPower=TotalPower;
peakParams.P_iFFTLow=powerspec(5)+powerspec(6)+powerspec(7);
peakParams.P_iFFTMedium=powerspec(n1)+powerspec(n1+1)+powerspec(n1+2);
peakParams.P_iFFTHigh=powerspec(n2)+powerspec(n2+1)+powerspec(n2+2);

peakParams.P_Even_FFT = sum( powerspec(1:2:specLength));
peakParams.P_Odd_FFT = sum( powerspec(2:2:specLength));
peakParams.P_OddEvenRatio=peakParams.P_Odd_FFT/peakParams.P_Even_FFT;

third = sum(powerspec(1:3:specLength));
halfs = sum( powerspec(1:floor(end/2)) ) / sum( powerspec(floor(end/2):end) ) ;

peakCoef = zeros([nComponents 1]);
indxs = round( specLength * (0: (1/nComponents) :1).^3);
if indxs(1)==0;
    indxs=indxs+1;
end

for iI=2:length(indxs)
    if  indxs(iI)==indxs(iI-1)
        indxs(iI:end)=indxs(iI:end) + 1;
    end
end

indxs(indxs>length(powerspec))=length(powerspec);

cc3=1;

for k=1:nComponents
    try
        peakCoef(cc3) =mean(  powerspec(indxs(k):indxs(k+1) ));
    catch mex
        disp (mex);
    end
    cc3=cc3+1;
end

peakParams.P_peakFFTWhole_TotalPowerW=TotalPowerW;
peakParams.P_peakFFTWhole_maxFreq=maxFreq;
peakParams.P_peakFFTWhole_tilt=tilt;
peakParams.P_peakFFTWhole_misMatch=misMatch;

peakParams.P_peakFFTWhole_Halfs=halfs;
peakParams.P_peakFFTWhole_Third=third;

peakParams.P_Reserved1=0;
peakParams.P_Reserved2=0;
peakParams.P_Reserved3=0;
peakParams.P_Reserved4=0;


peakParams.P_peakFFT_Whole=powerspecW;

peakParams.P_peakFFT=peakCoef;
peakParams.P_highLow_Ratio=peakCoef(round(end*.75))/peakCoef(1);

end