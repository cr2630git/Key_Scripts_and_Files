%script is oisstNcToMat

%Current runtime: about 20 sec to convert one 6-month file

rawNcDir='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data/';
outputDir='/Volumes/MacFormatted4TBExternalDrive/NOAA_OISST_Daily_Data_Mat/';
maxNum=100;
varName='tos'; %i.e. SST

ncFileNames = dir([rawNcDir, '*.nc']);
ncFileNames = {ncFileNames.name};
fileCount = 0;

for k = 1:length(ncFileNames)
    if fileCount >= maxNum && maxNum ~= -1;return;end
    ncFileName = ncFileNames{k}; fprintf('Reading file %s\n',ncFileName);
    ncid = netcdf.open([rawNcDir, '/', ncFileName]);
    [ndim, nvar, natts] = netcdf.inq(ncid);
    dataTime = '';
    
    yearthisfile=double(str2num(ncFileName(28:31)));
    startingmonththisfile=double(str2num(ncFileName(32:33)));
    
    %Check for output folder and make it if it doesn't already exist
    folDataTarget = [outputDir, num2str(yearthisfile)];
    if ~isdir(folDataTarget);mkdir(folDataTarget);end
    
    %Get dimensions of data & metadata
    dimIdLat = -1;dimIdLon = -1;dimIdLev = -1;dimIdTime = -1;
    
    dims={};
    for i = 0:ndim-1
        [dimname, dimlen] = netcdf.inqDim(ncid,i);
        if length(findstr(dimname, 'level')) ~= 0
            dimIdLev = i+1;
        end
        if length(findstr(dimname, 'lat')) ~= 0
            dimIdLat = i+1;
        end
        if length(findstr(dimname, 'lon')) ~= 0
            dimIdLon = i+1;
        end
        if length(findstr(dimname, 'time')) ~= 0
            dimIdTime = i+1;
        end
        dims{i+1} = {dimname, dimlen};
        %disp(dims{i+1});
    end
    attIdTitle = -1;
    
    atts = {};
    for i=0:natts-1
        attname = netcdf.inqAttName(ncid, netcdf.getConstant('NC_GLOBAL'), i);
        attval = netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), attname);
        if length(findstr(attname, 'title')) ~= 0
            attIdTitle = i+1;
        end
        atts{i+1} = {attname, attval};
        %This output is a bit messy but still helpful in troubleshooting cases where script doesn't recognize
        %the time step of the input file
        %fprintf('This attribute has name %s and value %d\n',attname,attval);
    end
    
    
    varIdLat = 0;varIdLon = 0;varIdLev = 0;varIdMain = 0;
    
    vars={};
    for i = 0:nvar-1
        [vname, vtype, vdim, vatts] = netcdf.inqVar(ncid,i);
        if length(findstr(vname, 'lat')) ~= 0
            varIdLat = i+1;
        end
        if length(findstr(vname, 'lon')) ~= 0
            varIdLon = i+1;
        end
        if length(findstr(vname, varName)) ~= 0
            varIdMain = i+1;
        end
        if length(findstr(vname, 'level')) ~= 0
            varIdLev = i+1;
        end
        vars{i+1} = {vname, vtype, vdim, vatts};
    end
    
    scaleFactor = 1;addOffset = 0;
    missingValue = NaN;fillValue = NaN;
    
    %Start at Jan 1 of the file year
    startDate = datenum(yearthisfile, startingmonththisfile, 1, 0, 0, 0);
    deltaT = etime(datevec('24', 'HH'), datevec('00', 'HH')); %daily timestep
    
    colin=ncread(strcat(rawNcDir,ncFileName),'lat');
    
    timestep = [];
    for t = 0:1:dims{dimIdTime}{2}-1
        timestep(t+1) = addtodate(startDate, t*deltaT, 'second');
    end
    
    if dimIdLev ~= -1
        for p=1:length(pressureLevels)
            data(:,:,p,:) = netcdf.getVar(ncid, varIdMain-1, [0, 0, pressureLevels(p), 0], [dims{dimIdLon}{2}, dims{dimIdLat}{2}, 1, dims{dimIdTime}{2}]);
        end
        data = permute(data, [2 1 3 4]);
    else
        %if startingmonththisfile==1 %i.e. reading the Jan 1-Jun 30 data
            data(:,:,:) = netcdf.getVar(ncid, 6, [0, 0, 0], [dims{dimIdLon}{2}, dims{dimIdLat}{2}, dims{dimIdTime}{2}]);
            %data = permute(data, [2 1 3]);
        %else %reading the Jul 1-Dec 31 data, which is 184 days
        %    sizepreexistingdata=size(data,3);
        %    data(:,:,sizepreexistingdata+1:sizepreexistingdata+185) = netcdf.getVar(ncid, varIdMain-1, [0, 0, 0], [dims{dimIdLon}{2}, dims{dimIdLat}{2}, dims{dimIdTime}{2}]);
        %    %data = permute(data, [2 1 3]);
        %end
    end
    
    data = single(data);
    
    data(data == missingValue) = NaN;
    data(data == -missingValue) = NaN;
    
    if length(findstr('snod', ncFileName)) ~= 0
        data(data == 0) = NaN;
    end
    
    data = data * scaleFactor + addOffset;
    
    
    %Now, actually run through the .nc file and save the data to a new .mat file
    
    curTime = timestep(1);
    endTime = addtodate(startDate, dims{dimIdTime}{2}*deltaT, 'second');
    %disp(curTime);disp(endTime);
    
    while curTime < endTime
        nextTime = addtodate(curTime, 1, 'month');
        
        %Find indices in the timestep matrix
        curIndex = find(timestep >= curTime, 1, 'first');
        nextIndex = find(timestep < nextTime, 1, 'last');
        
        %Get monthly data
        monthlyData = [];
        if dimIdLev == -1
            monthlyData = data(:, :, curIndex:nextIndex);
        else
            monthlyData = data(:, :, :, curIndex:nextIndex);
        end
        
        %Necessary adjustments
        temp=abs(monthlyData)>1000;monthlyData(temp)=NaN;
        monthlyData=monthlyData-273.15;
        
        monthlyDataSet = {oisstlats, oisstlons, double(monthlyData)};
        
        %save this data to a .mat file in the correct location and with the correct name
        fileName = [varName, '_', datestr(timestep(curIndex),'yyyy_mm')];
        eval([fileName ' = monthlyDataSet;']);
        save(strcat(folDataTarget, '/', fileName, '.mat'), fileName, '-v7.3');
        
        clear monthlyData monthlyDataSet;
        eval(['clear ' fileName]);
        
        curTime = nextTime;
    end
    
    eval(['clear ' fileName ';']);
	clear data dims vars timestep;
    netcdf.close(ncid);
    fileCount = fileCount + 1;
end


