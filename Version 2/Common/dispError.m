function dispError(mex)


fprintf([mex.message '\n\n']);
fprintf('\n');
for I=1:length(mex.stack)
    fprintf('%s\n',mex.stack(I).file);
    fprintf([ mex.stack(I).name '\n' num2str( mex.stack(I).line) '\n\n\n\n']);
end


end