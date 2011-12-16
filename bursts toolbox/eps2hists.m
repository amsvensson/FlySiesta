function [histogram,survival_histogram]=eps2hists(Eps,startpoint,binsize)

if ~isempty(Eps)
  
  if ~iscell(Eps)
    if all(size(Eps)>1)
      error('bursts:eps2hists:InputDimensions','Valid input are 1 dimensional cell array or numerical vector.')
    elseif all(size(Eps)==1)
      % Input is scalar.
      if Eps >= startpoint
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
  if nargin<2 || isempty(startpoint)
    startpoint = min(Eps);
    %startpoint = binsize;
    %warning('bursts:eps2hists:startpoint','No startpoint provided: %g will be used.',startpoint)
  end
  
  maxEps=cellfun(@max,Eps);
  x = startpoint : binsize : max(maxEps);
  histogram = NaN(length(x),length(Eps));
  survival_histogram = NaN(length(x),length(Eps));
  
  for i=1:length(Eps)
    imax=sum(x<=maxEps(i));
    histogram(1:imax,i) = hist(Eps{i},x(1:imax));
    histogram(:,i) = histogram(:,i) / nansum(histogram(:,i));
    survival_histogram(imax:-1:1,i) = cumsum(histogram(imax:-1:1,i));
  end
  
else
  % Empty input -> empty output
  histogram=[];
  survival_histogram=[];
end

end