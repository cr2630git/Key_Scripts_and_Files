function cgridpts = wnarrgridptsstrippeddown(deslat,deslon)
%Same as wnarrgridpts but minimalist and optimized for maximum speed
%Among other things, assumes ocean pts are OK

xnumber=1;
deslatrad=deslat*pi/180;
closestxnumber=1000*ones(xnumber,6);mindists=1000*ones(xnumber,1);

%Use soil moisture for lats/lons
temp=load('-mat','soilm_narr_01_01');

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
            closestxnumber=sortrows(closestxnumber,5);
        end
    end
end
%disp(closestxnumber);

cgridpts(1,1)=closestxnumber(1,3);
cgridpts(1,2)=closestxnumber(1,4);

end

