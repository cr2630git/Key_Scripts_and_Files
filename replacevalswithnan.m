function finalvec = replacevalswithnan(origvec,threshold,stringaboveorbelow)
%Replaces all values on one side of a threshold (either above or below) with NaN
%   The point of this function is to remember the best way to do this retaining the dimensional info of the original vector

%Example: a=[5 6 3;7 12 0;20 6 -1];
%b=replacevalswithnan(a,10,'above');
%--> b=[5 6 3;7 NaN 0;NaN 6 -1];

if strcmp(stringaboveorbelow,'above')
    razor=origvec>threshold;
elseif strcmp(stringaboveorbelow,'below')
    razor=origvec<threshold;
else
    disp('Please enter ''above'' or ''below'' for your choice');
    return;
end

%Razor is now an array of 1's and 0's, where 1's mean "this is a bad value"
%So, we just have to use it to get back the original vector
origvec(razor)=NaN;
finalvec=origvec;

end

