%Runs wncepgridpts function for multiple locations
%The bulk of this is finding the 3 closest gridpts in the 73x144 NCEP domain (& their weights) for:
    %a. each city >100,000 in the US (10 sec)
    %b. each metro area >3,000,000 in the world (20 sec)
        %source: http://www.demographia.com/db-worldua.pdf
        
douscomputation=0;
doworldcomputation=1;

if douscomputation==1
    %These are the lats/lons for cities listed in rwstationsforcomfortindices.xlsx (in the same order as those as well)
    loclats=[32.41;41.04;35.04;40.65;35.23;33.74;61.17;42.29;33.95;33.63;33.36;41.78;30.18;35.43;39.17;30.54;30.1;45.81;...
        33.57;43.57;42.36;39.99;41.16;25.91;42.94;26.59;41.88;32.9;35.22;35.03;42;39.04;36.55;41.41;30.59;38.8;38.94;33.94;...
        32.52;39.99;37.98;27.77;32.85;41.47;39.91;33.2;39.76;41.53;42.23;40.47;31.81;42.08;44.13;38.04;38.27;46.93;35.06;...
        40.61;26.07;40.97;32.82;36.78;29.69;42.88;44.48;36.1;21.32;29.64;34.64;39.73;32.32;30.5;41.6;39.12;31.08;35.82;30.21;...
        28.00;34.63;42.78;27.53;32.28;36.07;38.04;40.85;34.73;34.02;38.18;42.64;33.67;32.68;43.14;42.99;26.18;33.19;35.06;...
        25.79;31.95;43.11;44.88;30.69;37.62;32.30;35.92;36.12;29.99;40.78;37.13;33.21;35.39;41.31;28.43;34.21;28.1;40.67;...
        39.87;33.43;40.48;27.19;45.60;41.72;40.25;38.29;35.89;39.48;37.51;33.95;43.9;43.12;42.19;38.51;44.91;36.66;40.78;...
        31.35;29.34;32.73;37.77;37.36;34.18;34.9;38.5;32.13;47.44;32.45;43.59;41.71;47.62;39.84;41.94;37.24;38.75;37.89;...
        43.11;30.39;27.96;33.67;41.59;39.07;32.13;36.2;32.35;34.54;36.9;36.33;31.62;38.85;41.51;26.68;33.98;37.65;34.27;42.27];

    loclons=[-99.68;-81.46;-106.62;-75.45;-101.7;-117.87;-150.03;-83.71;-83.33;-84.44;-81.96;-88.31;-97.68;-119.05;-76.68;...
        -91.15;-94.1;-108.54;-86.75;-116.24;-71.01;-105.27;-73.13;-97.42;-78.74;-81.86;-91.72;-80.04;-80.96;-85.20;-87.93;...
        -84.67;-87.34;-81.85;-96.36;-104.7;-92.32;-81.12;-84.94;-82.88;-122.07;-97.51;-96.86;-90.52;-84.22;-97.11;-104.87;...
        -93.65;-83.33;-74.44;-106.38;-80.18;-123.22;-87.52;-121.93;-96.81;-78.86;-105.13;-80.15;-85.21;-97.36;-119.72;...
        -82.28;-85.52;-88.14;-79.94;-157.93;-95.28;-86.79;-86.28;-90.08;-81.69;-88.09;-94.6;-97.68;-83.99;-91.99;-82.05;...
        -118.08;-84.58;-99.47;-106.76;-115.16;-84.61;-96.75;-92.24;-118.29;-85.74;-71.36;-101.82;-83.65;-89.35;-71.39;...
        -98.25;-96.59;-89.99;-80.32;-102.21;-88.03;-93.23;-88.25;-120.95;-86.41;-86.37;-86.69;-90.25;-73.97;-76.49;-117.40;...
        -97.6;-95.9;-81.33;-119.14;-80.64;-89.68;-75.23;-112.00;-80.21;-80.24;-122.61;-71.43;-111.65;-104.5;-78.78;-119.77;...
        -77.32;-117.39;-92.49;-77.68;-89.09;-121.5;-123.00;-121.61;-111.97;-100.50;-98.47;-117.18;-122.43;-121.92;-118.57;...
        -120.45;-122.81;-81.21;-122.31;-93.82;-96.73;-86.32;-117.53;-89.68;-72.68;-93.39;-90.37;-121.23;-76.1;-84.35;...
        -82.54;-117.33;-83.80;-95.63;-110.96;-95.89;-95.4;-117.31;-76.19;-119.30;-97.23;-77.03;-72.94;-80.10;-98.49;-97.43;...
        -77.90;-71.87];

    locnames={'abilene tx';'akron oh';'albuquerque nm';'allentown pa';'amarillo tx';'anaheim ca';'anchorage ak';'ann arbor mi';...
        'athens ga';'atlanta ga';'augusta ga';'aurora il';'austin tx';'bakersfield ca';'baltimore md';'baton rouge la';...
        'beaumont tx';'billings mt';'birmingham al';'boise id';'boston ma';'boulder co';'bridgeport ct';'brownsville tx';...
        'buffalo ny';'cape coral fl';'cedar rapids ia';'charleston sc';'charlotte nc';'chattanooga tn';'chicago il';...
        'cincinnati oh';'clarksville tn';'cleveland oh';'college station tx';'colorado springs co';'coxlumbia mo';...
        'columbia sc';'columbus ga';'columbus oh';'concord ca';'corpus christi tx';'dallas tx';'davenport ia';'dayton oh';...
        'denton tx';'denver co';'des moines ia';'detroit mi';'edison nj';'el paso tx';'erie pa';'eugene or';'evansville in';...
        'fairfield ca';'fargo nd';'fayetteville nc';'fort collins co';'fort lauderdale fl';'fort wayne in';'fort worth tx';...
        'fresno ca';'gainesville fl';'grand rapids mi';'green bay wi';'greensboro nc';'honolulu hi';'houston tx';...
        'huntsville al';'indianapolis in';'jackson ms';'jacksonville fl';'joliet il';'kansas city mo';'killeen tx';...
        'knoxville tn';'lafayette la';'lakeland fl';'lancaster ca';'lansing mi';'laredo tx';'las cruces nm';'las vegas nv';...
        'lexington ky';'lincoln ne';'little rock ar';'los angeles ca';'louisville ky';'lowell ma';'lubbock tx';'macon ga';...
        'madison wi';'manchester nh';'mcallen tx';'mckinney tx';'memphis tn';'miami fl';'midland tx';'milwaukee wi';...
        'minneapolis mn';'mobile al';'modesto ca';'montgomery al';'murfreesboro tn';'nashville tn';'new orleans la';...
        'new york ny';'newport news va';'oceanside ca';'oklahoma city ok';'omaha ne';'orlando fl';'oxnard ca';'palm bay fl';...
        'peoria il';'philadelphia pa';'phoenix az';'pittsburgh pa';'port st lucie fl';'portland or';'providence ri';...
        'provo ut';'pueblo co';'raleigh nc';'reno nv';'richmond va';'riverside ca';'rochester mn';'rochester ny';...
        'rockford il';'sacramento ca';'salem or';'salinas ca';'salt lake city ut';'san angelo tx';'san antonio tx';...
        'san diego ca';'san francisco ca';'san jose ca';'santa clarita ca';'santa maria ca';'santa rosa ca';'savannah ga';...
        'seattle wa';'shreveport la';'sioux falls sd';'south bend in';'spokane wa';'springfield il';'springfield ma';...
        'springfield mo';'st louis mo';'stockton ca';'syracuse ny';'tallahassee fl';'tampa fl';'temecula ca';'toledo oh';...
        'topeka ks';'tucson az';'tulsa ok';'tyler tx';'victorville ca';'virginia beach va';'visalia ca';'waco tx';...
        'washington dc';'waterbury ct';'west palm beach fl';'wichita falls tx';'wichita ks';'wilmington nc';'worcester ma'};

    %Run function and save result
    %Make sure wncepgridpts set to top-3-only mode
    results={};
    for i=1:size(loclats,1)
        results{i}=wncepgridpts(loclats(i),loclons(i),1,0);
    end
    save('/Users/craymon3/General_Academics/Website/Recent_Weather/Discomfort_Scores/discomfortindicesncepgridpts.mat','results',...
        'loclats','loclons','locnames','-append');
end


if doworldcomputation==1
    worldloclats=[35.69;-6.17;28.7;37.57;14.6;19.08;24.86;31.23;40.71;-23.55;39.9;...
        19.43;23.13;34.69;55.76;23.81;30.04;13.76;34.05;22.57;-34.6;35.69;...
        41.01;6.52;22.54;-22.91;-4.44;39.08;-12.05;48.86;30.57;31.55;51.51;12.97;...
        10.82;35.18;13.08;4.71;41.88;-26.2;25.03;23.02;17.39;30.59;...
        30.27;21.03;29.56;6.14;23.02;3.14;22.4;24.87;-8.84;33.31;...
        51.46;43.65;32.06;32.78;-33.45;40.42;41.81;34.34;29.76;36.07;37.77;...
        24.71;25.76;18.52;-6.92;34.75;1.35;21.17;39.95;31.3;16.87;...
        45.47;15.5;59.93;33.75;38.91;-7.26;-1.29;45.8;5.36;31.2;41.39;...
        24.48;20.66;39.93;-19.92;42.36;29.31;-6.79;38.91;33.45;25.69;5.6;...
        52.52;26.07;-33.87;3.6;-37.81;41.9;29.87;36.65;35.18;-33.92;6.24;...
        28.23;37.87;21.29;31.82;24.88;40.85;12;36.75;31.42;31.49;36.2;42.33;34.56;...
        18.49;25.2;45.5;38.04;31.81;26.91;37.98;47.61;8.98;-3.73;...
        -29.86;-30.03;43.82;-8.05;36.26;43.83;27.99;26.85;22.35;33.57;13.79;...
        31.88;3.85;22.52;14.76;38.42;-25.43;15.37;12.64;32.72;26.45;4.05;26.65;...
        32.09;-25.75];
    worldloclons=[139.69;106.82;77.1;126.98;120.98;72.88;67.01;121.47;-74.01;-46.63;116.41;...
        -99.13;113.26;135.5;37.62;90.41;31.24;100.5;-118.24;88.36;-58.38;51.39;...
        28.98;3.38;114.06;-43.17;15.27;117.2;-77.04;2.35;104.07;74.36;-0.13;77.59;...
        106.63;136.91;80.27;-74.07;-87.63;28.05;121.57;113.75;78.49;114.31;...
        120.16;105.83;106.55;6.8;72.57;101.69;114.11;118.68;13.29;44.36;...
        7.01;-79.38;118.8;-96.8;-70.67;-3.7;123.43;108.94;-95.37;120.38;-122.42;...
        46.68;-80.19;73.86;107.62;113.63;103.82;72.83;-75.17;120.59;96.2;...
        9.19;32.56;30.34;-84.39;-77.04;112.75;36.82;126.53;-4.01;29.92;2.17;...
        118.09;-103.35;32.86;-43.94;-71.06;47.48;39.21;121.61;-112.07;-100.32;-0.19;...
        13.4;119.3;151.21;98.67;144.96;12.5;121.54;117.12;129.08;18.42;-75.58;...
        112.94;112.55;39.24;117.23;102.83;14.27;8.59;3.06;73.08;120.31;37.13;-83.05;69.21;...
        -69.93;55.27;-73.57;114.51;119.97;75.79;23.73;-122.33;38.76;-38.53;...
        31.02;-51.22;125.32;-34.88;59.62;87.62;120.7;80.95;91.81;-7.59;-88.9;...
        120.56;11.5;113.39;-17.37;27.14;-49.27;44.19;-8;-117.16;80.33;9.77;106.63;...
        34.78;28.23];
    worldlocnames={'tokyo';'jakarta';'delhi';'seoul';'manila';'mumbai';'karachi';'shanghai';'new york';'sao paulo';'beijing';...
    'mexico city';'guangzhou';'osaka';'moscow';'dhaka';'cairo';'bangkok';'los angeles';'kolkata';'buenos aires';'tehran';...
    'istanbul';'lagos';'shenzhen';'rio de janeiro';'kinshasa';'tianjin';'lima';'paris';'chengdu';'lahore';'london';'bangalore';...
    'ho chi minh city';'nagoya';'chennai';'bogota';'chicago';'johannesburg';'taipei';'dongguan';'hyderabad';'wuhan';...
    'hangzhou';'hanoi';'chongqing';'onitsha nigeria';'ahmadabad';'kuala lumpur';'hong kong';'quanzhou';'luanda';'baghdad';...
    'essen-dusseldorf';'toronto';'nanjing';'dallas';'santiago';'madrid';'shenyang';'xian';'houston';'qingdao';'san francisco';...
    'riyadh';'miami';'pune';'bandung indonesia';'zhengzhou';'singapore';'surat india';'philadelphia';'suzhou';'yangon';...
    'milan';'khartoum';'st petersburg';'atlanta';'washington';'surabaya';'nairobi';'harbin';'abidjan';'alexandria';'barcelona';...
    'xiamen';'guadalajara';'ankara';'belo horizonte';'boston';'kuwait';'dar es salaam';'dalian';'phoenix';'monterrey';'accra';...
    'berlin';'fuzhou';'sydney';'medan indonesia';'melbourne';'rome';'ningbo';'jinan';'busan';'cape town';'medellin';...
    'changsha';'taiyuan';'jiddah';'hefei';'kunming';'naples';'kano';'algiers';'faisalabad';'wuxi';'aleppo';'detroit';'kabul';...
    'santo domingo';'dubai';'montreal';'shijiazhuang';'changzhou';'jaipur';'athens';'seattle';'addis ababa';'fortaleza';...
    'durban';'porto alegre';'changchun';'recife';'mashhad';'urumqi';'wenzhou';'lucknow';'chittagong';'casablanca';'salvador';...
    'zhangjiaggang';'yaounde';'zhongshan';'dakar';'izmir';'curitiba';'sana';'bamako';'san diego';'kanpur';'douala';'guiyang';...
    'tel aviv';'pretoria'};
    
    %Run function and save result
    %Make sure wncepgridpts set to top-3-only mode
    worldresults={};
    for i=1:size(worldloclats,1)
        worldresults{i}=wncepgridpts(worldloclats(i),worldloclons(i),1,0);
    end
    save('/Users/craymon3/General_Academics/Website/Recent_Weather/Discomfort_Scores/discomfortindicesncepgridpts.mat','worldresults',...
        'worldloclats','worldloclons','worldlocnames','-append');
end