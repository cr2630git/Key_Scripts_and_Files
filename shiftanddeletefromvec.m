function newvec = shiftanddeletefromvec(origvec,position,numelemstodelete,roworcol)
%Deletes the prescribed number of elements from vector origvec, counting from position
%   This is essentially the inverse of the function shiftandinsertintovec
%   'roworcol' is really only used when the origvec is not 1D
%   Example usage: newvec=shiftanddeletefromvec([1;2;3;4;5],3,2,'row') -> [1;2;5]

[nr,nc]=size(origvec);
if nc==1 %a column vector
    sizechoice=1;origvecsize=size(origvec,1);origvecsizeotherdim=size(origvec,2);
elseif nr==1 %a row vector
    sizechoice=2;origvecsize=size(origvec,2);origvecsizeotherdim=size(origvec,1);
elseif strcmp(roworcol,'row') %2D array but deleting rows so it's kind of like it's a column vector
    sizechoice=1;origvecsize=size(origvec,1);origvecsizeotherdim=size(origvec,2);
elseif strcmp(roworcol,'col') %ditto but deleting columns
    sizechoice=2;origvecsize=size(origvec,2);origvecsizeotherdim=size(origvec,1);
end


%Split origvec into pieces and put them back together without the unwanted elements
if sizechoice==1
    origvecpiece1=origvec(1:position-1,:);
    origvecpiece2=origvec(position+numelemstodelete:size(origvec,1),:);
    newvec=[origvecpiece1;origvecpiece2];
elseif sizechoice==2
    origvecpiece1=origvec(:,1:position-1);
    origvecpiece2=origvec(:,position+numelemstodelete:size(origvec,2));
    newvec=[origvecpiece1 origvecpiece2];
end




end

