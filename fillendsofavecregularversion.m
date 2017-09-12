function [finalvec,numvalstoinsert] = fillendsofavecregularversion(inputvec,terminalvalue,firstorlast)
%Fills in the missing ends of a vector with ordinate counts
%   Whether this is filling in the beginning or end of a vector is given by firstorlast ('beginning' or 'end')
%   inputvec must be 1D

%e.g. terminalvalue=10;firstorlast='end';inputvec=[1;2;3;4;5;6;7];
% --> finalvec=[1;2;3;4;5;6;7;8;9;10];

[nr,nc]=size(inputvec);
if nr==1
    sizec=2;
elseif nc==1
    sizec=1;
else
    disp('Please enter an inputvec that is 1D');return;
end

if strcmp(firstorlast,'beginning')
    curfirstval=inputvec(1);
    numvalstoinsert=inputvec(1)-1;
    stufftoinsert=1:numvalstoinsert;
    if sizec==1;stufftoinsert=stufftoinsert';end
elseif strcmp(firstorlast,'end')
    curlastval=inputvec(size(inputvec,sizec));
    stufftoinsert=curlastval+1:terminalvalue;
    numvalstoinsert=size(stufftoinsert,2);
    if sizec==1;stufftoinsert=stufftoinsert';end
end

%Assign output vector
if sizec==1
    finalvec=[inputvec;stufftoinsert];
elseif sizec==2
    finalvec=[inputvec stufftoinsert];
end


end
