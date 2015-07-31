skipSize=1;
figure(2);clf;
% plot(Xrinse/20000/60,rinses,'b');
hold all;
for K=2:size(FileDatas,1)
    for J=1:size(FileDatas,2)
        
        shortData=FileRinsesRaw{K,J}';
        
        if isempty(shortData)==false
            x=  FileRinsesX{K,J};
            plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
        else
            shortDataT=FileDatas{K,J}';
            shortData=Raws{K,J}';
            if isempty(shortData)==false
                x=  FileXs{K,J};
                try 
                x=x(1:length(shortDataT));
                shortData=shortData(1:length(shortDataT));
                catch mex
                    
                end
              
                plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),colors{K});
              
            end
        end
    end
end
% 
% skipSize=1;
% if exist('FileDatas','var')==true
%     for K=1:size(FileDatas,1)
%         for J=1:size(FileDatas,2)
%             shortData=FileRinsesRaw{K,J}';
%             if isempty(shortData)==false
%                 x=  FileRinsesX{K,J};
%                 %plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'k');
%             else
%                 shortData=FileDatas{K,J}'+J*250;
%                 if isempty(shortData)==false
%                     x=  FileXs{K,J};
%                     
%                     if length(x)>length(shortData)
%                         x=x(1:length(shortData));
%                     else
%                         if length(shortData)>length(x)
%                             x=x(1) + (1:length(shortData));
%                         end
%                     end
%                     plot(x(1:skipSize:end)/20000/60,shortData(1:skipSize:end),'g');
%                 end
%             end
%         end
%     end
% end
