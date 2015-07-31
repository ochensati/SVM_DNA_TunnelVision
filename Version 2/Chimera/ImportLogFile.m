%% Import One Log File

function [logdata, samplerate, filename]=ImportLogFile(address, LPfiltercutoff, outputsamplerate)

if(strcmp(address,'gui') || strcmp(address,'GUI'))
    [filename, pathname, filterindex]=uigetfile('*.log', 'pick log files','MultiSelect','on');
    [~, name, ~]=fileparts(filename);
    datafilename=[pathname, name, '.log'];
    matfilename=[pathname, name, '.mat'];
else
    [a, filename, c]=fileparts(address);
    datafilename=[a, filesep, filename, '.log'];
    matfilename=[a, filesep, filename, '.mat'];
end

load(matfilename);
samplerate = ADCSAMPLERATE;
TIAgain = SETUP_TIAgain;
preADCgain = SETUP_preADCgain;
currentoffset = SETUP_pAoffset;
voltageoffset = SETUP_mVoffset;
ADCvref = SETUP_ADCVREF;
ADCbits = SETUP_ADCBITS;
closedloop_gain = TIAgain*preADCgain;
readfid = fopen(datafilename,'r');

bitmask = (2^16 - 1) - (2^(16-ADCbits) - 1);
rawvalues = fread(readfid,'uint16');
readvalues = bitand(cast(rawvalues,'uint16'),uint16(bitmask));
logdata = -ADCvref + (2*ADCvref) * double(readvalues) / 2^16;
      
logdata = -logdata./closedloop_gain + currentoffset;

fclose(readfid);


return;

filterorder = floor(samplerate/LPfiltercutoff*16);      % EDITED 8/15/2012
myLPfilter = fir1(filterorder, LPfiltercutoff/(0.5*samplerate), 'low');
logdata = -1e9*filtfilt(myLPfilter,1,logdata);

if(outputsamplerate~=0)  
    [P,Q] = rat(outputsamplerate/samplerate,0.02);
    samplerate=samplerate*P/Q*1e-3;   
    logdata = resample(logdata,P,Q,0);  
    logdata = logdata(filterorder:(length(logdata)-filterorder));   
end

end