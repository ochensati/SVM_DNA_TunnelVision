function [trace,trace2,trace3,colNames2,score,ident,bestSIL,infos]= ParamAndOptimize(emptyTrace,trace,trace2, lowSampleRange,sampleRangeStep, highSampleRange,classLow,classHigh)
bestSIL.s=0;
trace3=[];
nSamplesI=0;
for  nSamples=lowSampleRange:sampleRangeStep:highSampleRange%150:4*1024
    nSamplesI=nSamplesI+1
    try
        if (true)
            
            
            clear peakParams;
            peakParams.P_maxAmplitude=0;
            nComponents=60;
            minFFTSize=256;
            
            step =nSamples;%300;%256;%512;
            
            
            I=1;
            chunk=trace2(I:min([I+step-1 length(trace2)]));
            [peakParams]=PeakParameters(chunk, emptyTrace,nComponents, [],minFFTSize, peakParams);
            [colNames, values ] =linearizeParameters_SQL(peakParams,'');
            
            nSteps =ceil( length(trace2)/step);
            
            data = zeros([nSteps length(values) ]);
            cc=1;
            for I=1:step:length(trace2)
                
                chunk=trace2(I:min([I+step-1 length(trace2)]));
                [peakParams]=PeakParameters(chunk, emptyTrace,nComponents, [],minFFTSize, peakParams);
                
                [values] = linearizeValues_SQL( peakParams  );
                data(cc,:)=values;
                cc=cc+1;
                
                if (mod(cc,floor(nSteps/20))==0)
                    fprintf('%f\n',round( 100*cc/nSteps ));
                end
            end
            
            w = var(data);
            
            idx = find(w==0);
            data(:,idx)=[];
            colNames(idx)=[];
            
        end
        
        runParams.dataColStart=1;
        [colNames2,score]=ScaleData3(colNames,data);
        
        % w=1./var(score);
        % [wcoeff,score] = pca(score)%,...
        %'VariableWeights',w);
        
        
        % means = median(score);
        % deviations = median(abs( bsxfun(@minus, score, means) ));
        %
        % nCols=size(score,2);
        % for L=1:nCols
        %     score(:,L)=(score(:,L)-means(L))/deviations(L);
        % end
        
        
        
        xIDX = 1:size(score,1);
        % for I=1:size(score,2)
        %     idx = find(abs(score(:,I))>cut);
        %
        %     score(idx,:)=[];
        %     xIDX(idx)=[];
        % end
        X=score;
        clear sil;
        for k=classLow:classHigh
            opts = statset('Display','off');
            [ident] = kmeans(X,k,'Distance','correlation','EmptyAction','drop','start','cluster',...
                'Replicates',15,'Options',opts);
            
            figure(30);
            [silh4,h] = silhouette(X,ident,'correlation');
            sil(k) = mean(silh4);
            disp(['k' num2str(k) '-' num2str(sil(k)) ]);
            figure(40);clf; hold all;
           
            for J=1:max(ident)
                idx1=find(ident==J);
                x= score(idx1,1);
                y=score(idx1,5);
                z=score(idx1,6);
                idx =unique([ find(abs(x)>8)' find(abs(y)>8)' find(abs(z)>8)']);
                 x(idx)=[];
                 y(idx)=[];
                 z(idx)=[];
                 
               
                scatter3(x,y,z);
            end
        end
        % sil(1)=0;
         figure(3);
        [v,k]=max(sil);
        
        opts = statset('Display','off');
        [ident] = kmeans(X,k,'Distance','correlation','EmptyAction','drop','start','cluster',...
            'Replicates',15,'Options',opts);
        
       
        [silh4,h] = silhouette(X,ident,'correlation');
        s = mean(silh4);
        
        if (s>bestSIL.s)
            bestSIL.s=s;
            bestSIL.K = k;
            bestSIL.Samples = nSamples;
        end
        t.K=k;
        t.SIL=s;
        t.Samples = nSamples;
        infos{nSamplesI}=t; %#ok<AGROW>
        
        
        
        disp(['k' num2str(k) '-' num2str(sil(k)) ]);
        figure(4);clf; hold all;
        
        colors={[0 0 0], [1 0 0], [0 1 0], [0 0 1], [1 1 0], [0 1 1], [1 0 1], ...
            [.5 0 0],[0 .5 0], [0 0 .5], [.5 .5 0], [0 .5 .5], [.5 0 .5] ...
            [.5 .5 .5], [.5 0 1], [0 .5 1], [1 0 .5], [.5 .5 1], [1 .5 .5], [.5 1 .5]};
        lCol = 1+ zeros([1 size(data,1)]);
        lCol(xIDX)=ident+2;
        
        lCol2 = colors(lCol);
        
        figure(10);clf;hold all; xlabel('time (s)');ylabel('Tunnel Current (pA)');
        cc=1;
        trace3=smooth(trace,30);
        X=(1:length(trace3))/20000;
        for I=1:step:length(trace3)
            x = X(I:min([I+step-1 length(trace3)]));
            chunk=trace3(I:min([I+step-1 length(trace3)]));
            plot(x,chunk,'color',lCol2{cc});
            cc=cc+1;
        end
    catch mex
        dispError(mex)
    end
end

end
