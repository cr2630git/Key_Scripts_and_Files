function quicklymapsomethingusa(valuestoplot,latstouse,lonstouse,markertype,...
    colorcutoffs,markercolors,markersize,savingdir,figurename)
%Quickly map (using geoshow) a series of points situated in the continental US
%   The first three inputs must be identically-sized column vectors
%   'colorcutoffs' must be a column vector of 5 values -- for numbers
%           besides 5, modify below code as necessary
%   'markercolors' must be a 6x3 array
%   'markertype' must be a string 
%   obviously, 'savingdir' and 'figname' must be strings as well

%A good example of usage can be found in the docentroidplot loop of exploratorydataanalysis

plotBlankMap(1,'usa');curpart=1;highqualityfiguresetup;

if size(valuestoplot,1)==1
    disp('Please make input a column vector');return;
end

colorcutoffs=sort(colorcutoffs,'descend');


for i=1:size(valuestoplot,1)
    %disp(valuestoplot(i));
    %if i==1;disp(colorcutoffs);disp(markercolors);end
    if valuestoplot(i)>colorcutoffs(1)
        thiscolor=markercolors(6,:);
    elseif valuestoplot(i)>colorcutoffs(2)
        thiscolor=markercolors(5,:);
    elseif valuestoplot(i)>colorcutoffs(3)
        thiscolor=markercolors(4,:);
    elseif valuestoplot(i)>colorcutoffs(4)
        thiscolor=markercolors(3,:);
    elseif valuestoplot(i)>colorcutoffs(5)
        thiscolor=markercolors(2,:);
    else
        thiscolor=markercolors(1,:);
    end
    %disp(i);disp(thiscolor);
    h=geoshow(latstouse(i),lonstouse(i),'DisplayType','Point','Marker',markertype,...
        'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',markersize);hold on;
end

curpart=2;figloc=savingdir;figname=figurename;highqualityfiguresetup;

end

