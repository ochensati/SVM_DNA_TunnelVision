%must use loadDNAChannels to get the relivent data 
colors={[0 0 0], [1 0 0], [0 1 0], [0 0 1], [1 1 0], [0 1 1], [1 0 1], ...
    [.5 0 0],[0 .5 0], [0 0 .5], [.5 .5 0], [0 .5 .5], [.5 0 .5], ...
    [.5 .5 .5], [.5 0 1], [0 .5 1], [1 0 .5], [.5 .5 1], [1 .5 .5], [.5 1 .5], ...
    [0 0 0], [1 0 0], [0 1 0], [0 0 1], [1 1 0], [0 1 1], [1 0 1], ...
    [.5 0 0],[0 .5 0], [0 0 .5], [.5 .5 0], [0 .5 .5], [.5 0 .5], ...
    [.5 .5 .5], [.5 0 1], [0 .5 1], [1 0 .5], [.5 .5 1], [1 .5 .5], [.5 1 .5]};



if (true)
    %     clear bestRun
    %     clear infos;
    %     bestSIL=0;
    %     bestSamples =0;
    %     bestK =0;
    
%     emptyTrace = shortData( floor(40/480*end): floor(160/480*end))';
%     trace = shortData( floor(295/480*end): end)';
%     trace2 = trace -mean(trace);%- smooth(trace, 30*1024);
    
    emptyTrace = shortData( shortData>1.8);
    trace = shortData( 1:end);
    trace2 = trace -mean(trace);%- smooth(trace, 30*1024);
    
%     trace=trace(1:floor(end/10));
%     trace2=trace2(1:length(trace));
%     
    %turn the trace into a kmeans classified set of chunks
    % silhouette is used to optimize the step size of the traces
    step=150; %150 seems to work great, score of .79 with k =7
    [trace,trace2,trace3,colNames2,score,ident,bestSIL,infos]=  ParamAndOptimize(emptyTrace,trace,trace2,step,50,step,7,7);
    
    lCol = ident+2;
    lCol2 = colors(lCol);
    
    xIDX = 1:size(score,1);
    
    
    cut=25;
    convert = floor( length(ident)/3);% 5*floor(42e5* length(xIDX)/length(trace));
   
    sampled = ident(1:convert);
    cc=1;
    X=(1:length(trace3));
    
    figure(11);clf;hold all; xlabel('time (s)');ylabel('Tunnel Current (pA)');
    oTrace = zeros(size(sampled));
    for J=1:length(sampled)
        I=J*step;
        x = X(I:min([I+step-1 length(trace3)]));
        chunk=trace3(I:min([I+step-1 length(trace3)]));
      
        plot(x,chunk,'color',lCol2{cc});
        oTrace(cc)=mean(shortData(I:min([I+step-1 length(trace3)])));
        cc=cc+1;
    end
    
    %find the bursts from the kmeans labeled chunks
    state = zeros(size(sampled))+1;
    state(oTrace<1.2)=2;
  
    
    figure(12);clf
    [eTR,eE] = hmmestimate(sampled,state);
    %[eTR,eE] = hmmtrain(ident,eTR,eE);
    likelystates = hmmviterbi(ident, eTR, eE);
    plot(likelystates)
    
    
    % make a pretty graph of the bursts for evaluation
    lCol=likelystates+2;
    lCol2 = colors(lCol);
    
    figure(91);clf;hold all; xlabel('time (s)');ylabel('Tunnel Current (pA)');
    cc=1;
    trace3=smooth(trace,30);
    X=(1:length(trace3))/20000;
    for I=1:step:length(trace3)
        x = X(I:min([I+step-1 length(trace3)]));
        chunk=trace3(I:min([I+step-1 length(trace3)]));
        plot(x(1:20:end),chunk(1:20:end),'color',lCol2{cc});
        %drawnow;
        cc=cc+1;
    end
    drawnow;
end

if (true)
    %cut out only the burst states
    idxS=find(likelystates ==2);
    didx=idxS(2:end)-idxS(1:end-1);
    idx=find(didx~=1);
    starts = [1 (idx+1)]*step;
    ends = [idx length(idxS)]*step;
    idx=idxS*step;
    cuts = cell(size(starts));
    for I=1:length(starts)
        
        cuts{I}.trace = trace(starts(I):ends(I));
    end
    
    [newTraces]= resampleAndTemplateMatch(cuts);
    %using best traces
    %     cc=1;
    %     for I=1: length(idx)-2
    %         traces(cc:cc+step-1)= trace(idx(I):min([length(trace) idx(I)+step-1]));
    %         cc=cc+step;
    %     end
    
    traces=[];
    starts =zeros(size(newTraces));
    for I=1:length(newTraces)
        starts(I) = length(traces+1);
        traces= [traces newTraces{I}.bestTrace']; %#ok<AGROW>
        ends(I) = length(traces);
    end
    
    traces=traces';
    figure(92);
    plot(traces)
    
    trace2 = traces -mean(traces);%- smooth(trace, 30*1024);
    %now find the breaking of the bursts that produces the best seperation
    [traceT,trace2,trace3,colNames2,score2,ident2,bestSIL,infos]=  ParamAndOptimize(emptyTrace,traces,trace2,60,35,200,8,8);
    xIDX = 1:size(score2,1);
    [traceT,trace2,trace3,colNames2,score2,ident2,bestSIL2,infos]=  ParamAndOptimize(emptyTrace,traces,trace2,bestSIL.Samples,1,bestSIL.Samples,bestSIL.K,bestSIL.K);
end


bStep =bestSIL2.Samples;
iStarts = floor(starts./bStep)+1;
iEnds = floor(ends./bStep);

newTraces2 =newTraces(1:end);
for I=1:length(starts)
    
    newTraces{I}.ident = ident2(iStarts(I): min([iEnds(I) length(ident2)])); %#ok<SAGROW>
    newTraces2{I}.trace = ident2(iStarts(I): min([iEnds(I) length(ident2)])); %#ok<SAGROW>
end


figure(26);clf;hold all;
for I=1:length(newTraces)
    [newTraces3]= resampleAndTemplateMatch(newTraces2, I);
    plot(newTraces3{I}.trace);
    m=0;
    for J=1:length(newTraces)
        m=m+newTraces3{J}.matchCoef;
    end
    coeffs(I)=m/length(newTraces) ;
end
drawnow;

comparison = sum(coeffs)/length(newTraces);

iComp = zeros([1 length(newTraces)]);
available = 1:max(ident2);

I=0;
while (length(available)>0)
    I=I+1;
    baseIdent = available(1);
    coeffsIdent=[];
    for J=2:length(available)
        checkIdent = available(J);
        newTraces3=newTraces2(1:end);
        for K=1:length(newTraces2)
            newTraces3{K}.trace(newTraces3{K}.trace==checkIdent)=baseIdent;
        end
        
        m=0;
        for K=1:length(newTraces3)
            [newTraces3]= resampleAndTemplateMatch(newTraces3, K);
            
            for K2=1:length(newTraces)
                m=m+newTraces3{K2}.matchCoef;
                if (K~=K2)
                    iComp(K2)=iComp(K2) + newTraces3{K2}.matchCoef;
                end
            end
        end
        coeffsIdent(J)=m/length(newTraces)/length(newTraces) ; %#ok<SAGROW>
    end
    [v,idx]=max(coeffsIdent);
    comparison=[comparison v]; %#ok<AGROW>
    checkIdent = available(idx);
    t.coeffs=coeffsIdent;
    t.mCoeff = v;
    t.pair=[baseIdent,checkIdent];
    pairs{I}=t; %#ok<SAGROW>
    for K=1:length(newTraces2)
        newTraces2{K}.trace(newTraces2{K}.trace==checkIdent)=baseIdent;
    end
    [newTraces3]= resampleAndTemplateMatch(newTraces2);
    
    available(available==checkIdent)=[];
    available(available==baseIdent)=[];
    
    figure(28);clf;hold all;
    minT=1000000;
    for K=1:length(newTraces3)
        t= newTraces3{K}.trace;
        if (length(t)<minT)
            minT = length(t);
        end
        plot(smooth(t),'.');
    end
    
    mTrace = zeros([1 minT]);
    for K=1:length(newTraces3)
        t= newTraces3{K}.trace*iComp(K);
        mTrace = mTrace+t(1:minT);
    end
    mTrace=mTrace/sum(iComp) ;
    
    plot(mTrace,'k');
    
    drawnow;
end


% a=1
% g=2
% c=3
% t=4
% 
% seq =cctcgcatgactcaactgcctggtgat
seq =[3 3 4 3 2 3 1 4 2 1 3 4 3 1 1 3 4 2 3 3 4 2 2 4 2 1 4];

seqPos=  perms(1:4)+10;

seq2=zeros([size(seqPos,1) length(seq)]);
for I=1:size(seqPos,1)
   v=seqPos(I,:);
   s2=seq(:);
   for J=1:length(v)
       s2(s2==J)=v(J);
   end
   seq2(I,:)=s2-10;
end


mTrace=mTrace-mean(mTrace);
mTrace(1:3)=0;
mTrace(end-3:end)=0;

idx=[];
fTrace=fft(mTrace);
fTrace=conj(fTrace(1:floor(end/2)));
for I=1:size(seq2,1)
   v=seq2(I,:);
   v=v-mean(v);
   v=resample(v,length(mTrace),length(v));
   fV=fft(v);
   fV=fV(1:floor(end/2));
   m=real( ifft( fV.* fTrace) );
   [m2(I), idx(I)] = max( m); %#ok<SAGROW>
end

[~,I]=max(m2);
shift = idx(I);
v=seq2(I,:);
v=v-mean(v);

v=resample(v,length(mTrace),length(v));

if shift>0
    v=v(shift:end);
else
    v=[zeros([1 shift]) v];
end

figure(30);clf;hold all;

mTrace2 = 5*(mTrace-min(mTrace))/(max(mTrace)-min(mTrace))+1;

plot(smooth(mTrace2) - min(mTrace2)+1);

plot(v - min(v)+1);

[~,I]=max(m2);
shift = 15;
%v=seq2(I,:);


v= zeros(size(mTrace));
sT = floor(length(v)/length(seq2))-1;
cc=1;
for I=1:length(seq2)
   v(cc:cc+sT )=seq2(I) ;
   cc=cc+sT+1;
end

%v=resample(v,length(mTrace),length(v));

if shift>0
    v=v(shift:end);
else
    v=[zeros([1 shift]) v];
end

figure(30);clf;hold all;

mTrace2 = 5*(mTrace-min(mTrace))/(max(mTrace)-min(mTrace))+1;

plot((smooth(mTrace2,3) - min(mTrace2))*1.2-1.1);

x=1:length(v);

xx1=[0 2 8  20 31 38 50 68 86 92 103 115 121 127 141 145 160];
yy=[0 5 11 22 31 38 53 71 86 94 100 117 121 127 134 141 160];





xx = spline(xx1,yy,x);
yy2= spline(yy,xx1,x);
    %xx=x;
plot(xx,v );

xx3 = ceil(yy2(1:end-4));
xx3(xx3>length(v))=length(v);
timeSeq = v( xx3 );
plot(timeSeq);

figure(15);clf;hold all
plot(xx1,yy);
plot(xx1,xx1);

rTemplate = (timeSeq-mean(timeSeq))/std(timeSeq);
template = conj( fft(rTemplate) );
figure(8);clf;hold all;
 plot(rTemplate);
for I=1:length(newTraces3) 
     t=newTraces3{I}.trace;
     sI=10;%floor(length(t)*.05);
     t=t(sI:(sI+length(rTemplate)));
     t2 = (t-mean(t))/std(t);
     
     fT = real(ifft(template.* fft(t2(1:length(template)))));
     [m,shift ]=max(fT);

     clf;plot(t);hold all;plot(rTemplate)
     if (shift>0)
         t = t(abs(shift):end);
     else
         shift = abs(shift);
         t= [ (zeros([1 shift])+ mean(t))  t(end-shift)];
     end
     plot(t );
     
     drawnow;
     
     if I==1
         newMTrace = zeros(size( rTemplate));
         s = zeros(size( rTemplate));
         newMTrace(1:length(t)) = t(1:end) * m;
         s(1:length(t))= m;
     else
         newMTrace(1:length(t)) =newMTrace(1:length(t))+ t(1:end) * m;
         s(1:length(t))=s(1:length(t))+ m;
     end
end

s(s==0)=1;

newMTrace2= newMTrace(1:end-10)./s(1:end-10);

figure(7)
plot( (newMTrace2-mean(newMTrace2)) / std(newMTrace2));hold all
plot(rTemplate);
