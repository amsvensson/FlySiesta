function version=fsabout(instr)
% FSABOUT Information About FlySiesta Version and Creator.
% Pressing the information icon (i) or "About" menu item in any of the 
% FlySiesta Applications will open up the About window.
%
% Copyright (C) 2007-2015 Amanda Sorribes, Universidad Autonoma de Madrid, and
%                         Consejo Superior de Investigaciones Cientificas (CSIC).
% 
% This file is part of "FlySiesta" analysis program. FlySiesta is free 
% software: you can redistribute it and/or modify it under the terms of 
% the GNU General Public License as published by the Free Software 
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

version='1.01';

if nargin==0
  figurePosition=getpixelposition(gcf);
  Options.WindowStyle='non-modal';
  Options.Interpreter='tex';
  Title='{\fontsize{13}\bf{FlySiesta}}';
  Version=['{\fontsize{8}version: ' version '}'];
  Copyright1='Copyright \copyright 2007-2010 Amanda Sorribes, ';
  Copyright2='Universidad Autonoma de Madrid, and';
  Copyright3='Consejo Superior de Investigaciones Cientificas.';
  License1='This program is free software, you are welcome to redistribute';
  License2='it under the GNU GPL terms (version 3 or later). It comes with  ';
  License3='ABSOLUTELY NO WARRANTY; for details see "LICENSE.txt" ';
  License4='or http://www.gnu.org/licenses/gpl.txt.  ';
  Contact='More Info:';
  Homepage='http://www.neural-circuits.org/flysiesta';
  Email='{\fontsize{8}amanda@neural-circuits.org}';
  h_about=msgbox({Title Version '' Copyright1 Copyright2 Copyright3 '' License1 License2 License3 License4 '' Contact Homepage Email ''},'About','help',Options);
  dlgPosition=getpixelposition(h_about);
  setpixelposition(h_about,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
end
end