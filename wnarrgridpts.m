function [cgridpts,closelandgridpts] = ...
    wnarrgridpts(deslat,deslon,oceanok,returncloselandgridpts,dofirst3only)
%Four closest gridpts to a given lat/lon (the four corners of a square), 
%   with weights on each based on Cartesian distance (in km), calculated for 277x349 NARR reanalyses
%Ocean option dictates whether or not ocean points are OK
%Returnlandgridpts options are chosen according to whether we want to find
    %all the land gridpoints within a certain distance of the center
%Option at the bottom controls whether just 3 gridpoints will be outputted, or all 10

%Central Park a.ka. the center of the NYC metro area: 40.78 N, 73.97 W should give 130,258

cgridpts=zeros(8,3); %columns are lat & lon of point, and then its fractional weight
closelandgridpts=zeros(10,6);
xnumber=10; %number of gridpts we want to display as 'pretty close' (default: 10)
%by experimentation, centered on NYC there are 767 gridpoints within 500
%km, and 3077 gridpoints within 1000 km

deslatrad=deslat*pi/180;
closestxnumber=1000*ones(xnumber,6);mindists=1000*ones(xnumber,1);

%Use soil moisture for lats/lons
temp=load('-mat','soilm_narr_01_01');
%Land-sea mask
lsmask=ncread('lsmasknarr.nc','land')';

soilm_narr_01_01=temp(1).soilm_0000_01_01;
lats=soilm_narr_01_01{1}; %277x349, as are all NARR arrays
lons=soilm_narr_01_01{2}; %ditto
narrgriddimx=size(lats,1);
narrgriddimy=size(lons,2);

%Computation loop
%fprintf('Computing NARR gridpoints closest to %0.2f, %0.2f\n',deslat,deslon);
for i=1:narrgriddimx
    for j=1:narrgriddimy
        thislat=lats(i,j);
        thislon=lons(i,j);
        dist=sqrt(abs(((thislat-deslat)*111)^2)+...
            abs(((thislon-deslon)*111*cos(deslatrad))^2)); %in km
        mindists=sort(mindists);
        if dist<mindists(xnumber)
            mindists(xnumber)=dist;
            closestxnumber(xnumber,1)=thislat;
            closestxnumber(xnumber,2)=thislon;
            closestxnumber(xnumber,3)=i;
            closestxnumber(xnumber,4)=j;
            closestxnumber(xnumber,5)=dist;
            closestxnumber(xnumber,6)=lsmask(i,j);
            closestxnumber=sortrows(closestxnumber,5);
        end
    end
end
%disp(closestxnumber);

rowtomake=1;
if returncloselandgridpts==1
    for i=1:size(closestxnumber,1)
        if closestxnumber(i,6)==1
            closelandgridpts(rowtomake,:)=closestxnumber(i,:);
            rowtomake=rowtomake+1;
        end
    end
    %disp(closelandgridpts);
end

if oceanok==0
    i=1;endthis=0;cgrc=0;nopfinc=0;nopf=0; %numoceanptsfound
    oldlatloc=0;oldlonloc=0;
    while i-nopf<=8 && endthis==0
        if endthis==0
            %Let this loop through until the next land pt
            if lsmask(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4))==0 
                nopf=nopf+1;nopfinc=1;
                latloc=lats(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4));
                lonloc=lons(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4));
                fprintf('Ocean pt found at %0.2f, %0.2f\n',latloc,lonloc);
                if i+nopf==xnumber %can't find 8 land pts among xnumber closest
                    %disp('Still have not found 8 land pts... Reconsider your choices');
                    lsmask(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4))=0;
                end
            else
                exist latloc;if ans==1;oldlatloc=latloc;end
                ans1=ans;
                exist lonloc;if ans==1;oldlonloc=lonloc;end
                ans2=ans;
                latloc=lats(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4));
                lonloc=lons(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4));
                if ans1==0 && ans2==0 || oldlatloc~=latloc && oldlonloc~=lonloc
                    %disp(sprintf('Land point found at %0.2f, %0.2f',latloc,lonloc));
                end
                nopfinc=0;cgrc=cgrc+1;
            end
        end
        if i+nopf<=xnumber && nopf~=xnumber-1 && nopfinc==0
            cgridpts(cgrc,1)=closestxnumber(i+nopf,3);cgridpts(cgrc,2)=closestxnumber(i+nopf,4);
            cgridpts(cgrc,3)=sum(closestxnumber(1:4,5))/closestxnumber(i+nopf,5);
            i=i+1;
        end
        if cgrc==8 %happily found 8 pts
            endthis=1;
        elseif i+nopf==xnumber %couldn't find 8 land pts
            endthis=1;disp(sprintf('Could not find eight land pts. Using just %d land pts among the top %d\n',cgrc,xnumber));
        end
        %disp('End this');disp(endthis);disp('i');disp(i);disp('i+nopf');disp(i+nopf);
    end
    %disp(closestxnumber);
else
    cgridpts(:,1)=closestxnumber(1:8,3);
    cgridpts(:,2)=closestxnumber(1:8,4);
    for i=1:8
        cgridpts(i,3)=sum(closestxnumber(1:8,5))/closestxnumber(i,5);
    end
end
summ=sum(cgridpts(1:8,3));
for i=1:8;cgridpts(i,3)=cgridpts(i,3)/summ;end


%Dimensions of cgridpts are NARRx|NARRy|fractional weight

%Whether to return 3 or all 8 closest pts (varies according to the application)
if dofirst3only==1
    top3gridptsonly=cgridpts(1:3,:);
    sumoftop3=sum(top3gridptsonly(:,3));
    top3gridptsonly(:,3)=top3gridptsonly(:,3)/sumoftop3;
    cgridpts=top3gridptsonly;
else
    cgridpts=cgridpts(1:8,:);
end

end

