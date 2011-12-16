function [k,lambda,xcdf]=weibull_kL(ievs,startpoint,binsize)

if ~isempty(ievs)
  if nargin<3 || isempty(binsize)
    binsize=min(diff(unique(ievs)));
    binsize=max(binsize,max(ievs)/1000);
    %warning('bursts:weibull:binsize','No binsize provided: %g will be used.',binsize)
  end
  if nargin<2 || isempty(startpoint)
    startpoint=min(ievs);
    %startpoint=binsize;
    %warning('bursts:weibull:startpoint','No startpoint provided: %g will be used.',startpoint)
  end
  ievs=ievs-startpoint;
  
  % Calculate histogram
  %x=unique(ievs)';
  x=[0:binsize:max(ievs)];
  y=hist(ievs,x);
  y=y/sum(y);
  
  % Calculate surivival histogram
  x=x-binsize/2;
  x(1)=0;
  y(end:-1:1)=cumsum(y(end:-1:1));
  xcdf=x;
  
  % Plot Survival Histogram
  %plot(x,y,'.-','Color',rand(1,3))
  
  % Linearize
  y(~logical(y))=NaN;
  y(y>0.9999)=NaN;
  y=log(-log(y));
  x(~isfinite(y))=NaN;
  x=log(x);
  
  % Calculate linear fit
  k=nansum((x-nanmean(x)).*(y-nanmean(y)))./nansum((x-nanmean(x)).^2);
  A=nanmean(y)-k.*nanmean(x);
  lambda=exp(-A./k);
  
else
  k=NaN;
  lambda=NaN;
  xcdf=[];
end

end
