function curArr = getnarrdatabymonth(runningremotely,var,year,month)
%Gets NARR arrays for a given month for a given variable
%   Replaces the commands that were originally in every loop in readnarrdataXXX
%   var is given as a string: 'air', 'shum', 'hgt', 'uwnd', 'vwnd'


%Set up directories
if runningremotely==1
    curDir='/cr/cr2630/NARR_3-hourly_data_mat';
else
    curDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_mat';
end


%Get ready to load in the files
if month<=9
    curFile=load(char(strcat(curDir,'/',var,'/',num2str(year),'/',...
        var,'_',num2str(year),'_0',num2str(month),'_01.mat')));
    lastpartcur=char(strcat(var,'_',num2str(year),'_0',num2str(month),'_01'));
else
    curFile=load(char(strcat(curDir,'/',var,'/',...
        num2str(year),'/',var,'_',num2str(year),'_',num2str(month),'_01.mat')));
    lastpartcur=char(strcat(var,'_',num2str(year),'_',num2str(month),'_01'));
end
curArr=eval(['curFile.' lastpartcur]);
clear curFile;

end

