function [azimuthres] = azimuthfromnarrgridpts(narrpt1coord1,narrpt1coord2,narrpt2coord1,narrpt2coord2)
%Calculates azimuth angle, in degrees, between two NARR gridpts
%(specifically, from point 1 to point 2)

temp=load('-mat','soilm_narr_01_01'); %a soil-moisture array just used for its lats/lons
soilm_narr_01_01=temp(1).soilm_0000_01_01;
lats=soilm_narr_01_01{1}; %277x349, as are all NARR arrays
lons=soilm_narr_01_01{2}; %ditto
narrgriddimx=size(lats,1);
narrgriddimy=size(lons,2);

%Lat/lon of point 1
latpt1=lats(narrpt1coord1,narrpt1coord2);
lonpt1=lons(narrpt1coord1,narrpt1coord2);

%Lat/lon of point 2
latpt2=lats(narrpt2coord1,narrpt2coord2);
lonpt2=lons(narrpt2coord1,narrpt2coord2);

%Azimuth
azimuthres=azimuth(latpt1,lonpt1,latpt2,lonpt2);
            



