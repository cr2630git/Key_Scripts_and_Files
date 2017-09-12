function perc = pctreltodistn(backgrounddistribution,curval)
%Given an input value, calculates its percentile relative to a background (usually empirical) distribution
%   Originally written for script discomfscoresrecentreanalyses

distnwithcurval=[backgrounddistribution;curval];
refvals=[1:size(distnwithcurval,1)]';
fullarr=[distnwithcurval refvals];
distnfullsorted=sortrows(fullarr);
rowfoundaftersorting=0;row=1;
while row<=size(distnfullsorted,1) && rowfoundaftersorting==0
    if distnfullsorted(row,2)==size(distnfullsorted,1)
        rowtosave=row;
        rowfoundaftersorting=1;
    end
    row=row+1;
end
perc=100*((rowtosave/size(distnfullsorted,1))-(1/(size(distnfullsorted,1)*2)));


end

