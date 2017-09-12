%Converts .nc files to .mat ones for space and ease of access

%Example call from within Exploratory_Plots folder:
%ncepNcToMat('/Volumes/MacFormatted4TBExternalDrive/NCEP_daily_data_raw_activefiles',...
%       '/Volumes/MacFormatted4TBExternalDrive/NCEP_daily_data_mat','air','air',100);
%this creates monthly subdirectories within Exploratory_Plots

%For ease of debugging in the main window
%Modify these to suit whichever task is being worked on at the moment
%rawNcDir='/Volumes/ExternalDriveA/NCEP_daily_data_raw_activefiles';
%outputDir='/Volumes/ExternalDriveA/NCEP_daily_data_mat';
%varName='air';
%varNameinFileName='air.sig995';
%kindoflevel='pressure'; %'pressure' or 'mono'
%timeperiod='daily';    %'daily' or '4xdaily'
%maxNum=100; %maximum number of files to process on this run


%Current runtime: about 10 sec per year & variable


function ncepNcToMat(rawNcDir,outputDir,varName,varNameinFileName,kindoflevel,timeperiod,maxNum)


ts=0; %whether to display troubleshooting messages

if strcmp(kindoflevel,'pressure')
    pLevels=[6]; %500 hPa level (1, 3, 6, 8 are 1000, 850, 500, 300)
    truepLevels=[500]; %MUST match pLevels
else
    pLevels=1; %i.e. monolevel
    truepLevels=995; %sigma level of near-sfc data (change as necessary)
end
if strcmp(timeperiod,'4xdaily')
    divfactor=4;
else
    divfactor=1;
end
ncFileNames=dir([rawNcDir, '/', varNameinFileName, '.*.nc']);
ncFileNames={ncFileNames.name};
%disp(ncFileNames);
fileCount=0;

msl=[1 32 61 92 122 153 183 214 245 275 306 336];
ms=[1 32 60 91 121 152 182 213 244 274 305 335];

for plevel=1:size(pLevels,2)
    for k=1:length(ncFileNames)
        fprintf('Converting %s to .mat format\n',char(ncFileNames{k}));
        if fileCount>=maxNum && maxNum~=-1;return;end

        %Reset things for this new file
        ncFileName=ncFileNames{k};
        ncid=netcdf.open([rawNcDir, '/', ncFileName]);
        [ndim,nvar,natts]=netcdf.inq(ncid);
        vardata2={};vars={};deltaT=0;dataTime='';timestep=[];
        attIdTitle=-1;atts={};varIdMain=0;
        missingValue=NaN;fillValue=NaN;

        %Extract the data arrays in a way that makes sense
        %Check in Panoply that the file elements are actually in the order they are assumed to be here
        if strcmp(kindoflevel,'pressure')
            nameoflat=netcdf.inqVar(ncid,1);latid=netcdf.inqVarID(ncid,nameoflat);
            latdata=netcdf.getVar(ncid,latid);
            nameoflon=netcdf.inqVar(ncid,2);lonid=netcdf.inqVarID(ncid,nameoflon);
            londata=netcdf.getVar(ncid,lonid);
            nameoftime=netcdf.inqVar(ncid,3);timeid=netcdf.inqVarID(ncid,nameoftime);
            timedata=netcdf.getVar(ncid,timeid); %the hours associated with the start of each day
            nameoflevel=netcdf.inqVar(ncid,0);levelid=netcdf.inqVarID(ncid,nameoflevel);
            leveldata=netcdf.getVar(ncid,levelid);
            nameofvar=netcdf.inqVar(ncid,4);varid=netcdf.inqVarID(ncid,nameofvar);
            vardata=netcdf.getVar(ncid,varid);
        elseif strcmp(kindoflevel,'mono')
            nameoflat=netcdf.inqVar(ncid,0);latid=netcdf.inqVarID(ncid,nameoflat);
            latdata=netcdf.getVar(ncid,latid);
            nameoflon=netcdf.inqVar(ncid,1);lonid=netcdf.inqVarID(ncid,nameoflon);
            londata=netcdf.getVar(ncid,lonid);
            nameoftime=netcdf.inqVar(ncid,2);timeid=netcdf.inqVarID(ncid,nameoftime);
            timedata=netcdf.getVar(ncid,timeid); %the hours associated with the start of each day
            %disp(nameoflat);disp(nameoflon);disp(nameoftime); %sanity check, as the name should be descriptive
            nameofvar=netcdf.inqVar(ncid,3);varid=netcdf.inqVarID(ncid,nameofvar);
            vardata=netcdf.getVar(ncid,varid);
        end

        if strcmp(kindoflevel,'pressure')
            for kk=1:size(pLevels,2);vardata2{kk}=vardata(:,:,pLevels(kk),:);end
        elseif strcmp(kindoflevel,'mono')
            for kk=1:size(pLevels,2);vardata2{kk}=vardata;end
        end
        for ii=1:size(londata,1);latdatamatrix(ii,:)=latdata;end
        for jj=1:size(latdata,1);londatamatrix(:,jj)=londata;end
        
        if ts==1;disp('line 81');disp(size(vardata2{1}));disp(size(vardata));end
        vardata3=vardata2{1};

        %Extract metadata from the file name
        parts=strsplit(ncFileName, '/');parts=parts(end);parts=strsplit(parts{1}, '.');
        dataTime=lower(parts{end-1});
        dataYear=dataTime(1:4);

        outputVarName=varName;
        if length(findstr('air.2m', ncFileName))~=0;outputVarName='air_2m';end

        %Check for desired output folder and create it if it doesn't exist
        folDataTarget=[outputDir,'/',outputVarName,'/',dataYear,'/'];
        %if ~isdir(folDataTarget);mkdir(folDataTarget);end
        %disp(folDataTarget);

        for i=0:natts-1
            attname=netcdf.inqAttName(ncid, netcdf.getConstant('NC_GLOBAL'), i);
            attval=netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), attname);

            if length(findstr(attname, 'title'))~=0;attIdTitle=i+1;end
            atts{i+1}={attname,attval};
        end

        for i=0:nvar-1
            [vname,vtype,vdim,vatts]=netcdf.inqVar(ncid,i);
            if length(findstr(vname,varName))~=0;varIdMain=i+1;end
            vars{i+1}={vname,vtype,vdim,vatts};
        end

        for i=0:vars{varIdMain}{4}-1
            %Made modifications if .nc file requests them
            attname = netcdf.inqAttName(ncid, varIdMain-1, i);
            if strcmp(attname, 'scale_factor')
                scaleFactor = double(netcdf.getAtt(ncid, varIdMain-1,'scale_factor'));
            elseif strcmp(attname, 'add_offset')
                addOffset = double(netcdf.getAtt(ncid, varIdMain-1,'add_offset'));
            elseif strcmp(attname, 'missing_value')
                missingValue = int16(netcdf.getAtt(ncid, varIdMain-1,'missing_value'));
            elseif strcmp(attname, '_FillValue')
                fillValue = int16(netcdf.getAtt(ncid, varIdMain-1,'_FillValue'));
            end
        end

        %Find this file's timestep
        if length(findstr('8x', atts{attIdTitle}{2}))~=0 %3-hr timestep
            deltaT=etime(datevec('03','HH'),datevec('00','HH'));
        elseif length(findstr('4x', atts{attIdTitle}{2}))~=0 %6-hr timestep
            deltaT=etime(datevec('06','HH'),datevec('00','HH'));
        else %daily timestep
            deltaT=etime(datevec('24','HH'),datevec('00','HH'));
        end

        datahere=vardata3;%disp('line 133');disp(size(datahere));
        
        %disp(size(latdatamatrix));disp(size(londatamatrix));disp(size(double(datahere(:,:,1,:))));
            %can use 1 instead of plevel since only one level is analyzed
            %at a time (never more than 1 choice for the third dimension)
        monthlyDataSet={latdatamatrix,londatamatrix,double(datahere(:,:,1,:))};
        %disp('line 139');disp(size(datahere));
        disp('done with that; here comes a new file!');
        %Save the .mat file in the correct location and with the correct name
        %This means figuring out the months, and specifically the breaks between them
        if rem(dataYear,4)==0;suffix=['l'];else suffix=[''];end %consider leap years
        prevendday=0;
        for totalday=1:size(timedata,1) %total day is actually the total number of timesteps,
            %so e.g. for 4xdaily data totalday=4*#days (but this is already taken into account with 'timeperiod' argument)
            curdaystarthour=timedata(totalday);if totalday~=size(timedata,1);nextdaystarthour=timedata(totalday+1);end
            curcorrespday=round2(curdaystarthour/24,1,'floor')+657438; %offset is in units of days
                %so as to get the first hour of the dataset to correspond to 01:00 1/1/dataYear, as it should 
                %(offset figured out by trial and error)
            %disp('line 126');disp(totalday);disp(curdaystarthour);disp(curcorrespday);
            if totalday~=size(timedata,1);nextcorrespday=round2(nextdaystarthour/24,1,'floor')+657438;end
            curdate=datestr(curcorrespday,'yyyy_mm_dd');curmonfortitle=datestr(curcorrespday,'yyyy_mm');
            if totalday~=size(timedata,1);nextdate=datestr(nextcorrespday,'yyyy_mm_dd');end
            monofcurday=str2num(curdate(6:7));monstartsthisyear=eval(['ms' suffix]);
            if monofcurday~=12
                curmonlen=monstartsthisyear(monofcurday+1)-monstartsthisyear(monofcurday);
            else
                curmonlen=31; %it now has to be Dec by process of elimination
            end
            if totalday~=size(timedata,1)
                monofnextday=str2num(nextdate(6:7));
                if monofnextday~=12
                    nextmonlen=monstartsthisyear(monofnextday+1)-monstartsthisyear(monofnextday);
                else
                    nextmonlen=31; %ditto
                end
            end
            
            if ts==1
                disp('Line 172. Let the troubleshooting begin!');
                disp(curdate);disp(nextdate);disp(monofcurday);disp(monofnextday);disp(totalday);
                disp(size(latdatamatrix));disp(size(londatamatrix));disp(prevendday);disp(size(datahere));
                colin=prevendday+1:totalday;disp(size(colin));
                disp('Line 176. Now for the denouement.');
            end
            %disp(monofcurday);disp(totalday);
            
            %If at the end of a month, organize all its data and save to a .mat file
            if monofnextday~=monofcurday || ...
                    (monofcurday==12 && totalday/divfactor==365) || (monofcurday==12 && totalday/divfactor==366)
                    %i.e. the last day of a month
                if strcmp(kindoflevel,'pressure')
                    datathismon={latdatamatrix;londatamatrix;datahere(:,:,:,prevendday+1:totalday)};
                elseif strcmp(kindoflevel,'mono')
                    datathismon={latdatamatrix;londatamatrix;datahere(:,:,prevendday+1:totalday)};
                end
                fprintf('Saving to mat file for month #%d\n',monofcurday);
                %disp('line 172');disp(prevendday);disp(totalday);
                %disp(size(datathismon{1}));disp(size(datathismon{2}));disp(size(datathismon{3}));
                prevendday=totalday;
                fileName=[outputVarName,'_',curmonfortitle,'_',num2str(truepLevels(plevel))];
                %disp('line 176');disp(fileName);disp(truepLevels(plevel));
                eval([fileName ' = datathismon;']);
                whattosave=strcat(folDataTarget,'/',fileName,'.mat');
                save(whattosave,fileName,'-v7.3');
            end
        end

        eval(['clear ' fileName ';']);
        clear data dims vars timestep;
        netcdf.close(ncid);
        fileCount=fileCount+1;
    end
end

