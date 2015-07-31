% Use ICM to remove the noise from the given image.
% * covar is the known covariance of the Gaussian noise.
% * max_diff is the maximum contribution to the potential
%   of the difference between two neighbouring pixel values.
% * weight_diff is the weighting attached to the component of the potential
%   due to the difference between two neighbouring pixel values.
% * iterations is the number of iterations to perform.

function [src,dst, levels, classes] = restore_imageVGMM4(src, covar, window, max_diff, weight_diff, iterations)


[src,levels]=Removeback(src,2);
t.m=mean(src);
t.s=std(src);
levels{1}=t;

% Maintain two buffer images.
% In alternate iterations, one will be the
% source image, the other the destination.
%V_step=1;
max_diff=max_diff*max_diff;
%mn=min(src);
%src=floor( (src-mn)/V_step );
buffer = zeros(size(src,1), 2);
buffer(:,1) = src;
s = 2;
d = 1;
classes=zeros(size(src));

%Untitled;

cc=1;
mu=[];
su=[];
tLevels={};
for I=1:length(levels)
    tt=levels{I};
    if (tt.s~=0)
        tLevels{cc}=tt;
        mu(cc)=tt.m;
        su(cc)=tt.s;
        cc=cc+1;
    end
end

maxSu = mean(su);

levels=tLevels;

%if (length(levels)>1)
mu1=mu(:);

mu=sort(mu);
s=max(su);
d=.3;%2*s;%4*abs(mu(1)-mu(2));

mX=min(src);
MX=max(src);
l=MX-mX;
n=floor(l/d);
try 
 levels=cell([1 n]);
catch mex
   disp(mex); 
end
for I=1:n
    t.m=I*d+mX;
    t.s=s;
    levels{I}=t;
end
%end

tLevels ={};
ctL=1;
for I=1:length(levels)
    t=abs(src-levels{I}.m )/levels{I}.s;
    if length(find(t<1))>length(src)*.005
        tLevels{ctL}=levels{I};
        ctL=ctL+1;
    end
end

levels=tLevels;

% This value is guaranteed to be larger than the
% potential of any configuration of pixel values.
V_max = (size(src,1) * size(src,2)) * ...
    ((256)^2 / (2*covar) + 4 * weight_diff * max_diff);

alpha=0;

gap = .1;
weights = exp(-1*(-window:window).^2/(2*window*.3)^2);
    %     figure(2)
    %     plot(weights)
    sumWeights = sum(weights);
    weights=weights./sumWeights;
    
for i = 1 : iterations
    
    alpha = (1 - (iterations-i)/iterations) * (1-2*gap) + gap;
    % Switch source and destination buffers.
    if s == 1
        s = 2;
        d = 1;
    else
        s = 1;
        d = 2;
    end
    
    % Vary each pixel individually to find the
    % values that minimise the local potentials.
    
    
    
    min_val=src(:);
    tCurrents=zeros([1 length(src)])+max_diff^2;
    last=buffer(:,s);
    
    for JJ=1:length(levels)%val = sV :rangeStep: eV
        tt=levels{JJ};
        val=tt.m;
        covar = tt.s^2/2;
        V_data = (val - src).^2 ./ (2 * covar);
        maxDiffWindow2=(val-last).^2./ (2 * covar);
        maxDiffWindow2(maxDiffWindow2>max_diff)=max_diff;
        w=conv(maxDiffWindow2,weights,'same');
        lLocals=V_data + weight_diff *w;
        for x=1:length(src)
            if lLocals(x)<tCurrents(x)
                tCurrents(x)=lLocals(x);
                min_val(x)=val;
                classes(x)=JJ;
            end
        end
    end
    
    min_val= min_val * alpha + src*(1-alpha);
    
    
    if (mod(i,5)==0 || i==iterations)
        figure(25);clf;
        plot(src);hold all;plot(min_val);
        drawnow;
    end
    
    disp(i);
    % if (mod(i,3)==0 || i==1)
    if i<iterations
        tLevels={};
        cc_tL=1;
        mu=[];
        su=[];
        pu=[];
        for JJ=1:length(levels)
            idx = find(classes==JJ);
            if (isempty(idx)==false) 
                if length(idx)>100
                tt=levels{JJ};
                tt.m=mean(src(idx));
                tt.s=std(src(idx));
                mu(cc_tL)=tt.m;
                su(cc_tL)=tt.s;
                pu(cc_tL)=length(idx);
                tLevels{cc_tL}=tt; %#ok<AGROW>
                cc_tL=cc_tL+1;
                end
            end
        end
        [ mu idx]=sort(mu);
        su=su(idx);
        tLevels=tLevels(idx);
        
       // su(su>maxSu)=maxSu;
        dmu=abs(mu(2:end)-mu(1:end-1))./su(1:end-1);
        
        idx = find(dmu<.5);%.5 previous to vgmm7
        idx2=randperm(length(idx));
        idx=idx(idx2);
        
        tLevels(idx)=[];
        
        levels=tLevels;
    end
    
    buffer(:,d) = min_val;
end


dst = buffer(:,d);
