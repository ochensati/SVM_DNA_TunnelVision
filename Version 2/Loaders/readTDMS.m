function [sampleInt, numPoints,alpha, maxVal, numchans] = readTDMS(pathname, fn)  


%There are 3 different 'classes' for a TDMS file
%1) File
%2) Group
%3) Channel
%
% The channels are within a group and all of the groups are within the
% file. Each class has it's own properties. 
tDebug = 0;

filename = [pathname fn];
%These are the file properties we care about

%The size of the chunks of data we are going to rewrite to file
chunkSize = 1e6;
[fid,msg] = fopen(['~$' fn],'w+');
% disp(fid)
% disp(msg)
% disp(filename)
%We're going to keep track of the max value
maxVal = -inf;

important_props_datalogger = {'alpha', 'Num_Signals', 'Num_Sweeps', 'Sample_Rate', 'Sweep_Length'};
important_props_servocontrol = {'Stationary', 'SampleFreq__kHz_'};
%alpha is also a function, so we have to make it clear we want it as a
%variable now
alpha = 0;

%Recreate needed property constants defined in nilibddc_m.h
DDC_FILE_NAME					=	'name';
DDC_FILE_DESCRIPTION			=	'description';
DDC_FILE_TITLE					=	'title';
DDC_FILE_AUTHOR					=	'author';
DDC_FILE_DATETIME				=	'datetime';
DDC_CHANNELGROUP_NAME			=	'name';
DDC_CHANNELGROUP_DESCRIPTION	=	'description';
DDC_CHANNEL_NAME				=	'name';

libname = 'nilibddc';
data = [];
sampleInt = 0;
numEvents = 0;
currentChannel = 0;
voltageChannel = 0;
numPointsTotal = 0;
Num_Signals=0;

% filename = 'S:\home\Brett Gyarfas\Data\Datalogger\TDMS\08Feb2011_014.tdms';

switch computer
    case 'PCWIN'
        DCC_POINTER = 'int32Ptr';
    case 'PCWIN64'
        DCC_POINTER = 'int64Ptr';
end
disp(libname)

%Open the file (Always call 'DDC_CloseFile' when you are finished using a file)
fileIn = 0;
[err,dummyVar,dummyVar,file]=calllib(libname,'DDC_OpenFileEx',filename,'',1,fileIn);

%Get the number of properties for the file
numFPIn = 0;
[err,numFP] = calllib(libname, 'DDC_GetNumFileProperties', file, numFPIn);

%Get all of the property names and values for the file
if err==0
    for i=1:numFP
        numFPIn = 0;
        [err, FPLen] = calllib(libname, 'DDC_GetFilePropertyNameLengthFromIndex',file,i-1, numFPIn);
        pause(.01)
        if err == 0
            pfilename=libpointer('stringPtr',blanks(FPLen));
            [err, FPName] = calllib(libname, 'DDC_GetFilePropertyNameFromIndex', file, i-1, pfilename, FPLen+1);
            %Read and display file name property
            filenamelenIn = 0;
            %Get the length of the 'DDC_FILE_NAME' string property
            FPNameAdj = regexprep(FPName, '\W', '');

            if tDebug == 1
                disp(FPName)
            end
            
            if nnz(strcmp(FPNameAdj, important_props_datalogger)) || nnz(strcmp(FPNameAdj, important_props_servocontrol))
%                 [err,dummyVar,filenamelen]=calllib(libname,'DDC_GetFileStringPropertyLength',file,FPName,filenamelenIn)
                if err==0 %Only proceed if the property is found
                    %Initialize a string to the length of the property value
%                     pfilename=libpointer('stringPtr',blanks(20));
%                     [err,dummyVar,filename]=calllib(libname,'DDC_GetFileProperty',file,FPName,pfilename,filenamelen+1);
                      type = 0;
                      [err, dummyVar, type] = calllib(libname, 'DDC_GetFilePropertyType', file, FPName, type);
    
                      switch type
                          case 'DDC_Double'
                              pfileprop=libpointer('doublePtr',8);
                              pause(0.01);
                              [err,dummyVar,filepropval]=calllib(libname,'DDC_GetFileProperty',file,FPName,pfileprop,8);
                              setdatatype(filepropval,'doublePtr',1,1);
                              eval([regexprep(FPName, '\W', '') '=' 'filepropval.Value;'])
                          case 'DDC_UInt8'
                              pfileprop=libpointer('uint8Ptr',1);
                              pause(0.01);
                              [err,dummyVar,filepropval]=calllib(libname,'DDC_GetFileProperty',file,FPName,pfileprop,1);
                              setdatatype(filepropval,'uint8Ptr',1,1);
                              eval([regexprep(FPName, '\W', '') '=' 'filepropval.Value;'])
                          case 'DDC_String'
                              numFPDIn = 0;
                              [err, dummyVar, FPDataLen] = calllib(libname, 'DDC_GetFileStringPropertyLength', file, FPName, numFPDIn);
                              pfileprop=libpointer('stringPtr',blanks(FPDataLen));
                              pause(0.01)
                              [err,dummyVar,filepropval]=calllib(libname,'DDC_GetFileProperty',file,FPName,pfileprop,FPDataLen+1);
                              setdatatype(filepropval,'int8Ptr',1,FPDataLen);
                              eval([regexprep(FPName, '\W', '') '=' 'str2num(char(filepropval.Value));'])
                      end

                      if tDebug == 1
                          eval(['disp([''' regexprep(FPName, '\W', '') ': '' num2str(' regexprep(FPName, '\W', '') ')])'])
                      end
                end
            end
            clear FPName pfilename
            pause(.01)
        else
            disp('Problem getting propery name length from index')
        end
    end
end

if exist('Stationary','var')
    servocontrol = 1;  %marking whether the data was gather with the servocontrol labview program
    Sample_Rate = SampleFreq__kHz_;
    alpha = 1;
    maxVal = -inf*ones(1,2);
else
    servocontrol = 0;
    if Num_Signals > 1
        maxVal = -inf*ones(1,Num_Signals);
    end
end

%==================
%Get channel groups
%===================
%Get the number of channel groups
numgrpsIn = 0;
[err,numgrps]=calllib(libname,'DDC_GetNumChannelGroups',file,numgrpsIn);
%Get channel groups only if the number of channel groups is greater than zero
if numgrps>0
	%Initialize an array to hold the desired number of groups
    pgrps=libpointer(DCC_POINTER,zeros(1,numgrps));

    [err,grps]=calllib(libname,'DDC_GetChannelGroups',file,pgrps,numgrps);
end    
   
%Iterate through each group, if the file came from the Datalogger then
%there should only be one group.
%For servocontrol files there could be any number greater then 1. All of
%the data will get appended into one file for now.

for k=1:numgrps
    % disp(['numchans: ' num2str(numchans)])

    groupnamelenIn = 0;

    %Getting the name of the group
    [err,dummyVar,groupnamelen]=calllib(libname,'DDC_GetChannelGroupStringPropertyLength',grps(k),DDC_CHANNELGROUP_NAME,groupnamelenIn);
    pgroupname=libpointer('stringPtr',blanks(groupnamelen));
    [err,dummyVar,groupname]=calllib(libname,'DDC_GetChannelGroupProperty',grps(k),DDC_CHANNELGROUP_NAME,pgroupname,groupnamelen+1);
    setdatatype(groupname,'int8Ptr',1,groupnamelen);
    if tDebug == 1
        disp(['DDC_GetChannelGroupProperty: ' char(groupname.Value)])
    end

    %===============
    %Get the properties of the group
    %===============
    numGPIn = 0;
    [err,numGP] = calllib(libname, 'DDC_GetNumChannelGroupProperties', grps(k), numGPIn);

    % disp(['Number of chan grp properties: ' num2str(numGP)])
    if err==0
        for i=1:numGP
            numFPIn = 0;
            [err, GPLen] = calllib(libname, 'DDC_GetChannelGroupPropertyNameLengthFromIndex',grps(k),i-1, numFPIn);
    %         disp(['Length of chan grp properties name ' num2str(i) ': ' num2str(GPLen)])
            pause(.01)
            grppname=libpointer('stringPtr',blanks(GPLen));
            [err, GPName] = calllib(libname, 'DDC_GetChannelGroupPropertyNameFromIndex', grps(k), i-1, grppname, GPLen+1);
            if tDebug == 1
                disp(['Property name for chan grp ' num2str(i) ': ' GPName])
            end
            pause(0.01)
            changroupnamelenIn = 0;
            [err,dummyVar,changroupnamelen]=calllib(libname,'DDC_GetChannelGroupStringPropertyLength',grps(k),GPName,changroupnamelenIn);
            if changroupnamelen ~= 0
                pgroupname=libpointer('stringPtr',blanks(changroupnamelen));
                pause(0.01)
                [err,dummyVar,changrouppropname]=calllib(libname,'DDC_GetChannelGroupProperty',grps(k),GPName,pgroupname,changroupnamelen+1);
                setdatatype(changrouppropname,'int8Ptr',1,changroupnamelen);
                if tDebug == 1
                    disp(['Property ' GPName ': ' char(changrouppropname.Value)])
                end
            end
        end
    end

    %===============
    %Get channels
    %===============
    
    numchansIn = 0;
    %Get the number of channels in this channel group
    [err,numchans]=calllib(libname,'DDC_GetNumChannels',grps(k),numchansIn);
    %Get channels only if the number of channels is greater than zero
    if numchans>0
        %Initialize an array to hold the desired number of channels
        pchans=libpointer(DCC_POINTER,zeros(1,numchans));

        [err,chans]=calllib(libname,'DDC_GetChannels',grps(k),pchans,numchans);
    end

    if servocontrol == 0
        if numchans ~= Num_Signals
            disp('Number of Channels do not match');
        end
    end
    
    %===================
    %Get channel properties
    %===================
    for p=1:numchans
        numCPIn = 0;
        [err,numCP] = calllib(libname, 'DDC_GetNumChannelProperties', chans(p), numCPIn);

        % disp(['Number of chan grp properties: ' num2str(numGP)])
        if err==0
            for i=1:numCP
                numCPIn = 0;
                [err, CPLen] = calllib(libname, 'DDC_GetChannelPropertyNameLengthFromIndex',chans(p),i-1, numCPIn);
                pause(.01)
                crppname=libpointer('stringPtr',blanks(CPLen));
                [err, CPName] = calllib(libname, 'DDC_GetChannelPropertyNameFromIndex', chans(p), i-1, crppname, CPLen+1);
                if tDebug == 1
                    disp(['Property name for chan prop ' num2str(i) ': ' CPName])
                end
                %Get the type of property
                type = 0;
                [err, dummyVar, type] = calllib(libname, 'DDC_GetChannelPropertyType', chans(p), CPName, type);
                if tDebug == 1
                    disp(type)
                end
                
                switch type
                    case 'DDC_Double'
                        pchanprop=libpointer('doublePtr',8);
                        pause(0.01);
                        [err,dummyVar,chanpropval]=calllib(libname,'DDC_GetChannelProperty',chans(p),CPName,pchanprop,8);
                        setdatatype(chanpropval,'doublePtr',1,1);
                        if tDebug == 1
                            disp([CPName ': ' num2str(double(chanpropval.Value))]);
                        end
                    case 'DDC_Int32'
                        pchanprop=libpointer('int32Ptr',4);
                        pause(0.01);
                        [err,dummyVar,chanpropval]=calllib(libname,'DDC_GetChannelProperty',chans(p),CPName,pchanprop,4);
                        setdatatype(chanpropval,'int32Ptr',1,1);
                        if tDebug == 1
                            disp([CPName ': ' num2str(int32(chanpropval.Value))]);
                        end
                    case 'DDC_String'
                        numCPDIn = 0;                      
                        [err, dummyVar, CPDataLen] = calllib(libname, 'DDC_GetChannelStringPropertyLength', chans(p), CPName, numCPDIn);
                        pchanprop=libpointer('stringPtr',blanks(CPDataLen));
                        pause(0.01)
                        if CPDataLen ~= 0
                            [err,dummyVar,chanpropval]=calllib(libname,'DDC_GetChannelProperty',chans(p),CPName,pchanprop,CPDataLen+1);
                            setdatatype(chanpropval,'int8Ptr',1,CPDataLen);
                            if tDebug == 1
                                disp([CPName ': ' char(chanpropval.Value)]);
                            end

                            if strcmp(CPName, 'name') 
                                switch char(chanpropval.Value)
                                    case 'Current'
                                        currentChannel = p;
                                    case {'Voltage', 'Y Piezo'}
                                        voltageChannel = p;
                                end
                            end
                        end
                end   
            end
        end
    end    
    
    %=========================
    %Get values from channel
    %=========================
    
    if currentChannel == 0
        disp('Error: Can''t find the current channel')
    elseif voltageChannel == 0
        numchans = 1;
        chans = chans(currentChannel);
    else
        numchans = 2;
        chans = chans([currentChannel voltageChannel]);
        if ~exist('fidCur','var')
            [fidVol,msg] = fopen(['~$' fn '_vol'],'w+');
            [fidCur,msg] = fopen(['~$' fn '_cur'],'w+');
        end
    end
    
    numvals_max = zeros(1,numchans);
    if numchans > 0
        for j=1:numchans
            numvalsIn = 0;
            [err,numvals]=calllib(libname,'DDC_GetNumDataValues',chans(j),numvalsIn);
            if numvals > numvals_max(j)
                numvals_max(j) = double(numvals);
            end
        end
    end

    % disp('numvals_max')

    % disp(numvals_max)

    numvals_max = min(numvals_max);

    numPointsTotal = numPointsTotal + numvals_max;
    %Calculate how many iterations we will need

    numOfIters = ceil(numvals_max/chunkSize);

    if numchans > 0
        for j=1:numchans
            %Get channel data type
            
            for i=1:numOfIters
                typeIn = 0;
                [err,type]=calllib(libname,'DDC_GetDataType',chans(j),typeIn);
                %Get channel values if data type of channel is double (DDC_Double = 10)
                if strcmp(type,'DDC_Int16')
                    %Initialize an array to hold the desired number of values

                    if i==numOfIters
                        %Last part, need to finish up whats left
                        numOfPointsRemain = numvals_max-(chunkSize*(numOfIters-1));
%                         data = int16(zeros(numOfPointsRemain,1));
                        pvals = libpointer('int16Ptr',zeros(1,numOfPointsRemain));
                        [err,vals]=calllib(libname,'DDC_GetDataValues',chans(j),chunkSize*(i-1),numOfPointsRemain,pvals);
                        setdatatype(vals,'int16Ptr',1,numOfPointsRemain);
                    else
%                         data = int16(zeros(chunkSize,1));
                        pvals=libpointer('int16Ptr',zeros(1,chunkSize));
                        [err,vals]=calllib(libname,'DDC_GetDataValues',chans(j),chunkSize*(i-1),chunkSize,pvals);
                        setdatatype(vals,'int16Ptr',1,chunkSize);
                    end

                    data = (vals.Value);
                    maxVal(j) = max(maxVal(j),max(data));
                    if numchans == 1
                        fwrite(fid,data,'int16');
                    else
                        if j == 1
                            fwrite(fidCur, data, 'int16');
                        else
                            fwrite(fidVol, data, 'int16');
                        end
                    end
                    clear vals data
                end
            end
        end
    end
end

%Combine the two files into one

if exist('fidCur','var')
    frewind(fidCur);
    frewind(fidVol);
    
    while ~feof(fidCur)
        fwrite(fid, fread(fidCur, 1e6, '*int16'), 'int16');
    end
    fclose(fidCur);
    while ~feof(fidVol)
        fwrite(fid, fread(fidVol,1e6, '*int16'), 'int16');
    end
    fclose(fidVol);
    
    pause(0.01);
    
    delete(['~$' fn '_vol']);
    delete(['~$' fn '_cur']);
end
%Convert to pA

sampleInt = (1/(Sample_Rate*1e3))*1e6;
numPoints = numPointsTotal;
alpha = -1*(10000/32768)/alpha;

clear pvals

pause(0.1)
%Close file
err = calllib(libname,'DDC_CloseFile',file);

if err
end
pause(0.1)

fclose(fid);
% unloadlibrary(libname);