function [h_barb_handles,brbindx] = plot_windbarb(u,v,lat,lon,scale,units)
%
% [h_barb_handles,brbindx] = plot_windbarb(u,v,lat,lon,scale,units);
%
% plot_windbarb takes u,v components of the windfield
% and plots them as standard meteorological wind-barbs.
% Scale adjusts the size(s) of the barbs while lat determines
% if the barbs are clockwise (northern hemisphere) or
% counterclockwise-pointing.
%
% input:
% u,v components of the wind field.
% lat,lon the latitude, longitude (or x,y) coordinates of the u,v data.
% Southern hemisphere (negative lat) sites have counterclockwise-
% pointing feathers. (N.B. if data are not geographical this
% might be a problem if the y/lat coordinate is partially
% negative).
% scale the length in centimeters that the barb should be on the page.
% [default = 1].
% units 'kt' or 'm/s' units of u,v. Program assumes the standard
% 5|10|50 knot speeds for half|full|flag feathers. If the data
% are in m/s it multiplies them by 2 to get barbs that conform
% to the 2.5|5|25 m/s standard. [default = 'kt'];
%
% output:
% h_barb_handles the handles to the patch objects plotted.
% brbindx the indices for the u,v obs that are actually plotted
% (NaNs, if there are any, are removed before plotting)
%

% James Foster 17 July 2003

if nargin < 6 || isempty(units)
     units = 'kt';
end

if nargin < 5 || isempty(scale)
     scale = 1; % default scale = 1 cm.
end

% define default dimensions for the barb * feather components:
shaft_length = 1;
half_length = .2;
full_length = .4;
flag_length = .4;
feather_ang = 20.*pi./180;
feather_sep = sin(feather_ang).*flag_length; % defined so that the base of a flag is exactly one separation wide.

% first check the vectors and remove any NaN observations:
allindx = 1:length(u);
nanindx = find(isnan(u+v+lat+lon));
brbindx = setxor(allindx,nanindx);
u(nanindx)=[];
v(nanindx)=[];
lat(nanindx)=[];
lon(nanindx)=[];

sense = sign(lat).*ones(size(u)); % check for hemisphere and set clockwise/counterclockwise feathers

% convert u,v to azimuth and speed:
azmth = atan2(u,v);
speed = sqrt(u.^2 + v.^2);

% check units and multiply speed by 2 if units are 'ms' in order to get
% barbs are 2.5,5 and 25 m/s.
if strcmp(units,'m/s')
     speed = 2.*speed;
end

% test the axes properties to find out what the scaling is so that
% we can plot 1 cm:
oldunits = get(gca,'Units');
set(gca,'Units','centimeters');
cmposn = get(gca,'Position');
set(gca,'Units',oldunits);

xcmrange = cmposn(3);
ycmrange = cmposn(4);

% get the Xlims and Ylims so that we can define coordinates in proper
% units:
xlims = get(gca,'XLim');
ylims = get(gca,'YLim');

xrange = diff(xlims); yrange = diff(ylims);
xscale = (xrange./xcmrange);
yscale = (yrange./ycmrange);

% use this scalings to form a scale matrix that will convert a unit vector
% into one that is "scale" centimeters long when plotted in these axes:

scalemat = scale.*[xscale 0;0 yscale];

% too tricky to make the call as a matrix/vector. Swallow it and do a loop:
nbarbs = length(u(:));

for ibarb = 1:nbarbs

     barb_patch=[];
     flag_patch=[];
     full_patch=[];
     half_patch=[];

     % First work out what combination
     % of flag/full/half feathers are needed to represent the speed

     [nflag,nfull,nhalf] = speed2feathers(speed(ibarb));

     % define a mirror matrix for clockwise/counterclockwise feathers
     %disp('line 110');disp(nflag);disp(nfull);disp(nhalf);
     clockmat = [sense(ibarb) 0;0 1];

     % define a rotation matrix for the wind direction:
    colin=cos(azmth(ibarb)) -sin(azmth(ibarb));
    raymond=sin(azmth(ibarb))+cos(azmth(ibarb));
     windrotn = [colin;raymond];

     % now trace out the whole barb as a patch object making sure to
     % catch the special cases:

     if nflag+nfull+nhalf == 0 % no feathers:
         % just plot a point:
         barb_patch = [];
         %disp(['Barb #',int2str(ibarb),': (rounded) speed = 0: simply drawing a point']);
     elseif nhalf==1 && nflag+nfull==0 % only a 5 m/s feather:
         % place the half-feather in the second feather spot, not at the end
         barb_patch = [0 0;0 shaft_length;0 shaft_length-feather_sep;...
             half_length.*cos(feather_ang) half_length.*sin(feather_ang)+shaft_length-feather_sep;...
             0 shaft_length-feather_sep]*clockmat;
         %disp(['Barb #',int2str(ibarb),': (rounded) speed = 5; drawing half-feather in from the end']);
     else % all other cases:
         ifeather = 0;
         barb_patch = [0 0;0 shaft_length];
         %disp(['Barb #',int2str(ibarb),': (rounded) speed =',int2str(speed(ibarb))]);
         for iflag = 1:nflag
             flag_patch = [0 0;full_length.*cos(feather_ang) 0;0
0-feather_sep]*clockmat + repmat([0
shaft_length-ifeather.*feather_sep],3,1);
             barb_patch = [barb_patch;flag_patch];
             ifeather=ifeather+1;
             %disp([' ',int2str(ifeather),': drawing a 50 m/s flag']);
         end
         for ifull = 1:nfull
             full_patch = [0 0;full_length.*cos(feather_ang)
full_length.*sin(feather_ang);0 0]*clockmat + repmat([0
shaft_length-ifeather.*feather_sep],3,1);
             barb_patch = [barb_patch;full_patch];
             ifeather=ifeather+1;
             %disp([' ',int2str(ifeather),': drawing a 10 m/s feather']);
         end
         if nhalf == 1
             half_patch = [0 0;half_length.*cos(feather_ang)
half_length.*sin(feather_ang);0 0]*clockmat + repmat([0
shaft_length-ifeather.*feather_sep],3,1);
             barb_patch = [barb_patch;half_patch];
             ifeather=ifeather+1;
             %disp([' ',int2str(ifeather),': drawing a 5 m/s feather']);
         end
     end

     % tack on a final closing vertex:
     barb_patch = [barb_patch;0 0];

     % check how many vertices we have
     [nverts,ndims]=size(barb_patch);
     %disp([' We have ',int2str(nverts),' vertices for the final barb patch']);

     % should now have an outline of the barb as if wind was northerly with
     % feathers pointing in correct direction for the hemisphere. Now apply the
     % wind-direction rotation matrix:
     barb_patch = barb_patch*windrotn;
     %disp([' Rotated the patch for wind direction of',int2str(round(azmth(ibarb).*180./pi)),' degrees']);

     % should now have a patch in cart-xy of unit length and with correct
     % direction. Need scale it up so that it is "scale" centimeters long
     % in the current axes and to move it to the correct lat lon point:
     size(barb_patch);disp(scalemat);
     barb_patch_lonlat = barb_patch.*scalemat + repmat([lon(ibarb) lat(ibarb)],nverts,1);
     %disp([' Scaled and translated the patch to be ',num2str(scale),'
%cm long and rooted at correct location']);

     h_temp = patch(barb_patch_lonlat(:,1),barb_patch_lonlat(:,2),[0 0 0]);

     h_barb_handles(ibarb)=h_temp;
end
