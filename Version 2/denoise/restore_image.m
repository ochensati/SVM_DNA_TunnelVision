% Use ICM to remove the noise from the given image.
% * covar is the known covariance of the Gaussian noise.
% * max_diff is the maximum contribution to the potential
%   of the difference between two neighbouring pixel values.
% * weight_diff is the weighting attached to the component of the potential
%   due to the difference between two neighbouring pixel values.
% * iterations is the number of iterations to perform.

function dst = restore_image(src, covar, max_diff, weight_diff, iterations)

% Maintain two buffer images.
% In alternate iterations, one will be the
% source image, the other the destination.
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
   
    weights = exp(-1*(-10:10).^2/2/4^2);
    diffs=ones([2 length(src)]) + max_diff;
    sumWeights = sum(weights);
    weights=weights./sumWeights;
    
    V_local =ones([1 length(src)]) + max_diff;% V_max;
    min_val=src(:);
    
    for val = 0 : 255
        
        % The component of the potential due to the known data.
        V_data = (val - src).^2 ./ (2 * covar);
        diffs(1,:)= (val-buffer(:,s)).^2;
        mdiff=min(diffs);
        V_diff=conv( mdiff ,weights,'same');
        
        V_current = V_data + weight_diff * V_diff';
        
        
        for x=1:length(src)
            if V_current(x) < V_local(x)
                min_val(x) = val;
                V_local(x) = V_current(x);
            end
        end
    end
    
    buffer(:,d) = min_val;
end


dst = buffer(:,d);
