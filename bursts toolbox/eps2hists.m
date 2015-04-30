function [histogram,survival_histogram]=eps2hists(Eps,mintime,binsize)
% Calculate probability density distribution in HISTOGRAM and survival
% distribution in SURVIVAL_HISTOGRAM, from Episodes EPS. Optional input 
% argument MINTIME defines the shortest possible episode duration, while BINSIZE
% controls the used binsize used for the time vector. Default values for mintime,
% if not provided, is the smallest Eps, while default for binsize is the minimum
% difference (larger than zero) found between episodes in Eps.
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


if ~isempty(Eps)
  
  if ~iscell(Eps)
    if all(size(Eps)>1)
      error('bursts:eps2hists:InputDimensions','Valid input are 1 dimensional cell array or numerical vector.')
    elseif all(size(Eps)==1)
      % Input is scalar.
      if Eps >= mintime
        Eps={Eps};
      else
        error('bursts:eps2hists:ScalarInput','Valid input are 1 dimensional cell array or numerical vector.')
      end
    else
      % OK, input is a row or column vector.
      Eps={Eps};
    end
  end
  
  if nargin<3 || isempty(binsize)
    binsize = min(diff(unique(Eps)));
    binsize = max(binsize,max(Eps)/1000);
    %warning('bursts:eps2hists:binsize','No binsize provided: %g will be used.',binsize)
  end
  if nargin<2 || isempty(mintime)
    mintime = min(Eps);
    %mintime = binsize;
    %warning('bursts:eps2hists:mintime','No minimum episode duration was provided: %g will be used.',mintime)
  end
  
  maxEps=cellfun(@max,Eps);
  x = mintime : binsize : max(maxEps);
  histogram = NaN(length(x),length(Eps));
  survival_histogram = NaN(length(x),length(Eps));
  
  for i=1:length(Eps)
    imax=sum(x<=maxEps(i));
    histogram(1:imax,i) = hist(Eps{i},x(1:imax));
    histogram(:,i) = histogram(:,i) / sum(histogram(1:imax,i));
    survival_histogram(imax:-1:1,i) = cumsum(histogram(imax:-1:1,i));
  end
  
else
  % Empty input -> empty output
  histogram=[];
  survival_histogram=[];
end

end