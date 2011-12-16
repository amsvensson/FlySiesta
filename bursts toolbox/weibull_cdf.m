function y=weibull_cdf(x,k,lambda)
% Calculate the Weibull Cumulative Density Function with scale LAMBDA and shape
% K, at points in X. K and LAMBDA must be either scalars or same size vectors.

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
y=1-exp(-(x./lambda).^k);
 
end
