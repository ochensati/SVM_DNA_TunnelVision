function [files]=GetRecursiveFiles(path)
folders = dir(path);
files={};
cc=1;
for I=1:length(folders)
    if (strcmp(folders(I).name,'.')==false) && (strcmp(folders(I).name,'..')==false)
        if (folders(I).isdir)
            tFiles = GetRecursiveFiles([path '\' folders(I).name]);
            files=horzcat(files,tFiles);
            cc=length(files)+1;
        else
            t.path=path;
            t.name = folders(I).name;
            files{cc}=t;
            cc=cc+1;
        end
    end
end