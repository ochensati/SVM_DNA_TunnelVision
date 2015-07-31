
function [n, xout] = histx(varargin)
% A wrapper for hist that picks the "ideal" number of bins to use if
% unspecified. 
% 
% N = HISTX(Y) bins the elements of Y into M equally spaced containers and
% returns the number of elements in each container.  If Y is a matrix, HIST
% works down the columns.  The value of M is the middle (median) value of
% the optimal number of bins calculated using the Freedman-Diaconis, Scott
% and Sturges methods.  See below for further information on these methods.
% 
% N = HISTX(Y,M), where M is a scalar, uses M bins.  (This is identical to
% N = HIST(Y,M).)
% 
% N = HISTX(Y, X), where X is a vector, returns the distribution of Y among
% bins with centers specified by X. The first bin includes data between
% -inf and the first center and the last bin includes data between the last
% bin and inf. Note: Use HISTC if it is more natural to specify bin edges
% instead.  (This is identical to N = HIST(Y,X).) 
% 
% N = HISTX(Y, METHOD), where METHOD is a string chooses the number of bins
% as follows:
% 
% 'fd': The Freedman-Diaconis method, based upon the inter-quartile range
% and number of data, is used. 
% 'scott': The Scott method, based upon the sample standard deviation and
% nnumber of data, is used. 
% 'sturges': The Sturges method, based upon the number of data, is used.
% 'middle': All three methods are tried, and the middle value is used.
% 
% N = HISTX(Y, [], MINIMUM), where MINIMUM is a numeric scalar, defines the
% smallest acceptable number of bins.
% 
% N = HISTX(Y, [], [], MAXIMUM), where MAXIMUM is a numeric scalar, defines the
% largest acceptable number of bins.
% 
% HISTX(...) without output arguments produces a histogram bar plot of the
% results. The bar edges on the first and last bins may extend to cover the
% min and max of the data unless a matrix of data is supplied.
% 
% HISTX(Y, 'all') produces three histograms in a new figure window, drawn
% with the number of bins calculated using each of the three methods.
% 
% HISTX(AX, ...) plots into AX instead of GCA.
% 
% Notes:  
% 1. When the method chosen is 'all', any axes inputted will be ignored
% with a warning.  Likewise for output arguments.
% 
% 2. References for the methods can be found in the help page for
% CALCNBINS.
% 
% Examples:
% y = randn(10000,1);
% histx(y)
% histx(y, 'all')
% 
% See also: CALCNBINS, HIST.
% 
% $ Author: Richard Cotton $		$ Date: 2008/08/28 $    $ Version 1.1 $

% Check there is at least one input, and see if the first input is an axis.
error(nargchk(1,inf,nargin,'struct'));
[cax,args,nargs] = axescheck(varargin{:});

plotall = false;
y = args{1};

% If the number of bins wasn't specified, calculate it using calcnbins.
if nargs < 4 || isempty(args{4})
   args{4} = []; % this also sets missing arguments before this positon to [].
end

if ~isempty(args{2}) && isnumeric(args{2})
   nbins = args{2};
else
   nbins = calcnbins(y, args{2}, args{3}, args{4});
   if ischar(args{2}) && strcmpi(args{2}, 'all')
      plotall = true;
   end
end

% Plot the histogram(s)
if plotall
   if nargout > 0 
      warning('histx:ignoreargout', 'No arguments will be returned when the method is "all".');
   end
   if ~isempty(cax)
      warning('histx:ignoreaxes', 'The input axes are ignored when the method is "all".');
   end
   n = [];
   xout = [];
   figure();
   subplot(3, 1, 1); hist(y, nbins.fd);
   title('Freedman-Diaconis'' method');
   subplot(3, 1, 2); hist(y, nbins.scott);
   title('Scott''s method');
   subplot(3, 1, 3); hist(y, nbins.sturges);
   title('Sturges'' method');
else
   if nargout==0
      if isempty(cax)
         hist(y, nbins);
      else
         hist(cax, y, nbins);
      end
   else
      if isempty(cax)
      [n, xout] = hist(y, nbins);
   else
      [n, xout] = hist(cax, y, nbins);
      end
   end
end
end

function nbins = calcnbins(x, method, minimum, maximum)
% Calculate the "ideal" number of bins to use in a histogram, using a
% choice of methods.
% 
% NBINS = CALCNBINS(X, METHOD) calculates the "ideal" number of bins to use
% in a histogram, using a choice of methods.  The type of return value
% depends upon the method chosen.  Possible values for METHOD are:
% 'fd': A single integer is returned, and CALCNBINS uses the
% Freedman-Diaconis method,
% based upon the inter-quartile range and number of data.
% See Freedman, David; Diaconis, P. (1981). "On the histogram as a density
% estimator: L2 theory". Zeitschrift fr Wahrscheinlichkeitstheorie und
% verwandte Gebiete 57 (4): 453-476.

% 'scott': A single integer is returned, and CALCNBINS uses Scott's method,
% based upon the sample standard deviation and number of data.
% See Scott, David W. (1979). "On optimal and data-based histograms".
% Biometrika 66 (3): 605-610.
% 
% 'sturges': A single integer is returned, and CALCNBINS uses Sturges'
% method, based upon the number of data.
% See Sturges, H. A. (1926). "The choice of a class interval". J. American
% Statistical Association: 65-66.
% 
% 'middle': A single integer is returned.  CALCNBINS uses all three
% methods, then picks the middle (median) value.
% 
% 'all': A structure is returned with fields 'fd', 'scott' and 'sturges',
% each containing the calculation from the respective method.
% 
% NBINS = CALCNBINS(X) works as NBINS = CALCNBINS(X, 'MIDDLE').
% 
% NBINS = CALCNBINS(X, [], MINIMUM), where MINIMUM is a numeric scalar,
% defines the smallest acceptable number of bins.
% 
% NBINS = CALCNBINS(X, [], MAXIMUM), where MAXIMUM is a numeric scalar,
% defines the largest acceptable number of bins.
% 
% Notes: 
% 1. If X is complex, any imaginary components will be ignored, with a
% warning.
% 
% 2. If X is an matrix or multidimensional array, it will be coerced to a
% vector, with a warning.
% 
% 3. Partial name matching is used on the method name, so 'st' matches
% sturges, etc.
% 
% 4. This function is inspired by code from the free software package R
% (http://www.r-project.org).  See 'Modern Applied Statistics with S' by
% Venables & Ripley (Springer, 2002, p112) for more information.
% 
% 5. The "ideal" number of depends on what you want to show, and none of
% the methods included are as good as the human eye.  It is recommended
% that you use this function as a starting point rather than a definitive
% guide.
% 
% 6. The wikipedia page on histograms currently gives a reasonable
% description of the algorithms used.
% See http://en.wikipedia.org/w/index.php?title=Histogram&oldid=232222820
% 
% Examples:     
% y = randn(10000,1);
% nb = calcnbins(y, 'all')
%    nb = 
%             fd: 66
%          scott: 51
%        sturges: 15
% calcnbins(y)
%    ans =
%        51
% subplot(3, 1, 1); hist(y, nb.fd);
% subplot(3, 1, 2); hist(y, nb.scott);
% subplot(3, 1, 3); hist(y, nb.sturges);
% y2 = rand(100,1);
% nb2 = calcnbins(y2, 'all')
%    nb2 = 
%             fd: 5
%          scott: 5
%        sturges: 8
% hist(y2, calcnbins(y2))
% 
% See also: HIST, HISTX
% 
% $ Author: Richard Cotton $		$ Date: 2008/10/24 $    $ Version 1.5 $

% Input checking
error(nargchk(1, 4, nargin));

if ~isnumeric(x) && ~islogical(x)
    error('calcnbins:invalidX', 'The X argument must be numeric or logical.')
end

if ~isreal(x)
   x = real(x);
   warning('calcnbins:complexX', 'Imaginary parts of X will be ignored.');
end

% Ignore dimensions of x.
if ~isvector(x)
   x = x(:);
   warning('calcnbins:nonvectorX', 'X will be coerced to a vector.');
end

nanx = isnan(x);
if any(nanx)
   x = x(~nanx);
   warning('calcnbins:nanX', 'Values of X equal to NaN will be ignored.');
end

if nargin < 2 || isempty(method)
   method = 'middle';
end

if ~ischar(method)
   error('calcnbins:invalidMethod', 'The method argument must be a char array.');
end

validmethods = {'fd'; 'scott'; 'sturges'; 'all'; 'middle'};
methodmatches = strmatch(lower(method), validmethods);
nmatches = length(methodmatches);
if nmatches~=1
   error('calnbins:unknownMethod', 'The method specified is unknown or ambiguous.');
end
method = validmethods{methodmatches};

if nargin < 3 || isempty(minimum)
   minimum = 1;
end

if nargin < 4 || isempty(maximum)
   maximum = Inf;
end
   
% Perform the calculation
switch(method)
   case 'fd'
      nbins = calcfd(x);
   case 'scott'
      nbins = calcscott(x);
    case 'sturges'
      nbins = calcsturges(x);
   case 'all'
      nbins.fd = calcfd(x);    
      nbins.scott = calcscott(x);
      nbins.sturges = calcsturges(x);
   case 'middle'
      nbins = median([calcfd(x) calcscott(x) calcsturges(x)]);
end

% Calculation details
   function nbins = calcfd(x)
      h = diff(prctile0(x, [25; 75])); %inter-quartile range
      if h == 0
         h = 2*median(abs(x-median(x))); %twice median absolute deviation
      end
      if h > 0
         nbins = ceil((max(x)-min(x))/(2*h*length(x)^(-1/3)));
      else
         nbins = 1;
      end
      nbins = confine2range(nbins, minimum, maximum);
   end

   function nbins = calcscott(x)
      h = 3.5*std(x)*length(x)^(-1/3);
      if h > 0 
         nbins = ceil((max(x)-min(x))/h);
      else 
         nbins = 1;
      end
      nbins = confine2range(nbins, minimum, maximum);
   end

   function nbins = calcsturges(x)
      nbins = ceil(log2(length(x)) + 1);
      nbins = confine2range(nbins, minimum, maximum);
   end

   function y = confine2range(x, lower, upper)
      y = ceil(max(x, lower));
      y = floor(min(y, upper));
   end

   function y = prctile0(x, prc)
      % Simple version of prctile that only operates on vectors, and skips
      % the input checking (In particluar, NaN values are now assumed to
      % have been removed.)
      lenx = length(x);
      if lenx == 0
         y = [];
         return
      end
      if lenx == 1
         y = x;
         return
      end
      
      function foo = makecolumnvector(foo)
         if size(foo, 2) > 1 
            foo = foo';
         end
      end
         
      sortx = makecolumnvector(sort(x));
      posn = prc.*lenx/100 + 0.5;
      posn = makecolumnvector(posn);
      posn = confine2range(posn, 1, lenx);
      y = interp1q((1:lenx)', sortx, posn);
   end
end