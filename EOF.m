function [L, EOFs, EC, error, norms] = EOF( U, n, norm, varargin )
% EOF - computes EOF of a matrix.
%
% Usage: [L, EOFs, EC, error, norms] = EOF( M, num, norm, ... )
%
% M is the matrix on which to perform the EOF.  
%
% num is the number of EOFs to return.  If num='all' (the default), all EOFs are returned. 
%
% If norm is true, then all time series are normalized by their standard
% deviation before EOFs are computed.  Default is false.  If true,
% the fifth output argument will be the standard deviations of each column.
%
% ... are extra arguments to be given to the svds function.  These will
% be ignored in the case that all EOFs are to be returned, in which case
% the svd function is used instead. Use these with care.
%
% Data must be detrended first using the detrend function.
%
% L are the eigenvalues of the covariance matrix (i.e. they are normalized
% by 1/(m-1), where m is the number of rows).  EC are the expansion
% coefficients (PCs in other terminology) and error is the reconstruction
% error (L2-norm).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	$Id: EOF.m,v 1.3 2003/06/01 22:20:23 dmk Exp $	
%
% Copyright (C) 2001 David M. Kaplan
% Licence: GPL (Gnu Public License)
% Source: https://pmc.ucsc.edu/~dmk/notes/EOFs/EOFs.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
  n = 'all';
end

if nargin < 3
  norm = 0==1;
end

s = size(U);
ss = min(s);

% Normalize by standard deviation if desired.
if norm
  norms = std(U);
else
  norms = ones([1,s(2)]);
end
U = U * diag(1./norms);

% Do SVD
if (ischar(n) & n == 'all') | n >= ss
  % Use svd in case we want all EOFs - quicker.
  [ C, lambda, EOFs ] = svd( full(U) ); 
else
  % Otherwise use svds.
  [ C, lambda, EOFs, flag ] = svds( U, n, varargin{:} );
  
  if flag % Case where things did not converge - probably an error.
    warning( 'HFRC_utility - Eigenvalues did not seem to converge!!!' );
  end
  
end

% Compute EC's and L
EC = C * lambda; % Expansion coefficients.
L = diag( lambda ) .^ 2 / (s(1)-1); % eigenvalues.

% Compute error.
diff=(U-EC*EOFs');
error=sqrt( sum( diff .* conj(diff) ) );

