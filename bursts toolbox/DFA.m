function Alpha=DFA(IEVs,doplot)
% Calculate Detrended Fluctuation Analysis ALPHA parameter from
% inter-event-intervals IVES. As a second optional argument TRUE or FALSE can be
% passed, to control whether to plot the straight line fit to the detrended 
% integrated time series. Default is FALSE.
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


minnr=1;
minsize=5;
if length(IEVs)>=minsize
  allwins=floor(length(IEVs)./[minnr:floor(length(IEVs)/minsize)]);
  [n,ni]=unique(allwins);
  N=n.*ni;
  notin=length(IEVs)-N;

  F_n=NaN(1,length(n));
  for i=1:length(n)
    fn=NaN(notin(i)+1,1);
    for offset=0:notin(i);
      % Integrate Time Series
      x=repmat([1:n(i)]',[1,ni(i)]);
      y=reshape(cumsum(IEVs([1:N(i)]+offset))' - cumsum(mean(IEVs([1:N(i)]+offset))*ones(1,N(i))),[n(i),ni(i)]);

      % Fit Straight Line in Window
      k=sum( (x-repmat(mean(x),[n(i),1])) .* (y-repmat(mean(y),[n(i),1])) )./sum( (x-repmat(mean(x),[n(i),1])).^2 );
      m=mean(y) - k .* mean(x);

      % Detrend Integrated Time Series
      Yn=repmat(k,[n(i),1]) .* x + repmat(m,[n(i),1]);
      fn(offset+1)=sqrt(sum((y(:)-Yn(:)).^2)/N(i));
    end
    F_n(i)=mean(fn,1);
  end

  % Fit Straight Line in log-log to obtain Power-Law Exponent
  xlog=log(n(1:sum(~isnan(F_n))));
  ylog=log(F_n(1:sum(~isnan(F_n))));
  Alpha=sum( (xlog-mean(xlog)) .* (ylog-mean(ylog)) ) ./ sum( (xlog-mean(xlog)).^2 );

if nargin > 1
  if islogical(doplot) && doplot || (ischar(doplot) && strcmp(doplot,'plot'))
    figure
    plot(log(n),log(F_n),'Color',rand(3,1),'Marker','o');
    xlabel('n')
    ylabel('F(n)')
    pause
  end
end

else
  Alpha=NaN;
end

end
