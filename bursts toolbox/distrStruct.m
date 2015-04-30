function STRUCT=distrStruct(nrIndvs)
% Returns STRUCT structure for use in the FlySiesta analysis suit. STRUCT is the
% underlying unit of each DISTR(ev,per). Requires input NRINDVS, stating the 
% number of individuals the STRUCT should be created for.
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

STRUCT=struct('Eps',[],'matrix',[],'startpoint',[],'minEps',[],'histogram',[],'survival_histogram',[],'okindex',[], ...
    'sumEps',NaN(1,nrIndvs), ...
     'nrEps',NaN(1,nrIndvs), ...
   'meanEps',NaN(1,nrIndvs), ...
         'F',NaN(1,nrIndvs), ...
         'B',NaN(1,nrIndvs), ...
        'wB',struct('k',NaN(1,nrIndvs),'lambda',NaN(1,nrIndvs),'rsquare',NaN(3,nrIndvs),'okfit',[]), ...
       'wnl',struct('k',NaN(1,nrIndvs),'lambda',NaN(1,nrIndvs),'rsquare',NaN(3,nrIndvs),'okfit',[],'counter',NaN(1,nrIndvs)), ...
      'wlin',struct('k',NaN(1,nrIndvs),'lambda',NaN(1,nrIndvs),'rsquare',NaN(3,nrIndvs),'okfit',[]), ...
         'M',NaN(1,nrIndvs), ...
         'DFA',NaN(1,nrIndvs), ...
         'weibull_pdf',@(x,k,lambda)((repmat(k./lambda,[size(x,1) 1]).*(x*(1./lambda)).^repmat(k-1,[size(x,1) 1])).*exp(-(x*(1./lambda)).^repmat(k,[size(x,1),1]))), ...
         'weibull_survival',@(x,k,lambda)(-(x*(1./lambda)).^repmat(k,[size(x,1) 1])), ...
         'weibull_lin',@(x,k,lambda)(x*k-repmat(k.*log(lambda),[size(x,1) 1])) ...
         );
STRUCT.Eps=cell(1,nrIndvs);
end