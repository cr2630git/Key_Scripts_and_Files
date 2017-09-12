function [dayvec,monthvec,yearvec] = ...
    timevecfromhourvec(hourvec,daytostartwith,monthtostartwith,curmonlen,...
    nummonthsspanned,yeartostartwith,leapyearornot)
%Calculates days corresponding to a given input vector of desired hours
%   Loosely inspired by the (limitations of the) function valuesatstandardtimesfromnonstandard
%   Capable of spanning multiple months (and even years), the first one's length being given by curmonlen
%   leapyearornot option ('regyear' or 'leapyear') dictates whether Feb has 28 or 29 days

monthlengths={'31';'28';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
monthlengthsl={'31';'29';'31';'30';'31';'30';'31';'31';'30';'31';'30';'31'};
if strcmp(leapyearornot,'leapyear')
    monlens=monthlengthsl;
else
    monlens=monthlengths;
end

if size(hourvec,1)==1 && size(hourvec,2)>1
    disp('Please input a column vector');
    return;
end

%Assumes times are in the range 0<=x<24, 
%and that timevec is a column vector arranged in chronological order
thisday=1;
dayvec(1)=thisday;
for i=2:size(hourvec,1)
    if hourvec(i)<hourvec(i-1) %i.e. timevec(i) is in early morning and 
        %timevec(i-1) is in late evening
        thisday=thisday+1;
    end
    dayvec(i)=thisday;
end

if size(dayvec,1)==1;dayvec=dayvec';end %starts with 1
dayvec=dayvec+daytostartwith-1; %starts with daytostartwith, keeps going up
monthvec=ones(size(dayvec,1),1)+monthtostartwith-1;
yearvec=ones(size(dayvec,1),1)+yeartostartwith-1;
%disp(dayvec);disp(monthvec);

if strcmp(class(curmonlen),'char')
    curmonlen=str2num(curmonlen);
end
%disp(max(dayvec));disp(curmonlen);disp(class(max(dayvec)));disp(class(curmonlen));

%Wrap days around to the next month if they exceed relevant month's length
%Also wrap month
if max(dayvec)>curmonlen %does anything even need to be done?
    for j=1:nummonthsspanned-1 %loop starts with second month spanned
        relevantmonlen=str2num(monlens{j+monthtostartwith-1});
        for i=1:size(dayvec,1)
            if dayvec(i)>relevantmonlen
                %disp('line 35');disp(dayvec(i));disp(relevantmonlen);
                dayvec(i)=dayvec(i)-relevantmonlen;
                monthvec(i)=monthvec(i)+1;
            end
        end
    end
end

%Wrap around year if necessary (and consequently month as well)
%Days have already been wrapped enough, so to speak
if max(monthvec)>12 %does anything even need to be done?
    for i=1:size(monthvec,1)
        if monthvec(i)>12
            monthvec(i)=1;
            yearvec(i)=yearvec(i)+1;
        end
    end
end


end

