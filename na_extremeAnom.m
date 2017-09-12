% computes the difference in the yearly mean of maximum summertime
% temperatures between NARCCAP models and NARR reanalysis.

season = 'summer';
baseTime = 'past';
testTime = 'future';

baseDataset = 'narccap';
testDataset = 'narccap';

% baseModels = {'crcm/ccsm'};
% testModels = {'crcm/ccsm'};
% baseModels = {'crcm/ccsm', 'crcm/cgcm3', 'ecp2/gfdl', ...
%           'hrm3/gfdl', 'hrm3/hadcm3', 'mm5i/ccsm', ...
%           'mm5i/hadcm3', 'rcm3/cgcm3', 'rcm3/gfdl', ...
%           'wrfg/ccsm', 'wrfg/cgcm3'};
% testModels = {'crcm/ccsm', 'crcm/cgcm3', 'ecp2/gfdl', ...
%           'hrm3/gfdl', 'hrm3/hadcm3', 'mm5i/ccsm', ...
%           'mm5i/hadcm3', 'rcm3/cgcm3', 'rcm3/gfdl', ...
%           'wrfg/ccsm', 'wrfg/cgcm3'};

%testModels = {''};
% baseModels = {''};

%models = {'gfdl-cm2.1'};
%models = {'wrfg/cgcm3'};

% % for mrso
baseModels = {'crcm/ccsm', 'crcm/cgcm3', 'ecp2/gfdl', ...
          'hrm3/gfdl', 'mm5i/ccsm', ...
          'mm5i/hadcm3', 'rcm3/cgcm3', ...
          'wrfg/ccsm', 'wrfg/cgcm3'};
testModels = {'crcm/ccsm', 'crcm/cgcm3', 'ecp2/gfdl', ...
          'hrm3/gfdl', 'mm5i/ccsm', ...
          'mm5i/hadcm3', 'rcm3/cgcm3', ...
          'wrfg/ccsm', 'wrfg/cgcm3'};

% for swe
% models = {'crcm/ccsm', 'crcm/cgcm3', 'ecp2/gfdl', ...
%           'rcm3/cgcm3', 'rcm3/gfdl', ...
%           'wrfg/ccsm'};


baseTimePeriod = 1981:1998;
baseScenario = '20c3m';
futureTimePeriod = 2051:2069;
futureScenario = 'sresa2';

baseVar = 'mrso';
testVar = 'mrso';

baseRegrid = true;
testRegrid = true;

blockWater = true;

% compare the annual mean or the mean extreme or both

meanOrExt = 'mean';
findMax = false;

subtractZonalMean = false;

% whether to do statistical testing
statTest = true;
% how many standard deviations above mean to consider significant
statTestThresh = 1;
% what percentage of models must be above threshold
statTestModelFrac = 0.25;
% whether to do the stat test for only base period extremes (true) or for all days (false)
statTestExt = false;

plotRegion = 'usa-exp';
exportformat = 'pdf';

baseDir = 'e:/data/';
yearStep = 1;

if findMax
    maxMinStr = 'maximum';
else
    maxMinStr = 'minimum';
end

if strcmp(season, 'summer')
    months = [6 7 8];
elseif strcmp(season, 'winter')
    months = [12 1 2];
end

maxMinStr = [meanOrExt ' '];
maxMinFileStr = meanOrExt;

if strcmp(testTime, 'past')
    testPeriod = baseTimePeriod;
elseif strcmp(testTime, 'future')
    testPeriod = futureTimePeriod;
end

if strcmp(baseTime, 'past')
    basePeriod = baseTimePeriod;
elseif strcmp(baseTime, 'future')
    basePeriod = futureTimePeriod;
end

customColorMap = [];

if strcmp(baseVar, 'tasmax') | strcmp(baseVar, 'tasmin')
    if strcmp(baseTime, 'past') & strcmp(testTime, 'future')
        %plotRange = [-8 8];
        if strcmp(meanOrExt, 'both')
            plotRange = [-2 2];
        else
            plotRange = [0 6];
        end
    else
        plotRange = [-6 6];
    end
    unitsStr = 'degrees C';
elseif strcmp(baseVar, 'swe')
    if strcmp(baseTime, 'past') & strcmp(testTime, 'future')
        plotRange = [-0.025 0.025];
    else
        plotRange = [0 0.25];
    end
    unitsStr = 'm';
    customColorMap = ceprecip;
elseif strcmp(baseVar, 'zg500')
    unitsStr = 'm';
    if subtractZonalMean
        plotRange = [-10 10];
    else
        plotRange = [-100 100];
    end
elseif strcmp(baseVar, 'mrso')
    unitsStr = 'kg / m^2';
    plotRange = [-200 200];
end

testFileStr = '';
testTitleStr = '';
if ~strcmp(testVar, '')
    testDatasetStr = testDataset;
    if strcmp(testDatasetStr, 'narccap')
        if length(testModels) == 1
            modelStr = strsplit(testModels{1}, '/');
            testDatasetStr = ['narccap-' modelStr{1} '-' modelStr{2}];
        else 
            testDatasetStr = ['narccap-mm'];
        end
        
        testDataDir = 'narccap/output';
        testEmissionsScenarioStr = '';
    elseif strcmp(testDatasetStr, 'cmip3')
        if length(testModels) == 1
            testDatasetStr = ['cmip3-' testModels{1}];
        else
            testDatasetStr = ['cmip3-mm'];
        end
        
        testDataDir = 'cmip3/output';
        testEmissionsScenarioStr = [futureScenario '/'];
    elseif strcmp(testDatasetStr, 'narr')
        testDatasetStr = ['narr'];
        testDataDir = 'narr/output';
        testEmissionsScenarioStr = '';
    end
    testFileStr = [testDatasetStr '-' testTime '-'];
    testTitleStr = [testDatasetStr ' [' num2str(testPeriod(1)) '-' num2str(testPeriod(end)) '] yearly '];
end

baseDatasetStr = baseDataset;
if strcmp(baseDatasetStr, 'narccap')
    if length(baseModels) == 1
        modelStr = strsplit(baseModels{1}, '/');
        baseDatasetStr = ['narccap-' modelStr{1} '-' modelStr{2}]
    else
        baseDatasetStr = ['narccap-mm'];
    end
    
    baseDataDir = 'narccap/output';
    baseEmissionsScenarioStr = '';
elseif strcmp(baseDatasetStr, 'cmip3')
    if length(baseModels) == 1
        baseDatasetStr = ['cmip3-' baseModels{1}];
    else
        baseDatasetStr = ['cmip3-mm'];
    end

    baseDataDir = 'cmip3/output';
    baseEmissionsScenarioStr = [baseScenario '/'];
elseif strcmp(baseDatasetStr, 'narr')
    baseDatasetStr = ['narr'];
    baseDataDir = 'narr/output';
    baseEmissionsScenarioStr = '';
end

%plotTitle = [baseVar ': ' testTitleStr season ' ' maxMinStr ' - ' baseDataset ' [' num2str(basePeriod(1)) '-' num2str(basePeriod(end)) ']'];
fileTitle = ['extremeAnom-' baseVar '-' season '-' maxMinFileStr '-' testFileStr baseDatasetStr '-' baseTime '.' exportformat];

baseExtData = {};
baseMeanData = {};
testExtData = {};
testMeanData = {};

baseMeanStdDev = {};
baseExtStdDev = {};
testMeanStdDev = {};
testExtStdDev = {};

for m = 1:length(baseModels)
    if ~strcmp(baseModels{m}, '')
        curModel = ['/' baseModels{m} '/'];
    else
        curModel = '/';
    end

    baseExtData{m} = {};
    baseMeanData{m} = {};
    baseMeanStdDev{m} = [];
    baseExtStdDev{m} = [];
    curBaseMeanStdDev = [];
    curBaseExtStdDev = [];
    
    ['loading ' baseDataset curModel ' ' baseTime]
    for y = basePeriod(1):yearStep:basePeriod(end)
        ['year ' num2str(y) '...']
        if baseRegrid
            baseDaily = loadDailyData([baseDir baseDataDir curModel  baseEmissionsScenarioStr baseVar '/regrid'], 'yearStart', y, 'yearEnd', (y+yearStep)-1);
        else
            baseDaily = loadDailyData([baseDir baseDataDir curModel baseEmissionsScenarioStr baseVar], 'yearStart', y, 'yearEnd', (y+yearStep)-1);
        end
        
        if strcmp(baseDataset, 'narccap') & strcmp(baseVar, 'mrso')
            curBaseMeanStdDev = cat(3, curBaseMeanStdDev, reshape(baseDaily{3}(:,:,:,months,1:8:end), ...
                                                    [size(baseDaily{3}(:,:,:,months,1:8:end), 1), size(baseDaily{3}(:,:,:,months,1:8:end), 2), ...
                                                    size(baseDaily{3}(:,:,:,months,1:8:end), 3)*size(baseDaily{3}(:,:,:,months,1:8:end), 4)*size(baseDaily{3}(:,:,:,months,1:8:end), 5)]));
        else
            curBaseMeanStdDev = cat(3, curBaseMeanStdDev, reshape(baseDaily{3}(:,:,:,months,:), ...
                                                    [size(baseDaily{3}(:,:,:,months,:), 1), size(baseDaily{3}(:,:,:,months,:), 2), ...
                                                    size(baseDaily{3}(:,:,:,months,:), 3)*size(baseDaily{3}(:,:,:,months,:), 4)*size(baseDaily{3}(:,:,:,months,:), 5)]));
        end
        
        baseMeanTmp = {{baseDaily{1}, baseDaily{2}, nanmean(nanmean(baseDaily{3}(:,:,:,months,:), 5), 4)}};
        baseExtTmp = findYearlyExtremes(baseDaily, months, findMax);
        
        curBaseExtStdDev = cat(3, curBaseExtStdDev, baseExtTmp{1}{3});
        
        if subtractZonalMean
            for lat = 1:size(baseExtTmp{1}{3}, 1)
                zonalMean = nanmean(nanmean(nanmean(nanmean(baseExtTmp{1}{3}(lat, :, :, :, :), 5), 4), 3), 2);
                for mon = 1:size(baseExtTmp{1}{3}, 4)
                    for d = 1:size(baseExtTmp{1}{3}, 5)
                        baseExtTmp{1}{3}(lat, :, 1, mon, d) = baseExtTmp{1}{3}(lat, :, 1, mon, d) - zonalMean;
                    end
                end
            end
            
            for lat = 1:size(baseMeanTmp{1}{3}, 1)
                zonalMean = nanmean(nanmean(nanmean(nanmean(baseMeanTmp{1}{3}(lat, :, :, :, :), 5), 4), 3), 2);
                for mon = 1:size(baseMeanTmp{1}{3}, 4)
                    for d = 1:size(baseMeanTmp{1}{3}, 5)
                        baseMeanTmp{1}{3}(lat, :, 1, mon, d) = baseMeanTmp{1}{3}(lat, :, 1, mon, d) - zonalMean;
                    end
                end
            end
        end
        
        baseExtData{m} = {baseExtData{m}{:} baseExtTmp{:}};
        baseMeanData{m} = {baseMeanData{m}{:} baseMeanTmp{:}};
        clear baseDaily baseExtTmp baseMeanTmp;
    end
    
    for xlat = 1:size(curBaseMeanStdDev, 1)
        for ylon = 1:size(curBaseMeanStdDev, 2)
            baseMeanStdDev{m}(xlat, ylon) = nanstd(squeeze(curBaseMeanStdDev(xlat, ylon, :)));
            baseExtStdDev{m}(xlat, ylon) = nanstd(squeeze(curBaseExtStdDev(xlat, ylon, :)));
        end
    end
    
end

% if we are only looking at one dataset
if ~strcmp(testVar, '')
    for m = 1:length(testModels)
        if ~strcmp(testModels{m}, '')
            curModel = ['/' testModels{m} '/'];
        else
            curModel = '/';
        end
        
        testExtData{m} = {};
        testMeanData{m} = {};
        
        ['loading ' testDataset curModel ' ' testTime]
        for y = testPeriod(1):yearStep:testPeriod(end)
            ['year ' num2str(y) '...']
            % load daily data
            if testRegrid
                testDaily = loadDailyData([baseDir testDataDir curModel testEmissionsScenarioStr testVar '/regrid'], 'yearStart', y, 'yearEnd', (y+yearStep)-1);
            else
                testDaily = loadDailyData([baseDir testDataDir curModel testEmissionsScenarioStr testVar], 'yearStart', y, 'yearEnd', (y+yearStep)-1);
            end

            testMeanTmp = {{testDaily{1}, testDaily{2}, nanmean(nanmean(testDaily{3}(:,:,:,months,:), 5), 4)}};
            testExtTmp = findYearlyExtremes(testDaily, months, findMax);

            if subtractZonalMean
                for lat = 1:size(testExtTmp{1}{3}, 1)
                    zonalMean = nanmean(nanmean(nanmean(nanmean(testExtTmp{1}{3}(lat, :, :, :, :), 5), 4), 3), 2);
                    for mon = 1:size(testExtTmp{1}{3}, 4)
                        for d = 1:size(testExtTmp{1}{3}, 5)
                            testExtTmp{1}{3}(lat, :, 1, mon, d) = testExtTmp{1}{3}(lat, :, 1, mon, d) - zonalMean;
                        end
                    end
                end

                for lat = 1:size(testMeanTmp{1}{3}, 1)
                    zonalMean = nanmean(nanmean(nanmean(nanmean(testMeanTmp{1}{3}(lat, :, :, :, :), 5), 4), 3), 2);
                    for mon = 1:size(testMeanTmp{1}{3}, 4)
                        for d = 1:size(testMeanTmp{1}{3}, 5)
                            testMeanTmp{1}{3}(lat, :, 1, mon, d) = testMeanTmp{1}{3}(lat, :, 1, mon, d) - zonalMean;
                        end
                    end
                end
            end

            testExtData{m} = {testExtData{m}{:}, testExtTmp{:}};
            testMeanData{m} = {testMeanData{m}{:}, testMeanTmp{:}};
            clear testDaily testDailyExtTmp testDailyMeanTmp;
        end
    end
end
['done loading...']

baseExtAvg = [];
baseMeanAvg = [];

if statTest
    baseExtStatOutput = {};
    baseMeanStatOutput = {};
end

% average over models and years
for m = 1:length(baseExtData)
    for y = 1:length(baseExtData{m})
        baseExtAvg(:,:,m,y) = baseExtData{m}{y}{3};
    end
    
    if statTest
        % calculate sig for each model for the base ext
        baseExtStatOutput{m} = [];
        for xlat = 1:size(baseExtAvg, 1)
            for ylon = 1:size(baseExtAvg, 2)
                if abs(squeeze(nanmean(baseExtAvg(xlat, ylon, m), 4))) > statTestThresh*baseExtStdDev{m}(xlat, ylon) & baseExtStdDev{m}(xlat, ylon) ~= 0
                    baseExtStatOutput{m}(xlat, ylon) = 1;
                else
                    baseExtStatOutput{m}(xlat, ylon) = 0;
                end
            end
        end
    end
end
% create plotable structure
baseExtAvg = {baseExtData{1}{1}{1}, baseExtData{1}{1}{2}, squeeze(nanmean(nanmean(baseExtAvg, 4), 3))};

% and for the base mean
for m = 1:length(baseMeanData)
    for y = 1:length(baseMeanData)
        baseMeanAvg(:,:,m,y) = baseMeanData{m}{y}{3};
    end
    
    if statTest
        baseMeanStatOutput{m} = [];
        for xlat = 1:size(baseMeanAvg, 1)
            for ylon = 1:size(baseMeanAvg, 2)
                if abs(squeeze(nanmean(baseMeanAvg(xlat, ylon, m), 4))) > statTestThresh*baseMeanStdDev{m}(xlat, ylon) & baseMeanStdDev{m}(xlat, ylon) ~= 0
                    baseMeanStatOutput{m}(xlat, ylon) = 1;
                else
                    baseMeanStatOutput{m}(xlat, ylon) = 0;
                end
            end
        end
    end
    
end
baseMeanAvg = {baseMeanData{1}{1}{1}, baseMeanData{1}{1}{2}, squeeze(nanmean(nanmean(baseMeanAvg, 4), 3))};

if ~strcmp(testVar, '')
    testExtAvg = [];
    testMeanAvg = [];
    
    for m = 1:length(testExtData)
        for y = 1:length(testExtData{m})
            testExtAvg(:,:,m,y) = testExtData{m}{y}{3};
        end
    end
    testExtAvg = {testExtData{1}{1}{1}, testExtData{1}{1}{2}, nanmean(nanmean(testExtAvg, 4), 3)};
    
    for m = 1:length(testMeanData)
        for y = 1:length(testMeanData{m})
            testMeanAvg(:,:,m,y) = testMeanData{m}{y}{3};
        end
    end
    testMeanAvg = {testMeanData{1}{1}{1}, testMeanData{1}{1}{2}, nanmean(nanmean(testMeanAvg, 4), 3)};
    
    % regrid the base data if needed
    if size(baseExtAvg{3}) ~= size(testExtAvg{3})
        baseExtAvgRegrid = regridGriddata(baseExtAvg, testExtAvg);
    else
        baseExtAvgRegrid = baseExtAvg;
    end
    curModelExtAvgBias = {testExtAvg{1}, testExtAvg{2}, testExtAvg{3}-baseExtAvgRegrid{3}};
    
    % regrid the base data if needed
    if size(baseMeanAvg{3}) ~= size(testMeanAvg{3})
        baseMeanAvgRegrid = regridGriddata(baseMeanAvg, testMeanAvg);
    else
        baseMeanAvgRegrid = baseMeanAvg;
    end
    curModelMeanAvgBias = {testMeanAvg{1}, testMeanAvg{2}, testMeanAvg{3}-baseMeanAvgRegrid{3}};
else
    curModelExtAvgBias = {baseExtAvg{1}, baseExtAvg{2}, baseExtAvg{3}};
    curModelMeanAvgBias = {baseMeanAvg{1}, baseMeanAvg{2}, baseMeanAvg{3}};
end

result = {};
outputStatData = [];

if strcmp(meanOrExt, 'mean')
    result = curModelMeanAvgBias;
    
    if statTest
        for m = 1:length(baseModels)
            outputStatData(:, :, m) = baseMeanStatOutput{m}(:,:);
        end

        outputStatData = nansum(outputStatData, 3);
        outputStatData(outputStatData < statTestModelFrac*length(baseModels)) = 0;
        outputStatData(outputStatData >= statTestModelFrac*length(baseModels)) = 1;
    end
elseif strcmp(meanOrExt, 'ext')
    result = curModelExtAvgBias;
    
    if statTest
        for m = 1:length(baseModels)
            outputStatData(:, :, m) = baseExtStatOutput{m}(:,:);
        end

        outputStatData = nansum(outputStatData, 3);
        outputStatData(outputStatData < statTestModelFrac*length(baseModels)) = 0;
        outputStatData(outputStatData >= statTestModelFrac*length(baseModels)) = 1;
    end
    
elseif strcmp(meanOrExt, 'both')
    result = {curModelMeanAvgBias{1}, curModelMeanAvgBias{2}, curModelExtAvgBias{3}-curModelMeanAvgBias{3}};
    outputStatData = [];
end

plotTitle = ['NARCCAP summer mean soil moisture change'];

saveData = {result, plotRegion, plotRange, plotTitle, fileTitle, unitsStr, [], customColorMap, blockWater, outputStatData};
plotFromDataFile(saveData);

