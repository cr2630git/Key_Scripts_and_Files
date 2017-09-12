function [theta,rho] = cart2compass(u,v)
%CART2COMPASS convert cartesian coordinates into
% speed and direction data (degN).
%    [THETA,RHO] = CART2COMPASS convert the vectors u and v
%      from a cartesian reference system into rho (e.g. speed) with
%      direction theta (degree North).
%
%   See also CART2POL
%

% Author: Arnaud Laurent
% Creation : March 20th 2009
% MATLAB version: R2007b
%

[theta,rho] = cart2pol(u,v);

theta = theta*180/pi;

idx = find(theta<0);
theta(idx) = 360 + theta(idx);

idx = find(theta>=0&theta<90);
theta_comp(idx,1) = abs(theta(idx) - 90);

idx = find(theta>=90&theta<=360);
theta_comp(idx,1) = abs(450 - theta(idx));

theta = theta_comp;

%Adjust for meteorological conventions
if theta<180;theta=theta+180;else theta=theta-180;end
