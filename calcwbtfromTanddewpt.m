function wbtarray = calcwbtfromTanddewpt(Tarray,dewptarray)
%Calculates WBT from T and dewpt via conversion to RH,
%using the formula of Stull 2011, DOI: 10.1175/JAMC-D-11-0143.1
%T and dewpt are in C, RH is in %, WBT is in C
%wbt=airtemp.*atan(0.151977.*(rh+8.313659).^0.5)+atan(airtemp+rh)-atan(rh-1.676331)+...
%            0.00391838.*(rh.^1.5).*atan(0.0231.*rh)-4.686035;

%Sat VP for T
eta=1-((Tarray+273.15)./647.1); %dimensionless ratio
satvpairt=220640*exp((647.1./(Tarray+273.15)).*(-7.86*eta+1.844*eta.^1.5-11.787*eta.^3+...
22.681*eta.^3.5-15.962*eta.^4+1.801*eta.^7.5)); %in hPa
%Sat VP for dewpt
eta=1-((dewptarray+273.15)./647.1);
satvpdewptt=220640*exp((647.1./(dewptarray+273.15)).*(-7.86*eta+1.844*eta.^1.5-11.787*eta.^3+...
22.681*eta.^3.5-15.962*eta.^4+1.801*eta.^7.5));
%RH
rharray=100*satvpdewptt./satvpairt; %in percent
%WBT
wbtarray=Tarray.*atan(0.151977.*(rharray+8.313659).^0.5)+atan(Tarray+rharray)-...
    atan(rharray-1.676331)+0.00391838.*(rharray.^1.5).*atan(0.0231.*rharray)-4.686035;
wbtarray=round2(wbtarray,0.01);


end

