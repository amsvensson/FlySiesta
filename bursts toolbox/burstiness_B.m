function B=burstiness_B(ievs,mintime)
% Calculate the burstiness B of the time-intervals IEVS, with minimum possible
% durations MINTIME. Usually the shortest minimum duration of an inter-event 
% interval is the sampling bin durations. If MINTIME is not provided, the 
% smallest/shortest inter-event-interval will be used.
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



if nargin<2 || isempty(mintime)
  mintime=min(ievs);
  %mintime=binsize;
  %warning('bursts:burstiness_B:mintime','No mintime provided: %g will be used.',mintime)
end

if ~isempty(ievs)
  ievs=ievs-mintime;
  if any(ievs)
    B=(std(ievs)-mean(ievs))/(std(ievs)+mean(ievs));
  else
    B=-1;
  end
else
  B=NaN;
end

end