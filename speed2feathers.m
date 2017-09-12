function [nflag,nfull,nhalf] = speed2feathers(speed)
%
% [nflag,nfull,nhalf] = speed2feathers(speed);
%
% speed2feathers takes the scalar speed and returns the
% number of flag/full/half feathers necessary to represent
% the speed on a standard meteorological wind-barb vector.
%
% input:
% speed scalar speed (units assumed to be kt)
%
% output:
% nflag number of 50 kt flags needed
% nfull number of 10 kt full feathers needed
% nhalf number (0|1) of 5 kt half feathers needed
%

round_speed = 5.*round(speed./5);
nflag = floor(round_speed./50);
nfull = floor((round_speed - nflag.*50)./10);
nhalf = floor((round_speed - nflag.*50 - nfull.*10)./5);

