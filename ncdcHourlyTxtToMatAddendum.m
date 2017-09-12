%ncdcHourlyTxtToMatAddendum
%Intended as an addendum to ncdcHourlyTxtToMat2
%That script both does quality-control checks and pulls
    %timestamps & station metadata as well as meteorological data
%This one only pulls additional selected variables for a subset of the comprehensive set examined before
    %(e.g. for stations that have passed all quality control in ncdcHourlyTxtToMat2, findmaxtwbt, etc)
    %As currently written, those variables are winddir and windspeed -- others could be substituted with a bit of legwork
    
%Note that as long as there were relatively few bad station-year combos (often with e.g. a few 99s at the end), 
%the station overall will pass quality control,
%and the bad values will be just changed to NaN in the removebadstnsanddefinefinaldatat loop of findmaxtwbt
    
%Current runtime: 1.5 min per station, or 4 hours total

rawTxtDir='/Volumes/MacFormatted4TBExternalDrive/NCDC_hourly_station_data_active/';    
yeariwf=1981;yeariwl=2015;
troubleshoot=0;
monthscaredabout=[5;6;7;8;9;10];
numdeshoursthisyear=4416;
monthlengths={'31';'28';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
monthlengthsl={'31';'29';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
monthstarthours=[1;745;1417;2161;2881;3625;4345;5089;5833;6553;7297;8017];
monthendhours=[744;1416;2160;2880;3624;4344;5088;5832;6552;7296;8016;8760];
monthstarthoursl=[1;745;1441;2185;2905;3649;4369;5113;5857;6577;7321;8041];
monthendhoursl=[744;1440;2184;2904;3648;4368;5112;5856;6576;7320;8040;8784];
hours={'00';'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23'};
masterfile=load(strcat(curArrayDir,'temparrayholder220aug31'));
newstnNumList=masterfile.newstnNumList;

maxhourgap=12;
maxvaluegap=5;
maxvaluegapsecondary=23;    %if this is long, one can expect to see identical repeating diurnal cycles when plotting the final data
numsecondarygapsallowed=20;
maxpercdatamissing=3;           %maximum percent of data missing that's tolerated
maxpercbadyears=33.3;           %maximum percent of a station's years disallowed for not meeting the above criteria
    %(i.e. maximum before station is disallowed altogether)

verbosity='laconic'; %'verbose' or 'laconic'
missingDataValvar1=361;missingDataValvar2=100;
setminvalvar1=1;setminvalvar2=1;
if setminvalvar1==1;minValvar1=0;else clear minValvar1;end
if setminvalvar2==1;minValvar2=0;else clear minValvar2;end
strictness='silver';
numstnsdisallowedendobsnotinendmonths=0;
numstnsdisallowedincompletetimevec=0;

%for stn=1:size(newstnNumList,1)
for stn=171:size(newstnNumList,1)
    validstnc=stn;
    curstnnum=newstnNumList(stn);
    thisstnnumbadyears=0;
    fprintf('Current station ordinate is %d\n',stn);
    for year=yeariwf:yeariwl
    %for year=1981:1981
        relyear=year-yeariwf+1;
        if rem(year,4)==0;suffix='l';else suffix='';end %consider leap years
        if strcmp(suffix,'l')
            numhoursthisyear=8784;leapyearornot='leapyear';
        else
            numhoursthisyear=8760;leapyearornot='regyear';
        end
        curmonthlengthsvec=eval(['monthlengths' suffix ';']);
        curmonthstarthoursvec=eval(['monthstarthours' suffix ';']);
        curmonthendhoursvec=eval(['monthendhours' suffix ';']);

        firsthourcaredabout=curmonthstarthoursvec(monthscaredabout(1));
        lasthourcaredabout=curmonthendhoursvec(monthscaredabout(size(monthscaredabout,1)));
        
        curtextfile=strcat(rawTxtDir,'/',num2str(curstnnum),'*',num2str(year));
        a=dir(curtextfile);
        fprintf('Current text file is %s\n',a.name);
        %If data exists, read it in
        %Otherwise (i.e. for stations that are missing a handful of years but are otherwise good),
            %simply set this year's finaldataXXX array to NaN
        if stn==96 && year>=2011 || stn==178 && year>=2011
            finaldatawinddir{relyear,validstnc}=zeros(4416,1);
            finaldatawindspeed{relyear,validstnc}=zeros(4416,1);
        else
            fileID=fopen(strcat(rawTxtDir,a.name),'r');
            data=textscan(fileID,'%s','delimiter','\n','whitespace','');
            data=char(data{1});

            allhourvec=str2num(data(:,24:27))/100;  %hours of all obs, regardless of how close together or far apart they are
            allmonthvec=str2num(data(:,20:21));     %months of all obs

            %Efficiently decide whether a given hour lies in a month we should care about or not
            monthsholdervec=(allmonthvec==monthscaredabout(1));
            for j=2:size(monthscaredabout,1);monthsholdervec=[monthsholdervec allmonthvec==monthscaredabout(j)];end
            monthsholdervec=sum(monthsholdervec,2); %1 if obs lies in a month we care about, 0 if not

            %Now we can eliminate obs we don't care about
            %This is just to evaluate gaps, remainder of variables will be done if the gap test is passed
            hourvecmjjaso=allhourvec(monthsholdervec==1);
            if troubleshoot==1;fprintf('Size of data with MJJASO obs only is %d hours\n',size(hourvecmjjaso,1));end

            %Now, for the actual data-reading and -parsing -- goal is to find all MJJASO obs at the top of an hour
            %At this point we know either the gaps are small and/or there are off-hour obs times we can use for interpolation
            %'Plain' vectors indicate those that have not yet been modified by elimination of off-hour obs or non-desired months
            %This part also saves indices so we know which rows in original data array ('data') 
                %corresponded to what we're using here in creating newdata
            %This index-saving makes it easier both to delete obs, and to track which obs were deleted vs retained
            temporary=double(strcmp(cellstr(data(:,26:27)),'00'));temporary(temporary==0)=-1; %off-hour obs times get -1
            indexsaver=[1:size(data,1)]';indexsaver(temporary==-1)=0;

            newdataminplain=str2num(data(:,26:27));
            newdatahourplain=str2num(data(:,24:25));
            newdatadayplain=str2num(data(:,22:23));
            newdatamonthplain=str2num(data(:,20:21));
            newdatayearplain=str2num(data(:,16:19));


            %%%ACTUALLY GET THE DATA FOR THE ADDITIONAL DESIRED VARIABLES%%%
            curwinddirvec=str2num(data(:,61:63));
            winddirqc=zeros(size(data,1),1);
            winddirqc(str2num(data(:,64))<=1)=1; %good data
            winddirqc(str2num(data(:,64))==4)=1; %good
            winddirqc(str2num(data(:,64))==5)=1; %good
            winddirqc(str2num(data(:,64))==9)=1; %good -- anything other than these codes is bad
            newdatawinddirplain=curwinddirvec;

            curwindspeedvec=str2num(data(:,66:69))/10; %this is a speed, not a velocity, so min value is zero
            windspeedqc=zeros(size(data,1),1);
            windspeedqc(str2num(data(:,70))<=1)=1;
            windspeedqc(str2num(data(:,70))==4)=1;
            windspeedqc(str2num(data(:,70))==5)=1;
            windspeedqc(str2num(data(:,70))==9)=1;
            newdatawindspeedplain=curwindspeedvec;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



            %Eliminate off-hour obs, with hours & min requiring special attention so good values
                %are not accidentally deleted along with the bad ones
            newdatahourplain(newdatahourplain==0)=24;newdataminplain(newdataminplain==0)=60;
            newdatahour=newdatahourplain.*temporary; %negative values for the hour represent off-hour obs times
            newdatamin=newdataminplain.*temporary; %ditto for min
            newdatahour=newdatahour(newdatahour>=0); %eliminate negatives so that only top-of-the-hour obs remain
            %the indices corresponding to these top-of-the-hour obs are stored in indexsaver
            newdatamin=newdatamin(newdatamin>=0);
            newdatahour(newdatahour==24)=0;newdatamin(newdatamin==60)=0; %restore these good values
            newdatamonth=newdatamonthplain(indexsaver>0);
            newdataday=newdatadayplain(indexsaver>0);
            newdatayear=newdatayearplain(indexsaver>0);
            newdatawinddir=newdatawinddirplain(indexsaver>0);
            newdatawindspeed=newdatawindspeedplain(indexsaver>0);
            indexsaver=indexsaver(indexsaver>0); %update indexsaver itself
            if troubleshoot==1
                disp('Before eliminating off-hour values, size of newdatahour, newdataday, and indexsaver are:');
                fprintf('%dx1, %dx1, and %dx1\n',size(newdatahour,1),size(newdataday,1),size(indexsaver,1));
            end


            %Repeat the step we had to do before, efficiently deciding whether a given hour lies in a month we should care about or not
            %Then, use this result to eliminate obs not in months we care about
            %If all obs exist, for MJJASO, size should be 4416 (somewhat less is fixable; certainly not greater, or there's a real problem)
            newdatamonthsholdervec=(newdatamonth==monthscaredabout(1));
            for j=2:size(monthscaredabout,1);newdatamonthsholdervec=[newdatamonthsholdervec newdatamonth==monthscaredabout(j)];end
            newdatamonthsholdervec=sum(newdatamonthsholdervec,2); %1 if obs lies in a month we care about, 0 if not
            newdatamin=newdatamin(newdatamonthsholdervec==1);
            newdatahour=newdatahour(newdatamonthsholdervec==1);
            newdataday=newdataday(newdatamonthsholdervec==1);
            newdatamonth=newdatamonth(newdatamonthsholdervec==1);
            newdatayear=newdatayear(newdatamonthsholdervec==1);
            newdatawinddir=newdatawinddir(newdatamonthsholdervec==1);
            newdatawindspeed=newdatawindspeed(newdatamonthsholdervec==1);
            indexsaver=indexsaver(newdatamonthsholdervec==1);
            if troubleshoot==1;
                disp('After eliminating values in months we do not care about, size of newdatahour, newdataday, and indexsaver are:');
                fprintf('%dx1, %dx1, and %dx1\n',size(newdatahour,1),size(newdataday,1),size(indexsaver,1));
            end

            %Further clean things up by eliminating repeat hours
            %First, have to find where they are
            newdatahourcleanedup=newdatahour; %so we don't contaminate newdatahour/newdataday with these modifications
            newdatadaycleanedup=newdataday;
            keepcleaning=1;numrepeathours=0;indiceswheresame=0;
            while keepcleaning==1
                [newdatahourcleaneduptemp,newdatadaycleaneduptemp,indexwheresame]=elimrepeatvalues(newdatahourcleanedup,newdatadaycleanedup);
                if indexwheresame>0 %this being =0 is how we know there's nothing more to do
                    newdatahourcleanedup=newdatahourcleaneduptemp;
                    newdatadaycleanedup=newdatadaycleaneduptemp;
                    numrepeathours=numrepeathours+1;
                    indiceswheresame(numrepeathours)=indexwheresame;
                    if troubleshoot==1
                        fprintf('Have now found %d repeat hours\n',numrepeathours);
                        %fprintf('Size of newdatahourcleaneduptemp is %d\n',size(newdatahourcleaneduptemp,1));
                        %fprintf('Size of newdatadaycleaneduptemp is %d\n',size(newdatadaycleaneduptemp,1));
                    end
                else
                    keepcleaning=0;
                end
            end
            newdatahour=newdatahourcleanedup;
            newdataday=newdatadaycleanedup;
            %Eliminate these rows in the other arrays as well
            for littlec=1:numrepeathours
                newdatamonth=shiftanddeletefromvec(newdatamonth,indiceswheresame(littlec),1);
                newdatayear=shiftanddeletefromvec(newdatayear,indiceswheresame(littlec),1);
                newdatawinddir=shiftanddeletefromvec(newdatawinddir,indiceswheresame(littlec),1);
                newdatawindspeed=shiftanddeletefromvec(newdatawindspeed,indiceswheresame(littlec),1);
                indexsaver=shiftanddeletefromvec(indexsaver,indiceswheresame(littlec),1);
            end
            if troubleshoot==1;
                fprintf('After eliminating repeat values, size of newdatahour, newdataday, and indexsaver are %dx1, %dx1, and %dx1\n',...
                    size(newdatahour,1),size(newdataday,1),size(indexsaver,1));
            end


            %For troubleshooting:
            %curmin should now be all zeroes, since all off-hour obs were eliminated
            %there should be no more consecutive identical hours
            %before eliminating zeroes, the number of zeroes in curhour, curmin, indexsaver, etc should all be the same




            %Time to comb through preliminary curhour looking for gaps, and to fill them in
            %EITHER with special-obs data if it exists there,
            %OR with plain unaided linear interpolation if it does not
            %Before doing this, newdatahour and indexsaver should and must be the same size 
            %(b/c the latter defines where the former came from)
            numhoursfilledin=0;prevnumhoursfilledin=0;
            indicesatcleantimes=0;hoursatcleantimes=0;
            daysatcleantimes=0;monthsatcleantimes=0;yearsatcleantimes=0;
            winddirsatcleantimes=0;windspeedsatcleantimes=0;
            if troubleshoot==1;fprintf('Before filling gaps, size of newdatahour (and indexsaver) is %dx1\n',size(newdatahour,1));end



            %First thing to do is fill out the ends of the vector (with NaN's for the variable values there)
            %If vector begins not in the first month cared about, or ends not in the last month cared about,
                %the current station/year combination must be disallowed
            if size(newdatamonth,1)==0
                thisstnnumbadyears=thisstnnumbadyears+1;
                keepgoingthisyear(relyear)=0;
                goodstnyearcombo(relyear,stn)=0;
                year=year+1;
                fclose(fileID);
                fprintf(['This station/year combination is disallowed because first obs is not in month %d and/or',...
                    ' last obs is not in month %d\n'],monthscaredabout(1),monthscaredabout(size(monthscaredabout,1)));
                numstnsdisallowedendobsnotinendmonths=numstnsdisallowedendobsnotinendmonths+1;
                continue;
            else
                if newdatamonth(1)~=monthscaredabout(1) || newdatamonth(size(newdatamonth,1))~=monthscaredabout(size(monthscaredabout,1))
                    thisstnnumbadyears=thisstnnumbadyears+1;
                    keepgoingthisyear(relyear)=0;
                    goodstnyearcombo(relyear,stn)=0;
                    year=year+1;
                    fclose(fileID);
                    fprintf(['This station/year combination is disallowed because first obs is not in month %d and/or',...
                        ' last obs is not in month %d\n'],monthscaredabout(1),monthscaredabout(size(monthscaredabout,1)));
                    numstnsdisallowedendobsnotinendmonths=numstnsdisallowedendobsnotinendmonths+1;
                    continue;
                else
                    tentativegoodstnyearcombo(relyear,stn)=1;
                    if newdatahour(1)~=0 || newdataday(1)~=1
                        [fillerhours,fillerdays]=fillendsofavectimeversion(newdatahour(1),newdataday(1),31,'beginning');
                        newdatahour=[fillerhours;newdatahour];
                        newdataday=[fillerdays;newdataday];
                        newdatamonth=[monthscaredabout(1)*ones(size(fillerhours,1),1);newdatamonth];
                        newdatayear=[year*ones(size(fillerhours,1),1);newdatayear];
                        newdatawinddir=[missingDataValvar1*ones(size(fillerhours,1),1);newdatawinddir];
                        newdatawindspeed=[missingDataValvar2*ones(size(fillerhours,1),1);newdatawindspeed];
                        indexsaver=[(1:size(fillerhours,1))';indexsaver];
                    end
                    if troubleshoot==1
                        fprintf('After filling in at the start, sizes of newdatahour and newdataday are now %dx1 and %dx1\n',...
                            size(newdatahour,1),size(newdataday,1));
                    end
                    if newdatahour(size(newdatahour,1))~=23 || newdataday(size(newdataday,1))~=31 
                            %last obs must be in last month cared about, & for Oct month length is 31
                        [fillerhours,fillerdays]=fillendsofavectimeversion(newdatahour(size(newdatahour,1)),newdataday(size(newdataday,1)),31,'end');
                        maxoffillerdays=max(fillerdays);adjby=31-maxoffillerdays;
                        newdatahour=[newdatahour;fillerhours];
                        newdataday=[newdataday;fillerdays+adjby];
                        newdatamonth=[newdatamonth;monthscaredabout(size(monthscaredabout,1))*ones(size(fillerhours,1),1)];
                        newdatayear=[newdatayear;year*ones(size(fillerhours,1),1)];
                        newdatawinddir=[newdatawinddir;missingDataValvar1*ones(size(fillerhours,1),1)];
                        newdatawindspeed=[newdatawindspeed;missingDataValvar2*ones(size(fillerhours,1),1)];
                        maxofindexsaver=max(indexsaver);
                        indexsaver=[indexsaver;(maxofindexsaver-size(fillerhours,1)+1:maxofindexsaver)'];
                    end
                    if troubleshoot==1
                        fprintf('After filling in at the end, sizes of newdatahour and newdataday are now %dx1 and %dx1\n',...
                            size(newdatahour,1),size(newdataday,1));
                    end
                end
            end

            %Now, run through and look for a. temporal gaps that will be filled by interpolation and 
                %b. off-hour obs that will be corrected by weighted averaging
            for j=2:size(newdatahour,1) %j's are the top-of-the-hour hours we have already
            %for j=2:200
                prevhour=newdatahour(j-1);curhour=newdatahour(j);
                prevhoursday=newdataday(j-1);curhoursday=newdataday(j);
                prevhoursmonth=newdatamonth(j-1);curhoursmonth=newdatamonth(j);
                prevmonlen=str2num(curmonthlengthsvec{prevhoursmonth});
                curmonlen=str2num(curmonthlengthsvec{curhoursmonth});
                curprevdiff=curhour-prevhour;
                nummonthsspanned=1; %initial value (changed below if it turns out multiple months are spanned)
                if curprevdiff~=1 || prevhoursday~=curhoursday || prevhoursmonth~=curhoursmonth
                    if (curhour==0 && prevhour==23 && (prevhoursday+1==curhoursday || (prevhoursday==prevmonlen && curhoursday==1)))
                        %everything's as it should be
                    else
                        %i.e. if there is a gap of some kind; curprevdiff can't be <1 since we only 
                        %took top-of-the-hour obs when making newdata
                        prevhoursyear=newdatayear(j-1);curhoursyear=newdatayear(j);
                        if strcmp(verbosity,'verbose')
                            fprintf('There is a gap of some kind at newdatahour row %d\n',j);
                            fprintf('Curhour is %d\n',curhour);fprintf('Prevhour is %d\n',prevhour);
                            fprintf('Day of curhour is %d\n',curhoursday);fprintf('Day of prevhour is %d\n',prevhoursday);
                            fprintf('Month of curhour is %d\n',curhoursmonth);fprintf('Month of prevhour is %d\n',prevhoursmonth);
                        end
                        previndex=indexsaver(j-1);curindex=indexsaver(j);
                        %Figure out how many hours need to be filled in
                        if curprevdiff>1 && prevhoursday==curhoursday && prevhoursmonth==curhoursmonth %gap on same day
                            numhourstofillin=curprevdiff-1;
                            numdaystofillin=1;
                        elseif prevhoursday~=curhoursday && prevhoursmonth==curhoursmonth 
                            %gap spans multiple days but they're in the same month
                            numhourstofillin=curhour+(curhoursday-prevhoursday)*24-prevhour-1;
                            numdaystofillin=curhoursday-prevhoursday+1;
                        elseif prevhoursmonth~=curhoursmonth && prevhoursyear==curhoursyear
                            %gap spans multiple months but they're in the same year
                            nummonthsspanned=curhoursmonth-prevhoursmonth+1;
                            if nummonthsspanned>=3;moninbetweenlena=str2num(curmonthlengthsvec{curhoursmonth-1});end
                            if nummonthsspanned>=4;moninbetweenlenb=str2num(curmonthlengthsvec{curhoursmonth-2});end
                            if nummonthsspanned>=5;moninbetweenlenc=str2num(curmonthlengthsvec{curhoursmonth-3});end
                            if nummonthsspanned>=6;moninbetweenlend=str2num(curmonthlengthsvec{curhoursmonth-4});end
                            if nummonthsspanned>=7;moninbetweenlene=str2num(curmonthlengthsvec{curhoursmonth-5});end
                            if nummonthsspanned>=8;moninbetweenlenf=str2num(curmonthlengthsvec{curhoursmonth-6});end
                            if nummonthsspanned>=9;moninbetweenleng=str2num(curmonthlengthsvec{curhoursmonth-7});end
                            if nummonthsspanned>=10;moninbetweenlenh=str2num(curmonthlengthsvec{curhoursmonth-8});end
                            if nummonthsspanned==2
                                quoteunquotedayofearliermonth=prevmonlen+curhoursday;
                            elseif nummonthsspanned==3
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+curhoursday;
                            elseif nummonthsspanned==4
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+curhoursday;
                            elseif nummonthsspanned==5
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+moninbetweenlenc+curhoursday;
                            elseif nummonthsspanned==6
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+moninbetweenlenc+...
                                    moninbetweenlend+curhoursday;
                            elseif nummonthsspanned==7
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+moninbetweenlenc+...
                                    moninbetweenlend+moninbetweenlene+curhoursday;
                            elseif nummonthsspanned==8
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+moninbetweenlenc+...
                                    moninbetweenlend+moninbetweenlene+moninbetweenlenf+curhoursday;
                            elseif nummonthsspanned==9
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+moninbetweenlenc+...
                                    moninbetweenlend+moninbetweenlene+moninbetweenlenf+moninbetweenleng+curhoursday;
                            elseif nummonthsspanned==10
                                quoteunquotedayofearliermonth=prevmonlen+moninbetweenlena+moninbetweenlenb+moninbetweenlenc+...
                                    moninbetweenlend+moninbetweenlene+moninbetweenlenf+moninbetweenleng+moninbetweenlenh+curhoursday;
                            end
                            numhourstofillin=curhour+(quoteunquotedayofearliermonth-prevhoursday)*24-prevhour-1;
                            numdaystofillin=(quoteunquotedayofearliermonth-prevhoursday)+1;
                        elseif prevhoursyear~=curhoursyear
                            %gap spans multiple years (assuming just 2, and that the months are adjacent)
                            quoteunquotedayofearlieryear=prevmonlen+curhoursday;
                            numhourstofillin=curhour+(quoteunquotedayofearlieryear-prevhoursday)*24-prevhour-1;
                            numdaystofillin=(quoteunquotedayofearlieryear-prevhoursday)+1;
                        end

                        %Determine if there are off-hour obs that we can use to help fill in this gap
                        if curindex>previndex+1 %yes, there are 
                            %gap can be any length (even months long), because there are many off-hour obs within it
                            if strcmp(verbosity,'verbose')
                                fprintf('There are %d off-hour obs to use here\n',...
                                    (curindex-previndex)-1);
                                fprintf('Number of top-of-the-hour hours to fill in is %d\n',numhourstofillin);
                                fprintf('Previndex and curindex are %d and %d\n',previndex,curindex);
                                fprintf('Prevhour and curhour are %0.2f and %0.2f\n',prevhour,curhour);
                            end
                            %In this case, use these off-hour obs to fill the gap
                            %Schema for dealing with present but invalid variable obs: 
                            %   -check if either of the values being interpolated from is missing; if so, use previous and/or subsequent value
                            %   -but, if either of *those* is missing, make the interpolated value missing as well
                            %   this is implemented in the function valuesatstandardtimesfromnonstandard
                            hoursofinterest=findcleanhours(prevhour,curhour,numdaystofillin);
                            numhoursfilledin=numhoursfilledin+size(hoursofinterest,1);
                            inputyear=str2num(data(previndex:curindex,16:19));
                            inputmonth=str2num(data(previndex:curindex,20:21));
                            inputday=str2num(data(previndex:curindex,22:23));
                            inputtimes=str2num(data(previndex:curindex,24:27))/100;
                            inputwinddirs=str2num(data(previndex:curindex,61:63));
                            inputwindspeeds=str2num(data(previndex:curindex,66:69))/10;
                            %plusminusvecfort=cellstr(data(previndex:curindex,88));
                            %plusminusvecfordewpt=cellstr(data(previndex:curindex,94));
                            %comparefort=double(strcmp(plusminusvecfort,'+'));comparefort(comparefort==0)=-1;
                            %comparefordewpt=double(strcmp(plusminusvecfordewpt,'+'));comparefordewpt(comparefordewpt==0)=-1;
                            %Multiply sign by absolute value to get actual one
                            %inputwinddirs=inputwinddirs.*comparefort;
                            %inputwindspeeds=inputwindspeeds.*comparefordewpt;

                            %if troubleshoot==1;disp('Made it to line 526');end


                            %Note down the indices, hours, variables, etc that will be later inserted into 
                            %the full temporally-complete vectors in the appropriate places
                            %i.e. save positions and values to insert for later insertion into newdataxxx
                            if troubleshoot==1
                                disp('hoursofinterest: ');disp(hoursofinterest);
                                disp('inputtimes: ');disp(inputtimes);
                                disp('inputtemps: ');disp(inputwinddirs);
                                disp('inputday: ');disp(inputday);
                                fprintf('prevnumhoursfilledin (previously): %d\n',prevnumhoursfilledin);
                                fprintf('numhourstofillin (here): %d\n',numhourstofillin);
                                fprintf('numhoursfilledin (total so far): %d\n',numhoursfilledin);
                                fprintf('Size of hoursofinterest is %d\n',size(hoursofinterest,1));
                                fprintf('Size of inputtimes is %d\n',size(inputtimes,1));
                                fprintf('Size of input[var1]s is %d\n',size(inputwinddirs,1));
                                fprintf('Reminder: current j (index of newdatahour & indexsaver) is %d\n',j);
                                %Size(hoursofinterest) should equal numhourstofillin, and equivalently numhoursfilledin-prevnumhoursfilledin
                            end
                            indicesatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=...
                                [j+(prevnumhoursfilledin-1):j+(prevnumhoursfilledin-1)+(numhourstofillin-1)]';
                            hoursatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=...
                                findcleanhours(inputtimes(1),inputtimes(size(inputtimes,1)),numdaystofillin);
                            %Times can't be directly averaged -- they demand special treatment
                            if hoursofinterest(1)==0;inputday(1)=inputday(1)+1;end %need to advance so that 
                                %there is not confusion b/c inputtimes begins in late evening and hoursofinterest begins at midnight
                            [daytemp,monthtemp,yeartemp]=timevecfromhourvec(hoursofinterest,inputday(1),inputmonth(1),...
                                curmonthlengthsvec{inputmonth(1)},nummonthsspanned,inputyear(1),leapyearornot);
                            daysatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=daytemp;
                            monthsatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=monthtemp;
                            yearsatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=yeartemp;
                            %Variables like T & dewpt can be directly averaged -- but the nefarious effect of missing data must be addressed
                            winddirsatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=...
                                valuesatstandardtimesfromnonstandard2(hoursofinterest,inputtimes,inputday,inputwinddirs,missingDataValvar1);
                            windspeedsatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=...
                                valuesatstandardtimesfromnonstandard2(hoursofinterest,inputtimes,inputday,inputwindspeeds,missingDataValvar2);
                            if troubleshoot==1
                                curdatestr=strcat(num2str(inputmonth),'/',num2str(inputday),'/',num2str(inputyear));
                                hourfractions=hoursatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)/24;
                                serialnumbers(prevnumhoursfilledin+1:numhoursfilledin,1)=datenum(curdatestr(1,:))+hourfractions;
                            end

                            %if troubleshoot==1;disp('Made it to line 569');end
                            if strcmp(verbosity,'verbose')
                                fprintf('Clean hours newly filled in are %0.0f\n',hoursatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1));
                                if troubleshoot==1
                                    fprintf('This gap ended on %s\n',curdatestr(1,:));
                                    fprintf('Serial numbers of those hours are %0.2f\n',serialnumbers(prevnumhoursfilledin+1:numhoursfilledin,1));
                                    fprintf('Addition to tempsatcleantimes: %0.2f\n',winddirsatcleantimes(numhoursfilledin,1));
                                    fprintf('Addition to dewptsatcleantimes: %0.2f\n',windspeedsatcleantimes(numhoursfilledin,1));
                                end
                                fprintf('Total # of hours filled in so far is %d\n',numhoursfilledin);fprintf('\n');
                            end
                            prevnumhoursfilledin=numhoursfilledin;

                        else %there exist no off-hour obs to use, and so interpolation must be plain and unaided
                            %if running properly, this means that this loop should only be entered if the gap is <=maxhourgap hours
                            if strcmp(verbosity,'verbose')
                                disp('There are no off-hour obs to use in this gap');
                                fprintf('Number of hours to fill in is %d\n',numhourstofillin);
                            end
                            cleanhourshere=findcleanhours(prevhour,curhour,numdaystofillin);
                            numhoursfilledin=numhoursfilledin+size(cleanhourshere,1);
                            prevtime=str2num(data(previndex,24:27))/100;nominalcurtime=str2num(data(curindex,24:27))/100;
                            inputyear=str2num(data(previndex,16:19));
                            inputmonth=str2num(data(previndex,20:21));
                            inputday=str2num(data(previndex,22:23));
                            prevtemp=str2num(data(previndex,89:92))/10;if strcmp(data(previndex,88),'-');prevtemp=-prevtemp;end
                            prevdewpt=str2num(data(previndex,95:98))/10;if strcmp(data(previndex,92),'-');prevdewpt=-prevdewpt;end
                            curtemp=str2num(data(curindex,89:92))/10;if strcmp(data(curindex,88),'-');curtemp=-curtemp;end
                            curdewpt=str2num(data(curindex,95:98))/10;if strcmp(data(curindex,92),'-');curdewpt=-curdewpt;end

                            %Note down the indices, hours, variables, etc that will be later inserted into the full 8760-hour vectors
                                %in the appropriate places
                            %i.e. save positions and values to insert for later insertion into newdataxxx
                            if troubleshoot==1
                                fprintf('prevnumhoursfilledin (previously): %d\n',prevnumhoursfilledin);
                                fprintf('numhourstofillin (here): %d\n',numhourstofillin);
                                fprintf('numhoursfilledin (total so far): %d\n',numhoursfilledin);
                                disp('prevtemp: ');disp(prevtemp);disp('curtemp: ');disp(curtemp);
                                disp('prevdewpt: ');disp(prevdewpt);disp('curdewpt: ');disp(curdewpt);
                                disp('inputday: ');disp(inputday);
                            end
                            for k=1:size(cleanhourshere,1)
                                numhoursfilledin=numhoursfilledin+1;
                                indicesatcleantimes(numhoursfilledin,1)=j+(numhoursfilledin-1);
                                hoursatcleantimes(numhoursfilledin,1)=...
                                    interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,prevtime,nominalcurtime,'yes');
                                daysatcleantimes(numhoursfilledin,1)=...
                                    interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,inputday,inputday,'yes');
                                monthsatcleantimes(numhoursfilledin,1)=...
                                    interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,inputmonth,inputmonth,'yes');
                                yearsatcleantimes(numhoursfilledin,1)=...
                                    interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,inputyear,inputyear,'yes');
                                winddirsatcleantimes(numhoursfilledin,1)=...
                                    interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,prevtemp,curtemp,'yes');
                                windspeedsatcleantimes(numhoursfilledin,1)=...
                                    interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,prevdewpt,curdewpt,'yes');
                                if troubleshoot==1
                                    curdatestr=strcat(num2str(inputmonth),'/',num2str(inputday),'/',num2str(inputyear));
                                    hourfractions=cleanhourshere(k)/24;
                                    serialnumbers(numhoursfilledin,1)=datenum(curdatestr(1,:))+hourfractions;
                                end
                                prevnumhoursfilledin=numhoursfilledin;
                                if strcmp(verbosity,'verbose')
                                    if troubleshoot==1
                                        fprintf('This gap ended on %s\n',curdatestr(1,:));
                                        fprintf('Serial number of that hour is %0.2f\n',serialnumbers(numhoursfilledin,1));
                                        disp('addition to tempsatcleantimes: ');disp(winddirsatcleantimes(numhoursfilledin,1));
                                        disp('addition to dewptsatcleantimes: ');disp(windspeedsatcleantimes(numhoursfilledin,1));
                                    end
                                    fprintf('Clean hour newly filled in is %0.0f; previous and following are %d and %d\n',...
                                        hoursatcleantimes(numhoursfilledin,1),prevhour,curhour);
                                    fprintf('Total # of hours filled in so far is %d\n',numhoursfilledin);fprintf('\n');
                                end
                            end
                        end
                    end
                end
            end

            %Insert newly interpolated hours, variables, etc into newdataxxx to fill it out to its full complete destiny
            finaldatahour=newdatahour;finaldatayear=newdatayear;
            finaldatamonth=newdatamonth;finaldataday=newdataday;
            newdatawinddir2=newdatawinddir;newdatawindspeed2=newdatawindspeed;
            for j=1:size(indicesatcleantimes,1)
                if size(finaldataday,1)<numdeshoursthisyear
                    finaldatahour=shiftandinsertintovec(finaldatahour,indicesatcleantimes(j)+1,hoursatcleantimes(j));
                    finaldatayear=shiftandinsertintovec(finaldatayear,indicesatcleantimes(j)+1,yearsatcleantimes(j));
                    finaldatamonth=shiftandinsertintovec(finaldatamonth,indicesatcleantimes(j)+1,monthsatcleantimes(j));
                    finaldataday=shiftandinsertintovec(finaldataday,indicesatcleantimes(j)+1,daysatcleantimes(j));
                    newdatawinddir2=shiftandinsertintovec(newdatawinddir2,indicesatcleantimes(j)+1,winddirsatcleantimes(j));
                    newdatawindspeed2=shiftandinsertintovec(newdatawindspeed2,indicesatcleantimes(j)+1,windspeedsatcleantimes(j));
                end
            end

            %Do serial numbers only if troubleshooting, to be able to otherwise slim script down the maximum possible amount
            if troubleshoot==1
                disp('Made it to line 722');fprintf('relyear and validstnc are %d and %d\n',relyear,validstnc);
                %disp('Newdatahour2(1775:1805),Newdataday2(1775:1805),Newdatamonth2(1775:1805),Newdatayear2(1775:1805)');
                %disp(newdatahour2(1775:1805));disp(newdataday2(1775:1805));disp(newdatamonth2(1775:1805));disp(newdatayear2(1775:1805));
                newdataserialnumbers2={};
                newdataserialnumbers2{relyear,validstnc}=datenum(strcat(num2str(finaldatamonth),'/',num2str(finaldataday),'/',...
                    num2str(finaldatayear)))+finaldatahour./24;
                %disp('Newdataserialnumbers2{relyear,validstnc}(1775:1805) is');disp(newdataserialnumbers2{relyear,validstnc}(1775:1805));
                fprintf('Before filling gaps, size of newdataserialnumbers2 is %d\n',size(newdataserialnumbers2{relyear,validstnc},1));
            end
            %More troubleshooting, if necessary
            %for j=2:8756;prevsn=newdataserialnumbers2(j-1);cursn=newdataserialnumbers2(j);diffhere(j)=cursn-prevsn;end
            %figure(figc);clf;figc=figc+1;plot(diffhere);

            %Finalize arrays of additional desired variables, and prepare to store them
            finaldatawinddir{relyear,validstnc}=newdatawinddir2;
            finaldatawindspeed{relyear,validstnc}=newdatawindspeed2;
            %fprintf('After filling temporal gaps, final size of finaldatahour is %d\n',size(finaldatahour,1)); 
                %others should be of identical size, e.g. all should be 4416x1


            %To be able to continue, times must be all filled in
            %At this point, interpolation of values has not yet been done - do it now!!
            if size(finaldatahour,1)==numdeshoursthisyear
                %Now, examine mjjasotemp and mjjasodewpt to determine how many value gaps (a.k.a. missing values) there are, and how long they are
                %This is where we see if the gaps >maxvaluegap but <=maxvaluegapsecondary can be tolerated (if both bracketing values
                    %are <90th percentile of that array)
                maxmjjasowinddir=max(finaldatawinddir{relyear,validstnc});
                maxmjjasowindspeed=max(finaldatawindspeed{relyear,validstnc});
                plotvaluesbeforeinterp=0;
                if troubleshoot==1 && plotvaluesbeforeinterp==1
                    fprintf('Maxes of mjjasotemp and mjjasodewpt BEFORE interpolation are %0.0f and %0.0f respectively\n',...
                        maxmjjasowinddir,maxmjjasowindspeed);
                    figure(554);clf;plot(finaldatawinddir{relyear,validstnc});hold on;plot(finaldatawindspeed{relyear,validstnc},'r');
                    title(sprintf('Final T & dewpt BEFORE interpolation: Station %d, Year %d',curstnnum,year),...
                    'FontSize',16,'fontweight','bold','fontname','arial');
                    xlabel('Hour count (MJJASO only)','FontSize',16,'fontweight','bold','fontname','arial');
                    ylabel('Temperature (deg C)','FontSize',16,'fontweight','bold','fontname','arial');
                    set(gca,'FontSize',12,'fontweight','bold','fontname','arial');
                end


                %Ensure that bracketing values don't exceed the 90th percentile with respect to either T or dewpt
                letsinterpolate=1; %default
                for varc=1:2
                    if varc==1
                        thisarr=finaldatawinddir{relyear,validstnc};missingDataVal=missingDataValvar1;
                    elseif varc==2
                        thisarr=finaldatawindspeed{relyear,validstnc};missingDataVal=missingDataValvar2;
                    end
                    arr90p=quantile(thisarr,0.9);
                    [gaplengths,gaplocations]=findgapsandlengths(thisarr,missingDataVal);
                    [maxconsecmissing,~]=size(gaplengths);
                    if maxconsecmissing>maxvaluegapsecondary %gap is too long, there's no hope
                        maxmjjasowinddir=missingDataVal;maxmjjasowindspeed=missingDataVal;letsinterpolate=0;
                    elseif maxconsecmissing>maxvaluegap && maxconsecmissing<=maxvaluegapsecondary %there may be hope
                        numsecondarygaps=0;
                        if size(gaplengths,1)>=maxvaluegap+1;numsecondarygaps=numsecondarygaps+gaplengths(maxvaluegap+1);end
                        if size(gaplengths,1)>=maxvaluegap+2;numsecondarygaps=numsecondarygaps+gaplengths(maxvaluegap+2);end
                        if size(gaplengths,1)>=maxvaluegap+3;numsecondarygaps=numsecondarygaps+gaplengths(maxvaluegap+3);end
                        if numsecondarygaps<=numsecondarygapsallowed %hope continues
                            %Now, let's see if bracketing values on both sides of all these intermediate gaps are <=90th percentile
                            for row=maxvaluegap+1:size(gaplocations,1) %row corresponds to the length of the gap catalogued (if any even exists)
                                for col=2:size(gaplocations,2)
                                    if gaplocations(row,col)>0
                                        prevgoodindex=gaplocations(row,col)-1;
                                        prevgoodval=thisarr(prevgoodindex);
                                        nextgoodindex=gaplocations(row,col)+row;
                                        nextgoodval=thisarr(nextgoodindex);
                                        if prevgoodval<arr90p && nextgoodval<arr90p
                                            letsinterpolate=1;
                                        else
                                            letsinterpolate=0;
                                        end
                                    end
                                end
                            end
                        else %there are too many intermediate gaps to reasonably fill them all in
                            maxmjjasowinddir=missingDataVal;maxmjjasowindspeed=missingDataVal;letsinterpolate=0;
                        end
                    else %maxconsecmissing<=maxvaluegap so there is definitely hope
                        letsinterpolate=1;
                    end
                end



                %Now that the times are all filled out, interpolate missing/invalid variable values
                %This proceeds only if array was found to meet all necessary conditions for size and characteristics of gaps
                %The interpolation scheme is the same as in the function valuesatstandardtimesfromnonstandard, viz.:
                    %use values from either side of missing value, either closest, second-closest, third-closest, or fourth-closest
                    %i.e. need at least one of these from either side to be valid to be able to interpolate at X
                %The maximum allowable number of consecutive missing hours is set in the function linearlyinterpolatevector
                %Rule promulgated here is that no MJJASO day can have a single uninterpolatable T *or* dewpt value
                if letsinterpolate==1
                    finaldatawinddir{relyear,validstnc}=linearlyinterpolatevector(finaldatawinddir{relyear,validstnc},maxvaluegapsecondary,missingDataValvar1);
                    finaldatawindspeed{relyear,validstnc}=linearlyinterpolatevector(finaldatawindspeed{relyear,validstnc},maxvaluegapsecondary,missingDataValvar2);
                    %Eliminate the slightly-too-large and slightly-too-small values that were created in the process of interpolation
                    temp=finaldatawinddir{relyear,validstnc};temp2=temp>=missingDataValvar1;temp(temp2)=missingDataValvar1-1;
                    finaldatawinddir{relyear,validstnc}=temp;
                    temp=finaldatawindspeed{relyear,validstnc};temp2=temp>=missingDataValvar2;temp(temp2)=missingDataValvar2-1;
                    finaldatawindspeed{relyear,validstnc}=temp;
                    exist minValvar1;
                    if ans==1
                        temp=finaldatawinddir{relyear,validstnc};temp2=temp<minValvar1;temp(temp2)=minValvar1;
                        finaldatawinddir{relyear,validstnc}=temp;
                    end
                    exist minValvar2;
                    if ans==1
                        temp=finaldatawindspeed{relyear,validstnc};temp2=temp<minValvar2;temp(temp2)=minValvar2;
                        finaldatawindspeed{relyear,validstnc}=temp;
                    end

                    if troubleshoot==1;fprintf('Size of finaldatawinddir after interpolation is %d\n',size(finaldatawinddir{relyear,validstnc},1));end

                    %Check to ensure that 
                        %a. in the platinum case, no MJJASO day has a single uninterpolatable T *or* dewpt value OR
                        %b. in the silver case, the only uninterpolatable values are within 3 days of the start or end of the period of interest
                    %If these conditions aren't met, then this station/year combination is disallowed
                    if strcmp(strictness,'platinum')
                        maxmjjasowindwinddir=max(finaldatawinddir{relyear,validstnc});
                        maxmjjasowindspeed=max(finaldatawindspeed{relyear,validstnc});
                    elseif strcmp(strictness,'silver')
                        maxmjjasowinddir=max(finaldatawinddir{relyear,validstnc}(73:size(finaldatawinddir{relyear,validstnc},1)-72));
                        maxmjjasowindspeed=max(finaldatawindspeed{relyear,validstnc}(73:size(finaldatawinddir{relyear,validstnc},1)-72));
                    end
                    if troubleshoot==1
                        fprintf('Maxes of mjjasotemp and mjjasodewpt after interpolation are %0.0f and %0.0f respectively\n',...
                            maxmjjasowinddir,maxmjjasowindspeed);
                        plotvaluesafterinterp=0;
                        if troubleshoot==1 && plotvaluesafterinterp==1
                            figure(figc);figc=figc+1;clf;plot(finaldatawinddir{relyear,validstnc});hold on;plot(finaldatawindspeed{relyear,validstnc},'r');
                            title(sprintf('Final T & dewpt AFTER interpolation: Station %d, Year %d',curstnnum,year),...
                            'FontSize',16,'fontweight','bold','fontname','arial');
                            xlabel('Hour count (MJJASO only)','FontSize',16,'fontweight','bold','fontname','arial');
                            ylabel('Temperature (deg C)','FontSize',16,'fontweight','bold','fontname','arial');
                            set(gca,'FontSize',12,'fontweight','bold','fontname','arial');
                        end
                    end
                    %Find max consecutive number of missing values, to be able to save and report this statistic
                    maxconsecmissingvalswinddir=0;maxconsecmissingvalswindspeed=0;
                    numconsecwinddirmissinghere=0;numconsecwindspeedmissinghere=0;
                    missingwinddirvalsonlyatend=0;missingwindspeedvalsonlyatend=0;
                    for k=1:lasthourcaredabout-firsthourcaredabout+1
                        if finaldatawinddir{relyear,validstnc}(k)>=missingDataValvar1
                            numconsecwinddirmissinghere=numconsecwinddirmissinghere+1;
                        else
                            if numconsecwinddirmissinghere>maxconsecmissingvalswinddir
                                maxconsecmissingvalswinddir=numconsecwinddirmissinghere;
                            end
                            numconsecwinddirmissinghere=0;
                        end
                        if finaldatawindspeed{relyear,validstnc}(k)>=missingDataValvar2
                            numconsecwindspeedmissinghere=numconsecwindspeedmissinghere+1;
                        else
                            if numconsecwindspeedmissinghere>maxconsecmissingvalswindspeed
                                maxconsecmissingvalswindspeed=numconsecwindspeedmissinghere;
                            end
                            numconsecwindspeedmissinghere=0;
                        end


                        %Account for the fact that vector may end in missing vals
                        if k==lasthourcaredabout-firsthourcaredabout+1 && numconsecwinddirmissinghere>maxconsecmissingvalswinddir
                            if maxconsecmissingvalswinddir==0;missingwinddirvalsonlyatend=1;end %if everything was OK right up until the end
                            maxconsecmissingvalswinddir=numconsecwinddirmissinghere;
                        end
                        if k==lasthourcaredabout-firsthourcaredabout+1 && numconsecwindspeedmissinghere>maxconsecmissingvalswindspeed
                            if maxconsecmissingvalswindspeed==0;missingwindspeedvalsonlyatend=1;end %if everything was OK right up until the end
                             maxconsecmissingvalswindspeed=numconsecwindspeedmissinghere;
                        end
                    end
                    maxconsecmissing=max(maxconsecmissingvalswinddir,maxconsecmissingvalswindspeed);
                else
                    maxmjjasowinddir=missingDataValvar1;maxmjjasowindspeed=missingDataValvar2;
                    missingwinddirvalsonlyatend=0;missingwindspeedvalsonlyatend=0; %defaults
                end


                %Determine if there were any uninterpolatable MJJASO T or dewpt values, and if so, disallow station/year combo
                if maxmjjasowinddir>=missingDataValvar1 || maxmjjasowindspeed>=missingDataValvar2
                    if missingwinddirvalsonlyatend==1 && maxconsecmissingvalswinddir<=6 || missingwindspeedvalsonlyatend==1 && maxconsecmissingvalswindspeed<=6
                        %There were some consecutive missing values but they're only at the very end of the months of interest,
                        %so we'll let them slide

                        %Check if all the hours were filled in, and if yes output a message saying so
                        %Must have zero tolerance in final array size (otherwise dates will be off and comparisons will be futile)

                        if size(finaldatahour,1)==numdeshoursthisyear && tentativegoodstnyearcombo(relyear,i)==1
                            fprintf('For year %d and station %d, everything looks good and is ready to be saved\n',year,curstnnum);
                            goodstnyearcombo(relyear,stn)=1; %keep this as a good stnyearcombo
                        else
                            goodstnyearcombo(relyear,stn)=0;
                            thisstnnumbadyears=thisstnnumbadyears+1;
                        end
                    else
                        if strcmp(strictness,'platinum')
                            fprintf(['This station/year combination is disallowed because of %d separate incidents of',...
                                ' %d consecutive missing MJJASO T and/or dewpt values that are not interpolatable\n'],...
                                gaplengths(size(gaplengths,1)),maxconsecmissing);
                        elseif strcmp(strictness,'silver')
                            fprintf(['This station/year combination is disallowed because of %d separate incidents of',...
                                ' >=%d consecutive missing MJJASO T and/or dewpt values that are not interpolatable\n'],...
                                sum(gaplengths(maxvaluegap+1:size(gaplengths,1))),maxvaluegap+1);
                        end
                        finaldatawinddir{relyear,validstnc}=zeros(4416,1);
                        finaldatawindspeed{relyear,validstnc}=zeros(4416,1);
                        goodstnyearcombo(relyear,stn)=0;
                        year=year+1;
                        fclose(fileID);
                        continue;
                    end
                else
                    %Check if all the hours were filled in, and if yes output a message saying so
                    %Must have zero tolerance in final array size (otherwise dates will be off and comparisons will be futile)
                    if size(finaldatahour,1)==numdeshoursthisyear && tentativegoodstnyearcombo(relyear,stn)==1
                        fprintf('For year %d and station %d, everything looks good and is ready to be saved\n',year,curstnnum);
                        goodstnyearcombo(relyear,stn)=1; %keep this as a good stnyearcombo
                    else
                        goodstnyearcombo(relyear,stn)=0;
                        thisstnnumbadyears=thisstnnumbadyears+1;
                    end
                end

            else
                fprintf('This station/year combination is disallowed because the time vector contains only %d hours\n',size(finaldatahour,1));
                fprintf('     (it should contain %d hours)\n',numdeshoursthisyear);
                thisstnnumbadyears=thisstnnumbadyears+1;
                finaldatawinddir{relyear,validstnc}=zeros(4416,1);
                finaldatawindspeed{relyear,validstnc}=zeros(4416,1);
                keepgoingthisyear(relyear)=0;
                goodstnyearcombo(relyear,stn)=0;
                numstnsdisallowedincompletetimevec=numstnsdisallowedincompletetimevec+1;
                year=year+1;
                fclose(fileID);
                continue;
            end

            %Whether this year ended up being valid or not, need to close the file that was being read
            fclose(fileID);
        end
    end
    
    %Save arrays periodically at checkpoints, building up to the end where everything is included
    if rem(validstnc,5)==0
        fprintf('\n');disp('At a checkpoint, so saving data for all the valid stations thus far');
        save(strcat(curDir,'addendumncdcholder'),'finaldatawinddir','finaldatawindspeed','goodstnyearcombo');
    end
end

%One last save
fprintf('\n');disp('At a checkpoint, so saving data for all the valid stations thus far');
save(strcat(curDir,'addendumncdcholder'),'finaldatawinddir','finaldatawindspeed','goodstnyearcombo');



