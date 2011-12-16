function B=burstiness_B(ievs,startpoint)

if nargin<2 || isempty(startpoint)
  startpoint=min(ievs);
  %startpoint=binsize;
  %warning('bursts:burstiness_B:startpoint','No startpoint provided: %g will be used.',startpoint)
end

if ~isempty(ievs)
  ievs=ievs-startpoint;
  if any(ievs)
    B=(std(ievs)-mean(ievs))/(std(ievs)+mean(ievs));
  else
    B=-1;
  end
else
  B=NaN;
end

end