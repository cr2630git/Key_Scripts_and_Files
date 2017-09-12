function [gaplengths,gaplocations] = findgapsandlengths(inputvec,missingdataval)
%Finds the number and length of gaps within an input vector
%Outputs this vector (essentially a histogram) to the vector gaplengths

%Example: a=[5;99;99;99;0;-3;3;4;99;1;3;78;45;2;-9;-80;99];
%b=findgapsandlengths(a,99) --> b=[2;0;1] (2 gaps of 1 unit, 0 gaps of 2 units, 1 gap of 3 units)

if size(inputvec,1)==1;inputvec=inputvec';end


gaplengths=zeros(5,1); %just to start out
gaplocations=zeros(5,1);
i=1;
gapc=zeros(5,1);
while i<=size(inputvec,1)
    %Determine how long this gap is
    %disp('line 17');disp(i);
    gapfound=0;
    if inputvec(i)>=missingdataval
        gaplength=1;gapfound=1;gapcontinues=1;
        while gaplength<=size(inputvec,1)-i && gapcontinues==1
            i=i+1;%disp('line 22');disp(i);
            if inputvec(i)>=missingdataval
                gaplength=gaplength+1;
            else
                gapcontinues=0;
            end
        end
        
        %disp('line 30');disp(size(gaplocations));
        if gaplength>size(gaplengths,1) %need to lengthen vectors
            gaplengths=[gaplengths;zeros(gaplength-size(gaplengths,1),1)];
            gaplocations=[gaplocations;zeros(gaplength-size(gaplocations,1),size(gaplocations,2))];
            gapc=[gapc;zeros(gaplength-size(gapc,1),1)];
        end
        
        gapc(gaplength)=gapc(gaplength)+1;
        gaplengths(gaplength,1)=gaplengths(gaplength)+1;
        gaplocations(gaplength,gapc(gaplength))=i-gaplength; %the location of the first missing value
        %fprintf('Gap of %d units found\n',gaplength);disp(i);disp(gaplength);disp(gapc(gaplength));
    end
    
    
    %Advance vector index
    i=i+1;
end

end

