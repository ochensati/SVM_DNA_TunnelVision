function [ shortData , assignment ] = LoadAndFilterDat(pathname, filename, peakSelectParams )


if (peakSelectParams.lowPass_Freq~=-1)
    FpV=peakSelectParams.lowPass_Freq/50000;
    FstV=(peakSelectParams.lowPass_Freq+500)/50000;
    D = fdesign.lowpass('Fp,Fst,Ap,Ast',FpV,FstV,1,60);
    Hd = design(D,'equiripple','StopBandShape','linear','StopBandDecay',20);
    fc=5;% cut off frequency
    fn=50000/2; %nyquivst frequency = sample frequency/2;
    order = 2; %6th order filter, high pass
    [b14, a14]=butter(order,(fc/fn),'high'); %#ok<ASGLU>
end


assignment=0;
fn =  filename;

disp('-------')
disp('readTDMS')
disp('-------')

%  if exist(['~$' fn],'file')==0
if (isempty(findstr([pathname '\\' fn],'abf'))==false) %#ok<*FSTR>
    
    file= [pathname '\' fn];
    disp(file);
    [shortData] = abfload(file,'start',0);
    shortData = shortData(:,1);
    shortData = shortData(end*.1:end);
    %convert it to pA and clean off background
    shortData =( shortData - mean(shortData))/1000;
    x=1:200:length(shortData);
    p=polyfit(x',shortData(x),1);
    shortData =-1.*(shortData- polyval(p,1:length(shortData))');

    return;
else
    if (isempty(findstr([pathname '\\' fn],'.dat'))==false)
        
        file= [pathname '\' fn];
        disp(file);
        fid = fopen(file,'r');
        %formatted for chimera output
        if findstr(fn,'orig')
            C_data0 = textscan(fid,'%f %f %f %f %f');
            shortData =C_data0{5};
        else
           % C_data0 = textscan(fid,'%f %f %s %s %f %f %f');
            C_data0 = textscan(fid,'%f %f %f %f %f %f %s');
            shortData =C_data0{6};
            assignment=C_data0{7};
        end
        fclose(fid);

        return;
    else
        if (isempty(findstr([pathname '\\' fn],'.csv'))==false)
            
            file= [pathname '\' fn];
            disp(file);
            fid = fopen(file,'r');
            tline = fgets(fid); %#ok<NASGU>
            C_data0 = textscan(fid,'%f');
            shortData =C_data0{1};
         
            fclose(fid);
            figure(1);
           
            s=std(shortData);
            
            baseline = mean( shortData);
            
            baseline = mean(shortData(shortData<(baseline+s/2)));
            
            shortData = shortData -baseline;

            return;
        else
             if (isempty(findstr([pathname '\\' fn],'.mat'))==false)
                  temp =load([pathname '\\' fn]);
                  
                  t=fieldnames(temp);
                  if (strcmp( t{1},'MATdata'))
                      shortData = -1*(temp.MATdata);
                  else
                      shortData = -1* temp.(t{1});
                  end
                  
                  return;
             else
                 fle = [pathname '/'];
                 fle=strrep(fle,'/','\');
                     [shortData] = readTDMS2([fle ], fn);
             end
        end
    end
    
    
end



index = find(shortData<-.05 );

for K=length(index):-1:1
    try
        startIndex =index(K)-4000;
        shortData(startIndex:index(K)+4000)=-1000;
    catch me %#ok<NASGU>
    end
end

index = find(shortData>.5 );

for K=length(index):-1:1
    try
        shortData(index(K)-4000:index(K)+10000)=-1000;
    catch me %#ok<NASGU>
    end
end

index = find(shortData==-1000 );

if (length(index)/length(shortData))>.05
    shortData=[];
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

