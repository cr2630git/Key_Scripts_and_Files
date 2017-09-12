function datestring = DOYtoDate(doy,year)
%Converts day of year (number b/w 1 and 366) to a nice date
    
m1sl=1;m2sl=32;m3sl=61;m4sl=92;m5sl=122;m6sl=153;m7sl=183;m8sl=214;m9sl=245;m10sl=275;m11sl=306;m12sl=336;
m1s=1;m2s=32;m3s=60;m4s=91;m5s=121;m6s=152;m7s=182;m8s=213;m9s=244;m10s=274;m11s=305;m12s=335;

if rem(year,4)==0;suffix=['l'];else suffix=[''];end %have to consider leap years

%Determine the month of this date
if doy<eval(['m2s' suffix]) %Jan
    month='Jan';day=doy-eval(['m1s' suffix])+1;
elseif doy<eval(['m3s' suffix]) %Feb
    month='Feb';day=doy-eval(['m2s' suffix])+1;
elseif doy<eval(['m4s' suffix]) %Mar
    month='Mar';day=doy-eval(['m3s' suffix])+1;
elseif doy<eval(['m5s' suffix]) %Apr
    month='Apr';day=doy-eval(['m4s' suffix])+1;
elseif doy<eval(['m6s' suffix]) %May
    month='May';day=doy-eval(['m5s' suffix])+1;
elseif doy<eval(['m7s' suffix]) %Jun
    month='Jun';day=doy-eval(['m6s' suffix])+1;
elseif doy<eval(['m8s' suffix]) %Jul
    month='Jul';day=doy-eval(['m7s' suffix])+1;
elseif doy<eval(['m9s' suffix]) %Aug
    month='Aug';day=doy-eval(['m8s' suffix])+1;
elseif doy<eval(['m10s' suffix]) %Sep
    month='Sep';day=doy-eval(['m9s' suffix])+1;
elseif doy<eval(['m11s' suffix]) %Oct
    month='Oct';day=doy-eval(['m10s' suffix])+1;
elseif doy<eval(['m12s' suffix]) %Nov
    month='Nov';day=doy-eval(['m11s' suffix])+1;
else %Dec
    month='Dec';day=doy-eval(['m12s' suffix])+1;
end

    
datestring=sprintf('%s %d',month,day);

end

