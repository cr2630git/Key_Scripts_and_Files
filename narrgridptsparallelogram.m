function outputgridptsmatrix=narrgridptsparallelogram(corner1lat,corner1lon,corner2lat,corner2lon,corner3lat,corner3lon,corner4lat,corner4lon)
%Finds NARR gridpts within a parallelogram (in lat/lon space) / arch (in NARR-array space) 
%defined by the four lat/lon corners given as input
%Points must be entered such that either the x- or y-values increase in the
%first three -- this is generally accomplished by going consistently 
%clockwise or counterclockwise around the polygon
%Also, lats and lons of the pairs must match!

%Standard 277x349 NARR array is used although this script could be modified
%for datasets of other dimensions as well
%Output is an array of this same size, with 1's denoting points within this
%parallelogram, and 0's denoting points without

%Current runtime: 1 min

%Get the NARR lat/lon arrays to reference
curDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_mat';
curFile=load(char(strcat(curDir,'/air/2014/air_2014_08_01.mat')));
llsource=eval(['curFile.air_2014_08_01']);
lats=double(llsource{1});lons=double(llsource{2});

%Convert inputted corners to NARR-array space
corner1xyarray=wnarrgridpts(corner1lat,corner1lon,1,0,1);
corner1x=corner1xyarray(1,1);corner1y=corner1xyarray(1,2);
corner2xyarray=wnarrgridpts(corner2lat,corner2lon,1,0,1);
corner2x=corner2xyarray(1,1);corner2y=corner2xyarray(1,2);
corner3xyarray=wnarrgridpts(corner3lat,corner3lon,1,0,1);
corner3x=corner3xyarray(1,1);corner3y=corner3xyarray(1,2);
corner4xyarray=wnarrgridpts(corner4lat,corner4lon,1,0,1);
corner4x=corner4xyarray(1,1);corner4y=corner4xyarray(1,2);

if ~(corner3x>corner2x && corner2x>corner1x)
    if ~(corner3y>corner2y && corner2y>corner1y)
        disp('Please enter points in an order such that either the x- or y-values increase in the first 3 points');
        return;
    end  
end


%The points can be broken down into two sets have the same latitude & two
%that have the same longitude
%Calculate distance (in NARR-array space) from one from each latitude pair to center of
%semi-circle (imagescnan(lats) to see an illustration of why this is necessary)
%In other words, in this space can't judge latitude based on a
%parallelogram, but only by a semi-circle
centerptx=size(lats,1);centerpty=size(lats,2)/2;
if corner1lat==corner2lat %pts 1 and 3 differ (for instance)
    distcornera=sqrt((corner1x-centerptx)^2+(corner1y-centerpty)^2);
    distcornerb=sqrt((corner3x-centerptx)^2+(corner3y-centerpty)^2);
    differlat13=1;
    differlat12=0;
else %1 and 2 differ (for instance)
    distcornera=sqrt((corner1x-centerptx)^2+(corner1y-centerpty)^2);
    distcornerb=sqrt((corner2x-centerptx)^2+(corner2y-centerpty)^2);
    differlat13=0;
    differlat12=1;
end
%Determine which pts differ in longitude as well
if corner1lon==corner2lon
    differlon13=1;
    differlon12=0;
else
    differlon13=0;
    differlon12=1;
end
%Determine which of a and b is the larger, and which the smaller
if distcornera>distcornerb
    distlatfar=distcornera;distlatclose=distcornerb;
else
    distlatfar=distcornerb;distlatclose=distcornera;
end
    

%Step 1. Equation for the edges of the polygon in NARR-array space
%Equations are of form Ax+By+C=0
%If D>0, point is on LHS of line; if D<0, point is on RHS

%Line connecting pts 1 and 2
%Also, evaluation of all points as to which side of this line they fall on
linec=1;
A=-(corner2y-corner1y);
B=corner2x-corner1x;
C=-(A*corner1x+B*corner1y);
for i=1:size(lats,1)
    for j=1:size(lats,2)
        D(linec,i,j)=A*i+B*j+C;
    end
end
%Line connecting pts 2 and 3
linec=2;
A=-(corner3y-corner2y);
B=corner3x-corner2x;
C=-(A*corner2x+B*corner2y);
for i=1:size(lats,1)
    for j=1:size(lats,2)
        D(linec,i,j)=A*i+B*j+C;
    end
end
%Line connecting pts 3 and 4
linec=3;
A=-(corner4y-corner3y);
B=corner4x-corner3x;
C=-(A*corner3x+B*corner3y);
for i=1:size(lats,1)
    for j=1:size(lats,2)
        D(linec,i,j)=A*i+B*j+C;
    end
end
%Line connecting pts 4 and 1
linec=4;
A=-(corner1y-corner4y);
B=corner1x-corner4x;
C=-(A*corner4x+B*corner4y);
for i=1:size(lats,1)
    for j=1:size(lats,2)
        D(linec,i,j)=A*i+B*j+C;
    end
end

%Use the 4 values of D for each gridpoint to assess whether it's inside or
%outside the parallelogram that the inputted points define
for i=1:size(lats,1)
    for j=1:size(lats,2)
        if D(1,i,j)>=0 && D(3,i,j)<=0 || D(1,i,j)<=0 && D(3,i,j)>=0
            if D(2,i,j)>=0 && D(4,i,j)<=0 || D(2,i,j)<=0 && D(4,i,j)>=0
                %outputgridptsmatrix(i,j)=1;
            else
                %outputgridptsmatrix(i,j)=0;
            end
        else
            %outputgridptsmatrix(i,j)=0;
        end
        distthisptcenterpt=sqrt((i-centerptx)^2+(j-centerpty)^2);
        if distthisptcenterpt>=distlatclose && distthisptcenterpt<=distlatfar
            %This point looks good in terms of latitude, now what about longitude?
            if differlon12==0 %1 and 2 are a longitude pair, so compare D of line connecting
                %corner pts 1 & 2 to D of line connecting corner pts 3 & 4
                if D(1,i,j)>=0 && D(3,i,j)<=0 || D(1,i,j)<=0 && D(3,i,j)>=0
                    outputgridptsmatrix(i,j)=0;
                else
                    outputgridptsmatrix(i,j)=1;
                end
            else %1 and 4 are a longitude pair, so compare D of line connecting
                %corner pts 1 & 4 to D of line connecting corner pts 2 & 3
                if D(2,i,j)>=0 && D(4,i,j)<=0 || D(2,i,j)<=0 && D(4,i,j)>=0
                    outputgridptsmatrix(i,j)=0;
                else
                    outputgridptsmatrix(i,j)=1;
                end
            end
        else
            outputgridptsmatrix(i,j)=0;
        end
    end
end


end

