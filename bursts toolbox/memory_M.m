function M=memM(ievs,dim)

if isempty(ievs)
  M=NaN;
else
  if nargin<2
    dim=1;
  end
  if length(size(ievs))>2
    error('memM','Input matrices cannot be of dimensions greater than 2.');
  end
  if ~isscalar(dim) || ~any(dim==[1 2])
    error('memM','Dimension must be either 1 or 2.');
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
