
function varargout = UnwrapParameters(fields,  peaks)
disp('starting new section');
nCols = length(fields);
dataMatrix = zeros([length(peaks) nCols]);
for K=1:length(peaks)
  
    peak=peaks{K};
    for L=1:nCols
        %check how many subfields there are  
        fieldName = fields{L};
        parts = splitstring(fieldName,'.');
        %check if the last is an array index
        lastField = splitstring(parts{length(parts)},'+');
        if (length(lastField)>1)
            arrayIndex = str2num(lastField{2});
        end
        
        if (length(parts)==1 )
            if (length(lastField)==1)
                dataMatrix(K,L)=peak.(parts{1});
            else 
                dataMatrix(K,L)=peak.(lastField{1})(arrayIndex);
            end
        end
        
        if (length(parts)==2)
            if (length(lastField)==1)
                dataMatrix(K,L)=peak.(parts{1}).(parts{2});
            else 
                dataMatrix(K,L)=peak.(parts{1}).(lastField{1})(arrayIndex);
            end
        end
        
        if (length(parts)==3)
            dataMatrix(K,L)=peak.(parts(1)).(parts(2)).(parts(3));
        end

        if (length(parts)==4)
            dataMatrix(K,L)=peak.(parts(1)).(parts(2)).(parts(3)).(parts(4));
        end

    end
    
end



varargout ={dataMatrix};
end


function rv = splitstring( str, varargin )
%SPLITSTRING Split string into cell array
%    ARRAY = SPLITSTRING( STR, DELIM, ALLOWEMPTYENTRIES ) splits the
%    character string STR, using the delimiter DELIM (which must be a
%    character array). ARRAY is a cell array containing the resulting
%    strings. If DELIM is not specified, space delimiter is assumed (see
%    ISSPACE documentation). ALLOWEMPTYENTRIES should be a logical single
%    element, specifying weather empty elements should be included in the
%    results. If not specified, the value of ALLOWEMPTYENTRIES is false.
%
%    Example:
%         arr = splitstring( 'a,b,c,d', ',' )

delim = '';
AllowEmptyEntries = false;

if numel(varargin) == 2
        delim = varargin{1};
        AllowEmptyEntries = varargin{2};
elseif numel(varargin) == 1
        if islogical(varargin{1})
                AllowEmptyEntries = varargin{1};
        else
                delim = varargin{1};
        end
end

if isempty(delim)
        delim = ' ';
        ind = find( isspace( str ) );
else
        ind = strfind( str, delim );
end

startpos = [1, ind+length(delim)];
endpos = [ind-1, length(str)];

rv = cell( 1, length(startpos) );
for i=1:length(startpos)
        rv{i} = str(startpos(i):endpos(i));
end

if ~AllowEmptyEntries
        rv = rv( ~strcmp(rv,'') );
end
end