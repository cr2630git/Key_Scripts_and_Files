function [finalvec,placesinserted,locationsofzeros,numzerosremovedsofar,numfinalrowsorcolstackedon] = ...
    findandelimzeros (inputvec,roworcol,finalsize,whattoinsert)
%Finds and eliminates zeros in a vector, creating a complete vector of ordinate counts, taking into account all possible idiosyncrasies
%  Written for the compiledataarrays loop of findmaxtwbt
%  roworcol dictates vector orientation; e.g. 'row' means rows will be filled in across all columns of inputvec
%  finalsize indicates how large the final vector should be (in the dimension of the desired orientation)
%  whattoinsert is either 'counts' (ordinate counts) or 'zeros'
%  placesinserted is an array of the rows or columns at which things were inserted, plus how many, 
    %so that another vector can use this information for its own purposes -- all relative to original inputvec (zeros and all)

%Note: if vector is already complete (no changes need to be made), this function returns an error with output arguments unassigned
    
%e.g. [1 2 3 0 5] --> [1 2 3 4 5]
%     [1 2 0 6] --> [1 2 3 4 5 6]

if strcmp(roworcol,'col')
    fixednumrowsorcols=size(inputvec,1);
elseif strcmp(roworcol,'row')
    fixednumrowsorcols=size(inputvec,2);
end

%Look through the input vec for gaps and
%1. delete the extraneous numbers that are in them, using the function shiftanddeletefromvec
%2. fill them with counts or zeros, as desired, using the function shiftandinsertintovec

%First, if necessary, fill in the end of inputvec
%This is a solution for when e.g. finalsize=5 and inputvec=[1 2 3]
if inputvec(size(inputvec,2))~=finalsize
    [inputvec,numfinalrowsorcolstackedon]=fillendsofavecregularversion(inputvec,finalsize,'end');
else
    numfinalrowsorcolstackedon=0;
end


%Now, execute the main searching loop
i=2;loopnum=1;numinsertions=0;numthingsinsertedsofar=0;numzerolocations=0;numzerosremovedsofar=0;
while i<=finalsize
    %fprintf('i is currently %d   ',i);fprintf('loopnum is %d\n',loopnum);if i==200;disp(inputvec);end
    
    if inputvec(i+(loopnum-1))~=0 && inputvec(i-1)~=0
        difffromprev=inputvec(i+(loopnum-1))-inputvec(i-1);
        if difffromprev~=1+(loopnum-1) && min(inputvec(i-1:i+loopnum-1))~=0 %e.g. [198 200] or [197 200]
            %fprintf('Inserting something to fill a non-zero gap, with adjusted i=%d\n',i+(loopnum-1));
            numinsertions=numinsertions+1;
            %disp(difffromprev);disp(fixednumrowsorcols);
            numrowsorcolstoadd=difffromprev-1;
            placesinserted(numinsertions,1)=i+(loopnum-1)-numthingsinsertedsofar; %originally added +numzerosremovedsofar but
                %if the eventual vector that will use this info will have zeros removed first before insertion of new stuff,
                %this term should not be included
            placesinserted(numinsertions,2)=numrowsorcolstoadd;
            numthingsinsertedsofar=numthingsinsertedsofar+numrowsorcolstoadd;
            %fprintf('Numrowsorcolstoadd is %0.0f\n',numrowsorcolstoadd);
            if strcmp(whattoinsert,'counts')
                if strcmp(roworcol,'col')
                    inputvec=shiftandinsertintovec(inputvec,i,i:i+numrowsorcolstoadd-1,roworcol);
                elseif strcmp(roworcol,'row')
                    inputvec=shiftandinsertintovec(inputvec,i,[i:i+numrowsorcolstoadd-1]',roworcol);
                end
            elseif strcmp(whattoinsert,'zeros')
                if strcmp(roworcol,'col')
                    inputvec=shiftandinsertintovec(inputvec,i,zeros(fixednumrowsorcols,numrowsorcolstoadd),roworcol);
                elseif strcmp(roworcol,'row')
                    inputvec=shiftandinsertintovec(inputvec,i,zeros(numrowsorcolstoadd,fixednumrowsorcols),roworcol);
                end
            end
        elseif min(inputvec(i-1:i+loopnum-1))==0 %e.g. [1 2 0 6 7 8 9] or [1 2 3 0 5 6]
            %fprintf('Inserting something to fill a zero gap, with adjusted i=%d\n',i+(loopnum-1));
            numinsertions=numinsertions+1;
            numrowsorcolstoadd=difffromprev-1;
            placesinserted(numinsertions,1)=i+(loopnum-2)-numthingsinsertedsofar; %see remark above
            placesinserted(numinsertions,2)=numrowsorcolstoadd;
            numthingsinsertedsofar=numthingsinsertedsofar+numrowsorcolstoadd;
            numzerostoremove=loopnum-1;
            %numzerolocations=numzerolocations+1;
            %disp('line 60');disp(loopnum);disp(numrowsorcolstoadd);disp(numthingsinsertedsofar);
            %disp(numzerosremovedsofar);disp(numzerostoremove);disp(inputvec);
            locationsofzeros(numzerosremovedsofar+1:numzerosremovedsofar+1+numzerostoremove-1)=...
                i+(loopnum-1)-numthingsinsertedsofar+numzerosremovedsofar+(numrowsorcolstoadd-1):...
                i+(loopnum-1)-numthingsinsertedsofar+numzerosremovedsofar+(numrowsorcolstoadd-1)+numzerostoremove-1;
            numzerosremovedsofar=numzerosremovedsofar+numzerostoremove;
            if strcmp(whattoinsert,'counts')
                if strcmp(roworcol,'col')
                    temp=shiftanddeletefromvec(inputvec,i,numzerostoremove,roworcol);
                    inputvec=shiftandinsertintovec(temp,i,i:i+numrowsorcolstoadd-1,roworcol);
                elseif strcmp(roworcol,'row')
                    temp=shiftanddeletefromvec(inputvec,i,numzerostoremove,roworcol);
                    inputvec=shiftandinsertintovec(temp,i,[i:i+numrowsorcolstoadd-1]',roworcol);
                end
                %disp('line 53');disp(numrowsorcolstoadd);disp(loopnum);
            elseif strcmp(whattoinsert,'zeros')
                if strcmp(roworcol,'col')
                    temp=shiftanddeletefromvec(inputvec,i,numzerostoremove,roworcol);
                    inputvec=shiftandinsertintovec(temp,i,zeros(fixednumrowsorcols,numrowsorcolstoadd),roworcol);
                elseif strcmp(roworcol,'row')
                    temp=shiftanddeletefromvec(inputvec,i,numzerostoremove,roworcol);
                    inputvec=shiftandinsertintovec(temp,i,zeros(numrowsorcolstoadd,fixednumrowsorcols),roworcol);
                end
            end
        end
        loopnum=1;i=i+loopnum;
    elseif inputvec(1)==0 %special case that must be remedied before advancing deeper into the vector
            %(also, doesn't count as a zero removed)
        inputvec(1)=1;
    else
        loopnum=loopnum+1;%disp('line 66');disp(i);disp(loopnum);
    end
end

finalvec=inputvec;



end

