function [out]=scipyWiener(im, mysize)

%  # Estimate the local mean
lMean = xcorr(im, ones([mysize 1])) / mysize;
lMean=lMean(end-length(im)+1:end);
plot(lMean)
% # Estimate the local variance
lVar = (xcorr(im .^ 2, ones([mysize 1])) / mysize );
lVar =lVar(end-length(im)+1:end)- lMean.^2;
% # Estimate the noise power if needed.
noise = mean(lVar(:));

res = (im - lMean);
res =res.* (1 - noise ./ lVar);
res =res + lMean;
out=res;
out(lVar < noise) = lMean(lVar < noise);

end