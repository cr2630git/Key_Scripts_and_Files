%A flexible plotting script that can handle multiple types of data,%or, for wind, [lats;lons;uwndmatrix;vwndmatrix]
%data argument is of form [lats;lons;matrix] where each is an identically sized 2D grid
%277x349 for NARR, 144x73 for NCEP, 1440x720 for OISST, 144x96 for NorESM

%for example, the input might be:
%data={lats;lons;matrix};region='us-ne';
%vararginnew={'variable';'temperature';'contour';1;'mystepunderlay';2;'plotCountries';1;...
%'colormap';'jet';'caxismethod';'regional10';'datatounderlay';data;...
%'underlayvariable';'temperature';'overlaynow';0};
%vararginnew={'variable';'wet-bulb temp';'contour';0;'plotCountries';1;...
%'colormap';'jet';'caxismin';0.1;'caxismax';0.5;'overlaynow';0;'centeredon';180};
%datatype='NARR';

%for a temperature field overlaid with wind barbs:
%vararginnew={'variable';'wind';'contour';1;'plotCountries';1;...
%'caxismethod';'regional10';'vectorData';data;'overlaynow';1;...
%'overlayvariable';'temperature';'datatooverlay';overlaydata;'anomavg';'avg'};
%where data is of form {lats;lons;uwndmatrix;vwndmatrix} and
%overlaydata is of form {lats;lons;tmatrix}

%Then literally do plotModelData(data,region,vararginnew,datatype)

%If caxismethod='regionalxx', then mystep is overwritten to match this
%regional formulation, even if mystep was explicitly specified in the function call

function [caxisRange,mystep,mycolormap,fullshadingdescr,fullcontoursdescr,windbarbsdescr,...
    refval,normrefveclength,caxis_min,caxis_max]=...
    plotModelData(data,region,vararginnew,datatype)

addtext=0; %whether to algorithmically add 'after-market' text, or whether to save this step for highqualityfiguresetup
    %essentially, set to 1 if saving images via screenshot (makes things easier but doesn't look quite as nice)
    %set to 0 if saving images via highqualityfiguresetup into png or pdf format

caxisRange=[];
exist figc;if ans==1;figc=figc+1;else figc=1;end   
contour=false;
cb=0;fg=0;
if strcmp(datatype,'NARR')
    lsmask=ncread('lsmasknarr.nc','land')';sz1=277;sz2=349;
elseif strcmp(datatype,'NCEP')
    lsmask=ncread('lsmaskncep.nc','land')';sz1=144;sz2=73;
elseif strcmp(datatype,'OISST')
    lsmask=ncread('lsmaskquarterdegree.nc','lsm');sz1=1440;sz2=720;
elseif strcmp(datatype,'NorESM')
    lsmask=ncread('lsmask2point5by1point875.nc','sftlf');sz1=144;sz2=96;naturallycenteredon=0;
end
shadingdescr='';intervaldescr='';contoursdescr='';windbarbsdescr='';

fgTitle='';fgXaxis='';fgYaxis='';
noNewFig = false;
colormapVal = '';
vectorData = {};
varlistnames={'2-m Temp.';'Wet-Bulb Temp.';'Geopot. Height';'Wind';'q'};

if strcmp(datatype,'NARR') || strcmp(datatype,'NCEP') || strcmp(datatype,'OISST') || strcmp(datatype,'NorESM')
else
    disp('Please enter a valid data type.');
    return;
end
%disp('line 59');disp(max(max(data{3})));

fprintf('Region chosen is: %s\n',region);
disp('Variable arguments chosen are listed below:');
disp(vararginnew);
if mod(length(vararginnew),2)~=0
    disp('Error: must have an even # of arguments.');
else
    for count=1:2:length(vararginnew)-1
        key=vararginnew{count};
        val=vararginnew{count+1};
        switch key
            case 'variable'
                vartype=val; %'generic scalar', 'wind', 'temperature', 'height', 'wet-bulb temp',...
                    %'wv flux convergence', or 'specific humidity'
            case 'contour'
                contour=val;
            case 'plotCountries'
                plotcountries=val;
            case 'mystep'
                mystep=val;
            case 'mystepunderlay'
                mystepunderlay=val;
            case 'caxismin'
                caxis_min=val;
            case 'caxismax'
                caxis_max=val;
            case 'caxismethod'
                caxis_method=val; %'regional10', 'regional25', or 'global' (last is default)
            case 'underlaycaxismin'
                underlaycaxis_min=val;
            case 'underlaycaxismax'
                underlaycaxis_max=val;
            case 'figc'
                figc=val;
            case 'title'
                fgTitle=val;
            case 'xaxis'
                fgXaxis=val;
            case 'yaxis'
                fgYaxis=val;
            case 'nonewfig'
                noNewFig=val;
            case 'colormap'
                colormapVal=val;
            case 'vectorData'
                vectorData=val;
            case 'overlaynow'
                overlaynow=val;
            case 'overlayvariable'
                overlayvartype=val; %will be plotted as contours or barbs
            case 'overlayvariable2'
                overlayvartype2=val; %wind, so will be plotted as barbs
            case 'underlayvariable'
                underlayvartype=val; %will be plotted as colors
            case 'datatooverlay'
                overlaydata=val;
            case 'datatooverlay2'
                overlaydata2=val;
            case 'datatounderlay'
                underlaydata=val;
            case 'anomavg'
                anomavg=val;
            case 'centeredon' %longitude to center the world map on -- default is 0, other typical option is 180
                centeredon=val; 
            case 'levelplotted' %pressure level plotted -- current options are 1000, 850, 500, 300, or 200
                levelplotted=val;
            case 'contourlabels' %whether to add contour labels, or omit them
                contourlabels=val;
            case 'stateboundaries' %1 or 0; whether to show US state boundaries
                stateboundaries=val;
            case 'countryboundaries' %1 or 0; whether to show country boundaries -- overrides default
                countryboundaries=val;
            case 'omitzerocontour' %whether to omit the zero countour, in contour plots
                omitzerocontour=val;
            case 'omitfirstsubplotcolorbar' %whether to omit the colorbar on the first subplot (b/c it'll be added after)
                omitfirstsubplotcolorbar=1;
            case 'nolinesbetweenfilledcontours' %whether to omit the lines between filled contours in the underlaid data
                nolinesbetweenfilledcontours=1;
            case 'manualcontourlabels' %whether to place contour labels manually or algorithmically
                manualcontourlabels=1;
            case 'transparency'
                transparency=val; %0 is fully transparent, 1 is normal
            case 'plotasrasters'
                plotasrasters=val; %1 plots as rasters (mostly to address wrap-around issues for full world maps), 0 does the original default
        end
    end
end
%disp('line 138');disp(contour);
exist transparency;
if ans==0;transparency=1;end %i.e. make normal (non-transparent)
exist plotasrasters;
if ans==0;plotasrasters=0;end %i.e. do the original default mode

%fgHandles = findobj('Type','figure');
%if length(fgHandles)>0
%    figc=max(fgHandles)+1;
%end
%Only make a new figure (as opposed to a new subplot) if called upon to do so
if noNewFig~=1
    fg=figure(figc);clf;
    set(fg,'Color',[1,1,1]);
    axis off;
    title(fgTitle);xlabel(fgXaxis);ylabel(fgYaxis);
end

exist contourlabels;
if ans==0;contourlabels=0;end

if strcmp(region, 'world')
    mapproj='robinson';
    exist centeredon;
    if ans==1
        if centeredon==0
            southlat=-90;northlat=90;westlon=-180;eastlon=180;
        elseif centeredon==180
            %southlat=-90;northlat=90;westlon=0;eastlon=360;
            %southlat=-90;northlat=90;westlon=-360;eastlon=-3;
            southlat=-90;northlat=90;westlon=-360;eastlon=0; 
            %for some reason setting eastlon to 0, -1, or -2 messes up the plotting
        end
    else
        southlat=-90;northlat=90;westlon=-180;eastlon=180;
    end
elseif strcmp(region, 'worldminuspoles')
    southlat=-55;northlat=70;mapproj='robinson';
    exist centeredon;
    if ans==1
        if centeredon==0
            westlon=-180;eastlon=180;
        elseif centeredon==180
            westlon=-360;eastlon=0;
        end
    else
        westlon=-180;eastlon=180;
    end
elseif strcmp(region,'nhplustropics')
    southlat=-10;northlat=90;mapproj='robinson';
    exist centeredon;
    if ans==1
        if centeredon==0
            westlon=-180;eastlon=180;
        elseif centeredon==180
            westlon=-360;eastlon=0;
        end
    else
        westlon=-180;eastlon=180;
    end
elseif strcmp(region, 'nnh')
    southlat=30;northlat=90;westlon=-180;eastlon=180;mapproj='stereo';
elseif strcmp(region, 'north-atlantic')
    worldmap([25 75], [-75 10]);mapproj='lambert';
elseif strcmp(region, 'north-america')
    southlat=20;northlat=80;westlon=-170;eastlon=-35;mapproj='lambert';
elseif strcmp(region,'midlatband')
    southlat=10;northlat=60;westlon=-180;eastlon=-50;mapproj='lambert';
elseif strcmp(region, 'na-east')
    southlat=25;northlat=55;westlon=-100;eastlon=-50;mapproj='lambert';
elseif strcmp(region,'usa-full')
    southlat=15;northlat=75;westlon=-180;eastlon=-60;mapproj='lambert';
elseif strcmp(region,'usaminushawaii-tight')
    southlat=22;northlat=73;westlon=-175;eastlon=-65;mapproj='robinson';
elseif strcmp(region,'usaminushawaii-tight2')
    southlat=20;northlat=75;westlon=-175;eastlon=-60;mapproj='robinson';
elseif strcmp(region,'usaminushawaii-tight3') %a little more centered over the Lower 48
    southlat=20;northlat=75;westlon=-165;eastlon=-45;mapproj='robinson';
elseif strcmp(region, 'usa-exp')
    southlat=23;northlat=60;westlon=-135;eastlon=-55;mapproj='lambert';
elseif strcmp(region, 'usa-exp2')
    southlat=15;northlat=75;westlon=-165;eastlon=-50;mapproj='lambert';
elseif strcmp(region, 'usa')
    southlat=25;northlat=50;westlon=-126;eastlon=-64;mapproj='robinson';
elseif strcmp(region,'us-sw-small')
    southlat=31;northlat=39;westlon=-121;eastlon=-109;mapproj='mercator';
elseif strcmp(region, 'eastern-usa')
    southlat=23;northlat=50;westlon=-100;eastlon=-65;mapproj='lambert';
elseif strcmp(region,'us-mw')
    southlat=33;northlat=48;westlon=-105;eastlon=-80;mapproj='mercator';
elseif strcmp(region,'omaha-area')
    southlat=39.5;northlat=43;westlon=-98;eastlon=-94;mapproj='mercator';
elseif strcmp(region, 'us-ne')
    southlat=35;northlat=50;westlon=-85;eastlon=-60;mapproj='mercator';
elseif strcmp(region, 'us-ne-small')
    southlat=38;northlat=46;westlon=-80;eastlon=-68;mapproj='mercator';
elseif strcmp(region, 'nyc-area')
    southlat=39;northlat=42;westlon=-76;eastlon=-72;mapproj='mercator';
else
    worldmap(region);
    underlaydata{1}(:, end+1) = underlaydata{1}(:, end) + (underlaydata{1}(:, end)-underlaydata{1}(:, end-1));
    underlaydata{2}(:, end+1) = underlaydata{2}(:, end) + (underlaydata{2}(:, end)-underlaydata{2}(:, end-1));
end


numgridptsperdegree1=sz1/360;
numgridptsperdegree2=sz2/180;
%Convert lat/lon corners to NARR/NCEP/OISST gridpts
if strcmp(datatype,'NARR')
    temp1=wnarrgridpts(northlat,eastlon,1,0,1);
    temp2=wnarrgridpts(southlat,westlon,1,0,1);
elseif strcmp(datatype,'NCEP')
    temp1=wncepgridpts(northlat,eastlon,1,0);
    exist centeredon;
    if ans==1
        if centeredon==0
            temp2=wncepgridpts(southlat,westlon,1,0);
        elseif centeredon==180
            temp2=wncepgridpts(southlat,eastlon,1,0);
        else
            disp('Please make centeredon 0 or 180');return;
        end
    else
        %Default is western hemisphere, equivalent to centeredon=0
        temp2=wncepgridpts(southlat,westlon,1,0);
    end
else
    if southlat>=0;southindex=sz2-((90-southlat)*numgridptsperdegree2);else southindex=(90+southlat)*numgridptsperdegree2;end
    if northlat>=0;northindex=sz2-((90-northlat)*numgridptsperdegree2);else northindex=(90+northlat)*numgridptsperdegree2;end
    if westlon>=0;westindex=sz1-((180-westlon)*numgridptsperdegree1);else westindex=(180+westlon)*numgridptsperdegree1;end
    if eastlon>=0;eastindex=sz1-((180-eastlon)*numgridptsperdegree1);else eastindex=(180+eastlon)*numgridptsperdegree1;end
    if southindex==0;southindex=1;end
    if northindex==0;northindex=1;end
    if westindex==0;westindex=1;end
    if eastindex==0;eastindex=1;end
    %disp(centeredon);disp(naturallycenteredon);
    %Not quite sure what's going on with this next loop, but leave it in in case it's useful for modification in the future
    if centeredon==naturallycenteredon %nothing fancy needs to be done
        exist underlayvartype;
        if ans==1
            arraysz=size(underlaydata{1});
            %disp('line 274');%disp(arraysz);
            underlaydata{3}=[fliplr(underlaydata{3}(:,arraysz(2)/2+1:arraysz(2))) fliplr(underlaydata{3}(:,1:arraysz(2)/2))];
        end
    else %essentially need to move one half of the array to the other side before plotting can proceed
        exist underlayvartype;
        if ans==1
            arraysz=size(underlaydata{1});
            %disp('line 281');%disp(arraysz);
            underlaydata{3}=[fliplr(underlaydata{3}(:,arraysz(2)/2+1:arraysz(2))) fliplr(underlaydata{3}(:,1:arraysz(2)/2))];
        end
    end
    %disp(southindex);disp(northindex);disp(westindex);disp(eastindex);
end
%Account for the fact that the inputted corners may be just outside the domain
if ~strcmp(datatype,'OISST')
    if ~strcmp(region,'world')
        if temp1(1,1)<1000;northindex=temp1(1,1);else northindex=sz1;end
        if temp1(1,2)<1000;eastindex=temp1(1,2);else eastindex=sz2;end
        if temp2(1,1)<1000;southindex=temp2(1,1);else southindex=1;end
        if temp2(1,2)<1000;westindex=temp2(1,2);else westindex=1;end
    else
        northindex=1;eastindex=1;southindex=sz2;westindex=sz1;
    end
end
%disp('line 281');disp(northindex);disp(southindex);disp(eastindex);disp(westindex);

axesm(mapproj,'MapLatLimit',[southlat northlat],'MapLonLimit',[westlon eastlon]);
framem on;gridm off;mlabel off;plabel off;axis on;axis off;

if length(colormapVal)>0;colormap(colormapVal);else colormap('jet');end
mycolormap=colormap;

%Underlaydata{3} is the matrix to be plotted in color-filled contours, i.e. either the only thing, or the underlay
exist underlaydata;
if ans==0
    underlaydata=data;disp(min(min(underlaydata{3})));%disp('line 308');
end
exist vartype;
if ans==0;underlayvartype=vartype;end

exist underlayvartype;
if ans==1
    if strcmp(underlayvartype,'wet-bulb temp') || strcmp(underlayvartype,'temperature')
        dispunits='deg C';
    elseif strcmp(underlayvartype,'height')
        dispunits='m';
    elseif strcmp(underlayvartype,'wind')
        dispunits='m/s';
    elseif strcmp(underlayvartype,'specific humidity')
        dispunits='g/kg';
        %underlaydata{3}=underlaydata{3}.*1000;
    elseif strcmp(underlayvartype,'wv flux convergence')
        dispunits='kg/m^-^2';
    elseif strcmp(underlayvartype,'generic scalar')
        dispunits=''; %no units necessary
    else
        dispunits='';
    end
else
    if strcmp(vartype,'wet-bulb temp') || strcmp(vartype,'temperature')
        dispunits='deg C';
    elseif strcmp(vartype,'height')
        dispunits='m';
    elseif strcmp(vartype,'wind')
        dispunits='m/s';
    elseif strcmp(vartype,'specific humidity')
        dispunits='g/kg';
        %underlaydata{3}=underlaydata{3}.*1000;
    elseif strcmp(vartype,'wv flux convergence')
        dispunits='kg/m^-^2';
    elseif strcmp(vartype,'generic scalar')
        dispunits=''; %no units necessary
    else
        dispunits='';
    end
end
%disp('line 361');return;

%exist mystepunderlay;
%Default is 10 steps
%if ans==0;mystepunderlay=(max(max(underlaydata{3}))-min(min(underlaydata{3})))/10;end

%Determine the color range, either by specification in the function call or by default here
%Account for the fact that we don't know a priori which of (eastindex,westindex) and (southindex,northindex) will be larger
exist caxis_min;
if ans==0
    exist underlaycaxis_min;
    if ans==0
        exist caxis_method;
        if ans==0 %default is to determine range globally
            exist underlaydata;
            if ans==1;caxis_min=round2(min(min(underlaydata{3})),mystep,'floor');end
        elseif strcmp(caxis_method,'regional10')
            %disp('line 346');
            %disp(size(underlaydata{3}));
            %disp(min(southindex,northindex));disp(max(southindex,northindex));
            %disp(min(eastindex,westindex));disp(max(eastindex,westindex));
            %mystep=(max(max(mfcr(min(eastindex,westindex):max(eastindex,westindex),...
            %    min(southindex,northindex):max(southindex,northindex))))-...
            %    min(min(mfcr(min(eastindex,westindex):max(eastindex,westindex),...
            %    min(southindex,northindex):max(southindex,northindex)))))/10;
            %disp(max(max(mfcr(min(eastindex,westindex):max(eastindex,westindex),...
            %    min(southindex,northindex):max(southindex,northindex)))));
            %disp(min(min(mfcr(min(eastindex,westindex):max(eastindex,westindex),...
            %    min(southindex,northindex):max(southindex,northindex)))));
            caxis_min=round2(min(min(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),mystep,'floor');
            %caxis_min=round2(min(min(underlaydata{3})),mystep,'floor');
            disp('Note: Step size and color range have been overwritten to match the regional nature of the color axis.');
        elseif strcmp(caxis_method,'regional25')
            mystep=(max(max(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex))))-...
                min(min(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))))/25;
            caxis_min=round2(min(min(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),mystep,'floor');
            disp('Note: Step size and color range have been overwritten to match the regional nature of the color axis.');
        else
            caxis_min=round2(min(min(underlaydata{3})),mystep,'floor');
        end
    end
end
exist caxis_max;
if ans==0
    exist underlaycaxis_max;
    if ans==0
        exist caxis_method;
        if ans==0 %default is to determine range globally
            exist underlaydata;
            if ans==1;caxis_max=round2(max(max(underlaydata{3})), mystep, 'ceil');end
        elseif strcmp(caxis_method,'regional10')
            caxis_max=round2(max(max(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),mystep,'ceil');
        elseif strcmp(caxis_method,'regional25')
            caxis_max=round2(max(max(underlaydata{3}(min(eastindex,westindex):max(eastindex,westindex),...
                min(southindex,northindex):max(southindex,northindex)))),mystep,'ceil');
        else
            caxis_max=round2(max(max(underlaydata{3})),mystep,'ceil');
        end
    end
end
%disp('line 426');disp(mystep);disp(caxis_min);disp(caxis_max);


%Set underlay-data color axis
exist underlaycaxis_min;
if ans==1
    caxisRangeunderlay=[underlaycaxis_min,underlaycaxis_max];caxis(caxisRangeunderlay);
    %disp('line 433');disp(caxisRangeunderlay);
end


%Display the underlaid (or only) data, contoured or not
%This loop occasionally, unpredictably behaves problematically
exist underlayvartype;
if ans==1
    if contour
        if size(underlaydata{3},1)~=size(underlaydata{2},1);underlaydata{3}=underlaydata{3}';end
        %disp('line 620');disp(class(underlaydata{1}));disp(max(max((underlaydata{3}))));disp(mystepunderlay);
        %disp(size(underlaydata{1}));disp(size(underlaydata{2}));disp(size(underlaydata{3}));
        v=underlaycaxis_min:mystepunderlay:underlaycaxis_max;%disp('line 444');disp(v);
        %figure(100);imagescnan(underlaydata{3});colorbar;return;
        exist nolinesbetweenfilledcontours;
        %Option a: no lines between filled contours
        if ans==1
            if plotasrasters==1
                latlim=[southlat northlat];
                if westlon<0;westlon=westlon+360;end
                if eastlon<0;eastlon=eastlon+360;end
                lonlim=[westlon eastlon];
                Z1=underlaydata{3};
                R = georefcells(latlim,lonlim,size(Z1),'ColumnsStartFrom','north');
                contourm(Z1,R,v,'Fill','on');hold on;
            else %the original default mode
                h=contourm(underlaydata{1},underlaydata{2},underlaydata{3},v,'Fill','on','edgecolor','none');hold on;
                if transparency~=1;alpha(transparency);end
            end
        else %Option b: black lines between filled contours
            %IF NOT PLOTTING WHOLE GLOBE, MUST ADJUST COLUMN INDEX MANUALLY
                %SO ALL DATA IS NOT INADVERTENTLY PLOTTED
            if plotasrasters==1
                latlim=[southlat northlat];
                if westlon<0;westlon=westlon+360;end
                if eastlon<0;eastlon=eastlon+360;end
                if westlon==0 && eastlon==0;westlon=0;eastlon=360;end %if plotting entire globe
                lonlim=[westlon eastlon];
                Z1=underlaydata{3}(:,1:41)'; %only go to column 41, which matches the latitude limit of 10 S
                R = georefcells(latlim,lonlim,size(Z1),'ColumnsStartFrom','north');
                contourm(Z1,R,v,'Fill','on');hold on;
            else %the original default mode
                %disp('line 452');disp(transparency);disp(v);
                h=contourm(underlaydata{1},underlaydata{2},underlaydata{3},v,'Fill','on');hold on;
                %h=contourm(underlaydata{1},underlaydata{2},underlaydata{3},v,'LineColor','k');hold on;
                %h=contourf(underlaydata{1},underlaydata{2},underlaydata{3},v,'LineColor','k');hold on;
                if transparency~=1;alpha(transparency);end
            end
        end
        
        %Omitting the zero contour (not entirely working right now)
        %contourm(underlaydata{1},underlaydata{2},underlaydata{3},[underlaycaxis_min:mystepunderlay:0-mystepunderlay],...
        %    'Fill','on');hold on;
        %contourm(underlaydata{1},underlaydata{2},underlaydata{3},[mystepunderlay:mystepunderlay:underlaycaxis_max],...
        %    'Fill','on');
    else
        pcolorm(underlaydata{1},underlaydata{2},underlaydata{3});hold on;
    end
end
%disp('line 496');return;


%%%Prepare settings for displaying wind vectors%%%

%Calculate factors based on map size by which to multiply wind-vector sizes so that
    %they are visually accurate no matter what the map size is
%Tweaking should no longer be necessary (see recent changes in scaleval and reference-vector length within quivermc),
    %but if it is deemed to be so, proceed with caution so that any results are generalizable 
    %and excessive work need not be repeated with each minor change in the mapping options
    %Also, refvectorshrinkfactor is an outdated after-market attempt at fudging it and should NOT be changed from 1
%Tweak maparea as needed (for each region separately) to empirically make the vectors look right
    %to make arrows smaller (larger), divide maparea by a number > (<) 1 or make refval larger (smaller)
    %changing the size of the arrows must be accompanied by a corresponding change in refvectorshrinkfactor
        %e.g. if all other arrows are halved, set refvectorshrinkfactor=2 to halve it as well (default=1)
    %to make arrows more (less) dense, reduce (increase) extraskipstepfactor
    %don't change q as it affects both the length and the density
    %only refvectorshrinkfactor changes ref-vector length independent of the plotted arrows
    %(and since it's now been pretty well calibrated, it shouldn't need to be changed at all)
    
%Defaults for all regions: refvectorshrinkfactor=1, maparea=maparea/4
if length(vectorData)~=0
    maparea=(northlat-southlat)*(eastlon-westlon);
    if strcmp(region,'nhplustropics') || strcmp(region, 'north-america') || strcmp(region,'midlatband')
        q=4;extraskipstepfactor=2; %only plot every qth vector, further skipping selon skipstep
        exist levelplotted;
        if ans==1
            if length(levelplotted)~=0
                if levelplotted<=300 %high-level winds so reference vector must be longer
                    if strcmp(anomavg,'anom');refval=25;else refval=50;end
                else
                    if strcmp(anomavg,'anom');refval=15;else refval=30;end
                end
            end
        else
            if strcmp(anomavg,'anom');refval=15;else refval=30;end %default
        end
        refvectorshrinkfactor=1;
        maparea=maparea/4; %dividing by a larger number fools quivermc into making the arrows smaller
    elseif strcmp(region, 'usa-exp') || strcmp(region,'usaminushawaii-tight') || ...
            strcmp(region,'usaminushawaii-tight2') || strcmp(region, 'usa-exp2')
        q=4;extraskipstepfactor=2;
        exist levelplotted;
        if ans==1
            if length(levelplotted)~=0
                if levelplotted<=300 %high-level winds so reference vector must be longer
                    if strcmp(anomavg,'anom');refval=25;else refval=50;end
                else
                    if strcmp(anomavg,'anom');refval=15;else refval=30;end
                end
            end
        else
            if strcmp(anomavg,'anom');refval=7.5;else refval=15;end %default
        end
        refvectorshrinkfactor=1;
        maparea=maparea/4;
    elseif strcmp(region,'usaminushawaii-tight3') || strcmp(region,'usa')
        q=4;extraskipstepfactor=2;
        exist levelplotted;
        if ans==1
            if length(levelplotted)~=0
                if levelplotted<=300 %high-level winds so reference vector must be longer
                    if strcmp(anomavg,'anom');refval=25;else refval=50;end
                else
                    if strcmp(anomavg,'anom');refval=7.5;else refval=15;end
                end
            end
        else
            if strcmp(anomavg,'anom');refval=4;else refval=8;end
        end
        refvectorshrinkfactor=0.5;
        maparea=maparea/2;
    elseif strcmp(region, 'us-ne') || strcmp(region, 'us-ne-small') || strcmp(region,'us-sw-small') || strcmp(region,'us-mw')
        q=2;extraskipstepfactor=2;
        exist levelplotted;
        if ans==1
            if length(levelplotted)~=0
                if levelplotted<=300 %high-level winds so reference vector must be longer
                    if strcmp(anomavg,'anom');refval=12.5;else refval=25;end
                else
                    if strcmp(anomavg,'anom');refval=2.5;else refval=5;end
                end
            end
        else
            if strcmp(anomavg,'anom');refval=2.5;else refval=5;end %default
        end
        refvectorshrinkfactor=1;
        maparea=maparea/2;
    elseif strcmp(region, 'nyc-area') || strcmp(region,'omaha-area')
        q=1;extraskipstepfactor=1;
        exist levelplotted;
        if ans==1
            if length(levelplotted)~=0
                if levelplotted<=300 %high-level winds so reference vector must be longer
                    if strcmp(anomavg,'anom');refval=12.5;else refval=25;end
                else
                    if strcmp(anomavg,'anom');refval=2.5;else refval=5;end
                end
            end
        else
            if strcmp(anomavg,'anom');refval=2.5;else refval=5;end %default
        end
        refvectorshrinkfactor=1;
        maparea=maparea/2;
    else
        disp('Please add region in the "Prepare settings for displaying wind vectors" section of plotModelData');
        return;
    end
end

%Plot overlaid data (non-wind)
if overlaynow==1
    %Set overlay-data color axis
    exist caxis_min;
    if ans==1
        %caxisRange=[caxis_min,caxis_max];caxis(caxisRange);
        %disp('line 612');disp(caxisRange);
    end

    %The next 12 lines may have to be commented out, depending on the specifics of the situation
    if size(overlaydata,1)==3 %if it's wind, we don't want it to have labeled contours
        v=caxis_min:mystep:caxis_max;%disp('line 617');disp(v);
        exist omitzerocontour;
        if ans==1
            if omitzerocontour==1
                %Plots positive solid and negative dashed, and omits the zero contour
                contourm(overlaydata{1},overlaydata{2},overlaydata{3},[caxis_min:mystep:0-mystep],...
                    '--','linewidth',1,'linecolor','k');hold on;
                [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},[mystep:mystep:caxis_max],...
                    'linewidth',1,'linecolor','k');
            else
                %Plots all contours solid
                [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},v,'LineWidth',1,'LineColor','k');
            end
        else
            [C,h]=contourm(overlaydata{1},overlaydata{2},overlaydata{3},v,'LineWidth',1,'LineColor','k');
        end
        
        %Space out the labels so there's not too many but every line is still labeled
        %Bigger numbers = more space between labels
        if strcmp(region, 'us-ne') || strcmp(region, 'us-ne-small') || strcmp(region, 'nyc-area') ||...
                strcmp(region,'us-sw-small') || strcmp(region,'omaha-area') || strcmp(region,'us-mw')
            labelspacing=1000; 
        elseif strcmp(region, 'north-america') || strcmp(region,'midlatband') || strcmp(region,'usa')
            labelspacing=500;
        else
            labelspacing=10000;
        end
        
        
        %Labels are made toward the end of the script, so that they are not
            %overwritten by state borders (search for "actually make labels")
        %If desired, actually make labels
    end
    hold on;
    
    exist overlayvartype2;
    if ans~=0
        contourm(overlaydata2{1},overlaydata2{2},overlaydata2{3},'LineWidth',2,'LineColor','k');
    end
    
    overlaymax=roundsd(max(max(overlaydata{3})),1);overlaymin=roundsd(min(min(overlaydata{3})),1);
    overlayrange=overlaymax-overlaymin;overlayrangetenths=overlayrange/10;
    exist mystep;
    if ans==0
        overlaysteps=overlaymin:overlayrangetenths:overlaymax;
    else
        overlaysteps=overlaymin:mystep:overlaymax;
    end
    %disp('line 782');disp(overlaysteps);
    %disp(overlaymax);disp(overlaymin);disp(overlayrange);disp(overlayrangetenths);disp(overlaysteps);disp('hi');
    %Round steps to nearest 'number that ends in a zero' so they aren't odd values
    for i=1:size(overlaysteps,2)
        if abs(overlaysteps(i))<10
            overlaysteps(i)=round2(overlaysteps(i),20);
        elseif abs(overlaysteps(i))<100
            overlaysteps(i)=round2(overlaysteps(i),40);
        elseif abs(overlaysteps(i))>=100
            overlaysteps(i)=round2(overlaysteps(i),200);
        end
    end
    overlaysteps=unique(overlaysteps); %remove duplicate values
    %disp(overlaysteps);disp('hi 2.0');
end

%Second overlaid variable could show up under either of these names
exist overlayvartype2;phrfound=0;
if ans==1
    if strcmp(overlayvartype2,'wind');phr='Arrows: Wind in m/s';else phr='';end
    if addtext==1;disp('line 897');uicontrol('Style','text','String',phr,'Units','normalized',...
        'Position',[0.4 0.04 0.2 0.05],'BackgroundColor','w','FontName','Arial','FontSize',14);end
    phrfound=1;
end
exist overlaydata;
if ans==1 && phrfound==0
    if size(overlaydata,1)==4;phr='Arrows: Wind in m/s';else phr='';end
else
    phr='';
end
windbarbsdescr=phr;

%Finally, if plotting wind vectors, use quivermc to do so
%either 'addtext' or 'dontaddtext' for the reference vector
exist vectorData;
if ans==1
    if length(vectorData)~=0
        [~,~,normrefveclength]=quivermc(vectorData{1}(1:q:end,1:q:end),vectorData{2}(1:q:end,1:q:end),...
            vectorData{3}(1:q:end,1:q:end),vectorData{4}(1:q:end,1:q:end),'dontaddtext',...
            'reference',refval,'maparea',maparea,'mapregion',region,'skipstep',extraskipstepfactor,...
            'refvectorshrinkfactor',refvectorshrinkfactor);
    else
        normrefveclength=0;
    end
else
    normrefveclength=0;
end


%Plot geography in background
load coast;framem on;

plotstateboundaries=1;
exist stateboundaries;
if ans==1
    if stateboundaries==0;plotstateboundaries=0;end
end

%Set color to shade the land areas (each US state and all countries in the domain)
co=colors('ghost white'); %defaults are white or gray, but this can be any color in 'colors' script
cbc='k'; %countryboundarycolor

if plotstateboundaries==1
    states=shaperead('usastatelo','UseGeoCoords',true);
    geoshow(states,'DisplayType','polygon','DefaultFaceColor',co,'FaceAlpha',0);
end

exist countryboundaries;
if ans==1
    if countryboundaries==0;cbc=colors('ghost white');co=cbc;end
end
%disp('line 442');

if plotcountries
    borders('Canada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    borders('Mexico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    if strcmp(region,'nnh') || strcmp(region,'world') || strcmp(region,'worldminuspoles') || strcmp(region,'nhplustropics')
        borders('Mexico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Japan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Korea, Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Syrian Arab Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Korea, Democratic People''s Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Greenland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('China','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Mongolia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Nepal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Bhutan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('India','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Russia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Kazakhstan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Tajikistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Turkmenistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Uzbekistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Kyrgyzstan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Afghanistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Pakistan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Iran Islamic Republic of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Iraq','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Kuwait','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Lebanon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Israel','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Palestine','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Jordan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Azerbaijan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Georgia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Armenia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Turkey','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Egypt','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Libyan Arab Jamahiriya','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Algeria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Tunisia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Morocco','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Cyprus','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Ukraine','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Romania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Republic of Moldova','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Bulgaria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Greece','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Albania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Montenegro','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Croatia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Serbia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Slovenia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('The former Yugoslav Republic of Macedonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Bosnia and Herzegovina','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Lithuania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Latvia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Hungary','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Slovakia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Belarus','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Estonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Finland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Sweden','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Norway','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Aland Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Svalbard','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Faroe Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Poland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Czech Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Austria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Italy','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Switzerland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('France','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Germany','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Denmark','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Netherlands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Belgium','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('United Kingdom','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Ireland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Spain','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Portugal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Gibraltar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Iceland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Luxembourg','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Liechtenstein','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Monaco','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('San Marino','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Andorra','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Malta','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Holy See Vatican City','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    end
    if strcmp(region,'north-america') || strcmp(region,'usaminushawaii-tight') ||...
            strcmp(region,'usaminushawaii-tight2') || strcmp(region,'usaminushawaii-tight3') || strcmp(region,'world') ||...
            strcmp(region,'worldminuspoles') || strcmp(region,'nhplustropics') || strcmp(region,'midlatband')
        borders('Mexico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Cuba','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Bahamas','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Greenland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Haiti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Dominican Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Jamaica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Nicaragua','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Costa Rica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Panama','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Colombia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Venezuela','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Honduras','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Guatemala','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Belize','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('El Salvador','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('British Virgin Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Grenada','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Dominica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Bermuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Puerto Rico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Antigua and Barbuda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Barbados','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Saint Kitts and Nevis','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Saint Lucia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Saint Vincent and the Grenadines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Trinidad and Tobago','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Netherlands Antilles','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Aruba','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('United States Minor Outlying Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Martinique','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Cayman Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    elseif strcmp(region,'na-east') || strcmp(region,'usa-exp') || strcmp(region,'usa') || strcmp(region,'usa-exp2')
        borders('Mexico','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Cuba','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Bahamas','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    end
    if strcmp(region,'world') || strcmp(region,'worldminuspoles') || strcmp(region,'nhplustropics')
        borders('Guinea-Bissau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Equatorial Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Nicaragua','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Costa Rica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Suriname','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Guyana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('French Guiana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Brazil','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Ecuador','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Peru','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Bolivia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Chile','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Paraguay','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Argentina','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Uruguay','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Falkland Islands Malvinas','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Chad','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Senegal','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Mali','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Mauritania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Niger','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Nigeria','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Ghana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Togo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Benin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Liberia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Cameroon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Congo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Mauritius','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Gabon','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Democratic Republic of the Congo','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Angola','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Namibia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Botswana','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('South Africa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Swaziland','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Madagascar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Mozambique','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Malawi','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Gambia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Zambia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Zimbabwe','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Kenya','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('United Republic of Tanzania','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Uganda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Rwanda','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Burundi','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Ethiopia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Somalia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Oman','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Sudan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Central African Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Qatar','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Western Sahara','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Yemen','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Saudi Arabia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('United Arab Emirates','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Bahrain','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Macau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Hong Kong','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Sri Lanka','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Thailand','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Burma','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Cambodia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Cote d''Ivoire','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Cape Verde','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Sierra Leone','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Burkina Faso','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Djibouti','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Eritrea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Viet Nam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Philippines','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Malaysia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Taiwan','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Indonesia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Singapore','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Comoros','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Papua New Guinea','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('French Polynesia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Australia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('New Zealand','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Antarctica','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Solomon Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Fiji','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Micronesia, Federated States of','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Vanuatu','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Tonga','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Tuvalu','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Lesotho','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Bangladesh','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Brunei Darussalam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Samoa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('American Samoa','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('New Caledonia','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('British Indian Ocean Territory','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Reunion','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Seychelles','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Commonwealth of the Northern Mariana Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Palau','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Nauru','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Guam','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Lao People''s Democratic Republic','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);borders('Saint Martin','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('South Georgia South Sandwich Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Marshall Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Sao Tome and Principe','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('French Southern and Antarctic Lands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
        borders('Cocos Keeling Islands','k','facecolor',co,'edgecolor',cbc,'FaceAlpha',0);
    end
    %Whether to plot the US without any state boundaries (i.e. erasing the
        %ones that have previously been written)
    %borders('United States','k','facecolor',co,'edgecolor','k');
    tightmap;
end

if ~noNewFig
    exist underlaydata; %i.e. if plotting anything that needs a colorbar
    if ans==1
        exist omitfirstsubplotcolorbar;
        if ans==1
            if omitfirstsubplotcolorbar~=1
                cb=colorbar('Location','eastoutside');set(colorbar,'fontweight','bold','fontsize',15);
            end
        else
            cb=colorbar('Location','eastoutside');set(colorbar,'fontweight','bold','fontsize',15);
        end
    end
end

%If not making the final multipanel figure, shrink figure a little to give space for axis labels
%if ~noNewFig;set(gca,'Position',[.15 .15 .65 .7]);xlim([-0.5 0.5]);end

if strcmp(region,'us-ne') || strcmp(region,'us-ne-small') || strcmp(region,'us-sw-small') || strcmp(region,'us-mw')
    zoom(2.5);ylim([0.6 1.0]);
end
%disp('line 644');

%Need to repeat some steps so that parts of the map are not accidentally overwritten
skiphere=0;
if skiphere==0
 
   

%Add text labels in various places
if overlaynow==1
    exist underlayvartype;
    if ans==1
        if strcmp(underlayvartype,'height')
            underlaydatanum=3;phr=sprintf('Shading: %s',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'temperature')
            underlaydatanum=1;phr=sprintf('Shading: %s in deg C',varlistnames{underlaydatanum});
        %elseif strcmp(underlayvartype,'wind') %script not equipped to deal with underlaid wind yet
        %    phr=sprintf('Shading: %s in m/s',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'wet-bulb temp')
            underlaydatanum=2;phr=sprintf('Shading: %s in deg C',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'specific humidity')
            underlaydatanum=5;phr=sprintf('Shading: %s in g/kg',varlistnames{underlaydatanum});
        elseif strcmp(underlayvartype,'wv flux convergence')
            underlaydatanum=6;phr=sprintf('Shading: %s in kg/m^-2',varlistnames{underlaydatanum});
        else
            phr='';
        end
    else
        if strcmp(vartype,'height')
            datanum=3;phr=sprintf('Shading: %s',varlistnames{datanum});
        elseif strcmp(vartype,'temperature')
            datanum=1;phr=sprintf('Shading: %s in deg C',varlistnames{datanum});
        %elseif strcmp(vartype,'wind') %script not equipped to deal with underlaid wind yet
        %    phr=sprintf('Shading: %s in m/s',varlistnames{datanum});
        elseif strcmp(vartype,'wet-bulb temp')
            datanum=2;phr=sprintf('Shading: %s in deg C',varlistnames{datanum});
        elseif strcmp(vartype,'specific humidity')
            datanum=5;phr=sprintf('Shading: %s in g/kg',varlistnames{datanum});
        elseif strcmp(vartype,'wv flux convergence')
            datanum=6;phr=sprintf('Shading: %s in kg/m^-2',varlistnames{datanum});
        else
            phr='';
        end
    end
    shadingdescr=phr;
    if addtext==1;disp('line 923');uicontrol('Style','text','String',phr,'Units','normalized',...
        'Position',[0.4 0.09 0.2 0.05],'BackgroundColor','w','FontName','Arial','FontSize',14);end
    
    if strcmp(overlayvartype,'height')
        overlaydatanum=3;phrcont=sprintf('Contours: %s in m',varlistnames{overlaydatanum});
    elseif strcmp(overlayvartype,'temperature')
        overlaydatanum=1;phrcont=sprintf('Contours: %s in deg C',varlistnames{overlaydatanum});
    elseif strcmp(overlayvartype,'wind')
        overlaydatanum=4;phrcont=sprintf('Contours: %s in m/s',varlistnames{overlaydatanum});
    elseif strcmp(overlayvartype,'wet-bulb temp')
        overlaydatanum=2;phrcont=sprintf('Contours: %s in deg C',varlistnames{overlaydatanum});
    elseif strcmp(overlayvartype,'wv flux convergence')
        overlaydatanum=5;phrcont=sprintf('Contours: %s in kg/m^-2',varlistnames{overlaydatanum});
    else
        phrcont='';
    end
    contoursdescr=phrcont;
end

%Phrases to display in the caption
if contour
    exist underlayvartype;
    if ans==1
        if strcmp(underlayvartype,'height')
            phr=sprintf('(interval: %0.0f %s)',mystepunderlay,dispunits);
        %elseif strcmp(underlayvartype,'wv flux convergence')
        %    phr=sprintf('(Shading interval: %0.2f %s)',mystep,dispunits);
        else
            phr=sprintf(' (interval: %0.1f %s)',mystepunderlay,dispunits);
        end
    else
        if strcmp(vartype,'height')
            phr=sprintf('(interval: %0.0f %s)',mystep,dispunits);
        %elseif strcmp(vartype,'wv flux convergence')
        %    phr=sprintf('(Shading interval: %0.2f %s)',mystep,dispunits);
        else
            phr=sprintf(' (interval: %0.1f %s)',mystep,dispunits);
        end
    end
    intervaldescr=phr;
    
    fullshadingdescr=strcat([shadingdescr,' ',intervaldescr]);
    shadingphr=fullshadingdescr;
    
    exist overlaydata;
    if ans==1
        if size(overlaydata,1)==3 %i.e. if it's a scalar, contoured thing
            fullcontoursdescr=strcat([contoursdescr,' ',intervaldescr]);
            contoursphr=fullcontoursdescr;
        end
    end
    
    if addtext==1;disp('line 885');uicontrol('Style','text','String',shadingphr,...
        'Position',[100 30 0.2 0.05],'BackgroundColor','w','FontName','Arial','FontSize',18);end
    if overlaynow==1 && addtext==1
        disp('line 731');uicontrol('Style','text','String',phrcont,'Units','normalized',...
                'Position',[0.4 0.07 0.2 0.05],'BackgroundColor','w','FontName','Arial','FontSize',18);
    end
end


if contourlabels==1
    exist manualcontourlabels;
    if ans==1
        t=clabelm(C,h,'manual');
    else
        t=clabelm(C,h,'LabelSpacing',labelspacing);
    end
    set(t,'FontSize',15,'FontWeight','bold');
end

%THIS LOOP IS TEMPORARILY OUT OF SERVICE
%One more iteration of plotting & labeling just to ensure it is on top of the contour lines!!!
doublelabel=1;
if overlaynow==1
    if doublelabel==1 && size(overlaydata,1)==3 %if it's wind, we don't want it to have labeled contours
        if contourlabels==1
            %t=clabelm(C,h,overlaysteps,'LabelSpacing',labelspacing);
            set(t,'FontSize',12,'FontWeight','bold');
        end
        %uistack(t,'top');alpha(t,1);
        %allChildren = get(gca,'Children');
        %textChildren = findobj(allChildren,'Type','text');
        %set(gca,'Children',[textChildren; setdiff(allChildren,textChildren)]);
    end
end

%Finally, if plotting wind vectors, use quivermc to do so
%either 'addtext' or 'dontaddtext' for the reference vector
exist vectorData;
if ans==1
    if length(vectorData)~=0
        [~,~,normrefveclength]=quivermc(vectorData{1}(1:q:end,1:q:end),vectorData{2}(1:q:end,1:q:end),...
            vectorData{3}(1:q:end,1:q:end),vectorData{4}(1:q:end,1:q:end),'dontaddtext',...
            'reference',refval,'maparea',maparea,'mapregion',region,'skipstep',extraskipstepfactor,...
            'refvectorshrinkfactor',refvectorshrinkfactor);
    else
        normrefveclength=0;
    end
else
    normrefveclength=0;
end

exist refval;if ans==0;refval=0;end
exist windbarbsdescr;if ans==0;windbarbsdescr='';end
exist normrefveclength;if ans==0;normrefveclength=0;end
exist fullshadingdescr;if ans==0;fullshadingdescr='';end
exist fullcontoursdescr;if ans==0;fullcontoursdescr='';end
clear centeredon;

%disp('line 1033 -- made it through entire plotModelData script');

%tightmap;
end

