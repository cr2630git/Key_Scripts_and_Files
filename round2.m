function z = round2(x,y,swtch) 
%ROUND2 rounds number to nearest multiple of arbitrary precision. 
% Z = ROUND2(X,Y) rounds X to nearest multiple of Y. 
% swtch = 'floor' does the same thing, only towards -inf 
% = 'ceil' same, only towards +inf 
% = 'fix' same, only towards 0 
% 
%Example 1: round PI to 2 decimal places 
% >> round2(pi,0.01) 
% ans = 
% 3.14 
% 
%Example 2: round PI to 4 decimal places 
% >> round2(pi,1e-4) 
% ans = 
% 3.1416 
% 
%Example 3: round PI to 8-bit fraction 
% >> round2(pi,2^-8) 
% ans = 
% 3.1406 
% 
%Examples 4-6: round PI to other multiples 
% >> round2(pi,0.05) 
% ans = 
% 3.15 
% >> round2(pi,2) 
% ans = 
% 4 
% >> round2(pi,5) 
% ans = 
% 5 
%Examples 7-10: round, floor, ceil, and fix PI to nearest 1/7th 
%round2(pi,1/7) % recall that PI ~= 3+1/7... 
% ans = 
% 3.1429 
% round2(pi,1/7,'floor') % ... but is < 3+1/7 
% ans = 
% 3 
% round2(pi,1/7,'ceil') 
% ans = 
% 3.1429 
% round2(pi,1/7,'fix') 
% ans = 
% 3 
% 
% See also ROUND, FLOOR, CEIL, FIX.

%% defensive programming 
error(nargchk(2,3,nargin)) 
error(nargoutchk(0,1,nargout)) 
if numel(y)>1 
error('Y must be scalar') 
end

%% 
if nargin < 3 
swtch = ''; 
end 
switch swtch 
case 'floor' 
z = floor(x/y)*y; 
case 'ceil' 
z = ceil(x/y)*y; 
case 'fix' 
z = fix(x/y)*y; 
otherwise 
z = round(x/y)*y; 
end