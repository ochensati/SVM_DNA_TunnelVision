function [allStarts  allEnds]=FixedJunctionFinder( trace,  runParameters )

chunkSize =500;

idx=1:chunkSize:length(trace);

goodIDX=zeros(size(idx));

cc=1;

for I=1:length(idx)-1
    chunk=trace(idx(I):idx(I)+chunkSize);
    v=var(chunk);
    
   % if (v>1)
        goodIDX(cc)=idx(I);
        cc=cc+1;
   % end 
end

allStarts = goodIDX(1:cc-1);
allEnds = allStarts+chunkSize;


end