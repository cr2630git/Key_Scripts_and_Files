function [fillerhours,fillerdays] = fillendsofavec(terminalvalidhour,terminalvalidday,firstorlast)
%Fills in the ends of a vector with NaN's, given the first or last valid hour and valid day
%   Whether this is filling in the beginning or end of a vector is given by firstorlast ('beginning' or 'end')
%   For example, [fillerhours,fillerdays]=fillendsofavecwithnan(5,2)
%       --> fillerhours=[0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;0;1;2;3;4];
%       --> fillerdays=[1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];

if strcmp(firstorlast,'beginning')
    if terminalvalidday>1
        tentativehours=[0:23]';
        for i=1:terminalvalidday-2
            tentativehours=[tentativehours;(0:23)'];
        end
        tentativehours=[tentativehours;(0:terminalvalidhour-1)'];
    else
        tentativehours=[0:terminalvalidhour-1]';
    end
elseif strcmp(firstorlast,'end')
    if terminalvalidday>1
        tentativehours=[0:23]';
        for i=1:terminalvalidday-2
            tentativehours=[(0:23)';tentativehours];
        end
        tentativehours=[(terminalvalidhour+1:23)';tentativehours];
    else
        tentativehours=[(terminalvalidhour+1:23)'];
    end
end

%Assign output vectors
fillerhours=tentativehours;
curday=1;
if size(fillerhours,1)>23 %multiple days
    for i=1:size(fillerhours,1)
        fillerdays(i,1)=curday;
        if fillerhours(i)==23;curday=curday+1;end
    end
else
    fillerdays=ones(size(fillerhours,1),1);
end


end
