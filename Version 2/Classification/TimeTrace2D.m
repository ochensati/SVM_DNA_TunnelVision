thresh=[0 20 30 50 50];
for I=2:1%size(allSmoothed,1)
    features=[];
    ccFeature=1;
    for II=1:4
        
        t=allSmoothed{I,II};
        
        
        if isempty(t)==false
            
            t=t/255;
            if (I==4)
                t=t(floor(length(t)*.3):end);
            end
            %t=t(floor(4.1e5):floor(4.7e5));
            figure(4)
            plot((1:length(t))/20000,t);
            hold all;
            
            bThresh = mean(t(t<mean(t)));
            X=find(t<bThresh);
            f1=fit(X,t(X),'poly3','Robust','Bisquare')
            shortData = t - feval(f1,1:length(t));
            plot(shortData);
            
            %
            tt=zeros(size(t));
            idx = find(shortData>thresh(I))';
            tt(idx)=1;
            
            cc=1;
            while cc<length(tt)
                if tt(cc)==0
                    break;
                end
                cc=cc+1;
            end
            
            starts=[];
            ends=[];
            ccPairs=1;
            while cc<length(tt)
                if tt(cc)==1
                    starts(ccPairs)=cc-10;
                    while cc<length(tt)
                        if tt(cc)==0
                            ends(ccPairs)=cc+10;
                            ccPairs=ccPairs+1;
                            cc=cc+10;
                            break
                        end
                        cc=cc+1;
                    end
                end
                cc=cc+1;
            end
            
            peakssI{I}=starts;
            peakseI{I}=ends;
            
            % features=cell([1 ccPairs-1]);
            ffts=zeros([1 8*4096]);
            for J=1:ccPairs-1
                X=starts(J):ends(J);
                vals=t(X);
                v.mean=mean(vals);
                v.max=max(vals);
                v.std=std(vals);
                v.width = length(vals)/20000;
                
                
                if length(vals)<length(ffts)
                    ffts(:)=0;
                    ffts(1:length(vals))=vals(:);
                else
                    ffts=vals(1:length(ffts));
                end
                f=abs(fft(ffts));
                v.power = sum(f);
                v.fft=abs(f)/ v.power;
                
                v.low=sum ( f ( 1:floor(length(f)/3)));
                v.mid=sum ( f ( floor(length(f)/3):floor(2*length(f)/3)));
                v.high=sum ( f ( floor(2*length(f)/3):floor(3*length(f)/3)));
                features{ccFeature}=v;
                ccFeature=ccFeature+1;
                plot(X,shortData(X));
            end
        end
    end
    allFeatures{I}=features;
    hold off
    
end

figure(2);
clf;
figure(1);
clf;
for I=2:5
    vals=allFeatures{I};
    
    X=zeros([1 length(vals)]);
    Y=zeros([1 length(vals)]);
    Z=zeros([1 length(vals)]);
    for J=1:length(vals)
        X(J)=vals{J}.power;
        Y(J)=sum(vals{J}.std);
        Z(J)=vals{J}.fft(10);
    end
    figure(1);
    scatter(X,Z);
    xlabel('Power (pA)');
    %xlabel('Variance (pA)');
    ylabel('fft 10');
    hold all;
    
    figure(2);
    scatter3(X,Y,Z);
    xlabel('Power (pA)');
    ylabel('Variance (pA)');
    zlabel('fft10( pA)');
    hold all;
end



