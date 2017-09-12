function finalweighteddata = weightsofsandwichingvalidvalsposs2(inputtimes,inputdata,curdescleantime,i,j,missingdataval)
%From an index of interest in an time-denominated inputvec, looks for valid values both before and after
%   Built for 'possibility 2' in testvaluesatstandardtimes
%   j is the index of inputtimes which marks the latter time of the pair between which curdescleantime is found
%   If no valid value can be found on either of the sides, both weights are set to a missing value



%Find where and what the earlier valid data is, if any even exists
if j>=2
    if abs(inputdata(j-1))<missingdataval
        greenlightnumber1=1;
        distearliertime=curdescleantime+24-inputtimes(j-1);
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
                        valuesatcleantimes(i,1)=missingdataval;greenlightnumber1=0;
                    end
                else
                    valuesatcleantimes(i,1)=missingdataval;greenlightnumber1=0;
                end
            end
        else
            valuesatcleantimes(i,1)=missingdataval;greenlightnumber1=0;
        end
    end
else
    valuesatcleantimes(i,1)=missingdataval;greenlightnumber1=0;
end

%Find where and what the later valid data is, if any even exists
%If no valid earlier data existed, there's no point in bothering to check here
if greenlightnumber1==1
    if j<=size(inputtimes,1)
        if abs(inputdata(j))<missingdataval
            greenlightnumber2=1;
            distlatertime=inputtimes(j)-curdescleantime;
            laterdata=inputdata(j);
        else
            if j<=size(inputtimes,1)-1
                if abs(inputdata(j+1))<missingdataval
                    greenlightnumber2=1;
                    if inputtimes(j+1)>curdescleantime
                        distlatertime=curdescleantime+24-inputtimes(j+1);
                    else
                        distlatertime=curdescleantime-inputtimes(j+1);
                    end
                    laterdata=inputdata(j+1);
                else
                    if j<=size(inputtimes,1)-2
                        if abs(inputdata(j+2))<missingdataval
                            greenlightnumber2=1;
                            if inputtimes(j+2)>curdescleantime
                                distlatertime=curdescleantime+24-inputtimes(j+2);
                            else
                                distlatertime=curdescleantime-inputtimes(j+2);
                            end
                            laterdata=inputdata(j+2);
                        else
                            valuesatcleantimes(i,1)=missingdataval;greenlightnumber2=0;
                        end
                    else
                        valuesatcleantimes(i,1)=missingdataval;greenlightnumber2=0;
                    end
                end
            else
                valuesatcleantimes(i,1)=missingdataval;greenlightnumber2=0;
            end
        end
    end
else
    valuesatcleantimes(i,1)=missingdataval;greenlightnumber2=0;
end

%if greenlightnumber1==1;disp(distearliertime);disp(earlierdata);end
%if greenlightnumber2==1;disp(distlatertime);disp(laterdata);end

if greenlightnumber1==1 && greenlightnumber2==1
    earlierweight=distlatertime./(distearliertime+distlatertime);
    laterweight=distearliertime./(distearliertime+distlatertime);
    finalweighteddata=earlierweight*earlierdata+laterweight*laterdata;
else
    finalweighteddata=missingdataval;
end

end

