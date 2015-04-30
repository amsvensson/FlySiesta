function y=weibull_pdf(x,k,lambda)
% Calculate the Weibull Probability Density Function with scale LAMBDA and shape
% K, at points in X. K and LAMBDA must be either scalars or same size vectors.
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


% Control Input
if all(size(k)>1) || all(size(lambda)>1) || (length(k)>1 && length(lambda)>1 && length(k)~=length(lambda))
  error('bursts:weibull_pdf','Input Parameters K and LAMBDA must be either scalars or vectors of the same size.')
end

if find(size(k)>1)==2
  k=k';
  if isscalar(lambda)
    lambda=lambda*ones(size(k));
  end
end

if find(size(lambda)>1)==2
  lambda=lambda';
  if isscalar(k)
    k=k*ones(size(lambda));
  end
end

if find(size(x)>1)==1
  x=x';
end

if ~isscalar(k)
  k=repmat(k,[1 length(x)]);
end

if ~isscalar(lambda)
  lambda=repmat(lambda,[1 length(x)]);
end

if ~isscalar(x)
  x=repmat(x,[length(k) 1]);
end

% Calculate
y=(k./lambda) .* (x./lambda).^(k-1) .* exp( -(x./lambda).^k );

% Weibull PDF defined as 0 for values < 0.
y(x<0)=0;
  
end
