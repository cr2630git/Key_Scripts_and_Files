function interpolatedvec = linearlyinterpolatevector(inputvec)
%Interpolates a vector according to the schema promulgated in valuesatstandardtimesfromnonstandard and
%also described in the variable-interpolation section of ncdcHourlyTxtToMat2 (for which it was expressly designed)
%   For each missing value, uses values that are closest or second-closest to it on each side to
%   do a linear weighted interpolation at the missing value
%   On either side, if the closest and second-closest values are both missing, 
%   the missing value is considered uninterpolatable
%   Essentially, this means that 3 consecutive hours with missing values means the final result will have
%   at least one missing value as well
%   Inputvec represents hours (8760 in a year), so distance between two consecutive readings is always 1

missingdataval=99; %values with an absolute value >=missingdataval are considered invalid
if size(inputvec,1)==1;inputvec=inputvec';end


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

interpolatedvec=inputvec;

end

