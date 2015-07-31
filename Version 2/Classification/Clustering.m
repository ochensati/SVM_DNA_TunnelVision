
data=refinedData.dataTable;


analytes = unique(data(:,1));
sI=6;
eI=29;
norm = std(data(:,sI:eI));
figure(20);
hold off;
clf;
for KK=1:1
    for I=1:length(analytes)
        idx=find(data(:,1)==analytes(I));
        dT=data(idx,:);
        
        
        [clusterIDX,a,c ]=unique(dT(:,3));
        t=dT(10,sI:eI);
        
        
        t=corr(t);
        allCorr=zeros(size(t));
        stdCluster =[];%zeros([size(t,1) 1]);
        asCluster=0;
        cc=0;
        for J=1:length(clusterIDX)
            idx=find(dT(:,3)==clusterIDX(J));
            if length(idx)>5 && length(idx)<12
                t=dT(idx,sI:eI);
                allCorr=allCorr+ corr(t);
                st=std(t)./norm;
                stdCluster = vertcat(stdCluster ,st );
                asCluster=asCluster+mean(st)*length(idx);
                cc=cc+length(idx);
            end
        end
        asCluster=asCluster/cc;
        
        figure(21);
        plot(mean(stdCluster,2));
        
        figure(20);
        plot(mean(stdCluster));
        hold all;
        % figure(I);
        % surf(allCorr);
        
        dT=dT(:,sI:eI);
        %t=clusterdata(dT,10);
        %
        %    unique(t)
        radii(KK)=.5;%.2+(KK/10)*.9;
        [C,S] = subclust(dT,radii(KK));
        analyteNames{I}
        disp(size(C));
        
        if size(C,1)>2
            x=C;
            [n, p] = size(x);
            vWeights=ones(1,n)
            mu = classreg.learning.internal.wnanmean(x, vWeights);
            x = bsxfun(@minus,x,mu);
            
            [COEFF,SCORE,latent,tsquare] = pca(x,'Algorithm','eig','Centered',false,'Economy',false);
            x= bsxfun(@minus,dT,mu);
            s2 = x/COEFF';
            st=.2*std(s2);
            for L=1:length(st)
               idx=find(abs(s2(:,L) )>st(L));
               s2(idx,:)=[];
            end
            figure(30+I);
            scatter(s2(:,1),s2(:,2))
            
            figure(40+I);
            scatter(s2(:,1),s2(:,3))
           % scatter3(s2(:,1),s2(:,2),s2(:,3));
        end
        
        progress(KK,I)=size(C,1);
    end
end

figure(20);
xlabel('Feature Number');
ylabel('Simularity metric');
%

%data=data(a,:);
