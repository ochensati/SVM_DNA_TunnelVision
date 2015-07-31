function  [canvas,plotParams]=PlotConsensusGraph(trace, allStarts,allEnds,canvas,plotParams,saveFile,filename)

lCheck = allEnds-allStarts;
if (isempty(canvas)==true)
    m=500;%
    h=250;
    powerScale = 1%/3;
    w = floor((mean(lCheck)+ 9*std(lCheck)+500)^powerScale);
    
    minT=0;%min(trace);
    maxT=1.4;%max(trace);
    d=.1*(maxT-minT);
    
    
    minT=minT-d;
    cH=(h-1)/ ((d+ maxT) - minT);
    cW= (m-20.0)/ w;
    canvas = zeros([h m]);
    m=m-1;
    
    if (isempty(plotParams))
        plotParams.cH=cH;
        plotParams.cW=cW;
        plotParams.minT=minT;
        plotParams.maxT=maxT;
        plotParams.w=w;
        plotParams.d=d;
        plotParams.m=m;
        plotParams.h=h;
        plotParams.powerScale = powerScale;
        plotParams.step = 1;
    else
        if ( plotParams.w<w)
            plotParams.cH=cH;
            plotParams.cW=cW;
            plotParams.minT=minT;
            plotParams.maxT=maxT;
            plotParams.w=w;
            plotParams.d=d;
            plotParams.m=m;
            plotParams.h=h;
            plotParams.powerScale = powerScale;
            plotParams.step = 1;
        end
    end
end
try
    %                                     figure(4);clf;
    %                                     for I=1:length(allStarts)
    %                                         L=allEnds(I)-allStarts(I)+305;
    %                                         M=min([allStarts(I)+L length(trace)]);
    %                                         MM=max([1 allStarts(I)-100]);
    %                                         t=floor(cH* ( trace(MM:M) -minT))+1;
    %                                         plot(t);
    %                                         hold all;
    %                                     end
    
    %  figure(65);clf;hold all;
    padding = 100;
    for I=1:length(allStarts)
        L=floor(allEnds(I)-allStarts(I) + padding);% + min([2000 .1* plotParams.w]));
        M=min([ (allStarts(I)+L) length(trace)]);
        %MM=floor(max([1 allStarts(I)-min([1000 .05* plotParams.w])]));
        MM=floor(max([1 allStarts(I)]));
        
         L=floor(allEnds(I)-allStarts(I));
        
        t= trace(MM:M) ;
        
        tf=mean(t(1:min([400 length(t)])));% mean(t(end-40:end))]);
        tf=mean(t(t<tf*.5));
         t=t-tf;
        t=floor(plotParams.cH* (t - plotParams.minT))+1;
        
        %     plot(t);
        
       % if (abs( length(t) -plotParams.w)<1000)
            %X=floor((1:length(t)).^ plotParams.powerScale * plotParams.cW )+1;
            width = plotParams.m-150;
            X= floor(((1:length(t)) ) * width /L+75);
            %X =floor( X./max(X) * plotParams.m);
            p = floor( 75*L/width);
            MM2 = floor(max([ 1 allStarts(I)-p]));
            t2 = trace(MM2:MM);
            t2=floor(plotParams.cH* (t2 - plotParams.minT))+1;
            X= [floor(((1:length(t2)) ) * width /L), X];
            t=vertcat(t2, t);
            idx=find(X> plotParams.m);
            
            X(idx)=[];
            t(idx)=[];
            
            idx=(find(X<1));
            X(idx)=[];
            t(idx)=[];
  
            
            t= plotParams.h-t;
            
            idx=(find(t<1));
            X(idx)=[];
            t(idx)=[];
            
            idx=(find(t> plotParams.h));
            X(idx)=[];
            t(idx)=[];
            
            
            step=plotParams.step;%floor((1/cW)/2);
            if (step<1)
                step=1;
            end
            try 
            for J=1:step:length(X)
                canvas(t(J),X(J))=canvas(t(J),X(J))+1;
            end
            catch mex
            end
       % end
    end
catch mex
    dispError(mex)
end

canvas2 =(canvas+1).^.15;
canvas2=255*(canvas2- min(canvas2(:)))./(max(canvas2(:))- min(canvas2(:)));
im=uint8(zeros([size(canvas2,1) size(canvas2,2) 3]));
im(:,:,1)=255-round(canvas2);
im(:,:,2)=255-round(canvas2 );%$* (.25 + .75*(1-k/maxFiles)));
im(:,:,3)=255-round(canvas2);%* (.25 + .75*(1-k/maxFiles)));

figure(67);
clf;
imshow(im)%, 'YData', [minT maxT]);
drawnow;

if (saveFile)
    %filename = ['c:\temp\wanunugraphs' '\typical____'  dname num2str(k) '.jpg'];
    try 
    saveas(67,filename);
    catch mex 
        
    end
end


end