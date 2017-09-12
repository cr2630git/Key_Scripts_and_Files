function [u,v] = compass2cart(theta,rho)
%COMPASS2CART convert speed and direction data (degN) into
% cartesian coordinates.
%   COMPASS2CART(THETA,RHO) convert the vector rho (e.g. speed) with
%      direction theta (degree North) into cartesian coordinates u and v.
%      note: theta is in degrees and between 0 and 360.
%
%   See also POL2CART
%

% Author: Arnaud Laurent
% Creation : March 20th 2009
% MATLAB version: R2007b
%

if size(theta,2)>1
    theta = theta';
end

if size(rho,2)>1
    rho = rho';
end

idx = find(theta>=0&theta<90);
theta_pol(idx,1) = abs(theta(idx) - 90);

idx = find(theta>=90&theta<=360);
theta_pol(idx,1) = abs(450 - theta(idx));

[u,v] = pol2cart(theta_pol*pi/180,rho);
