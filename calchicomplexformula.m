function hi = calchicomplexformula(tArr,rhArr)
%Calculates heat index using complex NWS formula
%   T is in F, RH is in %
%   Input T matrix must be associated with heat indices that were preliminarily found
%       to be >=80 -- otherwise results of this formula are not meaningful
%   Requires various constants -- NWS values are the default

rhmultiplier=10.14333127;   %10.14333127 is the NWS default (larger-more weight)
t2multiplier=0.00683783;    %0.00683783 is the NWS default (smaller-more weight)
trh2multiplier=0.00085282;  %0.00085282 is the NWS default (larger-more weight)
rh2multiplier=0.05481717;   %0.05481717 is the NWS default (smaller-more weight)
t2rh2multiplier=0.00000199; %0.00000199 is the NWS default (smaller-more weight)

hi=(-42.379+2.04901523.*tArr+rhmultiplier.*rhArr-0.22475541.*tArr.*rhArr-t2multiplier*tArr.*tArr-...
    rh2multiplier.*rhArr.*rhArr+0.00122874.*tArr.*tArr.*rhArr+...
    trh2multiplier.*tArr.*rhArr.*rhArr-t2rh2multiplier.*tArr.*tArr.*rhArr.*rhArr);

end

