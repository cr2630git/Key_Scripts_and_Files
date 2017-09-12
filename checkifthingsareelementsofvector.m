function [outputvec] = checkifthingsareelementsofvector(inputvec,thingstocheck)
%One by one, checks if thingstocheck are elements of inputvec
%   Returns outputvec, with 1 (0) for each thing that is (isn't) an element of inputvec

if size(thingstocheck,1)==1;thingstocheck=thingstocheck';end
if size(inputvec,1)==1;inputvec=inputvec';end


for i=1:size(thingstocheck,1)
    %Current thing to check is thingstocheck(i)
    curthingfound=0;
    for j=1:size(inputvec,1)
        if thingstocheck(i)==inputvec(j)
            curthingfound=1;
        end
    end
    outputvec(i)=curthingfound;
end

end

