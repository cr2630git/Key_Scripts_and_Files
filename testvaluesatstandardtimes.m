function valuesatcleantimes = valuesatstandardtimesfromnonstandard2(descleantimes,inputtimes,inputday,inputdata)
%Given an input of data at messy/nonstandard times, converts them using linear interpolation to values at standard times
%   In current configuration, checks values 3 preceding & succeeding values in search of valid ones to use for interpolation
%   Can do this for multiple days as well, not just a single one -- but can't deal with inputday where a day is skipped wholesale
%   If inputdata are times themselves (e.g. days or months), use function timevecfromhourvec instead

%   In calling this function ***inputtimes & inputdata must include on either end times for which values are known***,
%   so that they completely bracket the descleantimes -- these known values are not included in the 
%   final outputted valuesatcleantimes

%   Number of nonstandard and standard times used as input need not be the same
%   However, times must be in chronological order and in DECIMAL FORM
%   Size of inputtimes and inputdata must be the same since they are supposed to correspond!!

%   Schema for dealing with present but invalid variable obs: 
%   -check if either of the values being interpolated from is missing; if so, use previous and/or subsequent value
%   -but, if either of *those* is missing, make the interpolated value missing as well



%For testing
%descleantimes=[22;23;0;1;2;3;4;5;6;7;8];
%inputtimes=[21;21.7;0.5;9];
%inputday=[1;1;2;2];
%inputdata=[29;27;20;99];


troubleshoot=1; %whether to display troubleshooting messages
missingval=99;  %numbers with absolute values greater than or equal to this are assumed to be missing or invalid

%Ensure that all inputs are column vectors before proceeding
size1=size(descleantimes,1);if size1==1;descleantimes=descleantimes';end
size2=size(inputtimes,1);if size2==1;inputtimes=inputtimes';end
size3=size(inputdata,1);if size3==1;inputdata=inputdata';end
%fprintf('Size of descleantimes is %d\n',size(descleantimes,1));
%disp(descleantimes);


%For each descleantime, find the input times that bracket it, 
    %and the weights of the bracketing inputtimes for the descleantime so that weighted-average values can ultimately be calculated
%As we are secure in knowing that the input times bracket all the descleantimes,
%if they appear not to numerically it must be because of a midnight getting in the way (Section 2 of this loop)
%Function can handle gaps of up to 48 hours

%i is the count of descleantimes
%j is the count of inputtimes

for i=1:size(descleantimes,1)
    curdescleantime=descleantimes(i); %this is the time we are looking for
    somethingfound=0;
    
    while somethingfound==0
        for j=2:size(inputtimes,1)
            thishoursearching=inputtimes(j);
            prevhoursearching=inputtimes(j-1);
            dayofthishour=inputday(j);
            dayofprevhour=inputday(j-1);

            %Possibility 1: curdescleantime is directly sandwiched between two times in the same day
            if thishoursearching>=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 1: Curdescleantime is sandwiched between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=1;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs1(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 2: curdescleantime is sandwiched between times that appear in chronological non-numerical order and span 2 days in total
                %curdescleantime is on the second of these days
            if thishoursearching>=curdescleantime && prevhoursearching>curdescleantime && dayofthishour==dayofprevhour+1
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 2: Curdescleantime is sandwiched between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=2;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs2(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 3: curdescleantime is found between times that appear in chronological non-numerical order and span 2 days in total
                %curdescleantime is on the first of these days
            if thishoursearching<=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+1
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 3: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=3;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs3(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 4.1: curdescleantime is found between times that appear in chronological numerical order but on different, though consecutive, days
                %curdescleantime is on the first of these days
            if thishoursearching>=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+1
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 4.1: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=4.1;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs4point1(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 4.2: curdescleantime is found between times that appear in chronological numerical order but on different, though consecutive, days
                %curdescleantime is on the second of these days
            if thishoursearching>=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+1
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 4.2: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=4.2;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs4point2(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 5.1: curdescleantime is found between times that appear in chronological non-numerical order and span 3 days in total
                %curdescleantime is on the first of these days
            if thishoursearching<=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+2
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 5.1: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=5.1;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs5point1(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 5.2: curdescleantime is found between times that appear in chronological non-numerical order and span 3 days in total
                %curdescleantime is on the second of these days
            if thishoursearching<=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+2
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 5.2: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=5.2;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs5point2(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 5.3: curdescleantime is found between times that appear in chronological non-numerical order and span 3 days in total
                %curdescleantime is on the third of these days
            if thishoursearching<=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+2
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 5.3: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=5.3;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs5point3(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 6.1: curdescleantime is found between times that appear in chronological numerical order and span 3 days in total
                %curdescleantime is on the first of these days
            if thishoursearching>=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+2
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 6.1: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=6.1;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs6point1(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 6.2: curdescleantime is found between times that appear in chronological numerical order and span 3 days in total
                %curdescleantime is on the second of these days
            if thishoursearching>=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+2
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 6.2: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=6.2;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs6point2(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end

            %Possibility 6.3: curdescleantime is found between times that appear in chronological numerical order and span 3 days in total
                %curdescleantime is on the third of these days
            if thishoursearching>=curdescleantime && prevhoursearching<curdescleantime && dayofthishour==dayofprevhour+2
                fprintf('Curdescleantime is %0.2f\n',curdescleantime);
                fprintf('Possibility 6.3: Curdescleantime is found between %0.2f and %0.2f\n',prevhoursearching,thishoursearching);
                possibility=6.3;somethingfound=1;
                finalweighteddata=weightsofsandwichingvalidvalsposs6point3(inputtimes,inputdata,curdescleantime,i,j);
                fprintf('Finalweighteddata is %0.2f\n',finalweighteddata);fprintf('\n');
            end
        end
    end
end

end
