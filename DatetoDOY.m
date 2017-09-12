function doy = DatetoDOY(mon,day,year)
%Converts a date to its day of year (number between 1 and 366)

m1sl=1;m2sl=32;m3sl=61;m4sl=92;m5sl=122;m6sl=153;m7sl=183;m8sl=214;m9sl=245;m10sl=275;m11sl=306;m12sl=336;
m1s=1;m2s=32;m3s=60;m4s=91;m5s=121;m6s=152;m7s=182;m8s=213;m9s=244;m10s=274;m11s=305;m12s=335;

%Loops through multiple times if inputs are vectors
for i=1:size(mon,1)

    if rem(year(i),4)==0;suffix=['l'];else suffix=[''];end %have to consider leap years

    %Determine the month of this date
    if mon(i)==1 %Jan
        doy(i)=day(i);
    elseif mon(i)==2 %Feb
        doy(i)=day(i)+eval(['m2s' suffix])-1;
    elseif mon(i)==3 %Mar
        doy(i)=day(i)+eval(['m3s' suffix])-1;
    elseif mon(i)==4 %Apr
        doy(i)=day(i)+eval(['m4s' suffix])-1;
    elseif mon(i)==5 %May
        doy(i)=day(i)+eval(['m5s' suffix])-1;
    elseif mon(i)==6 %Jun
        doy(i)=day(i)+eval(['m6s' suffix])-1;
    elseif mon(i)==7 %Jul
        doy(i)=day(i)+eval(['m7s' suffix])-1;
    elseif mon(i)==8 %Aug
        doy(i)=day(i)+eval(['m8s' suffix])-1;
    elseif mon(i)==9 %Sep
        doy(i)=day(i)+eval(['m9s' suffix])-1;
    elseif mon(i)==10 %Oct
        doy(i)=day(i)+eval(['m10s' suffix])-1;
    elseif mon(i)==11 %Nov
        doy(i)=day(i)+eval(['m11s' suffix])-1;
    elseif mon(i)==12 %Dec
        doy(i)=day(i)+eval(['m12s' suffix])-1;
    else
        disp('Please enter a valid month/day combination.');
    end
end


end