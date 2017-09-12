function newvec = shiftandinterpolatevec(origvec,position,numelemstoinsert)
%Inserts new interpolated values into 1D vector origvec at position, accommodating them
%   by shifting the original values down the necessary number of units [numelemstoinsert]
%Currently supports numelemstoinsert in the range 1-6
%   e.g. a=[1;2;7;8;11]
%   b=shiftvec(a,5,2) --> b=[1;2;7;8;9;10;11]
[nr,nc]=size(origvec);
if nc==1 %a column vector
    sizechoice1=1;
elseif nr==1 %a row vector
    sizechoice1=2;
else
    disp('Please choose an origvec that is one-dimensional');return;
end
origvecsize=size(origvec,sizechoice1);

%Shift origvec down to accommodate new interpolated values
origvec(position+numelemstoinsert:origvecsize+numelemstoinsert,1)=origvec(position:origvecsize,1);
tempvec=origvec;%disp(origvec);

%Do the interpolation, the weightings for each element varying by the size of the gap to fill
if numelemstoinsert==1 %i.e. a simple average of the values on either side
    %disp(0.5.*origvec(position-1));disp(0.5.*origvec(position+numelemstoinsert));
    tempvec(position,1)=0.5.*origvec(position-1)+0.5.*origvec(position+numelemstoinsert);
elseif numelemstoinsert==2
    tempvec(position,1)=0.67*origvec(position-1)+0.33*origvec(position+numelemstoinsert);
    tempvec(position+1,1)=0.33*origvec(position-1)+0.67*origvec(position+numelemstoinsert);
elseif numelemstoinsert==3
    tempvec(position,1)=0.75*origvec(position-1)+0.25*origvec(position+numelemstoinsert);
    tempvec(position+1,1)=0.5*origvec(position-1)+0.5*origvec(position+numelemstoinsert);
    tempvec(position+2,1)=0.25*origvec(position-1)+0.75*origvec(position+numelemstoinsert);
elseif numelemstoinsert==4
    tempvec(position,1)=0.8*origvec(position-1)+0.2*origvec(position+numelemstoinsert);
    tempvec(position+1,1)=0.6*origvec(position-1)+0.4*origvec(position+numelemstoinsert);
    tempvec(position+2,1)=0.4*origvec(position-1)+0.6*origvec(position+numelemstoinsert);
    tempvec(position+3,1)=0.2*origvec(position-1)+0.8*origvec(position+numelemstoinsert);
elseif numelemstoinsert==5
    tempvec(position,1)=5/6*origvec(position-1)+1/6*origvec(position+numelemstoinsert);
    tempvec(position+1,1)=4/6*origvec(position-1)+2/6*origvec(position+numelemstoinsert);
    tempvec(position+2,1)=3/6*origvec(position-1)+3/6*origvec(position+numelemstoinsert);
    tempvec(position+3,1)=2/6*origvec(position-1)+4/6*origvec(position+numelemstoinsert);
    tempvec(position+4,1)=1/6*origvec(position-1)+5/6*origvec(position+numelemstoinsert);
elseif numelemstoinsert==6
    tempvec(position,1)=6/7*origvec(position-1)+1/7*origvec(position+numelemstoinsert);
    tempvec(position+1,1)=5/7*origvec(position-1)+2/7*origvec(position+numelemstoinsert);
    tempvec(position+2,1)=4/7*origvec(position-1)+3/7*origvec(position+numelemstoinsert);
    tempvec(position+3,1)=3/7*origvec(position-1)+4/7*origvec(position+numelemstoinsert);
    tempvec(position+4,1)=2/7*origvec(position-1)+5/7*origvec(position+numelemstoinsert);
    tempvec(position+5,1)=1/7*origvec(position-1)+6/7*origvec(position+numelemstoinsert);
end

%Create newvec as prep for output
newvec=tempvec;

end

