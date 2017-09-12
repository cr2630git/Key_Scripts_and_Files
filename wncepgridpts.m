function [cgridpts,closelandgridpts] = wncepgridpts(deslat,deslon,oceanok,returncloselandgridpts)
%Four closest gridpts to a given lat/lon (the four corners of a square), 
%   with weights on each based on Cartesian distance, calculated for 144x73 NCEP reanalyses
        %Keep in mind this means, contrary to the usual meaning, 144 columns and 73 rows!!
%Ocean option dictates whether or not ocean points are OK
%Returnlandgridpts options are chosen according to whether we want to find
    %all the land gridpoints within a certain distance of the center
%Option at the bottom controls whether just 3 gridpoints will be outputted, or all 10

cgridpts=zeros(4,3); %columns are lat & lon of point, and then its fractional weight


deslatrad=deslat*pi/180;
closestxnumber=10^6*ones(10,5);mindists=10^6*ones(10,1);
xnumber=10; %number of gridpts we want to display as 'pretty close' (default: 10)

%Use soil moisture for lats/lons (air is just a stand-in)
temp=load('-mat','air_ncep_2015_01');
%Land-sea mask
lsmask=ncread('lsmaskncep.nc','land');
air_ncep_2015_01=temp(1).air_2015_01;
lats=air_ncep_2015_01{1}; %144x73, as are all NCEP arrays
lons=air_ncep_2015_01{2}; %ditto
for i=1:size(lons,1)
    for j=1:size(lons,2)
        if lons(i,j)>180;lons(i,j)=lons(i,j)-360;end %adjustment needed for Western Hemisphere
    end
end
ncepgriddimx=size(lats,1);
ncepgriddimy=size(lats,2);
sizecg=size(cgridpts,1);

%Computation loop
%fprintf('Computing NCEP gridpoints closest to %0.2f, %0.2f\n',deslat,deslon);
for i=1:ncepgriddimx
    for j=1:ncepgriddimy
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
    while i-nopf<=sizecg && endthis==0
        if endthis==0
            %Let this loop through until the next land pt
            if lsmask(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4))==0 
                nopf=nopf+1;nopfinc=1;
                latloc=lats(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4));
                lonloc=lons(closestxnumber(i+nopf,3),closestxnumber(i+nopf,4));
                fprintf('Ocean pt found at %0.2f, %0.2f\n',latloc,lonloc);
                if i+nopf==xnumber %can't find sizecg land pts among xnumber closest
                    %disp('Still have not found sizecg land pts... Reconsider your choices');
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
        if cgrc==sizecg %happily found sizecg pts
            endthis=1;
        elseif i+nopf==xnumber %couldn't find sizecg land pts
            endthis=1;disp('Could not find as many land pts as desired.');
            fprintf('Using just %d land pts among the top %d\n',cgrc,xnumber);
        end
        %disp('End this');disp(endthis);disp('i');disp(i);disp('i+nopf');disp(i+nopf);
    end
    %disp(closestxnumber);
else
    cgridpts(:,1)=closestxnumber(1:sizecg,3);
    cgridpts(:,2)=closestxnumber(1:sizecg,4);
    for i=1:sizecg
        cgridpts(i,3)=sum(closestxnumber(1:sizecg,5))/closestxnumber(i,5);
    end
end
summ=sum(cgridpts(1:sizecg,3));
for i=1:sizecg;cgridpts(i,3)=cgridpts(i,3)/summ;end


%Dimensions of cgridpts are NCEPx|NCEPy|fractional weight

%Optional addendum: weights for first 3 only
dofirst3only=1;
if dofirst3only==1
    top3gridptsonly=cgridpts(1:3,:);
    sumoftop3=sum(top3gridptsonly(:,3));
    top3gridptsonly(:,3)=top3gridptsonly(:,3)/sumoftop3;
    cgridpts=top3gridptsonly;
else
    cgridpts=cgridpts(1:sizecg,:);
end

end