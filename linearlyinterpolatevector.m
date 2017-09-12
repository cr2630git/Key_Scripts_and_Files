function interpolatedvec = linearlyinterpolatevector(inputvec,maxconsecmissingvalues,missingdataval)
%Interpolates a vector according to the schema promulgated in valuesatstandardtimesfromnonstandard and
%also described in the variable-interpolation section of ncdcHourlyTxtToMat2 (for which it was expressly designed)
%   For each missing value, uses closest values that bracket it on each side to
%   do a linear weighted interpolation at the missing value
%   If the sum of the distances from the bracketing values to the missing one exceeds maxdistsum, 
%   the missing value is considered uninterpolatable
%   For every missing value, this sum equals the number of consecutive missing values+1
%       for a vector 72;-99;-99;87, distsum=3 for both missing values
%       for a vector 72;-99;-99;-99;-99;-99;87, distsum=6 for all missing values
%   Inputvec represents hours (8760 in a year), so distance between two consecutive readings is always 1
%   Values with an absolute value >=missingdataval are considered invalid
maxdistsum=maxconsecmissingvalues+1;

if size(inputvec,1)==1;inputvec=inputvec';end


greenlightnumber1=0;greenlightnumber2=0;
for i=1:size(inputvec,1)
    %Do something if this value is invalid/missing
    if abs(inputvec(i))>=missingdataval
        %Look for possible valid values that **precede** the missing one
        if i>=maxdistsum
            foundvalidvalearlier=0;j=1;
            while j<=maxconsecmissingvalues && foundvalidvalearlier==0
                if abs(inputvec(i-j))<missingdataval
                    earliervalue=inputvec(i-j);earlierdist=j;greenlightnumber1=1;
                    foundvalidvalearlier=1;
                else
                    j=j+1;
                end
            end
            if foundvalidvalearlier==0 %no valid values found preceding & within the prescribed range of this missing one
                inputvec(i)=missingdataval;
            end 
        else %i is at the end of the vector, there's just nothing to be done
            earliervalue=missingdataval;
        end
        
        %Look for possible valid values that **succeed** the missing one
        if i<=size(inputvec,1)-maxconsecmissingvalues
            foundvalidvallater=0;j=1;
            while j<=maxconsecmissingvalues && foundvalidvallater==0
                if abs(inputvec(i+j))<missingdataval
                    latervalue=inputvec(i+j);laterdist=j;greenlightnumber2=1;
                    foundvalidvallater=1;
                else
                    j=j+1;
                end
            end
            if foundvalidvallater==0 %no valid values found succeeding & within the prescribed range of this missing one
                inputvec(i)=missingdataval;
            end
        else %i is at the end of the vector, there's just nothing to be done
            latervalue=missingdataval;
        end
        
        %Lots of checks to be sure everything works as expected
        if greenlightnumber1==1 && greenlightnumber2==1
            if sum(earlierdist,laterdist)<=maxdistsum
                if earliervalue~=missingdataval && latervalue~=missingdataval
                    earlierweight=laterdist/(earlierdist+laterdist);
                    laterweight=earlierdist/(earlierdist+laterdist);
                    inputvec(i)=earlierweight*earliervalue+laterweight*latervalue;
                else
                    inputvec(i)=missingdataval;
                end
            else
                inputvec(i)=missingdataval;
            end
        else
            inputvec(i)=missingdataval;
        end
    end
end


dooldsection=0;
if dooldsection==1
for i=1:size(inputvec,1)
    %Do something if this value is invalid/missing
    if abs(inputvec(i))>=missingdataval
        %Look for possible valid values that precede the missing one
        if i>=3
            if abs(inputvec(i-1))<missingdataval
                earliervalue=inputvec(i-1);earlierdist=1;
            elseif abs(inputvec(i-2))<missingdataval
                earliervalue=inputvec(i-2);earlierdist=2;
            else
                earliervalue=missingdataval;
            end
        else %there's just nothing to be done
            earliervalue=missingdataval;
        end
        %Look for possible valid values that succeed the missing one
        if i<=size(inputvec,1)-2
            if abs(inputvec(i+1))<missingdataval
                latervalue=inputvec(i+1);laterdist=1;
            elseif abs(inputvec(i+2))<missingdataval
                latervalue=inputvec(i+2);laterdist=2;
            else
                latervalue=missingdataval;
            end
        else %there's just nothing to be done
            latervalue=missingdataval;
        end
        
        %Now interpolate from earlier & later values, or keep value missing if it's uninterpolatable
        if earliervalue~=missingdataval && latervalue~=missingdataval
            earlierweight=laterdist/(earlierdist+laterdist);
            laterweight=earlierdist/(earlierdist+laterdist);
            inputvec(i)=earlierweight*earliervalue+laterweight*latervalue;
        else
            inputvec(i)=missingdataval;
        end
    end
end
end

interpolatedvec=inputvec;

end

