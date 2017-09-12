function cleanhours = findcleanhours(time1,time2,numdays)
%A simple little function to find the clean hours (e.g. 3:00, 4:00, 5:00) from two bracketing times (e.g. 2:22, 7:13)
%Things are slightly more complex (but only slightly) if multiple days are involved
%Times must be input IN DECIMAL FORM

hourtime1=round2(time1,1,'ceil');
hourtime2=round2(time2,1,'floor');
if numdays==1
    if hourtime1>hourtime2 %e.g. because hourtime1 is in the late evening and hourtime2 is in the early morning
        cleanhourspart1=[hourtime1:23]';
        cleanhourspart2=[0:hourtime2]';
    else
        cleanhourspart1=[hourtime1:hourtime2]';
    end
else
    cleanhourspart1=[hourtime1:23]';
    if numdays==2
        cleanhourspart2=[0:hourtime2]';
    elseif numdays>=3
        for j=1:numdays-2
            eval(['cleanhourspart' num2str(j+1) '=[0:23]'';']);
        end
        eval(['cleanhourspart' num2str(numdays) '=[0:hourtime2]'';']);
    end
end
%disp(cleanhourspart1);disp(cleanhourspart2);

%If round hours were inputted originally at the beginning and/or end of the vector, 
%eliminate since we don't actually need info about them
%Then, combine parts of cleanhours as created above
if numdays>=2 %times span multiple days
    if rem(time1,1)==0
        cleanhourspart1=[hourtime1+1:23]'; %remove very first hour of this sequence
    end
    if rem(time2,1)==0
        eval(['cleanhourspart' num2str(numdays) '=[0:hourtime2-1]'';']); %remove very last hour of this sequence
    end
    %Combine parts (just need to do this last part if no hour-removal adjustments were needed)
    cleanhours=cleanhourspart1;
    for j=2:numdays;cleanhours=[cleanhours;eval(['cleanhourspart' num2str(j)])];end
else %times occur only on one day, so things are pretty easy
    if rem(time1,1)==0
        newhourtime1=hourtime1+1;
        if hourtime1>hourtime2
            cleanhourspart1=[newhourtime1:23]';
            cleanhourspart2=[0:hourtime2]';
        else
            cleanhours=[newhourtime1:hourtime2]';
        end
    else
        newhourtime1=hourtime1;
        if hourtime1>hourtime2
            cleanhourspart1=[newhourtime1:23]';
            cleanhourspart2=[0:hourtime2]';
        else
            cleanhours=[newhourtime1:hourtime2]';
        end
    end
    if rem(time2,1)==0
        newhourtime2=hourtime2-1;
        if hourtime1>hourtime2
            cleanhourspart1=[newhourtime1:23]';
            cleanhourspart2=[0:newhourtime2]';
        else
            cleanhours=[newhourtime1:newhourtime2]';
        end
    else
        newhourtime2=hourtime2;
        if hourtime1>hourtime2
            cleanhourspart1=[newhourtime1:23]';
            cleanhourspart2=[0:newhourtime2]';
        else
            cleanhours=[newhourtime1:newhourtime2]';
        end
    end
    
    if ~rem(time1,1)==0 && ~rem(time2,1)==0 %no adjustments needed
        cleanhours=cleanhourspart1;
    end
end

end

