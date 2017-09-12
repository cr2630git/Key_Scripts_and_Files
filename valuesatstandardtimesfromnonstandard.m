function valuesatcleantimes = valuesatstandardtimesfromnonstandard(descleantimes,inputtimes,inputday,inputdata)
%Given an input of data at messy/nonstandard times, converts them using linear interpolation to values at standard times
%   In current configuration, checks values 3 preceding & succeeding values in search of valid ones to use for interpolation
%   Can do this for multiple days as well, not just a single one -- but can't deal with inputday where a day is skipped wholesale
%   If inputdata are times themselves (e.g. days or months), use function timevecfromhourvec instead

%   In calling this function ***inputtimes & inputdata must include on either end times for which values are known***,
%   so that they completely bracket the descleantimes -- these known values are not included in the 
%   final outputted valuesatcleantimes

%   Number of nonstandard and standard times used as input need not be the same
%   However, times must be in chronological order and in DECIMAL FORM
%   Size of inputtimes and inputdata must be the same since they are supposed to correspond!!

%   Schema for dealing with present but invalid variable obs: 
%   -check if either of the values being interpolated from is missing; if so, use previous and/or subsequent value
%   -but, if either of *those* is missing, make the interpolated value missing as well

%   Script assumes these inputtimes are in the range 0<=time<24
%   Example: valuesatcleantimes=valuesatstandardtimesfromnonstandard([3;4],[2;2.17;2.31;5],[90;89;88;85]);

troubleshoot=1; %whether to display troubleshooting messages
missingval=99;  %numbers with absolute values greater than or equal to this are assumed to be missing or invalid

%Ensure that all inputs are column vectors before proceeding
size1=size(descleantimes,1);if size1==1;descleantimes=descleantimes';end
size2=size(inputtimes,1);if size2==1;inputtimes=inputtimes';end
size3=size(inputdata,1);if size3==1;inputdata=inputdata';end
%fprintf('Size of descleantimes is %d\n',size(descleantimes,1));
%disp(descleantimes);


%For each descleantime, find the input times that bracket it
%As we are secure in knowing that the input times bracket all the descleantimes,
%if they appear not to numerically it must be because of a midnight getting in the way (Section 2 of this loop)
prevtime=0;prevday=inputday(1);daynum=1;partofalongchain=0;dayapartprevhour=0;firstgoaround=1;
pastsecondelementinlongchain=0;prevj=2;j=2;
for i=1:size(descleantimes,1)
%for i=1:60
    curtime=descleantimes(i,1);%fprintf('descleantime is currently %0.2f\n',curtime);
    
    somethingfound=0;
    while j<=size(inputtimes,1) && somethingfound==0
            %fprintf('inputtime(j) is %0.2f\n',inputtimes(j));
            greenlightnumber1=0;greenlightnumber2=0; %defaults
            if troubleshoot==1
                fprintf('Descleantime is %d\n',curtime);fprintf('j is %d\n',j);
                %fprintf('Inputtimes(j-1) is %0.2f\n',inputtimes(j-1));fprintf('Inputtimes(j) is %0.2f\n',inputtimes(j));
                %fprintf('Curtime is %d\n',curtime);fprintf('Somethingfound is %d\n',somethingfound);fprintf('\n');
                %disp(somethingfound);disp(size(somethingfound));
            end

            %If bracketing times are a day apart, ensure they are treated >24 hours apart (as they are)
                %e.g. if 10 AM on Day 1 and 12 PM on Day 2, then need to go through descleantimes [11;12;13;14;...11 12]
            %Firstgoaround dictates whether a descleantime is closer to
                    %the beginning or the end of a long chain of descleantimes between two bracketing hours


            %Determine how many days & hours are spanned by the given set of inputtimes, and act accordingly
            if inputday(j)==inputday(j-1)+1 %a day farther apart than one would think
                if troubleshoot==1
                    %fprintf('This is line 61 reporting in; my bracketing times are %0.2f and %0.2f\n',...
                    %    inputtimes(j-1),inputtimes(j));
                    %fprintf('Furthermore, my bracketing days are %d and %d\n',...
                    %    inputday(j-1),inputday(j));
                end
                if inputtimes(j-1)>inputtimes(j)
                    lengthofgaptofill=round2(inputtimes(j)+24-inputtimes(j-1),1,'ceil');
                else
                    lengthofgaptofill=round2(inputtimes(j)+24-inputtimes(j-1),1,'ceil');
                end
                if troubleshoot==1
                    fprintf('\n');fprintf('Length of gap to fill is %0.2f hours\n',lengthofgaptofill);
                    fprintf('Descleantime is %0.2f\n',curtime);
                end
                dayapart=1;

                if dayapartprevhour==0
                    firstdescleantimeinlongchain=curtime;firstgoaround=1;partofalongchain=1;
                end
                if curtime==firstdescleantimeinlongchain+1 || (firstdescleantimeinlongchain==23 && curtime==0)
                    pastsecondelementinlongchain=1;
                end

                fprintf('\n');
                if firstgoaround==1 && ~(curtime==0 && i~=1) %i.e. within the first day of a multi-day chain of hours
                    thingtoaddearlier=0;thingtoaddlater=24;disp('line 60');
                else %within the second 24 hours
                    thingtoaddearlier=24;thingtoaddlater=0;disp('line 62');
                end
                if curtime>inputtimes(j)
                    disp('line 65');%distlatertimetocurtime=inputtimes(j)+48-curtime;
                    distlatertimetocurtime=inputtimes(j)+thingtoaddlater-curtime;
                else
                    disp('line 68');%distlatertimetocurtime=inputtimes(j)+24-curtime;
                    distlatertimetocurtime=inputtimes(j)+thingtoaddlater-curtime;
                end
                if inputtimes(j-1)>curtime
                    disp('line 72');%distearliertimetocurtime=curtime+48-inputtimes(j-1);
                    distearliertimetocurtime=curtime+thingtoaddearlier-inputtimes(j-1);
                else
                    disp('line 75');%distearliertimetocurtime=curtime+24-inputtimes(j-1);
                    distearliertimetocurtime=curtime+thingtoaddearlier-inputtimes(j-1);
                end
            else %same day as one would think based on just looking at the hours
                if troubleshoot==1
                    %fprintf('This is line 92 reporting in; my bracketing times are %0.2f and %0.2f\n',...
                    %    inputtimes(j-1),inputtimes(j));
                    %fprintf('Furthermore, my bracketing days are %d and %d\n',...
                    %    inputday(j-1),inputday(j));
                end
                if inputtimes(j-1)>inputtimes(j)
                    lengthofgaptofill=round2(inputtimes(j)+24-inputtimes(j-1),1,'ceil');
                else
                    lengthofgaptofill=round2(inputtimes(j)-inputtimes(j-1),1,'ceil');
                end
                if troubleshoot==1
                    %fprintf('Length of gap to fill is %0.2f hours\n',lengthofgaptofill);
                    %fprintf('Descleantime is %0.2f\n',curtime);
                end
                dayapart=0;

                if curtime>inputtimes(j)
                    distlatertimetocurtime=inputtimes(j)+24-curtime;
                else
                    distlatertimetocurtime=inputtimes(j)-curtime;
                end
                if inputtimes(j-1)>curtime
                    distearliertimetocurtime=curtime+24-inputtimes(j-1);
                else
                    distearliertimetocurtime=curtime-inputtimes(j-1);
                end

            end

            if troubleshoot==1
                %fprintf('Dayapart is %d\n',dayapart);fprintf('Dayapartprevhour is %d\n',dayapartprevhour);
                %fprintf('Firstgoaround is %d\n',firstgoaround);disp('line 99');
            end




            %Determine whether the present descleantime is bracketed by the present inputtimes 
                %-- catalogue things if yes, move on if no
            %This first section of the loop covers most times (those not around midnight)
            if inputtimes(j)>=curtime && inputtimes(j-1)<curtime && somethingfound==0
                curj=j;
                for k=curj:curj+lengthofgaptofill-1
                    thisday=inputday(k);
                    if thisday~=prevday;daynum=daynum+1;end
                    if troubleshoot==1
                        fprintf('Current j and k are %d and %d\n',curj,k);
                        disp('Section 1');
                        fprintf('This descleantime is %0.2f and is at index %d\n',curtime,i);
                        fprintf('Length of gap to fill is %0.2f hours\n',lengthofgaptofill);disp('line 112');
                        fprintf('Bracketing times for this descleantime are %0.2f and %0.2f\n',...
                            inputtimes(j-1),inputtimes(j));
                        if j>=3 && j<=size(inputtimes,1)-1;fprintf('Previous and subsequent times, if necessary, are %0.2f and %0.2f\n',...
                            inputtimes(j-2),inputtimes(j+1));end
                        fprintf('Bracketing days for this descleantime are %0.0f and %0.0f\n',...
                            inputday(j-1),inputday(j));
                        %fprintf('Daynum is %d\n',daynum);
                    end




                    %Check if values to interpolate from are bad, &, if so, 
                    %if values at previous or subsequent times can be substituted
                    if abs(inputdata(j-1))>=missingval
                        if j>=3
                            if abs(inputdata(j-2))<missingval %substitution can be made
                                if inputtimes(j-2)>curtime
                                    distprevioustimetocurtime=curtime+24-inputtimes(j-2);
                                else
                                    distprevioustimetocurtime=curtime-inputtimes(j-2);
                                end
                                distfirsttime=distprevioustimetocurtime;
                                firstdata=inputdata(j-2);
                                greenlightnumber1=1;
                            else
                                if j>=4
                                    if abs(inputdata(j-3))<missingval %substitution can be made
                                        if inputtimes(j-3)>curtime
                                            distprevioustimetocurtime=curtime+24-inputtimes(j-3); 
                                        else
                                            distprevioustimetocurtime=curtime-inputtimes(j-3);
                                        end
                                        distfirsttime=distprevioustimetocurtime;
                                        firstdata=inputdata(j-3);
                                        greenlightnumber1=1;
                                    else
                                        valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                                        greenlightnumber1=0;
                                    end
                                else
                                    valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                                    greenlightnumber1=0;
                                end
                            end
                        else
                            valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                            greenlightnumber1=0;
                        end
                    else %interpolate from the previous value
                        distfirsttime=distearliertimetocurtime;
                        firstdata=inputdata(j-1);
                        greenlightnumber1=1;
                    end
                    if greenlightnumber1==1 %Only need to bother checking if there's a possibility of this all being worth it
                        if abs(inputdata(j))>=missingval
                            if j<=size(inputtimes,1)-1
                                if abs(inputdata(j+1))<missingval %substitution can be made
                                    if curtime>inputtimes(j+1)
                                        distsubsequenttimetocurtime=inputtimes(j+1)+24-curtime;
                                    else
                                        distsubsequenttimetocurtime=inputtimes(j+1)-curtime;
                                    end
                                    distsecondtime=distsubsequenttimetocurtime;
                                    seconddata=inputdata(j+1);
                                    greenlightnumber2=1;
                                else
                                    if j<=size(inputtimes,1)-2
                                        if abs(inputdata(j+2))<missingval %substitution can be made
                                            if curtime>inputtimes(j+2)
                                                distsubsequenttimetocurtime=inputtimes(j+2)+24-curtime; 
                                            else
                                                distsubsequenttimetocurtime=inputtimes(j+2)-curtime; 
                                            end
                                            distsecondtime=distsubsequenttimetocurtime;
                                            seconddata=inputdata(j+2);
                                            greenlightnumber2=1;
                                        else
                                            valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                                            greenlightnumber2=0;
                                        end
                                    else
                                        valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                                        greenlightnumber2=0;
                                    end
                                end
                            else
                                valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                                greenlightnumber2=0;
                            end
                        else
                            distsecondtime=distlatertimetocurtime;
                            seconddata=inputdata(j);
                            greenlightnumber2=1;
                        end
                    else
                        valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                        greenlightnumber2=0;
                    end

                    %Weights and final values with whatever combination of times was found to work
                    if greenlightnumber1==1 && greenlightnumber2==1
                        weightearlier(i)=(distsecondtime)/(distfirsttime+distsecondtime);
                        weightlater(i)=(distfirsttime)/(distfirsttime+distsecondtime);
                        valuesatcleantimes(i,1)=weightearlier(i)*firstdata+weightlater(i)*seconddata;
                    else %have to make it missing, sadly
                        valuesatcleantimes(i,1)=missingval;
                    end


                    if troubleshoot==1
                        fprintf('Distlater is %0.2f\n',distlatertimetocurtime);
                        fprintf('Distearlier is %0.2f\n',distearliertimetocurtime);
                        if greenlightnumber1==1 && greenlightnumber2==1
                            fprintf('Weightlater is %0.2f\n',weightlater(i));fprintf('Weightearlier is %0.2f\n',weightearlier(i));
                        end
                        fprintf('Bracketing j-1 and j are %0.2f and %0.2f\n',j-1,j);
                        fprintf('Inputdata(j-1) and inputdata(j) are %0.2f and %0.2f\n',inputdata(j-1),inputdata(j));
                        fprintf('Valuesatcleantimes(i,1) is %0.2f\n',valuesatcleantimes(i,1));fprintf('\n');
                    end
                    somethingfound=1;disp('line 322');disp(somethingfound);
                    %if dayapart==0
                    %    prevk=k;k=k+1;if troubleshoot==1;disp('line 279');fprintf('\n');end;
                    %elseif dayapart==1
                    %    k=k+lengthofgaptofill;
                    %end
                end
                prevj=j;j=j+lengthofgaptofill;

            %%%% Section 2: now essentially repeat the search of Section 1, but for descleantimes that are around midnight %%%%
            elseif (((((inputtimes(j)>=curtime && inputtimes(j-1)>curtime) ||...
                    (inputtimes(j)<=curtime && inputtimes(j-1)<curtime)) && inputtimes(j-1)>inputtimes(j)))...
                    || (dayapart==1 && ((inputtimes(j)>=curtime && inputtimes(j-1)>curtime) ||...
                    inputtimes(j)<=curtime && inputtimes(j-1)<curtime))) ...
                    && somethingfound==0 

                thisday=inputday(j);
                if thisday~=prevday;daynum=daynum+1;end
                if troubleshoot==1
                    fprintf('Current j is %d\n',j);
                    disp('Section 2');
                    fprintf('This descleantime is %0.2f and is at index %d\n',curtime,i);
                    disp('line 291');
                    fprintf('Bracketing times for this descleantime are %0.2f and %0.2f\n',...
                        inputtimes(j-1),inputtimes(j));
                    fprintf('Bracketing days for this descleantime are %0.0f and %0.0f\n',...
                        inputday(j-1),inputday(j));
                    %fprintf('Daynum is %d\n',daynum);
                end

                dothis=0;
                if dothis==1
                if inputday(j)==inputday(j-1)+1 %a day farther apart than one would think
                    dayapart=1;
                    if inputtimes(j-1)>curtime
                        distearliertimetocurtime=curtime+48-inputtimes(j-1);
                    else
                        distearliertimetocurtime=curtime+24-inputtimes(j-1);
                    end
                    if curtime>inputtimes(j)
                        distlatertimetocurtime=inputtimes(j)+48-curtime;
                    else
                        distlatertimetocurtime=inputtimes(j)+24-curtime;
                    end
                else %same day as one would think
                    dayapart=0;
                    if inputtimes(j-1)>curtime
                        distearliertimetocurtime=curtime+24-inputtimes(j-1);
                    else
                        distearliertimetocurtime=curtime-inputtimes(j-1);
                    end
                    if curtime>inputtimes(j)
                        distlatertimetocurtime=inputtimes(j)+24-curtime;
                    else
                        distlatertimetocurtime=inputtimes(j)-curtime;
                    end
                end
                end

                %Check if values to interpolate from are bad, &, if so, if values at previous or subsequent times can be substituted
                if abs(inputdata(j-1))>=missingval
                    if j>=3
                        if abs(inputdata(j-2))<missingval
                            if inputtimes(j-2)>curtime
                                distprevioustimetocurtime=curtime+24-inputtimes(j-2); %substitution can be made
                            else
                                distprevioustimetocurtime=curtime-inputtimes(j-2); %substitution can be made
                            end
                            distfirsttime=distprevioustimetocurtime;
                            firstdata=inputdata(j-2);
                            greenlightnumber1=1;
                        else
                            if j>=4
                                if abs(inputdata(j-3))<missingval %substitution can be made
                                    if inputtimes(j-3)>curtime
                                        distprevioustimetocurtime=curtime+24-inputtimes(j-3); 
                                    else
                                        distprevioustimetocurtime=curtime-inputtimes(j-3);
                                    end
                                    distfirsttime=distprevioustimetocurtime;
                                    firstdata=inputdata(j-3);
                                    greenlightnumber1=1;
                                else %have to make it missing, sadly
                                    valuesatcleantimes(i,1)=missingval; 
                                    greenlightnumber1=0;
                                end
                            else
                                valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                                greenlightnumber1=0;
                            end
                        end
                    else
                        valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                        greenlightnumber1=0;
                    end
                else
                    distfirsttime=distearliertimetocurtime;
                    firstdata=inputdata(j-1);
                    greenlightnumber1=1;
                end
                if greenlightnumber1==1
                    if abs(inputdata(j))>=missingval
                        if j<=size(inputtimes,1)-1
                            if abs(inputdata(j+1))<missingval %substitution can be made
                                if curtime>inputtimes(j+1)
                                    distsubsequenttimetocurtime=inputtimes(j+1)+24-curtime; 
                                else
                                    distsubsequenttimetocurtime=inputtimes(j+1)-curtime;
                                end
                                distsecondtime=distsubsequenttimetocurtime;
                                seconddata=inputdata(j+1);
                                greenlightnumber2=1;
                            else
                                if j<=size(inputtimes,1)-2
                                    if abs(inputdata(j+2))<missingval %substitution can be made
                                        if curtime>inputtimes(j+2)
                                            distsubsequenttimetocurtime=inputtimes(j+2)+24-curtime; 
                                        else
                                            distsubsequenttimetocurtime=inputtimes(j+2)-curtime;
                                        end
                                        distsecondtime=distsubsequenttimetocurtime;
                                        seconddata=inputdata(j+2);
                                        greenlightnumber2=1;
                                    else %have to make it missing, sadly
                                       valuesatcleantimes(i,1)=missingval; 
                                        greenlightnumber2=0; 
                                    end
                                else %have to make it missing, sadly
                                    valuesatcleantimes(i,1)=missingval; 
                                    greenlightnumber2=0;
                                end
                            end
                        else
                            valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                            greenlightnumber2=0;
                        end
                    else
                        distsecondtime=distlatertimetocurtime;
                        seconddata=inputdata(j);
                        greenlightnumber2=1;
                    end
                else
                    valuesatcleantimes(i,1)=missingval; %have to make it missing, sadly
                    greenlightnumber2=0;
                end

                %Weights and final values with whatever combination of times was found to work
                if greenlightnumber1==1 && greenlightnumber2==1
                    weightearlier(i)=(distsecondtime)/(distfirsttime+distsecondtime);
                    weightlater(i)=(distfirsttime)/(distfirsttime+distsecondtime);
                    valuesatcleantimes(i,1)=weightearlier(i)*firstdata+weightlater(i)*seconddata;
                else %have to make it missing, sadly
                    valuesatcleantimes(i,1)=missingval;
                end

                if troubleshoot==1
                    fprintf('Distlater is %0.2f\n',distlatertimetocurtime);
                    fprintf('Distearlier is %0.2f\n',distearliertimetocurtime);
                    if greenlightnumber1==1 && greenlightnumber2==1
                        fprintf('Weightlater is %0.2f\n',weightlater(i));fprintf('Weightearlier is %0.2f\n',weightearlier(i));
                    end
                    fprintf('Bracketing j-1 and j are %0.2f and %0.2f\n',j-1,j);
                    fprintf('Inputdata(j-1) and inputdata(j) are %0.2f and %0.2f\n',inputdata(j-1),inputdata(j));
                    fprintf('Valuesatcleantimes(i,1) is %0.2f\n',valuesatcleantimes(i,1));
                    fprintf('Descleantime index is %d\n',i);fprintf('\n');
                end
                somethingfound=1;
                if dayapart==0
                    j=j+1;%prevj=j;
                    if troubleshoot==1;disp('line 433');end
                elseif dayapart==1
                    j=j+lengthofgaptofill;
                end
            else %current pair of inputtimes don't bracket any descleantimes, so just move on
                j=j+1;
            end
            if somethingfound==1;disp('line 499');end
            fprintf('We are at line 500, i=%d, and j=%d\n',i,j);
    end

    %Update time and day counts
    prevtime=curtime;
    fprintf('Dayapart is %d\n',dayapart);fprintf('\n');disp('line 504');
    
    
    %if partofalongchain==1;if curtime==firstdescleantimeinlongchain && pastsecondelementinlongchain==1
    %        firstgoaround=0;end;
    %end
    if partofalongchain==1;if curtime==0 && pastsecondelementinlongchain==1
            firstgoaround=0;end;
    end
    if dayapart==0;prevday=thisday;if dayapartprevhour==1;partofalongchain=0;pastsecondelementinlongchain=0;end;end
    %if dayapart==1 && dayapartprevhour==0;firstdescleantimeinlongchain=curtime;end
    dayapartprevhour=dayapart;
end

end

