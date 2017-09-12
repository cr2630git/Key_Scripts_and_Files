
function daysapart = DaysApart(mon1,day1,year1,mon2,day2,year2)
%Calculates the number of days between two dates
%   Dates can be any mon/day/year combination
%   Output is number of days they are offset by, e.g. 4/4/05 and 4/6/05 are
%   2 days apart
%   Assumes dates are given in chronological order
%   Valid only since 1901 since it does not consider the lack of a leap
%   year in 1700, 1800, and 1900

if year1>year2
    disp('Please enter years in chronological order');
elseif year1==year2 && mon1>mon2
    disp('Please enter months in chronological order');
elseif year1==year2 && mon1==mon2 && day1>day2
    disp('Please enter days in chronological order');
end

%Convert mon/day to DOY
doy1=DatetoDOY(mon1,day1,year1);
doy2=DatetoDOY(mon2,day2,year2);

%Vector of years between the two selected years
yearsvec=year1:year2-1; %because we don't want to include the yearlen of the second date's year
%disp(size(yearsvec));
for i=1:size(yearsvec,2)
    if rem(yearsvec(i),4)==0;yearlen=366;else yearlen=365;end
    yearsveclens(i)=yearlen;
end

if year1==year2
    daysapart=doy2-doy1;
else
    daysapart=sum(yearsveclens)+(doy2-doy1);
end

