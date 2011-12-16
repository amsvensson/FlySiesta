function [eps,start_eps]=tState2eps(tState)
% Calculates EPISODE durations from STATE VECTOR. The state vector contains
% number of "counts" per constant abritrary time unit interval, and returns the
% duration - in time units - of all the continuos NON-ZERO state episodes.
%
% Copyright (C) 2007-2012 Amanda Sorribes, Universidad Autonoma de Madrid, and
%                         Consejo Superior de Investigaciones Cientificas (CSIC).
% 
% This file is part of the "Bursts Toolbox" of the "FlySiesta" analysis program.
% FlySiesta is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software 
% Foundation, either version 3 of the License, or any later version 
% (http://www.gnu.org/licenses/gpl.txt).
% 
% FlySiesta is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
% General Public License for more details.
%
% Contact:
% http://www.neural-circuits.org/flysiesta
% http://groups.google.com/group/flysiesta
% amanda@neural-circuits.org
%
% Please Acknowledge:
% If you publish or present results that are based, or have made use of 
% any part of the program, please acknowledge FlySiesta and cite:
%
%   A Sorribes, BG Armendariz, D Lopez-Pigozzi, C Murga, GG de Polavieja 
%   'The Origin of Behavioral Bursts in Decision-Making Circuitry'. 
%   PLoS Comp. Biol. 7(6): e1002075 (2011)
%
% Please see the FlySiesta homepage for updated reference. 
% Suggestions of improvements or corrections are gratefully received.
%


% Validate Input

nIn = nargin;
if nIn < 1
    error('MATLAB:ISMEMBER:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 1
    error('MATLAB:ISMEMBER:TooManyInputs', 'Too many input arguments.');
end

[r,c]=size(tState);
if r>1 && c>1
  error('BurstsToolbox:tState2eps:TooLargeDimension','Input must be a row or column vector.');
end

if ~isempty(tState)
  
  % Append opposite values at edges to also find initial and final events
  tState=[logical(tState(1)) ~logical(tState) logical(tState(end))];
  
  % Diff to find state transitions and calculate events
  diffmat=diff(tState);
  start_eps=find(diffmat(1:end-1)==-1);
  end_eps=find(diffmat(2:end)==1);
  eps=end_eps-start_eps+1;
  
else
  eps=[];
  start_eps=[];
end

end