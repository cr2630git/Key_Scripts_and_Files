%Calculates daily (within MJJAS) climatologies of the desired variable quickly and cleanly, without
    %any of the messiness inherent in using code from a big pre-existing script
    
%Runtime: about 1 min per month, or 3 hours total
resetall=0;

yeariwf=1981;yeariwl=2015;
monthiwf=5;monthiwl=9;
monthlengthsdays=[31;30;31;31;30];

curDir='/Users/craymon3/General_Academics/Research/Exploratory_Plots/';
narrDir='/Volumes/MacFormatted4TBExternalDrive/NARR_3-hourly_data_mat/';
varnames={'t';'shum';'uwnd';'vwnd';'gh'};
ghofsfc=ncread('/Volumes/MacFormatted4TBExternalDrive/narrghofsfc.nc','hgt');temp=ghofsfc<0;ghofsfc(temp)=NaN;
presofsfc=pressurefromheight(ghofsfc)';

%Disregard leap years (it's ok if the climatology in those years is one day offset from that in normal years)
%Set up climo arrays
if resetall==1
    for i=1:size(varnames,1)
        for day=120:300
            eval([varnames{i} 'climo1000{day}=zeros(277,349);']);eval([varnames{i} 'climo850{day}=zeros(277,349);']);
            eval([varnames{i} 'climo700{day}=zeros(277,349);']);eval([varnames{i} 'climo500{day}=zeros(277,349);']);
            eval([varnames{i} 'climo300{day}=zeros(277,349);']);
        end
    end
end

%Do the actual calculation
for year=yeariwf:yeariwl
    for month=monthiwf:monthiwl
        fprintf('Computing NARR climo for year %d and month %d\n',year,month);
        doyfirstdom=DatetoDOY(month,1,year);if rem(year,4)==0;doyfirstdom=doyfirstdom-1;end
        
        readncfiles=0;
        if readncfiles==0 %Read already-created mat files
            tfile=load(strcat(narrDir,'air/',num2str(year),'/air_',num2str(year),'_0',num2str(month),'_01.mat'));
            tdata=eval(['tfile.air_' num2str(year) '_0' num2str(month) '_01;']);tdata=tdata{3};clear tfile;
            shumfile=load(strcat(narrDir,'shum/',num2str(year),'/shum_',num2str(year),'_0',num2str(month),'_01.mat'));
            shumdata=eval(['shumfile.shum_' num2str(year) '_0' num2str(month) '_01;']);shumdata=shumdata{3};clear shumfile;
            uwndfile=load(strcat(narrDir,'uwnd/',num2str(year),'/uwnd_',num2str(year),'_0',num2str(month),'_01.mat'));
            uwnddata=eval(['uwndfile.uwnd_' num2str(year) '_0' num2str(month) '_01;']);uwnddata=uwnddata{3};clear uwndfile;
            vwndfile=load(strcat(narrDir,'vwnd/',num2str(year),'/vwnd_',num2str(year),'_0',num2str(month),'_01.mat'));
            vwnddata=eval(['vwndfile.vwnd_' num2str(year) '_0' num2str(month) '_01;']);vwnddata=vwnddata{3};clear vwndfile;
            ghfile=load(strcat(narrDir,'hgt/',num2str(year),'/hgt_',num2str(year),'_0',num2str(month),'_01.mat'));
            ghdata=eval(['ghfile.hgt_' num2str(year) '_0' num2str(month) '_01;']);ghdata=ghdata{3};clear ghfile;
        
            tdata1000=tdata(:,:,1,:);tdata850=tdata(:,:,2,:);
            tdata700=tdata(:,:,3,:);tdata500=tdata(:,:,4,:);tdata300=tdata(:,:,5,:);clear tdata;
            shumdata1000=shumdata(:,:,1,:);shumdata850=shumdata(:,:,2,:);
            shumdata700=shumdata(:,:,3,:);shumdata500=shumdata(:,:,4,:);shumdata300=shumdata(:,:,5,:);clear shumdata;
            uwnddata1000=uwnddata(:,:,1,:);uwnddata850=uwnddata(:,:,2,:);
            uwnddata700=uwnddata(:,:,3,:);uwnddata500=uwnddata(:,:,4,:);uwnddata300=uwnddata(:,:,5,:);clear uwnddata;
            vwnddata1000=vwnddata(:,:,1,:);vwnddata850=vwnddata(:,:,2,:);
            vwnddata700=vwnddata(:,:,3,:);vwnddata500=vwnddata(:,:,4,:);vwnddata300=vwnddata(:,:,5,:);clear vwnddata;
            ghdata1000=ghdata(:,:,1,:);ghdata850=ghdata(:,:,2,:);
            ghdata700=ghdata(:,:,3,:);ghdata500=ghdata(:,:,4,:);ghdata300=ghdata(:,:,5,:);clear ghdata;
        else
            %(Slower) alternative to mat files -- original nc files
            tfile=ncread(strcat(narrncDir,'air.',num2str(year),'0',num2str(month),'.nc'),'air');
            tdata=permute(tfile,[2 1 3 4]);clear tfile;fclose('all');
            tdata1000=tdata(:,:,1,:);tdata850=tdata(:,:,7,:);
            tdata700=tdata(:,:,13,:);tdata500=tdata(:,:,17,:);clear tdata;
            shumfile=ncread(strcat(narrncDir,'shum.',num2str(year),'0',num2str(month),'.nc'),'shum');
            shumdata=permute(shumfile,[2 1 3 4]);clear shumfile;fclose('all');
            shumdata1000=shumdata(:,:,1,:);shumdata850=shumdata(:,:,7,:);shumdata700=shumdata(:,:,13,:);
            shumdata500=shumdata(:,:,17,:);clear shumdata;
            ghfile=ncread(strcat(narrncDir,'hgt.',num2str(year),'0',num2str(month),'.nc'),'hgt');
            ghdata=permute(ghfile,[2 1 3 4]);clear ghfile;fclose('all');
            ghdata1000=ghdata(:,:,1,:);ghdata850=ghdata(:,:,7,:);
            ghdata700=ghdata(:,:,13,:);ghdata500=ghdata(:,:,17,:);clear ghdata;
            uwndfile=ncread(strcat(narrncDir,'uwnd.',num2str(year),'0',num2str(month),'.nc'),'uwnd');
            uwnddata=permute(uwndfile,[2 1 3 4]);clear uwndfile;fclose('all');
            uwnddata1000=uwnddata(:,:,1,:);uwnddata850=uwnddata(:,:,7,:);
            uwnddata700=uwnddata(:,:,13,:);uwnddata500=uwnddata(:,:,17,:);clear uwnddata;
            vwndfile=ncread(strcat(narrncDir,'vwnd.',num2str(year),'0',num2str(month),'.nc'),'vwnd');
            vwnddata=permute(vwndfile,[2 1 3 4]);clear vwndfile;fclose('all');
            vwnddata1000=vwnddata(:,:,1,:);vwnddata850=vwnddata(:,:,7,:);
            vwnddata700=vwnddata(:,:,13,:);vwnddata500=vwnddata(:,:,17,:);clear vwnddata; 
        end
        
        for day=1:monthlengthsdays(month-monthiwf+1)
            thisdaydoy=doyfirstdom+day-1;
            for i=1:size(varnames,1)
                eval([varnames{i} 'climo1000{thisdaydoy}=' varnames{i} 'climo1000{thisdaydoy}+mean(' varnames{i} ...
                    'data1000(:,:,1,day*8-7:day*8),4);']);
                eval([varnames{i} 'climo850{thisdaydoy}=' varnames{i} 'climo850{thisdaydoy}+mean(' varnames{i} ...
                    'data850(:,:,1,day*8-7:day*8),4);']);
                eval([varnames{i} 'climo700{thisdaydoy}=' varnames{i} 'climo700{thisdaydoy}+mean(' varnames{i} ...
                    'data700(:,:,1,day*8-7:day*8),4);']);
                eval([varnames{i} 'climo500{thisdaydoy}=' varnames{i} 'climo500{thisdaydoy}+mean(' varnames{i} ...
                    'data500(:,:,1,day*8-7:day*8),4);']);
                eval([varnames{i} 'climo300{thisdaydoy}=' varnames{i} 'climo300{thisdaydoy}+mean(' varnames{i} ...
                    'data300(:,:,1,day*8-7:day*8),4);']);
            end
            tclimo1000{thisdaydoy}=tclimo1000{thisdaydoy}-273.15;
            tclimo850{thisdaydoy}=tclimo850{thisdaydoy}-273.15;
            tclimo700{thisdaydoy}=tclimo700{thisdaydoy}-273.15;
            tclimo500{thisdaydoy}=tclimo500{thisdaydoy}-273.15;
            tclimo300{thisdaydoy}=tclimo300{thisdaydoy}-273.15;
        end
    end
    if rem(year,10)==0
        fprintf('At a checkpoint, so saving climatological arrays as computed thus far');
        disp(clock);
        save(strcat(curDir,'computenarrclimo'),'tclimo1000','tclimo850','tclimo700','tclimo500',...
        'tclimo300','shumclimo1000','shumclimo850','shumclimo700','shumclimo500','shumclimo300','uwndclimo1000',...
        'uwndclimo850','uwndclimo700','uwndclimo500','uwndclimo300','vwndclimo1000','vwndclimo850',...
        'vwndclimo700','vwndclimo500','vwndclimo300','ghclimo1000','ghclimo850','ghclimo700',...
        'ghclimo500','ghclimo300','-append');
    end
end

%Divide to go from sums to averages
for day=120:300
    for i=1:size(varnames,1)
        eval([varnames{i} 'climo1000{day}=' varnames{i} 'climo1000{day}./(yeariwl-yeariwf+1);']);
        eval([varnames{i} 'climo850{day}=' varnames{i} 'climo850{day}./(yeariwl-yeariwf+1);']);
        eval([varnames{i} 'climo700{day}=' varnames{i} 'climo700{day}./(yeariwl-yeariwf+1);']);
        eval([varnames{i} 'climo500{day}=' varnames{i} 'climo500{day}./(yeariwl-yeariwf+1);']);
        eval([varnames{i} 'climo300{day}=' varnames{i} 'climo300{day}./(yeariwl-yeariwf+1);']);
    end
    wbtclimo1000{day}=calcwbtfromTandshum(tclimo1000{day},shumclimo1000{day},1);
    wbtclimo850{day}=calcwbtfromTandshum(tclimo850{day},shumclimo850{day},1);
    wbtclimo700{day}=calcwbtfromTandshum(tclimo700{day},shumclimo700{day},1);
    wbtclimo500{day}=calcwbtfromTandshum(tclimo500{day},shumclimo500{day},1);
    wbtclimo300{day}=calcwbtfromTandshum(tclimo300{day},shumclimo300{day},1);
end
save(strcat(curDir,'computenarrclimo'),'tclimo1000','tclimo850','tclimo700','tclimo500','tclimo300',...
        'shumclimo1000','shumclimo850','shumclimo700','shumclimo500','shumclimo300','uwndclimo1000',...
        'uwndclimo850','uwndclimo700','uwndclimo500','uwndclimo300','vwndclimo1000','vwndclimo850',...
        'vwndclimo700','vwndclimo500','vwndclimo300','ghclimo1000','ghclimo850','ghclimo700','ghclimo500',...
        'ghclimo300','wbtclimo1000','wbtclimo850','wbtclimo700','wbtclimo500','wbtclimo300','-append');


%Use height of surface to compute climatologies that are at ground level (i.e. taking into account the terrain)
for day=120:300
    for k=1:4
        temp1000=eval([varnames{k} 'climo1000{day};']);
        temp850=eval([varnames{k} 'climo850{day};']);
        temp700=eval([varnames{k} 'climo700{day};']);
        temp500=eval([varnames{k} 'climo500{day};']);
        tempinterp=NaN.*ones(277,349);
        for i=1:277
            for j=1:349
                if narrlsmask(i,j)==1 %land only
                    if presofsfc(i,j)==1000
                        tempinterp(i,j)=temp1000(i,j);
                    elseif presofsfc(i,j)>850
                        wgt1000=(presofsfc(i,j)-850)./(1000-850);
                        wgt850=(1000-presofsfc(i,j))./(1000-850);
                        tempinterp(i,j)=wgt1000.*temp1000(i,j)+wgt850.*temp850(i,j);
                    elseif presofsfc(i,j)==850
                        tempinterp(i,j)=temp850(i,j);
                    elseif presofsfc(i,j)>700
                        wgt850=(presofsfc(i,j)-700)./(850-700);
                        wgt700=(850-presofsfc(i,j))./(850-700);
                        tempinterp(i,j)=wgt850.*temp850(i,j)+wgt700.*temp700(i,j);
                    elseif presofsfc(i,j)==700
                        tempinterp(i,j)=temp700(i,j);
                    else
                        wgt700=(presofsfc(i,j)-500)./(700-500);
                        wgt500=(700-presofsfc(i,j))./(700-500);
                        tempinterp(i,j)=wgt700.*temp700(i,j)+wgt500.*temp500(i,j);
                    end
                end
            end
        end
        eval([varnames{k} 'climoterrainsfc{day}=tempinterp;']);
    end
    wbtclimoterrainsfc{day}=calcwbtfromTandshum(tclimoterrainsfc{day},shumclimoterrainsfc{day},1);
end
save(strcat(curDir,'computenarrclimo'),'tclimoterrainsfc','shumclimoterrainsfc',...
    'uwndclimoterrainsfc','vwndclimoterrainsfc','wbtclimoterrainsfc','-append');