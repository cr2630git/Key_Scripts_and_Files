function tzlist = timezonesfromlatlon(latmatrix,lonmatrix)
%Uses inpolygon to find the time zones for a given matrix of latitude and longitude points
%   Have so far only found time-zone polygons (using Google Maps "Time-Zone Calculation" map) for the US

%First, need to define the time-zone polygons that were determined using Google Maps and Wikipedia's time-zone map
    %https://en.wikipedia.org/wiki/Time_in_the_United_States#/media/File:US-Timezones.svg
%Eastern Time, UTC-5
utc5polygonlats=[29.430;30.732;31.269;31.906;32.241;32.561;34.972;36.138;37.117;38.143;38.281;...
    38.942;39.028;40.839;40.930;41.788;42.488;43.654;45.259;46.180;46.574;48.005;48.305;...
    46.544;45.368;43.588;42.545;41.976;41.706;42.747;43.461;44.198;45.011;45.019;46.687;...
    47.480;47.369;47.212;45.691;45.599;44.809;41.146;35.498;26.692;24.587;24.317;29.430];
utc5polygonlons=[-85.155;-84.913;-85.122;-85.122;-84.946;-85.056;-85.616;-85.023;-85.045;-86.342;-86.561;...
    -86.539;-87.561;-87.539;-86.550;-86.616;-87;-87.144;-86.265;-87.737;-90.406;-89.506;-88.374;...
    -84.133;-82.551;-82.123;-82.595;-83.123;-82.672;-79.189;-79.222;-76.355;-74.949;-71.807;-70;...
    -69.236;-68.225;-67.753;-67.720;-67.368;-66.874;-69.851;-75.103;-79.926;-80.013;-82.068;-85.155];
%Central Time, UTC-6
utc6polygonlats=[29.43;30.732;31.269;31.906;32.241;32.561;34.972;36.138;37.117;38.143;38.281;...
    38.942;39.028;40.839;40.930;41.788;42.488;43.654;45.259;46.180;46.574;48;49.497;...
    49;49;48.049;47.924;47.975;47.190;45.966;45.966;44.949;44.135;43;...
    42.245;41.154;40;40;39.488;39.488;37.727;37.727;37;37;32;32;30.695;29.964;29.2;...
    28.874;29.698;26.264;25.968;25.75;25.899;29.43];
utc6polygonlons=[-85.155;-84.913;-85.122;-85.122;-84.946;-85.056;-85.616;-85.023;-85.045;-86.342;-86.561;...
    -86.539;-87.561;-87.539;-86.550;-86.616;-87;-87.144;-86.265;-87.737;-90.406;-89.506;-95.164;...
    -95.164;-104.106;-104;-102.546;-101.162;-101.514;-101.140;-100.459;-100.393;-100.481;-100.448;...
    -100.349;-101;-101;-102;-102;-101.316;-101.448;-102;-102;-103;-103;-104.93;-105;-104.755;-104.326;...
    -103.184;-102.140;-99.185;-98.207;-97.372;-97.108;-85.155];
%Mountain Time, UTC-7
utc7polygonlats=[49;48.049;47.924;47.975;47.190;45.966;45.966;44.949;44.135;43;...
    42.245;41.154;40;40;39.488;39.488;37.727;37.727;37;37;32;32;30.695;31.335;31.335;...
    32.503;32.713;32.852;33.376;34.307;34.868;36.138;36;36.306;42;42;42.423;...
    42.407;44.528;44.387;45.337;46;45.614;45.491;46.665;46.725;47.369;...
    47.975;49;49];
utc7polygonlons=[-104;-104;-102.546;-101.162;-101.514;-101.140;-100.459;-100.393;-100.481;-100.448;...
    -100.349;-101;-101;-102;-102;-101.316;-101.448;-102;-102;-103;-103;-104.93;-105;-108.226;-111.094;...
    -114.879;-114.722;-114.456;-114.719;-114.137;-114.598;-114.752;-114.148;-114;-114;-117;-117;...
    -118.630;-118.564;-117.246;-116.719;-116.895;-116.323;-114.478;-114.346;-114.741;-115.598;...
    -116;-116;-104];
%Pacific Time, UTC-8
utc8polygonlats=[32.713;32.852;33.376;34.307;34.868;36.138;36;36.306;42;42;42.423;...
    42.407;44.528;44.387;45.337;46;45.614;45.491;46.665;46.725;47.369;...
    47.975;49;49;48.458;48.531;42.924;40.397;34.089;32.389;32.713];
utc8polygonlons=[-114.722;-114.456;-114.719;-114.137;-114.598;-114.752;-114.148;-114;-114;-117;-117;...
    -118.630;-118.564;-117.246;-116.719;-116.895;-116.323;-114.478;-114.346;-114.741;-115.598;...
    -116;-116;-123.333;-123.508;-124.849;-124.673;-124.585;-120.806;-118.059;-114.722];
%Alaska Time, UTC-9
utc9polygonlats=[54.38;55.116;59.955;60.759;70;71.567;69;65.622;60.196;57.184;...
    52.909;52.536;55.179;59.823;58.286;54.38];
utc9polygonlons=[-133.133;-128.914;-135.132;-141;-141;-156.709;-167.2;-168.84;-167.827;-171.167;...
    -169.541;-168.75;-155.479;-146.162;-138.296;-133.133];

%Now, determine the time zone for the inputted lat/lon list
for col=1:349
    latlist=latmatrix(:,col);lonlist=lonmatrix(:,col);
    ptsinutc5(:,col)=inpolygon(latlist,lonlist,utc5polygonlats,utc5polygonlons);
    ptsinutc6(:,col)=inpolygon(latlist,lonlist,utc6polygonlats,utc6polygonlons);
    ptsinutc7(:,col)=inpolygon(latlist,lonlist,utc7polygonlats,utc7polygonlons);
    ptsinutc8(:,col)=inpolygon(latlist,lonlist,utc8polygonlats,utc8polygonlons);
    ptsinutc9(:,col)=inpolygon(latlist,lonlist,utc9polygonlats,utc9polygonlons);
end

tzlist=zeros(277,349);
tzlist(ptsinutc5==1)=-5;
tzlist(ptsinutc6==1)=-6;
tzlist(ptsinutc7==1)=-7;
tzlist(ptsinutc8==1)=-8;
tzlist(ptsinutc9==1)=-9;

end

