function [matrixofptsandweights] = interpolate2dlatlonarray(deslat,deslon,modellatarray,modellonarray)
%Given a desired lat/lon and a model's lat & lon arrays, find the 4 gridpoints that are closest
    %to the desired lat/lon and their corresponding weights

if deslon<0;deslon=deslon+360;end %convert to [0,360] range

deslatarray=deslat.*ones(size(modellatarray,1),size(modellatarray,2));
latdiff=abs(deslatarray-modellatarray);
[minlatdiff,minlatdiffpos]=min(latdiff);
deslonarray=deslon.*ones(size(modellonarray,1),size(modellonarray,2));
londiff=abs(deslonarray-modellonarray);
[minlondiff,minlondiffpos]=min(min(londiff));

closestptx=minlatdiffpos(1);
closestpty=minlondiffpos(1);
closestptlat=modellatarray(closestptx,closestpty);
closestptlon=modellonarray(closestptx,closestpty);
%Distance between closest gridpt & actual desired point, in lat/lon units
distclosestpttoactualpt=sqrt(abs(closestptlat-deslat).^2+abs(closestptlon-deslon).^2);

%Now get the 8 other surrounding points and compute their distances from the desired point
testpt1x=closestptx+1;testpt1y=closestpty;
testpt2x=closestptx-1;testpt2y=closestpty;
testpt3x=closestptx+1;testpt3y=closestpty-1;
testpt4x=closestptx-1;testpt4y=closestpty+1;
testpt5x=closestptx;testpt5y=closestpty+1;
testpt6x=closestptx;testpt6y=closestpty-1;
testpt7x=closestptx+1;testpt7y=closestpty+1;
testpt8x=closestptx-1;testpt8y=closestpty-1;

testpt1lat=modellatarray(testpt1x,testpt1y);testpt1lon=modellonarray(testpt1x,testpt1y);
testpt2lat=modellatarray(testpt2x,testpt2y);testpt2lon=modellonarray(testpt2x,testpt2y);
testpt3lat=modellatarray(testpt3x,testpt3y);testpt3lon=modellonarray(testpt3x,testpt3y);
testpt4lat=modellatarray(testpt4x,testpt4y);testpt4lon=modellonarray(testpt4x,testpt4y);
testpt5lat=modellatarray(testpt5x,testpt5y);testpt5lon=modellonarray(testpt5x,testpt5y);
testpt6lat=modellatarray(testpt6x,testpt6y);testpt6lon=modellonarray(testpt6x,testpt6y);
testpt7lat=modellatarray(testpt7x,testpt7y);testpt7lon=modellonarray(testpt7x,testpt7y);
testpt8lat=modellatarray(testpt8x,testpt8y);testpt8lon=modellonarray(testpt8x,testpt8y);

distpt1toactualpt=sqrt(abs(testpt1lat-deslat).^2+abs(testpt1lon-deslon).^2);
distpt2toactualpt=sqrt(abs(testpt2lat-deslat).^2+abs(testpt2lon-deslon).^2);
distpt3toactualpt=sqrt(abs(testpt3lat-deslat).^2+abs(testpt3lon-deslon).^2);
distpt4toactualpt=sqrt(abs(testpt4lat-deslat).^2+abs(testpt4lon-deslon).^2);
distpt5toactualpt=sqrt(abs(testpt5lat-deslat).^2+abs(testpt5lon-deslon).^2);
distpt6toactualpt=sqrt(abs(testpt6lat-deslat).^2+abs(testpt6lon-deslon).^2);
distpt7toactualpt=sqrt(abs(testpt7lat-deslat).^2+abs(testpt7lon-deslon).^2);
distpt8toactualpt=sqrt(abs(testpt8lat-deslat).^2+abs(testpt8lon-deslon).^2);

clear matrixofdists;
matrixofdists(:,1)=[closestptx;testpt1x;testpt2x;testpt3x;testpt4x;testpt5x;testpt6x;...
    testpt7x;testpt8x];
matrixofdists(:,2)=[closestpty;testpt1y;testpt2y;testpt3y;testpt4y;testpt5y;testpt6y;...
    testpt7y;testpt8y];
matrixofdists(:,3)=[distclosestpttoactualpt;distpt1toactualpt;distpt2toactualpt;...
    distpt3toactualpt;distpt4toactualpt;...
    distpt5toactualpt;distpt6toactualpt;distpt7toactualpt;distpt8toactualpt];
matrixofdists=sortrows(matrixofdists,3);
matrixofdists=matrixofdists(1:4,:);

%Add weights to each of the 4 closest matrix gridpts
sumdists=sum(matrixofdists(:,3));
for i=1:4
    thisdistweight=1/matrixofdists(i,3);
    matrixofdists(i,4)=thisdistweight;
end
sumweights=sum(matrixofdists(:,4));
matrixofdists(:,4)=matrixofdists(:,4)./sumweights;

matrixofptsandweights=matrixofdists;

end

