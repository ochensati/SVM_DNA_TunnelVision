 
function [crossAccuracy]= ChiSquaredTest( peaks1 , peaks2, peaksTest, variance,DisplayGraphs, PlotName )

 %define kernal
    kernel='htrbf';
    kerneloption=[.5 .5];
    verbose=0;
    nu=.95;

             
                %train the svm on all the data
                [xsup,alpha,rho,~]=svmoneclass(peaks1,kernel,kerneloption,nu,verbose);
                %now train on the other groups data
                [xsup2,alpha2,rho2,~]=svmoneclass(peaks2,kernel,kerneloption,nu,verbose);
                
                %now compare the results from the two training sets using
                %the orignal datapoints as the comparison points
                spred = svmoneclassval(peaks1,xsup,alpha,rho,kernel,kerneloption);
                ypred = svmoneclassval(peaks1,xsup2,alpha2,rho2,kernel,kerneloption);

                %we can not take something similar to the chi squared value
                %to compare the two distributions
                sI=size(peaks1);
                chisqrI= (sum(( (ypred-spred).^2)./variance)  );
                div1 = (sI(1)- sI(2)-1);
                
                %now compare the results from the two training sets using
                %the orignal datapoints as the comparison points
                spred = svmoneclassval(peaks2,xsup,alpha,rho,kernel,kerneloption);
                ypred = svmoneclassval(peaks2,xsup2,alpha2,rho2,kernel,kerneloption);
                
                sI=size(peaks2);
                chisqrI2= (sum(( (ypred-spred).^2)./variance)  ) ;
                div2 = (sI(1)- sI(2)-1);
                
                crossAccuracy = (chisqrI + chisqrI2)/ (div1 + div2);
                
                if (variance ==0)
                    crossAccuracy=1;
                end
               
                if (DisplayGraphs )
                       c1=1;
                       c4=6;
                       minX=min(peaks1(:,c1));
                       maxX=max(peaks1(:,c1));

                       minY=min(peaks1(:,c4));
                       maxY=max(peaks1(:,c4));
                        
                       % minX =-.04;minY=-1;
                       % maxX=.2;maxY=3;
                        
                       [xtest,xtest1,xtest2,nn]=DataGrid2D([minX:(maxX-minX)/20:maxX],[minY:(maxY-minY)/20:maxY]);

                        
                       [xsupg,alphag,rhog,~]=svmoneclass(peaks1(:,[c1 c4]),kernel,kerneloption,nu,verbose);
               
                
                       ypredg=svmoneclassval(xtest,xsupg,alphag,rhog,kernel,kerneloption);
                       ypredg=reshape(ypredg,nn,nn);

                       figure; 
                       clf; 
                       contourf(xtest1,xtest2,ypredg,50);shading flat;
                       hold on
                       [cc,hh]=contour(xtest1,xtest2,ypredg,[0 0],'k');
                       clabel(cc,hh); 
                       h1=plot(peaks1(:,c1),peaks1(:,c4),'+k'); 
                       set(h1,'LineWidth',2);
                       % axis([-.04 .2 -1 4]);
                       
                       if (isempty(peaksTest)==0)
                            h1=plot(peaksTest(:,c1),peaksTest(:,c4),'ow','MarkerSize',3); 
                            set(h1,'LineWidth',2);
                       end 
                       
                       xlabel('Normalized Amplitude');
                       ylabel('Normalized Width');
                       title(PlotName);
                       %h3=plot(tempJ(:,1),tempJ(:,2),'ok'); 
                       %set(h3,'LineWidth',2);
                end
end