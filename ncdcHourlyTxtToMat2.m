function [newstnNumList,newstnNumListnames,newstnNumListlats,newstnNumListlons,newstnNumListelevs,...
    keepgoingthisyear,finaldatat,finaldatadewpt,finaldatawbt,indexsaver,finaldatahour,finaldataday,...
    finaldatamonth,newdataserialnumbers2,newdatahour,newdataday,newdatamonth,newdatat,newdatadewpt,data,...
    indicesatcleantimes,hoursatcleantimes,daysatcleantimes,monthsatcleantimes,tempsatcleantimes,validstnc,...
    numstnsdisallowedtemporalgaps,disallowedstnstemporalgaps,numstnsdisallowedendobsnotinendmonths,numstnsdisallowedtoomuchdatamissing,...
    disallowedstnspercdatamissing,numstnsdisalloweduninterpolatabletordewpt,disallowedstnsuninterpolatabletordewpt,...
    numstnsdisallowedincompletetimevec]=...
    ncdcHourlyTxtToMat2(rawTxtDir,outputDir,stnlisttouse,startYear,stopYear,varNames,missingDataVal,verbosity,troubleshoot,strictness)
%Extracts desired variables from abstruse NCDC-style *hourly* station-observation text files, fills in missing times and converts
%   non-standard times to standard ones, interpolates missing data values insofar as is possible,
%   and puts the final results in nicely organized monthly .mat files -- all the while determining if the station is valid and thus
%   whether to go on to the next step in the process
%   This function is adapted from narrNcToMat (credit to Ethan Coffel for the bulk of that script)


%   There are two versions of this function that can be run:
       %'Platinum' version throws out any station with >maxpercbadyears percent of years where
%   a. there is at least one value gap of >maxhourgap hours where either bracketing value is >=90th percentile for that array,
%   or b. >numsecondarygapsallowed periods of >maxhourgapsecondary consecutive values in MJJASO are missing, 
%   or c. where >maxpercdatamissing percent of the values in MJJASO are missing (after attempts at interpolation), 
%   or d. all the hours are missing in the first or last month desired (foiling attempts at interpolation),
%   or e. where there are no valid obs at all
        %the issue with the platinum version is that <10% or so of stations meet it
        
    %'Silver' version is generally the same except it allows an unlimited number of value gaps of up to 24 hours,
        %so long as both bracketing values are <90th percentile
    %Also, uninterpolatable values (values that =missingDataVal even after attempts at interpolation) are allowed
        %so long as they are all contained within the first or last 3 days of the period of interest
    %This version is expedient for the 30/60 paper, as it retains as much station data as possible


    %Keep in mind there is a distinction between temporal gaps (where the hours themselves must be filled in)
        %and value gaps (where the temp or dewpt values are invalid) -- the latter can be up to maxhourgapsecondary in length,
        %the former only up to maxhourgap since they imply a more-serious lack of information
    %Gaps that are longer than maxhourgap or maxhourgapsecondary (depending on the case) are deemed 'uninterpolatable'
    %%%There's no real harm in interpolating across multiple hours b/c (for max analysis anyway) they won't figure in
%   Full list of stations to choose from (i.e. neweststnlist) is computed in the script readstndata
%   Verbosity ('verbose' or 'laconic') dictates whether to display troubleshooting-oriented comments in the two interpolation loops
%   If troubleshooting:
        %turn off doremainder near the bottom of the script so that everything can be outputted and then examined
        %also be sure that verbosity='verbose' and troubleshoot=1
%   To run this in main window and not as a function, simply define year and curstnnum, then run everything from curtextfile= to just before
%       the loop that fills gaps by interpolation
%***Note that WBT is calculated within script from temp & dewpt***

%All relevant .gz files must already have been unzipped using unzipandelimstnswithmissingdata loop in readstndata

%Example call during troubleshooting: 
%[newstnNumList,newstnNumListnames,keepgoingthisyear,finaldatat,finaldatadewpt,finaldatawbt,indexsaver,newdatahour2,newdataday2,...
%    newdatamonth2,newdataserialnumbers2,newdatahour,newdataday,newdatamonth,newdatat,newdatadewpt,data,...
%    indicesatcleantimes,hoursatcleantimes,daysatcleantimes,monthsatcleantimes,tempsatcleantimes,validstnc,...
%    numstnsdisallowedtemporalgaps,disallowedstnstemporalgaps,numstnsdisallowedendobsnotinendmonths,numstnsdisallowedtoomuchdatamissing,...
%    disallowedstnspercdatamissing,numstnsdisalloweduninterpolatabletordewpt,disallowedstnsuninterpolatabletordewpt,...
%    numstnsdisallowedincompletetimevec]=...
%   ncdcHourlyTxtToMat2('/Volumes/ExternalDriveA/NCDC_hourly_station_data_active/',...
%   '/Volumes/ExternalDriveA/NCDC_hourly_station_data_mat/',...
%   [700260],1981,1981,{'temp'},50,'verbose',1,'silver');

%Example call during limited operation:
%[newstnNumList,newstnNumListnames,keepgoingthisyear,finaldatat,finaldatadewpt,finaldatawbt,indexsaver,newdatahour2,newdataday2,...
%    newdatamonth2,newdataserialnumbers2,newdatahour,newdataday,newdatamonth,newdatat,newdatadewpt,data,...
%    indicesatcleantimes,hoursatcleantimes,daysatcleantimes,monthsatcleantimes,tempsatcleantimes,validstnc,...
%    numstnsdisallowedtemporalgaps,disallowedstnstemporalgaps,numstnsdisallowedendobsnotinendmonths,numstnsdisallowedtoomuchdatamissing,...
%    disallowedstnspercdatamissing,numstnsdisalloweduninterpolatabletordewpt,disallowedstnsuninterpolatabletordewpt,...
%    numstnsdisallowedincompletetimevec]=...
%   ncdcHourlyTxtToMat2('/Volumes/ExternalDriveA/NCDC_hourly_station_data_active/',...
%   '/Volumes/ExternalDriveA/NCDC_hourly_station_data_mat/',...
%   700260,1996,1996,{'temp'},50,'laconic',0,'silver');

%Example call during regular operation: 
%[newstnNumList,newstnNumListnames,keepgoingthisyear,finaldatat,finaldatadewpt,finaldatawbt,indexsaver,newdatahour2,newdataday2,...
%    newdatamonth2,newdataserialnumbers2,newdatahour,newdataday,newdatamonth,newdatat,newdatadewpt,data,...
%    indicesatcleantimes,hoursatcleantimes,daysatcleantimes,monthsatcleantimes,tempsatcleantimes,validstnc,...
%    numstnsdisallowedtemporalgaps,disallowedstnstemporalgaps,numstnsdisallowedendobsnotinendmonths,numstnsdisallowedtoomuchdatamissing,...
%    disallowedstnspercdatamissing,numstnsdisalloweduninterpolatabletordewpt,disallowedstnsuninterpolatabletordewpt,...
%    numstnsdisallowedincompletetimevec]=...
%   ncdcHourlyTxtToMat2('/Volumes/ExternalDriveA/NCDC_hourly_station_data_active/',...
%   '/Volumes/ExternalDriveA/NCDC_hourly_station_data_mat/',...
%   stnnumlistforref,1981,2015,{'temp';'dewpt';'wbt'},50,'laconic',0,'silver');


%Quick checking guide:
%plotting newdataxxx will show all the obs that occurred at the top of an hour (typically 1000-5000)
%once a point is identified there, indexsaver(point) will give that point's placement in data
%getting that point's placement in finaldataxxx, however, is a matter of trial and error
%for a full year, size of finaldataxxx should be 8760 (or 8784 in leap years)
%finaldataxxx is expected to have extrema not found in newdataxxx because the former incorporates information
%   from off-hour obs, which are frequently more numerous



%Southwest stations to double-check if not found valid on the first run for whatever reason:
%(hint: they should all be valid for 1981-2015)
%wichita falls tx, el paso tx, lubbock tx, midland tx, abilene tx, san angelo tx, grand jct co, ok city, 
%fort smith ar, ely nv, goodland ks
%swstns=[723510;722700;722670;722650;722660;722630;724760;723530;723440;724860;724650];



%If running as a script, need to set arguments here
%For example:
%rawTxtDir='/Volumes/ExternalDriveA/NCDC_hourly_station_data_active/';
%outputDir='/Volumes/ExternalDriveA/NCDC_hourly_station_data_mat/';
%stnlisttouse=newstnNumList; %generally either neweststnlist if starting from the very beginning, newstnNumList,
                                %or stnnumlistforref(=an authoritative version of newstnNumList) if just checking or adding some new stuff
                             %for tweaking (i.e. just removing a couple problematic stations), edit and use the newstnNumList & its associates as defined
                                %in helpfulmanualarraycreator
                             %problematic stations -- those that have data that passes tests but then upon further examination is bad -- get rid of these entirely
                             %bad stations -- those that fail tests like having enough valid years, not having too-large temporal gaps, etc -- can keep
                                %in newstnNumList as defined in helpfulmanualarraycreator or not, depending on how likely
                                %it is that such a station may ever be found valid for any future purpose without causing headaches
                             %whatever stnlisttouse is initially defined as, it is whittled down in domainloop and becomes a trimmer newstnNumList
%startYear=1981;stopYear=2015;
%varNames={'temp';'dewpt';'wbt'};
%missingDataVal=50;
%verbosity='laconic';troubleshoot=0;
%strictness='silver';



%Current runtime: 
%for main loop, about 11 min per station for 35 years, or 30 hours total on local computer evaluating the 560 stations of neweststnlist
%for saving to .mat files, about 3 min per year (for all stations), or 2 hr total on local computer


%Runtime options
domainloop=0;                   %whether to read in data from text files, organize it, etc
readdataintomatfiles=1;         %whether to create mat files or just save the arrays for spot checking
    %can only do this if domainloop=1, or if its output is imported by hand or in the loadsavedarrays loop down below


%Set various other options
monthscaredabout=[5;6;7;8;9;10];%data will only be read in, interpolated, and saved for these months each year
numdeshoursthisyear=4416;       %total # hours contained in monthscaredabout; comment out if monthscaredabout spans 1-12  
if strcmp(strictness,'platinum')
    maxhourgap=3;               %maximum temporal gap tolerated (in hours)
    maxvaluegap=3;              %maximum value gap tolerated
    maxvaluegapsecondary=6;     %maximum gap tolerated (in hours) when valid values on either side of gap are both
        %below the 90th percentile for that array
    numsecondarygapsallowed=3;  %number of such longer gaps tolerated (idea is to not unduly penalize arrays that are missing
        %too many values in just a handful of places, and places we don't particularly care about to boot)
elseif strcmp(strictness,'silver')
    maxhourgap=12;
    maxvaluegap=5;
    maxvaluegapsecondary=23;    %if this is long, one can expect to see identical repeating diurnal cycles when plotting the final data
    numsecondarygapsallowed=20;
end
maxpercdatamissing=3;           %maximum percent of data missing that's tolerated
maxpercbadyears=33.3;           %maximum percent of a station's years disallowed for not meeting the above criteria
    %(i.e. maximum before station is disallowed altogether)
    
    
curDir='/Users/colin/Documents/General_Academics/Research/WBTT_Overlap_Paper/';
%neweststnlist=load(strcat(curDir,'neweststationlist.txt'));


numyearsexamined=stopYear-startYear+1;
numallowablebadyearseachstn=maxpercbadyears/100*numyearsexamined;
monthlengths={'31';'28';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
monthlengthsl={'31';'29';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
monthstarthours=[1;745;1417;2161;2881;3625;4345;5089;5833;6553;7297;8017];
monthendhours=[744;1416;2160;2880;3624;4344;5088;5832;6552;7296;8016;8760];
monthstarthoursl=[1;745;1441;2185;2905;3649;4369;5113;5857;6577;7321;8041];
monthendhoursl=[744;1440;2184;2904;3648;4368;5112;5856;6576;7320;8040;8784];
hours={'00';'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';...
    '13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23'};


timeopt='yes'; %semi-permanent setting, for the function interpolatetovalidxvalue
figc=145;

%Counts of stations disallowed for various reasons, and initialization of vectors to store exactly
%what the values that got them disallowed were
numstnsdisallowedtemporalgaps=0;
disallowedstnstemporalgaps=0;
numstnsdisallowedendobsnotinendmonths=0;
numstnsdisallowedtoomuchdatamissing=0;
disallowedstnspercdatamissing=0;
numstnsdisalloweduninterpolatabletordewpt=0;
disallowedstnsuninterpolatabletordewpt=0;
numstnsdisallowedincompletetimevec=0;
gosavethisstn=0;goodstnyearcombo=0;


%Read in data from files, one hour at a time, and group by month
%This is significantly harder than it sounds
if domainloop==1
    newstnNumList=0;validstnc=1;
    finaldatat={};finaldatadewpt={};finaldatawbt={};
    for i=1:size(stnlisttouse,1)
        curstnnum=stnlisttouse(i);
        fprintf('Current station is %d\n',curstnnum);

        year=startYear;
        thisstnnumbadyears=0;
        keepgoingthisyear=zeros(stopYear-startYear+1,1);
        clear newdatat2;clear newdatadewpt2;clear newdatawbt2;

        %Identify, open, and read the text file for this station, one year at a time
        while year<=stopYear && thisstnnumbadyears<=numallowablebadyearseachstn
            if rem(year,4)==0;suffix='l';else suffix='';end %consider leap years
            if strcmp(suffix,'l');numhoursthisyear=8784;leapyearornot='leapyear';else numhoursthisyear=8760;leapyearornot='regyear';end
            relyear=year-startYear+1;

            curmonthlengthsvec=eval(['monthlengths' suffix ';']);
            curmonthstarthoursvec=eval(['monthstarthours' suffix ';']);
            curmonthendhoursvec=eval(['monthendhours' suffix ';']);

            firsthourcaredabout=curmonthstarthoursvec(monthscaredabout(1));
            lasthourcaredabout=curmonthendhoursvec(monthscaredabout(size(monthscaredabout,1)));


            curtextfile=strcat(rawTxtDir,'/',num2str(curstnnum),'*',num2str(year));
            a=dir(curtextfile);
            if size(a,1)~=0
                fprintf('Current text file is %s\n',a.name);
                fileID=fopen(strcat(rawTxtDir,a.name),'r');
                %The data as a huge array of unwieldy strings
                data=textscan(fileID,'%s','delimiter','\n','whitespace','');%disp(size(data{1})); %something like 9000 for a full year
                data=char(data{1});
                %Within this huge array, search for the strings representing the individual hours
                %Initially, record obs only at the top of the hour (if necessary, later the others will be used for interpolation)
                %Record the gaps between obs, as only gaps of <=maxhourgap hours are tolerated
                prevtime=0;prevtime4digit='0000';curprevdiffallobs=0;
                if troubleshoot==1;fprintf('Original size of data -- with all obs, completely untouched -- is %d hours\n',size(data,1));end


                if relyear==1
                    %Start off by reading basic facts about station from newdata
                    stnlat=str2double(data(1,30:34))/1000; %b/c all in Northern Hemisphere
                    stnlon=str2double(data(1,36:41))/-1000; %b/c all in Western Hemisphere
                    if strcmp(data(1,47),'+')
                        stnelev=str2double(data(1,48:51)); %in meters
                    elseif strcmp(data(1,47),'-')
                        stnelev=-str2double(data(1,48:51)); %in meters
                    end
                end

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



                %Check to be sure there are no unacceptably large temporal gaps in MJJASO
                %There should be no October->May transitions to have to deal with b/c data are analyzed for just 1 year at a time
                if size(hourvecmjjaso,1)>=2
                    for j=2:size(hourvecmjjaso,1)
                        curtime=hourvecmjjaso(j);
                        prevtime=hourvecmjjaso(j-1);
                        if curtime<prevtime
                            allhourdiffs(j)=curtime+24-prevtime;
                        else
                            allhourdiffs(j)=curtime-prevtime;
                        end
                    end
                    if troubleshoot==1;fprintf('Longest temporal gap is %0.1f hours; maximum allowed is %d\n',max(allhourdiffs),maxhourgap);end
                    if max(allhourdiffs)>maxhourgap
                        fprintf('This station/year combination is disallowed because of an unacceptably long temporal gap of %0.1f hours\n',...
                            max(allhourdiffs));
                        thisstnnumbadyears=thisstnnumbadyears+1;
                        keepgoingthisyear(relyear)=0;
                        goodstnyearcombo(relyear,i)=0;
                        year=year+1;
                        fclose(fileID);
                        numstnsdisallowedtemporalgaps=numstnsdisallowedtemporalgaps+1;
                        disallowedstnstemporalgaps(numstnsdisallowedtemporalgaps)=max(allhourdiffs);
                        continue;
                    else
                        keepgoingthisyear(relyear)=1;
                        tentativegoodstnyearcombo(relyear,i)=1;
                    end
                end



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

                plusminusvecfort=cellstr(data(:,88));curTvec=str2num(data(:,89:92))/10;
                plusminusvecfordewpt=cellstr(data(:,94));curdewptvec=str2num(data(:,95:98))/10;
                comparefort=double(strcmp(plusminusvecfort,'+'));comparefort(comparefort==0)=-1;
                comparefordewpt=double(strcmp(plusminusvecfordewpt,'+'));comparefordewpt(comparefordewpt==0)=-1;
                %Multiply sign by absolute value to get actual one
                newdatatplain=curTvec.*comparefort;
                newdatadewptplain=curdewptvec.*comparefordewpt;


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
                newdatat=newdatatplain(indexsaver>0);
                newdatadewpt=newdatadewptplain(indexsaver>0);
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
                newdatat=newdatat(newdatamonthsholdervec==1);
                newdatadewpt=newdatadewpt(newdatamonthsholdervec==1);
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
                    newdatat=shiftanddeletefromvec(newdatat,indiceswheresame(littlec),1);
                    newdatadewpt=shiftanddeletefromvec(newdatadewpt,indiceswheresame(littlec),1);
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
                tempsatcleantimes=0;dewptsatcleantimes=0;
                if troubleshoot==1;fprintf('Before filling gaps, size of newdatahour (and indexsaver) is %dx1\n',size(newdatahour,1));end



                %First thing to do is fill out the ends of the vector (with NaN's for the variable values there)
                %If vector begins not in the first month cared about, or ends not in the last month cared about,
                    %the current station/year combination must be disallowed
                if size(newdatamonth,1)==0
                    thisstnnumbadyears=thisstnnumbadyears+1;
                    keepgoingthisyear(relyear)=0;
                    goodstnyearcombo(relyear,i)=0;
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
                        goodstnyearcombo(relyear,i)=0;
                        year=year+1;
                        fclose(fileID);
                        fprintf(['This station/year combination is disallowed because first obs is not in month %d and/or',...
                            ' last obs is not in month %d\n'],monthscaredabout(1),monthscaredabout(size(monthscaredabout,1)));
                        numstnsdisallowedendobsnotinendmonths=numstnsdisallowedendobsnotinendmonths+1;
                        continue;
                    else
                        tentativegoodstnyearcombo(relyear,i)=1;
                        if newdatahour(1)~=0 || newdataday(1)~=1
                            [fillerhours,fillerdays]=fillendsofavectimeversion(newdatahour(1),newdataday(1),31,'beginning');
                            newdatahour=[fillerhours;newdatahour];
                            newdataday=[fillerdays;newdataday];
                            newdatamonth=[monthscaredabout(1)*ones(size(fillerhours,1),1);newdatamonth];
                            newdatayear=[year*ones(size(fillerhours,1),1);newdatayear];
                            newdatat=[missingDataVal*ones(size(fillerhours,1),1);newdatat];
                            newdatadewpt=[missingDataVal*ones(size(fillerhours,1),1);newdatadewpt];
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
                            newdatat=[newdatat;missingDataVal*ones(size(fillerhours,1),1)];
                            newdatadewpt=[newdatadewpt;missingDataVal*ones(size(fillerhours,1),1)];
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
                                inputtemps=str2num(data(previndex:curindex,89:92))/10;
                                inputdewpts=str2num(data(previndex:curindex,95:98))/10;
                                plusminusvecfort=cellstr(data(previndex:curindex,88));
                                plusminusvecfordewpt=cellstr(data(previndex:curindex,94));
                                comparefort=double(strcmp(plusminusvecfort,'+'));comparefort(comparefort==0)=-1;
                                comparefordewpt=double(strcmp(plusminusvecfordewpt,'+'));comparefordewpt(comparefordewpt==0)=-1;
                                %Multiply sign by absolute value to get actual one
                                inputtemps=inputtemps.*comparefort;
                                inputdewpts=inputdewpts.*comparefordewpt;
                                %if troubleshoot==1;disp('Made it to line 526');end


                                %Note down the indices, hours, variables, etc that will be later inserted into 
                                %the full temporally-complete vectors in the appropriate places
                                %i.e. save positions and values to insert for later insertion into newdataxxx
                                if troubleshoot==1
                                    disp('hoursofinterest: ');disp(hoursofinterest);
                                    disp('inputtimes: ');disp(inputtimes);
                                    disp('inputtemps: ');disp(inputtemps);
                                    disp('inputday: ');disp(inputday);
                                    fprintf('prevnumhoursfilledin (previously): %d\n',prevnumhoursfilledin);
                                    fprintf('numhourstofillin (here): %d\n',numhourstofillin);
                                    fprintf('numhoursfilledin (total so far): %d\n',numhoursfilledin);
                                    fprintf('Size of hoursofinterest is %d\n',size(hoursofinterest,1));
                                    fprintf('Size of inputtimes is %d\n',size(inputtimes,1));
                                    fprintf('Size of inputtemps is %d\n',size(inputtemps,1));
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
                                tempsatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=...
                                    valuesatstandardtimesfromnonstandard2(hoursofinterest,inputtimes,inputday,inputtemps);
                                dewptsatcleantimes(prevnumhoursfilledin+1:numhoursfilledin,1)=...
                                    valuesatstandardtimesfromnonstandard2(hoursofinterest,inputtimes,inputday,inputdewpts);
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
                                        fprintf('Addition to tempsatcleantimes: %0.2f\n',tempsatcleantimes(numhoursfilledin,1));
                                        fprintf('Addition to dewptsatcleantimes: %0.2f\n',dewptsatcleantimes(numhoursfilledin,1));
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
                                    tempsatcleantimes(numhoursfilledin,1)=...
                                        interpolatetovalidxvalue(cleanhourshere(k),prevhour,curhour,prevtemp,curtemp,'yes');
                                    dewptsatcleantimes(numhoursfilledin,1)=...
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
                                            disp('addition to tempsatcleantimes: ');disp(tempsatcleantimes(numhoursfilledin,1));
                                            disp('addition to dewptsatcleantimes: ');disp(dewptsatcleantimes(numhoursfilledin,1));
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
                newdatatemp2=newdatat;newdatadewpt2=newdatadewpt;
                for j=1:size(indicesatcleantimes,1)
                    if size(finaldataday,1)<numdeshoursthisyear
                        finaldatahour=shiftandinsertintovec(finaldatahour,indicesatcleantimes(j)+1,hoursatcleantimes(j));
                        finaldatayear=shiftandinsertintovec(finaldatayear,indicesatcleantimes(j)+1,yearsatcleantimes(j));
                        finaldatamonth=shiftandinsertintovec(finaldatamonth,indicesatcleantimes(j)+1,monthsatcleantimes(j));
                        finaldataday=shiftandinsertintovec(finaldataday,indicesatcleantimes(j)+1,daysatcleantimes(j));
                        newdatatemp2=shiftandinsertintovec(newdatatemp2,indicesatcleantimes(j)+1,tempsatcleantimes(j));
                        newdatadewpt2=shiftandinsertintovec(newdatadewpt2,indicesatcleantimes(j)+1,dewptsatcleantimes(j));
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


                %Interlude: check to be sure no more than maxpercdatamissing percent of the data are missing
                %THIS INTERLUDE SHOULDN'T BE USED AS-IS BECAUSE IT DOESN'T TAKE INTO ACCOUNT THE FACT THAT SIZE(NEWDATAT,1)
                %WILL DRAMATICALLY INCREASE ONCE GAPS ARE FILLED VIA INTERPOLATION
                dointerlude=0;
                if dointerlude==1
                    fprintf('Number of total hours is %d\n',size(newdatat,1));
                    missingdatatest=newdatat(newdatat>=missingDataVal);summissingt=size(missingdatatest,1);
                    missingdatatest=newdatadewpt(newdatadewpt>=missingDataVal);summissingdewpt=size(missingdatatest,1);
                    if troubleshoot==1
                        fprintf('%d hours (%d percent) of T data is missing\n',summissingt,100*summissingt/size(newdatat,1));
                        fprintf('%d hours (%d percent) of dewpt data is missing\n',summissingdewpt,100*summissingdewpt/size(newdatadewpt,1));
                        fprintf('Before filling gaps, size of newdatat and newdatadewpt are %dx1 and %dx1\n',size(newdatat,1),size(newdatadewpt,1));
                    end
                    if 100*summissingt/size(newdatat,1)>=maxpercdatamissing || 100*summissingdewpt/size(newdatadewpt,1)>=maxpercdatamissing
                        if summissingt/size(newdatat,1)>=maxpercdatamissing
                            fprintf('This station/year combination is disallowed because %0.1f percent of T data is missing\n',...
                                100*summissingt/size(newdatat,1));
                        else
                            fprintf('This station/year combination is disallowed because %0.1f percent of dewpt data is missing\n',...
                                100*summissingdewpt/size(newdatadewpt,1));
                        end
                        thisstnnumbadyears=thisstnnumbadyears+1;
                        keepgoingthisyear(relyear)=0;
                        goodstnyearcombo(relyear,i)=0;
                        year=year+1;
                        fclose(fileID);
                        numstnsdisallowedtoomuchdatamissing=numstnsdisallowedtoomuchdatamissing+1;
                        if summissingt/size(newdatat,1)>=maxpercdatamissing
                            disallowedstnspercdatamissing(numstnsdisallowedtoomuchdatamissing)=100*summissingt/size(newdatat,1);
                        else
                            disallowedstnspercdatamissing(numstnsdisallowedtoomuchdatamissing)=100*summissingdewpt/size(newdatadewpt,1);
                        end
                        continue;
                    else
                        keepgoingthisyear(relyear)=1;
                        tentativegoodstnyearcombo(relyear,i)=1;
                    end
                end




                %Finalize T & dewpt arrays, and prepare to store them
                finaldatat{relyear,validstnc}=newdatatemp2;
                finaldatadewpt{relyear,validstnc}=newdatadewpt2;
                fprintf('After filling temporal gaps, final size of finaldatahour is %d\n',size(finaldatahour,1)); 
                    %others should be of identical size

                %return; %if necessary while troubleshooting, uncomment this to be able to 
                %examine problematic newdatahour2, newdataserialnumbers2, etc before they're reset


                %To be able to continue, times must be all filled in
                %At this point, interpolation of values has not yet been done - do it now!!
                if size(finaldatahour,1)==numdeshoursthisyear
                    %Now, examine mjjasotemp and mjjasodewpt to determine how many value gaps (a.k.a. missing values) there are, and how long they are
                    %This is where we see if the gaps >maxvaluegap but <=maxvaluegapsecondary can be tolerated (if both bracketing values
                        %are <90th percentile of that array)
                    maxmjjasotemp=max(finaldatat{relyear,validstnc});
                    maxmjjasodewpt=max(finaldatadewpt{relyear,validstnc});
                    plotvaluesbeforeinterp=0;
                    if troubleshoot==1 && plotvaluesbeforeinterp==1
                        fprintf('Maxes of mjjasotemp and mjjasodewpt BEFORE interpolation are %0.0f and %0.0f respectively\n',...
                            maxmjjasotemp,maxmjjasodewpt);
                        figure(554);clf;plot(finaldatat{relyear,validstnc});hold on;plot(finaldatadewpt{relyear,validstnc},'r');
                        title(sprintf('Final T & dewpt BEFORE interpolation: Station %d, Year %d',curstnnum,year),...
                        'FontSize',16,'fontweight','bold','fontname','arial');
                        xlabel('Hour count (MJJASO only)','FontSize',16,'fontweight','bold','fontname','arial');
                        ylabel('Temperature (deg C)','FontSize',16,'fontweight','bold','fontname','arial');
                        set(gca,'FontSize',12,'fontweight','bold','fontname','arial');
                    end


                    %Ensure that bracketing values don't exceed the 90th percentile with respect to either T or dewpt
                    letsinterpolate=1; %default
                    for varc=1:2
                        if varc==1;thisarr=finaldatat{relyear,validstnc};elseif varc==2;thisarr=finaldatadewpt{relyear,validstnc};end
                        arr90p=quantile(thisarr,0.9);
                        [gaplengths,gaplocations]=findgapsandlengths(thisarr,missingDataVal);
                        [maxconsecmissing,~]=size(gaplengths);
                        if maxconsecmissing>maxvaluegapsecondary %gap is too long, there's no hope
                            maxmjjasotemp=missingDataVal;maxmjjasodewpt=missingDataVal;letsinterpolate=0;
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
                                maxmjjasotemp=missingDataVal;maxmjjasodewpt=missingDataVal;letsinterpolate=0;
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
                        finaldatat{relyear,validstnc}=linearlyinterpolatevector(finaldatat{relyear,validstnc},maxvaluegapsecondary);
                        finaldatadewpt{relyear,validstnc}=linearlyinterpolatevector(finaldatadewpt{relyear,validstnc},maxvaluegapsecondary);

                        if troubleshoot==1;fprintf('Size of finaldatat after interpolation is %d\n',size(finaldatat{relyear,validstnc},1));end

                        %Check to ensure that 
                            %a. in the platinum case, no MJJASO day has a single uninterpolatable T *or* dewpt value OR
                            %b. in the silver case, the only uninterpolatable values are within 3 days of the start or end of the period of interest
                        %If these conditions aren't met, then this station/year combination is disallowed
                        if strcmp(strictness,'platinum')
                            maxmjjasotemp=max(finaldatat{relyear,validstnc});
                            maxmjjasodewpt=max(finaldatadewpt{relyear,validstnc});
                        elseif strcmp(strictness,'silver')
                            maxmjjasotemp=max(finaldatat{relyear,validstnc}(73:size(finaldatat{relyear,validstnc},1)-72));
                            maxmjjasodewpt=max(finaldatadewpt{relyear,validstnc}(73:size(finaldatat{relyear,validstnc},1)-72));
                        end
                        if troubleshoot==1
                            fprintf('Maxes of mjjasotemp and mjjasodewpt after interpolation are %0.0f and %0.0f respectively\n',...
                                maxmjjasotemp,maxmjjasodewpt);
                            plotvaluesafterinterp=0;
                            if troubleshoot==1 && plotvaluesafterinterp==1
                                figure(figc);figc=figc+1;clf;plot(finaldatat{relyear,validstnc});hold on;plot(finaldatadewpt{relyear,validstnc},'r');
                                title(sprintf('Final T & dewpt AFTER interpolation: Station %d, Year %d',curstnnum,year),...
                                'FontSize',16,'fontweight','bold','fontname','arial');
                                xlabel('Hour count (MJJASO only)','FontSize',16,'fontweight','bold','fontname','arial');
                                ylabel('Temperature (deg C)','FontSize',16,'fontweight','bold','fontname','arial');
                                set(gca,'FontSize',12,'fontweight','bold','fontname','arial');
                            end
                        end
                        %Find max consecutive number of missing values, to be able to save and report this statistic
                        maxconsecmissingvalstemp=0;maxconsecmissingvalsdewpt=0;
                        numconsectmissinghere=0;numconsecdewptmissinghere=0;
                        missingtempvalsonlyatend=0;missingdewptvalsonlyatend=0;
                        for k=1:lasthourcaredabout-firsthourcaredabout+1
                            if finaldatat{relyear,validstnc}(k)>=missingDataVal
                                numconsectmissinghere=numconsectmissinghere+1;
                            else
                                if numconsectmissinghere>maxconsecmissingvalstemp
                                    maxconsecmissingvalstemp=numconsectmissinghere;
                                end
                                numconsectmissinghere=0;
                            end
                            if finaldatadewpt{relyear,validstnc}(k)>=missingDataVal
                                numconsecdewptmissinghere=numconsecdewptmissinghere+1;
                            else
                                if numconsecdewptmissinghere>maxconsecmissingvalsdewpt
                                    maxconsecmissingvalsdewpt=numconsecdewptmissinghere;
                                end
                                numconsecdewptmissinghere=0;
                            end


                            %Account for the fact that vector may end in missing vals
                            if k==lasthourcaredabout-firsthourcaredabout+1 && numconsectmissinghere>maxconsecmissingvalstemp
                                if maxconsecmissingvalstemp==0;missingtempvalsonlyatend=1;end %if everything was OK right up until the end
                                maxconsecmissingvalstemp=numconsectmissinghere;
                            end
                            if k==lasthourcaredabout-firsthourcaredabout+1 && numconsecdewptmissinghere>maxconsecmissingvalsdewpt
                                if maxconsecmissingvalsdewpt==0;missingdewptvalsonlyatend=1;end %if everything was OK right up until the end
                                 maxconsecmissingvalsdewpt=numconsecdewptmissinghere;
                            end
                        end
                        maxconsecmissing=max(maxconsecmissingvalstemp,maxconsecmissingvalsdewpt);
                    else
                        maxmjjasotemp=missingDataVal;maxmjjasodewpt=missingDataVal;
                        missingtempvalsonlyatend=0;missingdewptvalsonlyatend=0; %defaults
                    end


                    %Determine if there were any uninterpolatable MJJASO T or dewpt values, and if so, disallow station/year combo
                    if maxmjjasotemp>=missingDataVal || maxmjjasodewpt>=missingDataVal
                        if missingtempvalsonlyatend==1 && maxconsecmissingvalstemp<=6 || missingdewptvalsonlyatend==1 && maxconsecmissingvalsdewpt<=6
                            %There were some consecutive missing values but they're only at the very end of the months of interest,
                            %so we'll let them slide

                            %Check if all the hours were filled in, and if yes output a message saying so
                            %Must have zero tolerance in final array size (otherwise dates will be off and comparisons will be futile)

                            %Finally, if everything looks good, usse array operations to efficiently calculate WBT from T and dewpt, 
                            %setting WBT values ==missingDataVal as appropriate
                            if size(finaldatahour,1)==numdeshoursthisyear && tentativegoodstnyearcombo(relyear,i)==1
                                fprintf('For year %d and station %d, everything looks good and is ready to be saved\n',year,curstnnum);
                                goodstnyearcombo(relyear,i)=1; %keep this as a good stnyearcombo

                                finaldatawbt{relyear,validstnc}=calcwbtfromTanddewpt(finaldatat{relyear,validstnc},finaldatadewpt{relyear,validstnc});
                                finaldatawbt{relyear,validstnc}(abs(finaldatat{relyear,validstnc})>=missingDataVal)=missingDataVal; 
                                finaldatawbt{relyear,validstnc}(abs(finaldatadewpt{relyear,validstnc})>=missingDataVal)=missingDataVal;
                            else
                                goodstnyearcombo(relyear,i)=0;
                                thisstnnumbadyears=thisstnnumbadyears+1;
                                finaldatawbt{relyear,validstnc}=0;
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
                            thisstnnumbadyears=thisstnnumbadyears+1;
                            finaldatawbt{relyear,validstnc}=0;
                            keepgoingthisyear(relyear)=0;
                            goodstnyearcombo(relyear,i)=0;
                            numstnsdisalloweduninterpolatabletordewpt=numstnsdisalloweduninterpolatabletordewpt+1;
                            disallowedstnsuninterpolatabletordewpt(numstnsdisalloweduninterpolatabletordewpt)=maxconsecmissing;
                            year=year+1;
                            fclose(fileID);
                            continue;
                        end
                    else
                        %Check if all the hours were filled in, and if yes output a message saying so
                        %Must have zero tolerance in final array size (otherwise dates will be off and comparisons will be futile)
                        if size(finaldatahour,1)==numdeshoursthisyear && tentativegoodstnyearcombo(relyear,i)==1
                            fprintf('For year %d and station %d, everything looks good and is ready to be saved\n',year,curstnnum);
                            goodstnyearcombo(relyear,i)=1; %keep this as a good stnyearcombo
                            %%Use array operations to efficiently calculate WBT from T and dewpt, setting values ==missingDataVal as appropriate
                            finaldatawbt{relyear,validstnc}=calcwbtfromTanddewpt(finaldatat{relyear,validstnc},finaldatadewpt{relyear,validstnc});
                            finaldatawbt{relyear,validstnc}(abs(finaldatat{relyear,validstnc})>=missingDataVal)=missingDataVal; 
                            finaldatawbt{relyear,validstnc}(abs(finaldatadewpt{relyear,validstnc})>=missingDataVal)=missingDataVal;
                        else
                            goodstnyearcombo(relyear,i)=0;
                            thisstnnumbadyears=thisstnnumbadyears+1;
                            finaldatawbt{relyear,validstnc}=0; %so that the size of the T, dewpt, and WBT vectors (in terms of # cells) are all the same
                        end
                    end


                    %Consider also expressly disallowing a station if it has any dewpts greater than the corresponding T
                    for ii=1:size(finaldatat{relyear,validstnc})
                        thishourt=finaldatat{relyear,validstnc}(ii);
                        thishourdewpt=finaldatat{relyear,validstnc}(ii);
                        if thishourdewpt>thishourt
                            fprintf('Alert! For hour %d, dewpt is greater than T: dewpt=%d, T=%d\n',ii,thishourdewpt,thishourt);
                        end
                    end

                else
                    fprintf('This station/year combination is disallowed because the time vector contains only %d hours\n',size(finaldatahour,1));
                    fprintf('     (it should contain %d hours)\n',numdeshoursthisyear);
                    thisstnnumbadyears=thisstnnumbadyears+1;
                    finaldatawbt{relyear,validstnc}=0;
                    keepgoingthisyear(relyear)=0;
                    goodstnyearcombo(relyear,i)=0;
                    numstnsdisallowedincompletetimevec=numstnsdisallowedincompletetimevec+1;
                    year=year+1;
                    fclose(fileID);
                    continue;
                end


                %Whether this year ended up being valid or not, need to close the file that was being read
                fclose(fileID);
            end
            year=year+1;
        end


        %Check to ensure that station didn't breach any limits and is all set to be saved for posterity
        fprintf('This station had %d bad years out of %d examined\n',thisstnnumbadyears,(year-1)-startYear+1);fprintf('\n');
        if strcmp(verbosity,'verbose');disp('Updating newstnNumList and validstnc');fprintf('\n');end

        %Ensure this station has enough good years to even be worth saving at all
        %If it does, save its latitude & longitude and allow those good stn/year combos to go ahead and be saved
        %Reminder: dimensions of finaldatat and its ilk are {year,stnc}
        percbadyears=100*thisstnnumbadyears/numyearsexamined;
        if percbadyears<=maxpercbadyears
            newstnNumList(validstnc,1)=stnlisttouse(i);fprintf('Station %d will be saved\n',stnlisttouse(i));
            newstnNumListlats(1,validstnc)=stnlat;newstnNumListlons(1,validstnc)=stnlon;newstnNumListelevs(1,validstnc)=stnelev;
            newstnNumListnames{validstnc}=stationinfofromnumber(stnlisttouse(i));
            validstnc=validstnc+1;if troubleshoot==1;fprintf('Validstnc is now %d\n',validstnc-1);end
            gosavethisstn(i)=1;
        else
            gosavethisstn(i)=0;fprintf('Station %d will NOT be saved\n',stnlisttouse(i));
        end
        %Save arrays periodically at checkpoints, building up to the end where everything is included
        if rem(validstnc,5)==0
            fprintf('\n');disp('At a checkpoint, so saving data for all the valid stations thus far');
            if percbadyears<=maxpercbadyears
                save(strcat(curDir,'temparrayholder'),'finaldatat','finaldatadewpt','finaldatawbt',...
                    'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListelevs','newstnNumListnames',...
                    'numstnsdisallowedtemporalgaps','disallowedstnstemporalgaps',...
                    'numstnsdisallowedendobsnotinendmonths','numstnsdisallowedtoomuchdatamissing',...
                    'disallowedstnspercdatamissing','numstnsdisalloweduninterpolatabletordewpt',...
                    'disallowedstnsuninterpolatabletordewpt','goodstnyearcombo','gosavethisstn');
            end
        end
        fprintf('%d stations have been examined; %d valid ones have been found\n',i,validstnc-1);fprintf('\n');
    end

    %Do one final round of data-saving before reading things in
    %Keep in mind that e.g. finaldatat and finaldatawbt are hard to interpret in this form, since they are shifted
    %due to invalid years, etc (an issue dealt with when creating the .mat files just below)
    %-->so it's useful to save all this stuff in case there's an error or crash later on, but analyze at your own risk
    save(strcat(curDir,'temparrayholder'),'finaldatat','finaldatadewpt','finaldatawbt',...
        'newstnNumList','newstnNumListlats','newstnNumListlons','newstnNumListelevs','newstnNumListnames',...
        'numstnsdisallowedtemporalgaps','disallowedstnstemporalgaps','numstnsdisallowedendobsnotinendmonths',...
        'numstnsdisallowedtoomuchdatamissing','disallowedstnspercdatamissing',...
        'numstnsdisalloweduninterpolatabletordewpt','disallowedstnsuninterpolatabletordewpt',...
        'goodstnyearcombo','gosavethisstn');
end


%Code to merge together arrays that have been saved, so that the below .mat-file-creating loop can be run with more ease
%Of course, the sections omitted (because of accidental duplicate stations) are specific to each situation
%Runtime: about 1 min 30 sec
mergearrays=0;
if mergearrays==1
    arrayholder1=load('temparrayholder209aug24.mat');arrayholder2=load('temparrayholder11aug31.mat');
    
    newstnNumList=[arrayholder1.newstnNumList;arrayholder2.newstnNumList];
    newstnNumListnames=[arrayholder1.newstnNumListnames arrayholder2.newstnNumListnames];
    finaldatat=[arrayholder1.finaldatat(:,1:209) arrayholder2.finaldatat];
    finaldatadewpt=[arrayholder1.finaldatadewpt(:,1:209) arrayholder2.finaldatadewpt];
    finaldatawbt=[arrayholder1.finaldatawbt(:,1:209) arrayholder2.finaldatawbt];
    newstnNumListlats=[arrayholder1.newstnNumListlats arrayholder2.newstnNumListlats];
    newstnNumListlons=[arrayholder1.newstnNumListlons arrayholder2.newstnNumListlons];
    newstnNumListelevs=[arrayholder1.newstnNumListelevs arrayholder2.newstnNumListelevs];
    gosavethisstn=[arrayholder1.gosavethisstn arrayholder2.gosavethisstn];
    goodstnyearcombo=[arrayholder1.goodstnyearcombo arrayholder2.goodstnyearcombo]; %the 560 stations of neweststnlist + the 11 of swstns
    
    save('temparrayholdernewest','newstnNumList','newstnNumListnames','finaldatat','finaldatadewpt','finaldatawbt',...
        'newstnNumListlats','newstnNumListlons','newstnNumListelevs','gosavethisstn','goodstnyearcombo');
end
 


loadinsavedarrays=1;
if loadinsavedarrays==1 %runtime: about 45 sec
    arrayholder=load('temparrayholder220aug31.mat');
    newstnNumList=arrayholder.newstnNumList;
    newstnNumListnames=[arrayholder.newstnNumListnames];
    finaldatat=[arrayholder.finaldatat];
    finaldatadewpt=[arrayholder.finaldatadewpt];
    finaldatawbt=[arrayholder.finaldatawbt];
    newstnNumListlats=[arrayholder.newstnNumListlats];
    newstnNumListlons=[arrayholder.newstnNumListlons];
    newstnNumListelevs=[arrayholder.newstnNumListelevs];
    gosavethisstn=[arrayholder.gosavethisstn];
    goodstnyearcombo=[arrayholder.goodstnyearcombo];
end
    
%If there are valid stations at all, parse out data by month for each station and year, and save it into the designated .mat files
%This loop has written into it two choices that must be manually toggled between: the default, in which arrays 
    %calculated earlier in this script are used, and one in which arrays are saved and then imported from .mat files
%Lines corresponding to these two choices are marked with 'OPTION 1' and 'OPTION 2' respectively
if readdataintomatfiles==1
    exist validstnc;if ans==0;validstnc=2;end
    if validstnc-1>=1
        for year=startYear:stopYear
            fprintf('Saving valid data (if any) for year %d to .mat files\n',year);
            relyear=year-startYear+1;
            if rem(year,4)==0;suffix='l';else suffix='';end %consider leap years
            curmonthlengthsvec=eval(['monthlengths' suffix ';']);
            curmonthstarthoursvec=eval(['monthstarthours' suffix ';']);
            curmonthendhoursvec=eval(['monthendhours' suffix ';']);
            firsthourcaredabout=curmonthstarthoursvec(monthscaredabout(1));
            lasthourcaredabout=curmonthendhoursvec(monthscaredabout(size(monthscaredabout,1)));

            %Now that missing times are all filled in, we don't need to laboriously run through hour by hour again, but can just
                %grab the data in chunks since we know the month lengths
            %The stations are listed in order of appearance in newstnNumList (which is derived from the original input stnlisttouse)
            for var=1:size(varNames,1)
            %for var=2:2
                fprintf('Currently working on saving %s data\n',varNames{var});
                %Check for output folder and create it if it doesn't already exist
                folDataTarget=[outputDir,varNames{var},'/',num2str(year),'/'];
                %disp(folDataTarget);
                if ~isdir(folDataTarget);mkdir(folDataTarget);end
                if strcmp(varNames{var},'temp');t='t';else t=varNames{var};end
                %Make .mat files one month at a time
                for month=monthscaredabout(1):monthscaredabout(size(monthscaredabout,1))
                    curmonthlen=str2double(curmonthlengthsvec{month});%fprintf('Curmonthlen is %d\n',curmonthlen);
                    curmonthstarthour=curmonthstarthoursvec(month);%fprintf('Curmonthstarthour is %d\n',curmonthstarthour);
                    curmonthendhour=curmonthendhoursvec(month);%fprintf('Curmonthendhour is %d\n',curmonthendhour);
                    monthlydataset={};validstnsthismonth=0;
                    %for i=1:size(stnNumList,1) %OPTION 1
                    for i=1:size(newstnNumList,1) %OPTION 2
                    %for i=1:5
                        %curstnnum=stnNumList(i); %OPTION 1
                        curstnnum=newstnNumList(i); %OPTION 2
                        %if goodstnyearcombo(relyear,i)==1 && gosavethisstn(i)==1 %OPTION 1
                        %if goodstnyearcombo(relyear,i)==1 && gosavethisstn(i)==1 %OPTION 2
                            %shouldn't need this check b/c only good stn/year combos got into newstnNumList in the first place 
                            validstnsthismonth=validstnsthismonth+1;
                            temp=finaldatat{relyear,i};tarrsize=size(temp,1); %OPTION 2
                            temp=finaldatadewpt{relyear,i};dewptarrsize=size(temp,1); %OPTION 2
                            temp=finaldatawbt{relyear,i};wbtarrsize=size(temp,1); %OPTION 2
                            %disp(tarrsize);disp(dewptarrsize);disp(wbtarrsize);
                            if tarrsize>1 && dewptarrsize>1 && wbtarrsize>1 %OPTION 2 %ensuring this station/month combo has valid data for all variables
                                maxt=max(finaldatat{relyear,i});maxdewpt=max(finaldatadewpt{relyear,i});maxwbt=max(finaldatawbt{relyear,i});
                                if maxt~=0 && maxdewpt~=0 && maxwbt~=0
                                    %Now do yet another check, that there is not a long string of identical days --> some kind of problem that means
                                        %this station/month combo must be disallowed
                                    tempa=finaldatat{relyear,i};
                                    tempb=tempa(tempa<missingDataVal);
                                    dayc=1;for hour=1:24:size(tempb,1)-23;maxthisday(dayc,1)=max(tempb(hour:hour+23));dayc=dayc+1;end
                                    lsim=1;sim=1;for c=2:size(maxthisday,1);if maxthisday(c,1)==maxthisday(c-1,1);sim=sim+1;else if sim>lsim;lsim=sim;end;sim=1;end;end
                                        %sim=stringidenticalmaxes; lsim=longeststringidenticalmaxes
                                    if lsim<=4
                                        %if curstnnum==702000;fprintf('Station-month combination of station %d, year %d, month %d is valid and is being saved\n',...
                                        %    curstnnum,year,month);end
                                        if strcmp(verbosity,'verbose')
                                            fprintf('Saving %s data for month %d and station %d (valid station number %d for this month)\n',...
                                                varNames{var},month,curstnnum,validstnsthismonth);
                                            fprintf('Validstnsthismonth is %d\n',validstnsthismonth);
                                            fprintf('Slice of hours to look at within this month is from %d to %d\n',...
                                                curmonthstarthour-firsthourcaredabout+1,curmonthendhour-firsthourcaredabout+1);
                                        end
                                        monthlydataset{1}(1,validstnsthismonth)=i;
                                        monthlydataset{2}(1,validstnsthismonth)=newstnNumList(validstnsthismonth);
                                        monthlydataset{3}(1,validstnsthismonth)=newstnNumListnames(validstnsthismonth);
                                        monthlydataset{4}(1,validstnsthismonth)=newstnNumListlats(validstnsthismonth);
                                        monthlydataset{5}(1,validstnsthismonth)=newstnNumListlons(validstnsthismonth);
                                        monthlydataset{6}(1,validstnsthismonth)=newstnNumListelevs(validstnsthismonth);
                                        monthlydataset{7}(:,validstnsthismonth)=...
                                            eval(['finaldata' t...
                                            '{relyear,i}(curmonthstarthour-firsthourcaredabout+1:curmonthendhour-firsthourcaredabout+1);']);
                                        %disp('line 1135');disp(size(monthlydataset{7})); %should be something like 720 hoursx200 stations
                                        %Save this data to a .mat file in the correct location and with the correct name
                                        fileName=[varNames{var},'_',datestr(datenum(year,month,1),'yyyy_mm_dd')];
                                        eval([fileName ' =monthlydataset;']);
                                        save([folDataTarget,fileName,'.mat'],fileName,'-v7.3');
                                        else %OPTION 2
                                        validstnsthismonth=validstnsthismonth-1; %OPTION 2
                                    end
                                end
                            end %OPTION 2
                        %end
                    end
                    %Clear things out to get ready for the next month
                    %if goodstnyearcombo(relyear,i)==1 && gosavethisstn(i)==1 %OPTION 1
                        clear monthlydataset;eval(['clear ' fileName]);
                    %end %OPTION 1
                end
            end
            if strcmp(verbosity,'verbose');fprintf('Year just completed was %d\n',year);fprintf('\n');end
        end
    end
end

%Get summary statistics for all stations and years that this run encompassed
if domainloop==1
    fprintf('\n');
    fprintf('Number of station/year combos disallowed because of temporal gaps larger than %d hours is %d (out of %d)\n',...
        maxhourgap,numstnsdisallowedtemporalgaps,numyearsexamined*size(stnlisttouse,1));
    fprintf('Number of station/year combos disallowed b/c all of first desired month or last desired month was missing is %d (out of %d)\n',...
        numstnsdisallowedendobsnotinendmonths,numyearsexamined*size(stnlisttouse,1));
    fprintf('Number of station/year combos disallowed because more than %d percent of data was missing is %d (out of %d)\n',...
        maxpercdatamissing,numstnsdisallowedtoomuchdatamissing,numyearsexamined*size(stnlisttouse,1));
    fprintf('Number of station/year combos disallowed because of too many consecutive missing T or dewpt values is %d (out of %d)\n',...
        numstnsdisalloweduninterpolatabletordewpt,numyearsexamined*size(stnlisttouse,1));
    fprintf('Number of station/year combos disallowed because of an incomplete time vector is %d (out of %d)\n',...
        numstnsdisallowedincompletetimevec,numyearsexamined*size(stnlisttouse,1));
    fprintf('Number of good stations found on this run is %d (out of %d)\n',...
        validstnc-1,size(stnlisttouse,1));fprintf('\n');
end


%If no valid stations were found on this run, or certain loops weren't run, these arrays should not exist -- 
%but something needs to be outputted, so just assign them zeros
exist newdatat;
if ans==0;newdatat=0;newdatadewpt=0;end
exist newdatawbt; 
if ans==0;newdatawbt=0;end
exist indexsaver;
if ans==0;indexsaver=0;end
exist newdataserialnumbers2;
if ans==0;newdataserialnumbers2=0;end
exist newdatahour;
if ans==0;newdatahour=0;newdataday=0;newdatamonth=0;end
exist finaldatahour;
if ans==0;finaldatahour=0;finaldataday=0;finaldatamonth=0;end
exist indicesatcleantimes;
if ans==0;indicesatcleantimes=0;hoursatcleantimes=0;daysatcleantimes=0;monthsatcleantimes=0;tempsatcleantimes=0;end
exist keepgoingthisyear;
if ans==0;keepgoingthisyear=0;end

fclose('all'); %just to be sure everything's closed

end
