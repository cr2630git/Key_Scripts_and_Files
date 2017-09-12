function [finalweighteddata] = weightsofsandwichingvalidvalsposs1(inputtimes,inputdata,i,j)
%From an index of interest in an time-denominated inputvec, looks for valid values both before and after
%   Built for 'possibility 1' in testvaluesatstandardtimes
%   If no valid value can be found on either of the sides, both weights are set to a missing value


missingdataval=99;

%Find where and what the earlier valid data is, if any even exists
if j>=2
    if abs(inputdata(j-1))<missingdataval
        greenlightnumber1=1;
        distearliertime=curdescleantime-prevhoursearching;
        earlierdata=inputdata(j-1);
    else
        if j>=3
            if abs(inputdata(j-2))<missingdataval
                greenlightnumber1=1;
                if inputtimes(j-2)>curdescleantime
                    distearliertime=curdescleantime+24-inputtimes(j-2);
                else
                    distearliertime=curdescleantime-inputtimes(j-2);
                end
                earlierdata=inputdata(j-2);
            else
                if j>=4
                    if abs(inputdata(j-3))<missingdataval
                        greenlightnumber1=1;
                        if inputtimes(j-3)>curdescleantime
                            distearliertime=curdescleantime+24-inputtimes(j-3);
                        else
                            distearliertime=curdescleantime-inputtimes(j-3);
                        end
                        earlierdata=inputdata(j-3);
                    else
                        valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
                    end
                else
                    valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
                end
            end
        else
            valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
        end
    end
else
    valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
end

%Find where and what the later valid data is, if any even exists
if abs(inputdata(j))<missingdataval
    greenlightnumber1=1;
    distlatertime=curdescleantime-prevhoursearching;
    laterdata=inputdata(j-1);
else
    if j>=3
        if abs(inputdata(j-2))<missingdataval
            greenlightnumber1=1;
            if inputtimes(j-2)>curdescleantime
                distlatertime=curdescleantime+24-inputtimes(j-2);
            else
                distlatertime=curdescleantime-inputtimes(j-2);
            end
            laterdata=inputdata(j-2);
        else
            if j>=4
                if abs(inputdata(j-3))<missingdataval
                    greenlightnumber1=1;
                    if inputtimes(j-3)>curdescleantime
                        distlatertime=curdescleantime+24-inputtimes(j-3);
                    else
                        distlatertime=curdescleantime-inputtimes(j-3);
                    end
                    laterdata=inputdata(j-3);
                else
                    valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
                end
            else
                valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
            end
        end
    else
        valuesatcleantimes(i,1)=missingval;greenlightnumber1=0;
    end
end


earlierweight=distlatertime/(distearliertime+distlatertime);
laterweight=distearliertime/(distearliertime+distlatertime);
finalweighteddata=earlierweight*earlierdata+laterweight*laterdata;

end

