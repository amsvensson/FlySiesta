function M=memory_M(ievs,dim)
% Calculate short-term memory M as the correlation coefficient of consecutive
% ievs (inter-event intervals).
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


if isempty(ievs)
  M=NaN;
else
  if nargin<2
    dim=1;
  end
  if length(size(ievs))>2
    error('bursts:memory_M','Input matrices cannot be of dimensions greater than 2.');
  end
  if ~isscalar(dim) || ~any(dim==[1 2])
    error('bursts:memory_M','Dimension must be either 1 or 2.');
  end
  if dim==2
    ievs=ievs';
  end
  if ~isfloat(ievs)
    ievs=double(ievs);
  end
  
  N=size(ievs,1);
  M=1/(N-1) * sum( ...
    ((ievs(1:end-1,:)-repmat(mean(ievs(1:end-1,:),1),[N-1,1])) .* (ievs(2:end,:)-repmat(mean(ievs(2:end,:),1),[N-1,1]))) ./ ...
    (repmat(std(ievs(1:end-1,:),0,1),[N-1,1]) .* repmat(std(ievs(2:end,:),0,1),[N-1,1])) ...
                  );
  if dim==2
    M=M';
  end
end

end
