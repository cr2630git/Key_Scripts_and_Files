function newvec = shiftandinsertintovec(origvec,position,stufftoinsert,roworcol)
%Inserts values [stufftoinsert] into vector origvec at position
%   This is similar to shiftandinterpolatevec, except without the interpolation part
%   (interpolation is typically what this function will be used for however, it just
%   isn't calculated generically here but is done with some special treatment and the final result
%   inserted with this)
%   Roworcol -- whether stufftoinsert should be inserted as a row or as a column (only really needed for 2D arrays)

%Examples: 
%origvec=[1;2;3;4;5;7;8;9];position=6;stufftoinsert=6;roworcol='col' --> newvec=[1;2;3;4;5;6;7;8;9];
%origvec=[5 9 1 0 3;4 1 0 5 2];position=2;stufftoinsert=[15 15 15 15 15];roworcol='row';
    %newvec=[5 9 1 0 3;15 15 15 15 15;4 1 0 5 2];

[nr,nc]=size(origvec);
if nc==1 %a column vector
    sizechoice=1;origvecsize=size(origvec,1);origvecsizeotherdim=size(origvec,2);
elseif nr==1 %a row vector
    sizechoice=2;origvecsize=size(origvec,2);origvecsizeotherdim=size(origvec,1);
elseif strcmp(roworcol,'row') %2D array but inserting stufftoinsert as row so it's kind of like a column vector
    sizechoice=1;origvecsize=size(origvec,1);origvecsizeotherdim=size(origvec,2);
elseif strcmp(roworcol,'col') %ditto but inserting as col
    sizechoice=2;origvecsize=size(origvec,2);origvecsizeotherdim=size(origvec,1);
end


%Shift origvec down to accommodate new values
if sizechoice==1
    if origvecsizeotherdim~=size(stufftoinsert,2);disp('Stuff to insert must match size of array it is being inserted into');return;end
    origvec(position+size(stufftoinsert,1):origvecsize+size(stufftoinsert,1),:)=origvec(position:origvecsize,:);
    tempvec=origvec;%disp(origvec);
    tempvec(position:position+size(stufftoinsert,1)-1,:)=stufftoinsert;
elseif sizechoice==2
    if origvecsizeotherdim~=size(stufftoinsert,1);disp('Stuff to insert must match size of array it is being inserted into');return;end
    origvec(:,position+size(stufftoinsert,2):origvecsize+size(stufftoinsert,2))=origvec(:,position:origvecsize);
    tempvec=origvec;%disp(origvec);
    tempvec(:,position:position+size(stufftoinsert,2)-1)=stufftoinsert;
end

newvec=tempvec;

end

