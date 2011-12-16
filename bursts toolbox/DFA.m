function Alpha=DFA(IEVs,doplot)

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
