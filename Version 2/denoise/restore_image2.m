% Use ICM to remove the noise from the given image.
% * covar is the known covariance of the Gaussian noise.
% * max_diff is the maximum contribution to the potential
%   of the difference between two neighbouring pixel values.
% * weight_diff is the weighting attached to the component of the potential
%   due to the difference between two neighbouring pixel values.
% * iterations is the number of iterations to perform.

function dst = restore_image2(src, covar, window, max_diff, weight_diff, iterations)

% Maintain two buffer images.
% In alternate iterations, one will be the
% source image, the other the destination.
V_step=covar/80;
max_diff=max_diff*max_diff;
mn=min(src);
src=floor( (src-mn)/V_step );
buffer = zeros(size(src,1), 2);
buffer(:,1) = src;
s = 2;
d = 1;



% This value is guaranteed to be larger than the
% potential of any configuration of pixel values.
V_max = (size(src,1) * size(src,2)) * ...
    ((256)^2 / (2*covar) + 4 * weight_diff * max_diff);

for i = 1 : iterations
    
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
    
    weights = exp(-1*(-window:window).^2/(2*window*.3)^2);
%     figure(2)
%     plot(weights)
    diffs=ones([2 length(src)]) + max_diff;
    maxDiffWindow=zeros([2 length(weights)])+max_diff;
    sumWeights = sum(weights);
    weights=weights./sumWeights;
    
    rangeStep =round(6- ((5/iterations)*i));
   
    
    V_local =1000000;% ones([1 length(src)]) + max_diff;% V_max;
    min_val=src(:);
    lMax=length(src);
    for x=window+1:length(src)-window
        v=src(x);
        W=src( (x-window):(x+window) );
        dW=buffer((x-window):(x+window),s)';
        sV=min([min(W) min(dW)]);eV=max([max(W) max(dW)]);
      
        if (eV-sV>255)
            m=mean(W);
            sV=m-125;
            eV=m+125;
        end
       % rangeStep=2;
        V_local =100000000;
        for val = sV :rangeStep: eV
            % The component of the potential due to the known data.
            V_data = (val - v).^2 ./ (2 * covar);
            maxDiffWindow(2,:)=(val-dW).^2;
            diff= min(maxDiffWindow);
            V_current=V_data + weight_diff *sum( diff.*weights);
            
            if V_current < V_local
                min_val(x) = val;
                V_local = V_current;
            end
        end
    end
    
    if (mod(i,5)==0)
        figure(25);clf;
        plot(src);hold all;plot(min_val);
        drawnow;
    end
    
    buffer(:,d) = min_val;
end


dst = buffer(:,d)*V_step+mn;
