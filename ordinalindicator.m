function output=ordinalindicator(number)
%For an inputted number, calculates the ordinal indicator
%e.g. for 1 it returns 'st', for 2 'nd', for 3 'rd', etc.
%Intended for use on integers only!
if rem(number,10)==1 && number~=11
    output='st';
elseif rem(number,10)==2 && number~=12
    output='nd';
elseif rem(number,10)==3 && number~=13
    output='rd';
else
    output='th';
end

end

