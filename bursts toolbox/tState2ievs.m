function [ievs,start_ievs]=tState2ievs(tState)
% 

% Validate Input

nIn = nargin;
if nIn < 1
    error('MATLAB:ISMEMBER:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 1
    error('MATLAB:ISMEMBER:TooManyInputs', 'Too many input arguments.');
end

[r,c]=size(tState);
if all([r,c]>1)
  error('BurstsToolbox:tState2ievs:TooLargeDimension','Input must be a row or column vector.');
end

if ~isempty(tState)
  
  % Append opposite values at edges to also find initial and final events
  tState=[~logical(tState(1)) logical(tState) ~logical(tState(end))];
  
  % Diff to find state transitions and calculate events
  diffmat=diff(tState);
  start_ievs=find(diffmat(1:end-1)==-1);
  end_ievs=find(diffmat(2:end)==1);
  ievs=end_ievs-start_ievs+1;
  
else
  ievs=[];
  start_ievs=[];
end

end