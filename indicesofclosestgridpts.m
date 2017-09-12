function [matrixofrows,matrixofcols] = indicesofclosestgridpts(inputarray,inputrow,inputcol,howmanygridptsaway)
%Finds closest gridpts to a given gridpt within the array inputarray (with numrows rows and numcols cols), 
    %searching in a box (2*howmanygridptsaway)x(2*howmanygridptsaway)
    %so that (2*howmanygridptsaway+1)^2 gridpts are returned --> i.e. howmanygridptsaway=3 returns itself and 48 neighbors
%   For gridpts along the edge of the array, looks even further out but returns (almost) the same number of gridpts in the end

%Originally written for spatial-scale-of-extremes project

numrows=size(inputarray,1);
numcols=size(inputarray,2);

badrowc=0;
badcolc=0;

for rowsaway=0:howmanygridptsaway
    for colsaway=0:howmanygridptsaway
        %1. +row,+col
        potentialrow=inputrow+rowsaway;
        if potentialrow>numrows %potential row is outside of input array's size, so go the other way
            badrowc=badrowc+1;
            potentialrow=inputrow-howmanygridptsaway-abs(potentialrow-numrows);
        end
        potentialcol=inputcol+colsaway;
        if potentialcol>numcols %potential col is outside of input array's size, so go the other way
            badcolc=badcolc+1;
            potentialcol=inputcol-howmanygridptsaway-abs(potentialcol-numcols);
        end
        %disp('Part 1');disp(rowsaway);disp(colsaway);disp(inputrow+rowsaway);disp(inputcol+colsaway);
        %disp(potentialrow);disp(potentialcol);
        matrixofrows(potentialrow,potentialcol)=potentialrow;
        matrixofcols(potentialrow,potentialcol)=potentialcol;
        %rowsetterc=rowsetterc+1;
        
        %2. +row,-col
        if colsaway~=0 %if =0, no need to repeat this
            potentialrow=inputrow+rowsaway;
            if potentialrow>numrows %potential row is outside of input array's size, so go the other way
                badrowc=badrowc+1;
                potentialrow=inputrow-howmanygridptsaway-abs(potentialrow-numrows);
            end
            potentialcol=inputcol-colsaway;
            if potentialcol<=0 %potential col is outside of input array's size, so go the other way
                badcolc=badcolc+1;
                potentialcol=inputcol+howmanygridptsaway+abs(potentialcol);
            end
            matrixofrows(potentialrow,potentialcol)=potentialrow;
            matrixofcols(potentialrow,potentialcol)=potentialcol;
        end
        
        %3. -row,+col
        if rowsaway~=0
            potentialrow=inputrow-rowsaway;
            if potentialrow<=0 %potential row is outside of input array's size, so go the other way
                badrowc=badrowc+1;
                potentialrow=inputrow+howmanygridptsaway+abs(potentialrow);
            end
            potentialcol=inputcol+colsaway;
            if potentialcol>numcols %potential col is outside of input array's size, so go the other way
                badcolc=badcolc+1;
                potentialcol=inputcol-howmanygridptsaway-abs(potentialcol-numcols);
            end
            matrixofrows(potentialrow,potentialcol)=potentialrow;
            matrixofcols(potentialrow,potentialcol)=potentialcol;
        end
        
        %4. -row,-col
        if rowsaway~=0 && colsaway~=0
            potentialrow=inputrow-rowsaway;
            if potentialrow<=0 %potential row is outside of input array's size, so go the other way
                badrowc=badrowc+1;
                potentialrow=inputrow+howmanygridptsaway+abs(potentialrow);
            end
            potentialcol=inputcol-colsaway;disp(potentialcol);
            if potentialcol<=0 %potential col is outside of input array's size, so go the other way
                badcolc=badcolc+1;
                potentialcol=inputcol+howmanygridptsaway+abs(potentialcol);
            end
            disp('Part 4');disp(rowsaway);disp(colsaway);disp(inputrow+rowsaway);disp(inputcol+colsaway);
            disp(potentialrow);disp(potentialcol);
            matrixofrows(potentialrow,potentialcol)=potentialrow;
            matrixofcols(potentialrow,potentialcol)=potentialcol;
        end
    end
end

matrixofrows=matrixofrows(matrixofrows~=0);
matrixofcols=matrixofcols(matrixofcols~=0);

end

