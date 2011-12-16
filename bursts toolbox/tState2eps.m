function [eps,start_eps]=tState2eps(tState)
% 


% Validate Input

nIn = nargin;
if nIn < 1
    error('MATLAB:ISMEMBER:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 1
    error('MATLAB:ISMEMBER:TooManyInputs', 'Too many input arguments.');
end

[r,c]=size(tState);
if r>1 && c>1
  error('BurstsToolbox:tState2eps:TooLargeDimension','Input must be a row or column vector.');
end

if ~isempty(tState)
  
  % Append opposite values at edges to also find initial and final events
  tState=[logical(tState(1)) ~logical(tState) logical(tState(end))];
  
  % Diff to find state transitions and calculate events
  diffmat=diff(tState);
  start_eps=find(diffmat(1:end-1)==-1);
  end_eps=find(diffmat(2:end)==1);
  eps=end_eps-start_eps+1;
  
else
  eps=[];
  start_eps=[];
end

end