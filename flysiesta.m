function flysiesta
% FlySiesta - Analysis Program for Drosophila Activity and Sleep Data.
% Opens up FlySiesta Welcome Center, from where the FlySiesta Applications
% can be launched. Intended for use with DAMS recordings.
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

%%% Create GUI %%%
FlySiesta_version=fsabout('version');
outerbg=[0.75 0.78 0.92];
innerbg=[0.82 0.85 1];
titlecolor=[0.15 0.15 0.7];
textcolor=[0 0 0.3];
handles.figure=figure('Name','FlySiesta','NumberTitle','off','IntegerHandle','off','UserData',FlySiesta_version,'Color',outerbg,...
                        'MenuBar','none','ToolBar','none','Position',[150,200,670,440],'Resize','off','Visible','off');
handles.welcome1=uicontrol('Style','text','HorizontalAlignment','left','String','Welcome to', ...
                           'FontSize',18,'FontWeight','bold','FontAngle','italic','Background',outerbg, ...
                           'ForegroundColor',titlecolor,'Units','pixels','Position',[25 400 200 30]);
handles.welcome2=uicontrol('Style','text','HorizontalAlignment','left','String','FlySiesta', ...
                           'FontSize',26,'FontWeight','bold','FontAngle','italic','Background',outerbg, ...
                           'ForegroundColor',titlecolor,'Units','pixels','Position',[75 350 200 40]);

handles.preparepanel=uipanel('BackgroundColor',innerbg,'BorderType','beveledout','Units','pixels','Position',[15 70 310 240]);
handles.preparetext=uicontrol('Style','text','HorizontalAlignment','left','String','Prepare Data', ...
                           'FontSize',14,'FontWeight','normal','FontAngle','italic','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 200 270 30],'Parent',handles.preparepanel);
handles.analyzertext=uicontrol('Style','text','HorizontalAlignment','center','String',{'Create and analyze' 'FlySiesta files from' 'DAMS recordings'}, ...
                           'FontSize',9,'FontWeight','normal','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 127 145 46],'Parent',handles.preparepanel);
handles.poolertext=uicontrol('Style','text','HorizontalAlignment','center','String',{'Pool multiple FlySiesta' 'files into one single file,' 'that can be used for' 'further analysis'}, ...
                           'FontSize',9,'FontWeight','normal','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 30 145 60],'Parent',handles.preparepanel);
handles.analyzerbutton=uicontrol('Style','pushbutton','String','Analyzer','Callback',{@fsrun}, ...
                           'FontSize',12,'FontWeight','bold','Tooltip','Open FlySiesta Analyzer','UserData','fsanalyzer', ...
                           'Units','pixels','Position',[175 120 120 60],'Parent',handles.preparepanel);
handles.poolerbutton=uicontrol('Style','pushbutton','String','Pooler','Callback',{@fsrun}, ...
                           'FontSize',12,'FontWeight','bold','Tooltip','Open FlySiesta Pooler','UserData','fspooler', ...
                           'Units','pixels','Position',[175 30 120 60],'Parent',handles.preparepanel);

handles.visualizepanel=uipanel('BackgroundColor',innerbg,'BorderType','beveledout','Units','pixels','Position',[345 30 310 330]);
handles.vizualizetext=uicontrol('Style','text','HorizontalAlignment','left','String','Visualize Data', ...
                           'FontSize',14,'FontWeight','normal','FontAngle','italic','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 290 270 30],'Parent',handles.visualizepanel);
handles.explorertext=uicontrol('Style','text','HorizontalAlignment','center','String',{'Explore interactively' 'event-time distributions' 'and ''burst parameters''' 'of two FlySiesta files'}, ...
                           'FontSize',9,'FontWeight','normal','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 210 145 60],'Parent',handles.visualizepanel);
handles.viewertext=uicontrol('Style','text','HorizontalAlignment','center','String',{'View interactively patterns' 'and event parameters of' 'two FlySiesta files, and' 'perform statistical tests'}, ...
                           'FontSize',9,'FontWeight','normal','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 120 145 60],'Parent',handles.visualizepanel);
handles.viewertext=uicontrol('Style','text','HorizontalAlignment','center','String',{'Comparative overview' 'of all parameters of' 'multiple FlySiesta files,' 'with statistical tests'}, ...
                           'FontSize',9,'FontWeight','normal','Background',innerbg, ...
                           'ForegroundColor',textcolor,'Units','pixels','Position',[10 30 145 60],'Parent',handles.visualizepanel);
handles.explorerbutton=uicontrol('Style','pushbutton','String','Explorer','Callback',{@fsrun}, ...
                           'FontSize',12,'FontWeight','bold','Tooltip','Open FlySiesta Explorer','UserData','fsexplorer', ...
                           'Units','pixels','Position',[175 210 120 60],'Parent',handles.visualizepanel);
handles.viewerbutton=uicontrol('Style','pushbutton','String','Viewer','Callback',{@fsrun}, ...
                           'FontSize',12,'FontWeight','bold','Tooltip','Open FlySiesta Viewer','UserData','fsviewer', ...
                           'Units','pixels','Position',[175 120 120 60],'Parent',handles.visualizepanel);
handles.comparerbutton=uicontrol('Style','pushbutton','String','Comparer','Callback',{@fsrun}, ...
                           'FontSize',12,'FontWeight','bold','Tooltip','Open FlySiesta Comparer','UserData','fscomparer', ...
                           'Units','pixels','Position',[175 30 120 60],'Parent',handles.visualizepanel);


help_mine=[];
about_mine=[];
try load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsaux' filesep 'fsinit.dat'],'help_mine','about_mine')
  handles.help=uicontrol('Style','radiobutton','CData',help_mine,'Callback',{@help_Callback},'Background',outerbg, ...
                           'Tooltip','Online User Guide','Units','pixels','Position',[25 15 20 20]);
  handles.about=uicontrol('Style','radiobutton','CData',about_mine,'Callback',{@about_Callback},'Background',outerbg, ...
                           'Tooltip','About','Units','pixels','Position',[55 15 20 20]);
end
%%% Initialize GUI %%%
addpath(fullfile(fileparts(mfilename('fullpath')),'fsaux'))
movegui(handles.figure,'center')
set(handles.figure,'Visible','on')


% Callback functions
  function fsrun(source,event)
    set(findobj(handles.figure,'Style','pushbutton'),'Enable','inactive')
    fsapplication=get(source,'UserData');
    delete(handles.figure)
    eval(fsapplication)
  end

  function help_Callback(source,eventdata)
    stat=web('http://www.neural-circuits.org/flysiesta/userguide/','-browser');
    if logical(stat)
      web('http://www.neural-circuits.org/flysiesta/userguide/')
    end
  end
  function about_Callback(source,eventdata)
    fsabout;
  end

end