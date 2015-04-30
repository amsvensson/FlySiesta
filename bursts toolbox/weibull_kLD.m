function [k,lambda,r2,D,logL,CvM,Area,EMD]=weibull_kLD(ievs,mintime,binsize)%,xmin)
% Calculate the Weibull Linear Fit (least square error) parameters LAMBDA (scale)
% and K (shape), from the inter-event intervals in IEVS. Optional input 
% argument MINTIME defines the shortest possible IEVs duration, while BINSIZE
% controls the used binsize used for the time vector. Default values for mintime,
% if not provided, is the smallest IEVs, while default for binsize is the minimum
% difference (larger than zero) found between episodes in IEVs.
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


if ~isempty(ievs) && length(ievs)>=3
  if nargin<3 || isempty(binsize)
    binsize=min(diff(unique(ievs)));
    binsize=max(binsize,max(ievs)/1000);
    %warning('bursts:weibull:binsize','No binsize provided: %g will be used.',binsize)
  end
  if nargin<2 || isempty(mintime)
    mintime=min(ievs);
    %mintime=binsize;
    %warning('bursts:weibull:mintime','No minimum possible duration provided: %g will be used.',mintime)
  end
  ievs=ievs-mintime;
  
  % Calculate histogram
  %x=unique(ievs)';
  x=[0:binsize:max(ievs)];
  y=hist(ievs,x);
  y=y/sum(y);
  
  % Calculate surivival histogram
  x=x-binsize/2;
  x(1)=0;
  xcdf=x;
  ycdf=cumsum(y);
  y(end:-1:1)=cumsum(y(end:-1:1));
  
  % Linearize
  y(~logical(y))=NaN;
  y(x<(1-binsize))=NaN;
  y(y>0.9999)=NaN;
  y=log(-log(y));
  x(~isfinite(y))=NaN;
  x=log(x);
    
  % Calculate linear fit
  k=nansum((x-nanmean(x)).*(y-nanmean(y)))./nansum((x-nanmean(x)).^2);
  A=nanmean(y)-k.*nanmean(x);
  lambda=exp(-A./k);
  
  % Calculate R^2 Goodness-of-fit
  y_fit=x*k-k*log(lambda);
  r2= 1 - ( nansum( (y - y_fit).^2 ) / nansum( (y-nanmean(y)).^2 ) );
  
  % Calculate Kolmogorov-Smirnov distance
  yfitcdf = wblcdf(xcdf, lambda, k);
  D = max(abs(ycdf - yfitcdf));
  Area = sum(abs(ycdf - yfitcdf) * binsize);
  CvM = sum((ycdf - yfitcdf).^2 * binsize);
  
%   THRESHOLD = 3;
%   N = length(ycdf);
%   C = ones(N,N).*THRESHOLD;
%   for i = 1:N
%     for j = max([1 i-THRESHOLD+1]):min([N i+THRESHOLD-1])
%       C(i,j) = abs(i-j);
%     end
%   end
  EMD = NaN; %emd_hat_gd_metric_mex(ycdf', yfitcdf', C);
  
  
  % Calculate log-likelihood
  x = ievs;
  xmin = mintime; %now input - use xmin from powerlaw fit!
  x = x(x >= xmin);
  n = length(x);

  logL = n*log(k) - n*k*log(lambda) - n*(xmin/lambda)^k + (k-1)*sum(log(x)) - sum((x/lambda).^k);
  
else
  k=NaN;
  lambda=NaN;
  r2=NaN;
  D=NaN;
end

end
