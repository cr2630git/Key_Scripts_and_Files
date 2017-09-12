function [wbtarray,rharray] = calcwbtfromTandshum(Tarray,moisturearray,specifictorelative)
%Calculates WBT from T and relative humidity, using the formula of Stull 2011, DOI: 10.1175/JAMC-D-11-0143.1
%T is in C, shum is in kg/kg, RH is in %, WBT is in C
%Input moisture array can be RH (no extra calculations needed) or SH (need to set specifictorelative=1)
%wbt=airtemp.*atan(0.151977.*(rh+8.313659).^0.5)+atan(airtemp+rh)-atan(rh-1.676331)+...
%            0.00391838.*(rh.^1.5).*atan(0.0231.*rh)-4.686035;

%First, if necessary, convert specific humidity to relative humidity
if specifictorelative==1
    mrArr=moisturearray./(1-moisturearray); %mixing ratio
    esArr=6.11*10.^(7.5*Tarray./(237.3+Tarray)); %saturation vapor pressure
    wsArr=0.622*esArr/1000; %saturation mixing ratio
    rharray=100*mrArr./wsArr;
else
    rharray=moisturearray;
end

wbtarray=Tarray.*atan(0.151977.*(rharray+8.313659).^0.5)+atan(Tarray+rharray)-...
    atan(rharray-1.676331)+0.00391838.*(rharray.^1.5).*atan(0.0231.*rharray)-4.686035;


end

