function plotBlankMap(figct,region)

%fg=figure(figct);
exist dontclear;
if ans==1
    if dontclear==1
    else
        clf;
    end
end
fgTitle = '';fgXaxis = '';fgYaxis = '';
%fprintf('Region chosen is: %s\n',region);

if strcmp(region, 'world')
    southlat=-90;northlat=90;westlon=-180;eastlon=180;mapproj='robinson';
elseif strcmp(region, 'nnh')
    southlat=30;northlat=90;westlon=-180;eastlon=180;mapproj='stereo';
elseif strcmp(region,'placesivebeen')
    southlat=-20;northlat=70;westlon=-165;eastlon=45;mapproj='mercator';
elseif strcmp(region, 'north-atlantic')
    southlat=25;northlat=75;westlon=-75;eastlon=10;mapproj='lambert';
elseif strcmp(region, 'north-america')
    southlat=20;northlat=80;westlon=-170;eastlon=-35;mapproj='lambert';
elseif strcmp(region, 'na-east')
    southlat=25;northlat=55;westlon=-100;eastlon=-50;mapproj='lambert';
elseif strcmp(region,'usa-full')
    southlat=15;northlat=75;westlon=-180;eastlon=-60;mapproj='lambert';
elseif strcmp(region,'usaminushawaii-tight')
    southlat=22;northlat=73;westlon=-175;eastlon=-65;mapproj='robinson';
elseif strcmp(region, 'usa-exp')
    southlat=23;northlat=60;westlon=-135;eastlon=-55;mapproj='lambert';
elseif strcmp(region, 'usa')
    southlat=23;northlat=50;westlon=-127;eastlon=-64;mapproj='robinson';
elseif strcmp(region, 'eastern-usa')
    southlat=23;northlat=50;westlon=-100;eastlon=-65;mapproj='lambert';
elseif strcmp(region, 'northeasternquadrant-usa')
    southlat=35;northlat=50;westlon=-95;eastlon=-65;mapproj='mercator';    
elseif strcmp(region, 'africa')
    southlat=-30;northlat=30;westlon=-20;eastlon=60;mapproj='lambert';
elseif strcmp(region, 'west-africa')
    southlat=0;northlat=30;westlon=-20;eastlon=40;mapproj='mercator';
elseif strcmp(region, 'us-ne')
    southlat=35;northlat=50;westlon=-85;eastlon=-60;mapproj='mercator';
elseif strcmp(region, 'us-ne-small')
    southlat=38;northlat=46;westlon=-80;eastlon=-68;mapproj='mercator';
elseif strcmp(region, 'nyc-area')
    southlat=39;northlat=42;westlon=-76;eastlon=-72;mapproj='mercator';
elseif strcmp(region, 'nyc-area-small')
    southlat=40.2;northlat=41.2;westlon=-74.6;eastlon=-73.3;mapproj='mercator';
else
    worldmap(region);
    data{1}(:, end+1) = data{1}(:, end) + (data{1}(:, end)-data{1}(:, end-1));
    data{2}(:, end+1) = data{2}(:, end) + (data{2}(:, end)-data{2}(:, end-1));
end

%set(fg,'Color',[1 1 1]);
axesm(mapproj,'MapLatLimit',[southlat northlat],'MapLonLimit',[westlon eastlon]);
framem on; gridm off; mlabel off; plabel off;
axis on;axis off; %this is not crazy -- it somehow gets the frame lines to be all the same width

load coast;
%states=shaperead('usastatelo', 'UseGeoCoords', true, 'Selector', ...
%         {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
states=shaperead('usastatelo', 'UseGeoCoords', true);
geoshow(states, 'DisplayType', 'polygon', 'DefaultFaceColor', 'none');
%countries=shaperead('countries', 'UseGeoCoords', true);
%geoshow(countries, 'DisplayType', 'polygon', 'DefaultFaceColor', 'none');
borders('Canada','k'); %in most cases, Canada is the only other country in the domain of interest
if strcmp(region,'nnh') || strcmp(region,'north-atlantic') || strcmp(region,'world') || strcmp(region,'placesivebeen')
    borders('Mexico','k');borders('Japan','k');borders('Korea, Republic of','k');borders('Syrian Arab Republic','k');
    borders('Korea, Democratic People''s Republic of','k');borders('Greenland','k');borders('Puerto Rico','k');
    borders('China','k');borders('Mongolia','k');borders('Nepal','k');borders('India','k');borders('Bhutan','k');
    borders('Russia','k');borders('Kazakhstan','k');borders('Tajikistan','k');borders('Turkmenistan','k');
    borders('Uzbekistan','k');borders('Kyrgyzstan','k');borders('Afghanistan','k');borders('Pakistan','k');
    borders('Iran Islamic Republic of','k');borders('Iraq','k');borders('Kuwait','k');borders('Lebanon','k');
    borders('Israel','k');borders('Jordan','k');borders('Azerbaijan','k');borders('Georgia','k');borders('Armenia','k');
    borders('Turkey','k');borders('Egypt','k');borders('Libyan Arab Jamahiriya','k');borders('Algeria','k');borders('Tunisia','k');
    borders('Morocco','k');borders('Cyprus','k');borders('Ukraine','k');borders('Romania','k');
    borders('Bulgaria','k');borders('Greece','k');borders('Albania','k');borders('Montenegro','k');
    borders('Croatia','k');borders('Serbia','k');borders('Bosnia and Herzegovina','k');
    borders('Hungary','k');borders('Slovakia','k');borders('Belarus','k');borders('Lithuania','k');borders('Latvia','k');
    borders('Estonia','k');borders('Finland','k');borders('Sweden','k');borders('Norway','k');borders('Poland','k');
    borders('Czech Republic','k');borders('Austria','k');borders('Italy','k');borders('Switzerland','k');borders('France','k');
    borders('Germany','k');borders('Denmark','k');borders('Netherlands','k');borders('Belgium','k');borders('United Kingdom','k');
    borders('Ireland','k');borders('Spain','k');borders('Portugal','k');borders('Iceland','k');borders('Luxembourg','k');
    borders('Liechtenstein','k');borders('Monaco','k');borders('San Marino','k');borders('Andorra','k');borders('Malta','k');
end
if strcmp(region,'north-america') || strcmp(region,'usa-full') || strcmp(region,'usaminushawaii-tight') || ...
        strcmp(region,'usa-exp') || strcmp(region,'world') || strcmp(region,'placesivebeen')
    borders('Mexico','k');borders('Cuba','k');borders('Bahamas','k');borders('Jamaica','k');
    borders('Greenland','k');borders('Haiti','k');borders('Dominican Republic','k');borders('Russia','k');
    borders('Guatemala','k');borders('Honduras','k');borders('El Salvador','k');borders('Belize','k');
    borders('Dominica','k');borders('British Virgin Islands','k');borders('Bermuda','k');
elseif strcmp(region,'na-east') || strcmp(region,'usa')
    borders('Mexico','k');borders('Cuba','k');borders('Bahamas','k');
end
if strcmp(region,'world') || strcmp(region,'placesivebeen')
    borders('Antigua and Barbuda','k');borders('Barbados','k');borders('Grenada','k');
    borders('Saint Kitts and Nevis','k');borders('Saint Lucia','k');borders('Saint Vincent and the Grenadines','k');
    borders('Trinidad and Tobago','k');borders('Guinea-Bissau','k');borders('Equatorial Guinea','k');
    borders('Nicaragua','k');borders('Costa Rica','k');borders('Panama','k');borders('Colombia','k');
    borders('Venezuela','k');borders('Suriname','k');borders('Guyana','k');
    borders('Brazil','k');borders('Ecuador','k');borders('Peru','k');borders('Bolivia','k');
    borders('Chile','k');borders('Paraguay','k');borders('Argentina','k');borders('Uruguay','k');
    borders('Chad','k');borders('Senegal','k');borders('Mali','k');borders('Mauritania','k');
    borders('Niger','k');borders('Nigeria','k');borders('Ghana','k');borders('Togo','k');borders('Benin','k');
    borders('Liberia','k');borders('Guinea','k');borders('Cameroon','k');borders('Congo','k');
    borders('Gabon','k');borders('Democratic Republic of the Congo','k');borders('Angola','k');borders('Namibia','k');
    borders('Botswana','k');borders('South Africa','k');borders('Swaziland','k');borders('Madagascar','k');
    borders('Mozambique','k');borders('Malawi','k');borders('Gambia','k');borders('Zambia','k');
    borders('Zimbabwe','k');borders('Kenya','k');borders('United Republic of Tanzania','k');borders('Uganda','k');
    borders('Rwanda','k');borders('Burundi','k');borders('Ethiopia','k');borders('Somalia','k');borders('Oman','k');
    borders('Sudan','k');borders('Central African Republic','k');borders('Qatar','k');borders('Western Sahara','k');
    borders('Yemen','k');borders('Saudi Arabia','k');borders('United Arab Emirates','k');borders('Bahrain','k');
    borders('Sri Lanka','k');borders('Thailand','k');borders('Burma','k');borders('Cambodia','k');
    borders('Cote d''Ivoire','k');borders('Cape Verde','k');
    borders('Sierra Leone','k');borders('Burkina Faso','k');borders('Djibouti','k');borders('Eritrea','k');
end
if strcmp(region,'world')
    borders('Viet Nam','k');borders('Philippines','k');borders('Malaysia','k');borders('Taiwan','k');
    borders('Indonesia','k');borders('Singapore','k');borders('Comoros','k');borders('Papua New Guinea','k');
    borders('Australia','k');borders('New Zealand','k');borders('Antarctica','k');borders('Solomon Islands','k');
    borders('Fiji','k');borders('Micronesia, Federated States of','k');borders('Vanuatu','k');
    borders('Tonga','k');borders('Tuvalu','k');borders('Lesotho','k');borders('Bangladesh','k');
    borders('Brunei Darussalam','k');
    borders('Samoa','k');borders('American Samoa','k');borders('New Caledonia','k');
    borders('British Indian Ocean Territory','k');borders('Reunion','k');borders('Seychelles','k');
    borders('Palau','k');borders('Nauru','k');borders('Lao People''s Democratic Republic','k');
end

states=shaperead('usastatelo', 'UseGeoCoords', true);
geoshow(states, 'DisplayType', 'polygon', 'DefaultFaceColor', 'none');

tightmap;

%xlim([-0.5 0.5]);
if strcmp(region,'us-ne') || strcmp(region,'us-ne-small')
    zoom(2.5);
    ylim([0.6 1.0]);
end
tightmap;
    
end