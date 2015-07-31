function [ shortData  ] = LoadAndFilter(pathname, filename, peakSelectParams )
%LOADANDFILTER Summary of this function goes here
%   Detailed explanation goes here

if (peakSelectParams.lowPass_Freq~=-1)
    FpV=peakSelectParams.lowPass_Freq/50000;
    FstV=(peakSelectParams.lowPass_Freq+500)/50000;
    D = fdesign.lowpass('Fp,Fst,Ap,Ast',FpV,FstV,1,60);
    Hd = design(D,'equiripple','StopBandShape','linear','StopBandDecay',20);
    fc=5;% cut off frequency
    fn=50000/2; %nyquivst frequency = sample frequency/2;
    order = 2; %6th order filter, high pass
    [b14 a14]=butter(order,(fc/fn),'high');
end



fn =  filename;

disp('-------')
disp('readTDMS')
disp('-------')

%  if exist(['~$' fn],'file')==0
if (isempty(findstr([pathname '\\' fn],'abf'))==false)
    
    file= [pathname '\' fn]
    
    [shortData] = abfload(file,'start',0);
    shortData = shortData(:,1);
    shortData = shortData(end*.1:end);
    %convert it to pA and clean off background
%     shortData =( shortData - mean(shortData))/1000;
%     x=1:200:length(shortData);
%     p=polyfit(x',shortData(x),1);
%     shortData =-1.*(shortData- polyval(p,1:length(shortData))');
%     figure(1);
%     plot(shortData);
    return;
else
    if (isempty(findstr([pathname '\\' fn],'.dat'))==false)
        
        file= [pathname '\' fn]
        
        fid = fopen(file,'r');
        
        if findstr(fn,'orig')
            C_data0 = textscan(fid,'%f %f %f %f %f');
            shortData =C_data0{5};
        else
            C_data0 = textscan(fid,'%f %f %s %s %f %f %f');
            shortData =C_data0{7};
        end
        fclose(fid);
        figure(1);
        plot(shortData);
        return;
    else
        [shortData] = readTDMS2([pathname '\\'], fn);
    end
end

%fid = fopen(['~$' fn],'r');
%data = fread(fid,'*int16');
%fclose(fid);
%data = cast(data(10:(length(data)/2)),'double');

%shortData =-0.00030517578125.*data;

index = find(shortData<-.05 );

for K=length(index):-1:1
    try
        startIndex =index(K)-4000;
        shortData(startIndex:index(K)+4000)=-1000;
    catch me
    end
end

index = find(shortData>.5 );

for K=length(index):-1:1
    try
        shortData(index(K)-4000:index(K)+10000)=-1000;
    catch me
    end
end

index = find(shortData==-1000 );

if (length(index)/length(shortData))>.05
    shortData=[]
    return
end

shortData(index)=[];
clear data

if (peakSelectParams.lowPass_Freq~=-1)
    %filter off the freq above the amplifier.
    disp('filter')
    shortData=filter(Hd,shortData);
end

%disp('filtfilt')
% shortData=filtfilt(b14,a14,shortData);

testTrace=shortData(1:length(shortData)-2);
ave= sum(testTrace)/length(testTrace);
stdev=std(testTrace)*2;
for I=1:5
    sumTrace=0;
    count =0;
    for J=1:50:length(testTrace)
        if ( abs( testTrace(J)-ave)<stdev)
            sumTrace =sumTrace+testTrace(J);
            count = count +1;
        end
    end
    ave2 = sumTrace/count;
    sumTrace=0;
    for J=1:50:length(testTrace)
        if ( abs( testTrace(J)-ave)<stdev)
            sumTrace =sumTrace+  (testTrace(J)-ave2)*(testTrace(J)-ave2);
            count = count +1;
        end
    end
    ave = ave2;
    stdev= (sumTrace/(count-1))^.5*2;
end

shortData = (shortData - ave)';
end

