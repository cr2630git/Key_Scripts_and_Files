function [rowcorrtoindex,colcorrtoindex] = myind2sub(matrixrows,givenindex)
%Surrogate for Matlab's native ind2sub function which doesn't appear to be working in my copy of R2014a
%   The functionality is the same, however

rowcorrtoindex=rem(givenindex,matrixrows);if rowcorrtoindex==0;rowcorrtoindex=matrixrows;end
colcorrtoindex=round2(givenindex/matrixrows,1,'ceil');


end

