function varargout = fscolors(varargin)
% FSCOLORS Select Colors for FlySiesta Explorer and FlySiesta Viewer.
% Must be called from within FS Explorer or Viewer.
%
% Copyright (C) 2007-2010 Amanda Sorribes, Universidad Autonoma de Madrid, and
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
% Contact:
% http://www.neural-circuits.org/flysiesta
% http://groups.google.com/group/flysiesta
% amanda@neural-circuits.org
%
% Please Acknowledge:
% If you publish or present results that are based, or have made use of 
% any part of the program, please acknowledge FlySiesta and cite:
% "A Sorribes, BG Armendariz, D Lopez-Pigozzi, C Murga & GG de Polavieja,
% The Origin of Behavioral Bursts in Decision-Making Circuitry (Submitted)." 
% Please see the FlySiesta homepage for updated reference. 
% Suggestions of improvements or corrections are gratefully received.
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fscolors_OpeningFcn, ...
                   'gui_OutputFcn',  @fscolors_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

function fscolors_OpeningFcn(hObject, eventdata, handles, varargin)
figurePosition=getpixelposition(varargin{1});
dlgPosition=getpixelposition(hObject);
setpixelposition(hObject,[figurePosition(1)+0.2*figurePosition(3) figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
set(findobj(hObject,'BackgroundColor',get(get(hObject,'Children'),'BackgroundColor')),'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'))

handles.Style=getappdata(varargin{1},'style');
handles.csize=[15 26];
guidata(hObject, handles);

colorboxes(handles)

uiwait(handles.figure);
end

function varargout = fscolors_OutputFcn(hObject, eventdata, handles) 
varargout{1}=handles.Style;
delete(handles.figure);
end

function file1_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.DuoColor(1,:),'File 1');
handles.Style.DuoColor(1,:)=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end
function file2_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.DuoColor(2,:),'File 2');
handles.Style.DuoColor(2,:)=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end

function ttest_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.Stars.Ttest.Color,'t-test');
handles.Style.Stars.Ttest.Color=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end
function kstest_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.Stars.KStest.Color,'KS-test');
handles.Style.Stars.KStest.Color=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end
function nodiff_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.Stars.NotSignf.Color,'Not Significantly Different');
handles.Style.Stars.NotSignf.Color=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end

function lightperiod_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.PeriodColor(1,:),'Light Period Background');
handles.Style.PeriodColor(1,:)=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end
function darkperiod_Callback(hObject, eventdata, handles)
c=uisetcolor(handles.Style.PeriodColor(2,:),'Dark Period Background');
handles.Style.PeriodColor(2,:)=c;
set(hObject,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
guidata(hObject,handles);
end

function setdefault_Callback(hObject, eventdata, handles)
MyStyle=handles.Style;
save('-mat','-append',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'],'MyStyle')
end
function restore_Callback(hObject, eventdata, handles)
load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'],'AmiStyle')
handles.Style=AmiStyle;
guidata(hObject, handles);
colorboxes(handles)
end

function ok_Callback(hObject, eventdata, handles)
uiresume(handles.figure)
end
function cancel_Callback(hObject, eventdata, handles)
handles.Style=[];
guidata(hObject,handles)
uiresume(handles.figure)
end
function figure_CloseRequestFcn(hObject, eventdata, handles)
handles.Style=[];
guidata(hObject,handles)
uiresume(handles.figure)
end

function colorboxes(handles)
% Data
c=handles.Style.DuoColor(1,:);
 set(handles.file1,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
c=handles.Style.DuoColor(2,:);
 set(handles.file2,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))

% Stat-stars
c=handles.Style.Stars.Ttest.Color;
 set(handles.ttest,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
c=handles.Style.Stars.KStest.Color;
 set(handles.kstest,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
c=handles.Style.Stars.NotSignf.Color;
set(handles.nodiff,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))

% Background Colors
c=handles.Style.PeriodColor(1,:);
 set(handles.lightperiod,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
c=handles.Style.PeriodColor(2,:);
 set(handles.darkperiod,'CData',cat(3,c(1)*ones(handles.csize),c(2)*ones(handles.csize),c(3)*ones(handles.csize)))
end
