function [ievs,start_ievs]=tState2ievs(tState)
% Calculates INTER-EVENT INTERVALS durations from STATE VECTOR. The state vector
% contains number of "counts" per constant abritrary time unit interval, and 
% returns the duration - in time units - of all the continuos ZERO state
% episodes.
%
% Copyright (C) 2007-2015 Amanda Sorribes, Universidad Autonoma de Madrid, and
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
% Contact: amanda@amsorribes.com
%
% Please Acknowledge:
% If you publish or present results that are based, or have made use of 
% any part of the program, please acknowledge FlySiesta and cite:
%
%   A Sorribes, BG Armendariz, D Lopez-Pigozzi, C Murga, GG de Polavieja 
%   'The Origin of Behavioral Bursts in Decision-Making Circuitry'. 
%   PLoS Comp. Biol. 7(6): e1002075 (2011)
%
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
if all([r,c]>1)
  error('BurstsToolbox:tState2ievs:TooLargeDimension','Input must be a row or column vector.');
end

if ~isempty(tState)
  
  % Append opposite values at edges to also find initial and final events
  tState=[~logical(tState(1)) logical(tState) ~logical(tState(end))];
  
  % Diff to find state transitions and calculate events
  diffmat=diff(tState);
  start_ievs=find(diffmat(1:end-1)==-1);
  end_ievs=find(diffmat(2:end)==1);
  ievs=end_ievs-start_ievs+1;
  
else
  ievs=[];
  start_ievs=[];
end

end