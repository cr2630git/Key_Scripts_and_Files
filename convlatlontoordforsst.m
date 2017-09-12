function outputsst = convlatlontoordforsst(inputlat,inputlon,sstarray)
%Written for the NCEP 720x1440 grid, could be modified if so desired
%Computes the SST nearest the point given by the input lat and lon 
%Accomplishes this by converting lat/lon to ordinates of the NCEP grid, and then 
%searching nearby points as well if the input turns out to be right along a coast

stnlatconvtoord=round(720*(90-inputlat)/180); %ordinate of latitude corresp to JFK
stnlonconvtoord=round(1440*(360+inputlon)/360); %ditto for longitude

if isnan(sstarray(stnlatconvtoord,stnlonconvtoord))
    %find closest sea point in order to get its SST
    if ~isnan(sstarray(stnlatconvtoord,stnlonconvtoord+1))
        stnlonconvtoord=stnlonconvtoord+1;
    elseif ~isnan(sstarray(stnlatconvtoord,stnlonconvtoord-1))
        stnlonconvtoord=stnlonconvtoord-1;
    elseif ~isnan(sstarray(stnlatconvtoord+1,stnlonconvtoord))
        stnlatconvtoord=stnlatconvtoord+1;
    elseif ~isnan(sstarray(stnlatconvtoord-1,stnlonconvtoord))
        stnlatconvtoord=stnlatconvtoord-1;
    elseif ~isnan(sstarray(stnlatconvtoord-1,stnlonconvtoord+1))
        stnlatconvtoord=stnlatconvtoord-1;stnlonconvtoord=stnlonconvtoord+1;
    elseif ~isnan(sstarray(stnlatconvtoord-1,stnlonconvtoord-1))
        stnlatconvtoord=stnlatconvtoord-1;stnlonconvtoord=stnlonconvtoord-1;
    elseif ~isnan(sstarray(stnlatconvtoord+1,stnlonconvtoord-1))
        stnlatconvtoord=stnlatconvtoord+1;stnlonconvtoord=stnlonconvtoord-1;
    elseif ~isnan(sstarray(stnlatconvtoord+1,stnlonconvtoord+1))
        stnlatconvtoord=stnlatconvtoord+1;stnlonconvtoord=stnlonconvtoord+1;
    end
    %fprintf('stnlatconvtoord, stnlonconvtoord is now %d, %d\n',stnlatconvtoord,stnlonconvtoord);
end

outputsst=sstarray(stnlatconvtoord,stnlonconvtoord);

end

