%Code to display memory usage every 0.2s
% figH = figure;
%
% tt = timer('TimerFcn', {@plotMemory, figH}, 'Period', .2,...
%     'ExecutionMode', 'fixedSpacing', 'BusyMode', 'drop');
%
% start(tt)


function [RawGroupsInFile]=LoadData(folderPaths, runParams)

homeComputer =0;

switch computer
    case 'PCWIN'
        dlldir = fullfile(pwd,'dlls','bin','32-bit','nilibddc.dll');
        headerdir = fullfile(pwd,'dlls','include','32-bit','nilibddc_m.h');
    case 'PCWIN64'
        %             dlldir = fullfile(pwd,'dlls','bin','64-bit','nilibddc.dll');
        %             headerdir = fullfile(pwd,'dlls','include','64-bit','nilibddc_m.h');
        dlldir = fullfile(pwd,'matlabPeakFinder','dlls','bin','64-bit','nilibddc.dll');
        headerdir = fullfile(pwd,'matlabPeakFinder','dlls','include','64-bit','nilibddc_m.h');
end

disp(dlldir)
disp(headerdir)

if ~libisloaded('nilibddc')
    try
        % loadlibrary(dlldir,headerdir);
        loadlibrary(dlldir, @nilibddc, 'alias', 'nilibddc')
    catch %#ok<CTCH>
        warndlg({'Cannot load libraries to read TDMS files!',...
            'You can continue to use the program but it won''t read TDMS files,',...
            'you probably need to install a compiler in MATLAB.',...
            'Google "MATLAB Selecting a Compiler on Windows Platforms"',...
            'Or Talk to Brett Gyarfas!'},'Error!','modal')
    end
end


%Remove any previous instances of eventDetector_v2 from the path
remain = path; temppath = {}; counter = 1;
while true
    [str, remain] = strtok(remain, pathsep); %#ok<STTOK>
    if isempty(str)
        break
    elseif ~isempty(strfind(str, 'eventDetector_v2'))
        temppath{counter} = str;
        counter = counter + 1;
    end
end

if ~isempty(temppath), rmpath(temppath{:}); end


%this does a little more than just load the trace.  The trace is loaded,
%filtered, 60hz noise is checked, then the trace is broken up into all its
%peaks and clusters and all the peak parameters are assigned.  the trace is
%then disposed for memory reasons.

%%
if (~homeComputer)
    loadWorkSpace = false       ;
    
    disp('===============================')
    disp('LoadDataTraces')
    
    if (loadWorkSpace)
        open('c:\\temp\\workspace.mat');
    else
        
        clear RawGroupsInFile;%=cell([1 size(folderPaths,1)]);
        RawGroupsInFile=[]
        cc=1;
        
        neededFolders =[];
        
        for I=1:size(folderPaths,1)
            filename =  strcat( folderPaths{I,2} ,'\groupDescip.mat');
            
            if exist(filename, 'file')
                
                group = open( filename );
                group=group.group;
                params = group.params;
                if SameParams(params, runParams)==true
                    group.params=[];
                    RawGroupsInFile{cc}=group;
                    cc=cc+1;
                else
                    neededFolders = vertcat(neededFolders, folderPaths{I,:});
                end
                
            else
                if (isempty(neededFolders))
                    for J=1:size(folderPaths,2)
                        neededFolders{1,J} = folderPaths{I,J};
                    end
                    cc=cc+1;
                else
                    for J=1:size(folderPaths,2)
                        neededFolders{cc,J} = folderPaths{I,J};
                    end
                    cc  =cc+1;
                end
            end
        end
        
        otherGroups =  LoadDataTraces(neededFolders, runParams);
        
        RawGroupsInFile = vertcat(RawGroupsInFile,otherGroups);
        
        for I=1:length(RawGroupsInFile)
            group=RawGroupsInFile{I};
            group.params = runParams;
            save(strcat( group.FilePath ,'\groupDescip.mat'),'group','-v7.3');
        end
        
        clear group;
        
        disp('===============================')
        disp('Saving workspace for later retrieval');
        save('c:\\temp\\workspace.mat');
    end
end
end