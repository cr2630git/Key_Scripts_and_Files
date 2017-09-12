function [newinputarr,newsecondaryarr,indexwheresame] = elimrepeatvalues(inputarray,secondaryarray)
%Eliminates unwanted consecutive repeated values in inputarray, reducing array size accordingly
%   secondaryarray is used to determine if values are truly repeated (e.g. if inputarray is hours, secondaryarray is days)
%   -- if inputarray values are repeated but secondaryarray ones are not, no action is taken
%   If no secondaryarray is necessary or desired, it can be made identical to inputarray

%   On each run, eliminates just one repeated value
%   Assumes that values will be repeated only twice
%   Assumes that inputarray is a column vector
%   Designed for time arrays (specifically, for use with the hour arrays in ncdcHourlyTxtToMat2)

inputarraytrunc=inputarray(1:size(inputarray,1)-1);
inputarrayshifted=inputarray(2:size(inputarray,1));
secondaryarraytrunc=secondaryarray(1:size(secondaryarray,1)-1);
secondaryarrayshifted=secondaryarray(2:size(secondaryarray,1));

arraytrunc=[inputarraytrunc secondaryarraytrunc];
arrayshifted=[inputarrayshifted secondaryarrayshifted];

%Compare truncated & shifted versions to eliminate consecutive identical values
rowssameness=(arraytrunc==arrayshifted);%disp(rowssameness);
foundyet=0;
for i=1:size(rowssameness,1)
    if sum(rowssameness(i,:))==2 && foundyet==0 %value is repeated in both inputarray and secondaryarray --> marked for elimination
        indexwheresame=i;%disp(indexwheresame);
        foundyet=1;
    end
end

exist indexwheresame;
if ans==0;indexwheresame=0;end

%Reduce inputarray and secondaryarray by 1 to eliminate the consecutive values
newinputpiece=inputarray(indexwheresame+1:size(inputarray,1));
originputpiece=inputarray(1:indexwheresame-1);
%disp(size(origpiece));disp(size(newpiece));
newsecondarypiece=secondaryarray(indexwheresame+1:size(secondaryarray,1));
origsecondarypiece=secondaryarray(1:indexwheresame-1);

newinputarr=[originputpiece;newinputpiece];
newsecondaryarr=[origsecondarypiece;newsecondarypiece];






end

