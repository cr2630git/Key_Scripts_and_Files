function desyval=interpolatetovalidxvalue(desxval,validxvaltoleft,validxvaltoright,validyvaltoleft,validyvaltoright,timeyesorno)
%Given two x values any distance apart, and their corresponding y values, computes the 
%          y value at the desired x value
%   e.g. for time, if there are obs at 1:00 and 2:53, this function outputs an interpolated obs value for 2:00
%   Time option can be 'time' or 'not time', and mainly indicates whether or not to keep everything in the 0-23.99 range
%   For time, be sure that the DECIMAL VERSION of the minutes is used, not the raw one out of 60!
%   Example usage: interptemp=interpolatetovalidxvalue(2.00,1.00,2.88,10,6,'yes')

if strcmp(timeyesorno,'yes');necoffset=24;else necoffset=0;end

%Calculate 1D distances from desxval to valid x values on either side
if validxvaltoleft>desxval %e.g. because validxvaltoleft is in the late evening and desxval is in the early morning
    distdesxvaltovalidxvaltoleft=abs(validxvaltoleft-necoffset-desxval);
else
    distdesxvaltovalidxvaltoleft=abs(validxvaltoleft-desxval);
end
if desxval>validxvaltoright %e.g. because desxval is in the late evening and validxvaltoright is in the early morning
    distdesxvaltovalidxvaltoright=abs(desxval-necoffset-validxvaltoright);
else
    distdesxvaltovalidxvaltoright=abs(desxval-validxvaltoright);
end

%Use these distances to define inverse-distance weights
totaldist=distdesxvaltovalidxvaltoleft+distdesxvaltovalidxvaltoright;
weightleftvalidxval=(totaldist-distdesxvaltovalidxvaltoleft)/totaldist;
weightrightvalidxval=(totaldist-distdesxvaltovalidxvaltoright)/totaldist;

%Finally, use the weights to calculate desyval
desyval=validyvaltoleft*weightleftvalidxval+validyvaltoright*weightrightvalidxval;


end

