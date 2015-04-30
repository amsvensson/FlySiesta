function varargout = fsviewer(varargin)
% FlySiesta Viewer - Visualize activity and sleep parameters and
% perform statistical tests. Requires FlySiesta files, previously 
% created with FlySiesta Analyzer.
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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fsviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @fsviewer_OutputFcn, ...
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
function varargout = fsviewer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end

function fsviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% Version 
FlySiesta_version=fsabout('version');

% Tweak initiation
set(handles.figure,'Name','FlySiesta Viewer','UserData',FlySiesta_version)
 handles.tab=1;
 set(handles.name1,'Value',0)                                              % File loaded or not
 set(handles.name2,'Value',0)                                              % File loaded or not
 set(handles.file_load,'UserData',true)                                    % Plot DarkBoxes (Files have same light cycle)
 set(handles.plotviewpanel,'UserData',rand(1,2))                           % Unique dataset plot identification
 set(handles.flylist1,'Value',[],'String','')
 set(handles.flylist2,'Value',[],'String','')
 set(handles.tabpanel,'UserData',[false false])                            % If Stat-test stars have been plotted in [patterns bar-tabs]
set(handles.activitymenu,'Value',2,'UserData',false)                       % If activity menu has been changed -- only update activity parameters
 set(handles.stattest,'UserData',false)                                    % If stat-test has *just* been performed, and stars need to be plotted
 set(handles.statopts,'UserData','off')                                    % Default Visibility of p-values
 set(handles.settings_statopts,'UserData',NaN)                             % Tolerance level for outliers, in standard deviations
 set(handles.textalpha,'String','a','FontName','symbol','FontSize',11)     % Symbol to recieve Greek letters
set(handles.name1,'Enable','inactive')                                     % To activate ButtonDownFcn
 set(handles.name2,'Enable','inactive')                                    % To activate ButtonDownFcn
 set(handles.about,'Enable','inactive')                                    % To activate ButtonDownFcn
 set(handles.settings_timeaxis,'Enable','off')                             % Turn off circadian x-labelling if no dataset has been loaded
 set(handles.menu_tools,'Enable','off')                                    % Turn off Tools if no dataset has been loaded
warning('off','MATLAB:divideByZero')
movegui(handles.figure,'center')
 set(findobj(handles.figure,'HandleVisibility','on'),'HandleVisibility','callback')
 set(findobj(handles.figure,'Units','pixels','-or','Units','normalized'),'Units','characters')
 set(findobj(handles.figure,'Type','axes'),'Units','normalized')

% Load Button Icons & Get Style-structure for Plots
try 
  load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'])
end
set(handles.stattest,'ToolTip','Start Statistical Test','CData',stattest_play_star)
set(handles.color,'ToolTip','Change Colors','CData',color_swatch)
set(handles.copytoclipboard,'ToolTip','Copy Figure to Clipboard','CData',copy_figure)
set(handles.openaxes,'ToolTip','Select Axes to Open in a New Window','CData',openaxes_square)
set(handles.zoom,'ToolTip','Zoom','CData',magnify)
set(handles.female1,'ToolTip','Select all Female flies','CData',female)
set(handles.male1,'ToolTip','Select all Male flies','CData',male)
set(handles.female2,'ToolTip','Select all Female flies','CData',female)
set(handles.male2,'ToolTip','Select all Male flies','CData',male)
set(handles.name1,'ForegroundColor',MyStyle.DuoColor(1,:),'String','')
set(handles.name2,'ForegroundColor',MyStyle.DuoColor(2,:),'String','')

% Prepare Axes
 % Patterns
  set(handles.spatterns_full,'UserData',30.01);
  set(handles.apatterns_full,'UserData',[1 30.01 1 1]);
  for axis_handle=[handles.apatterns_full handles.apatterns_day handles.spatterns_full handles.spatterns_day]
    set(get(axis_handle,'XLabel'),'String','ZT','FontSize',7);
  end
  set(axis_handle,'Color',MyStyle.PeriodColor(1,:))
  ylabel_activity='Active minutes / 30 mins';
  ylabel_sleep='Sleep minutes / 30 mins';
  set([get(handles.apatterns_full,'YLabel') get(handles.apatterns_day,'YLabel')],'FontSize',8,'String',ylabel_activity);
  set([get(handles.spatterns_full,'YLabel') get(handles.spatterns_day,'YLabel')],'FontSize',8,'String',ylabel_sleep);
  set([handles.apatterns_full handles.apatterns_day handles.spatterns_full handles.spatterns_day],'XTick',[],'YTick',[],'Box','on')
  title(handles.apatterns_full,'Activity Profile, Full Analysis Period','FontSize',8)
  title(handles.apatterns_day,'Mean Activity Profile','FontSize',8)
  title(handles.spatterns_full,'Sleep Profile, Full Analysis Period','FontSize',8)
  title(handles.spatterns_day,'Mean Sleep Profile','FontSize',8)
  set(handles.settings_zt,'Checked','on')
 % Bar Graphs
  handles.tot=[handles.al_tot handles.ad_tot ; handles.sl_tot handles.sd_tot ; handles.iail_tot handles.iaid_tot ; handles.isil_tot handles.isid_tot];
  handles.num=[handles.al_num handles.ad_num ; handles.sl_num handles.sd_num ; handles.iail_num handles.iaid_num ; handles.isil_num handles.isid_num];
  handles.dur=[handles.al_dur handles.ad_dur ; handles.sl_dur handles.sd_dur ; handles.iail_dur handles.iaid_dur ; handles.isil_dur handles.isid_dur];
  handles.bar_axes=cat(3,handles.tot,handles.num,handles.dur);
  set(handles.bar_axes,'NextPlot','add','XLim',[0.2 2.8],'XTick',[1 2],'XTickLabel','','YTick',[],'Box','on','TickLength',[0.006 0.025])
  eventstr={'Activity Bouts' 'Sleep Bouts' 'IAIs' 'ISIs'};
  periodstr={' (Light)' ' (Dark)'};
  for ev=1:4
    for per=1:2
      title(handles.tot(ev,per),['Totals for ' eventstr{ev} periodstr{per}],'FontSize',8)
       set(get(handles.tot(ev,per),'YLabel'),'FontSize',8,'String','Minutes / Period');
      title(handles.num(ev,per),['Number of ' eventstr{ev} periodstr{per}],'FontSize',8)
       set(get(handles.num(ev,per),'YLabel'),'FontSize',8,'String','Number / Period');
      title(handles.dur(ev,per),['Durations of ' eventstr{ev} periodstr{per}],'FontSize',8)
       set(get(handles.dur(ev,per),'YLabel'),'FontSize',8,'String','Mean Duration (min)');
    end
  end
  set([handles.tot(:,1) handles.num(:,1) handles.dur(:,1)],'Color',MyStyle.PeriodColor(1,:))
  set([handles.tot(:,2) handles.num(:,2) handles.dur(:,2)],'Color',MyStyle.PeriodColor(2,:))

% Assure tabpanel works properly
TabPanel=get(handles.TBP_tabpanel,'UserData');
TabPanel.Filename='fsviewer.fig';
TabPanel.Color{1}=get(0,'defaultUicontrolBackgroundColor');
TabPanel.Count=5;
TabPanel.Tab=[TabPanel.Tab handles.iaitab handles.isitab];
TabPanel.Panel=[TabPanel.Panel handles.iaipanel handles.isipanel];
set(handles.TBP_tabpanel,'UserData',TabPanel)

% Create structures
 events=4;
 periods=2; % Light & Dark
 datasets=2;
 FD(1:events)=struct('events',events,'days',zeros(1,datasets),'hourscycle',zeros(periods,datasets),'hoursperiod',zeros(periods,datasets), ...
      'full',struct('means',[],'sems',[],'ttest',[],'kstest',[]), ...
       'day',struct('means',NaN(48,datasets),'sems',NaN(48,datasets),'ttest',NaN(48,2),'kstest',NaN(48,2)), ...
     'total',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
       'num',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
       'dur',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
         'B',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
         'M',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
       'knl',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
      'klin',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
       'lnl',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
      'llin',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
       'rnl',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods)), ...
      'rlin',struct('means',NaN(periods,datasets),'sems',NaN(periods,datasets),'ttest',NaN(2,periods),'kstest',NaN(2,periods))  );
 MX(1:events)=struct('full',[],'day',[],'total',[],'num',[],'dur',[],'B',[],'M',[],'knl',[],'klin',[],'lnl',[],'llin',[],'rnl',[],'rlin',[]);
 field=fieldnames(MX);
 type=ones(length(MX),length(field));
 type(1,1:3)=4;
 for ev=1:events
   for f=1:length(field)
     MX(ev).(field{f})=cell(2,type(ev,f));
   end
 end

% Save Init Data
setappdata(handles.figure,'style',MyStyle)
setappdata(handles.figure,'figuredata',FD)
setappdata(handles.figure,'matrices',MX)
handles.output = hObject;  % Choose default command line output for fsviewer
guidata(hObject, handles);  % Update handles structure
end

function figure_ResizeFcn(hObject, eventdata, handles)
%{
fPos=getpixelposition(handles.figure);
% Plot View Panel
pwPos=getpixelposition(handles.plotviewpanel);
setpixelposition(handles.plotviewpanel,[pwPos(1) fPos(4)-pwPos(4) pwPos(3:4)])
% Fly Panel
flyPos=getpixelposition(handles.flypanel);
newh=fPos(4)-pwPos(4)-5;
flyKids=get(handles.flypanel,'Children');
flyResizeObjs=findobj(flyKids,'Style','listbox','-or','Type','uipanel');
flyMoveObjs=setdiff(flyKids,flyResizeObjs);
setpixelposition(handles.flypanel,[flyPos(1) flyPos(2) flyPos(3) newh])
for i=1:length(flyMoveObjs)
  setpixelposition(flyMoveObjs(i),getpixelposition(flyMoveObjs(i))+[0 newh-flyPos(4) 0 0])
end
for i=1:length(flyResizeObjs)
  setpixelposition(flyResizeObjs(i),getpixelposition(flyResizeObjs(i))+[0 0 0 newh-flyPos(4)])
end
%}
%{
%%% Not working! %%% Set figure Resize to off!
TabPanel=get(handles.TBP_tabpanel,'UserData');
% Tabs
tabs=[TabPanel.TopTab];% handles.patternstab handles.activitytab handles.sleeptab handles.iaitab handles.isitab];
for i=1:length(tabs)
  tabPos=getpixelposition(tabs(i));
  setpixelposition(tabs(i),tabPos+[0 fPos(4)-tabPos(4) 0 0]);
end
% Tab Panels
tabpanels=[TabPanel.TopPanel];% handles.patternspanel handles.activitypanel handles.sleeppanel handles.iaipanel handles.isipanel];
for i=1:length(tabpanels)
  set(tabpanels(i),'Units','pixels')
  panelPos=getpixelposition(tabpanels(i));
  setpixelposition(tabpanels(i),panelPos+[0 fPos(4)-panelPos(4) 0 0]);
end
TabPanel.Size=[fPos(3)-flyPos(3)-7 fPos(4)-2];
set(handles.TBP_tabpanel,'UserData',TabPanel)
%}
end


%% Create Functions %%
function activitymenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function statopts_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function groupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function flylist1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function flylist2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%% Menu Toolbar %%
% File
function menu_file_Callback(hObject, eventdata, handles)
end
function file_load_Callback(hObject, eventdata, handles)
for dataset=1:2
  [FSfile,FSpath]=uigetfile('*.mat',sprintf('Select File %d',dataset));
  if ~isequal(FSfile,0)
    load([FSpath FSfile]);
    setappdata(handles.figure,sprintf('exp%d',dataset),EXPDATA)
    setappdata(handles.figure,sprintf('distr%d',dataset),DISTR)
    set(handles.(sprintf('name%d',dataset)),'Value',1,'String',EXPDATA.name)
    set(handles.(sprintf('all%d',dataset)),'UserData',EXPDATA.matrix_index{1})
    set(handles.(sprintf('female%d',dataset)),'UserData',EXPDATA.matrix_index{2})
    set(handles.(sprintf('male%d',dataset)),'UserData',EXPDATA.matrix_index{3})
    set(handles.(sprintf('flylist%d',dataset)),'UserData',EXPDATA.id_index,'Value',[],'Min',min(EXPDATA.matrix_index{1}),'Max',max(EXPDATA.matrix_index{1}),'String',fly_string(EXPDATA.matrix_index{1},EXPDATA.id_index))
    compare_load_files(handles)
    all_Callback=[sprintf('all%d',dataset) '_Callback(handles.' sprintf('all%d',dataset) ',[],handles)'];
    eval(all_Callback)
  end
end
end
function file_saveall_Callback(hObject, eventdata, handles)
[FileName,PathName]=uiputfile('*.fig','Save Entire Figure As');
if FileName~=0
  saveas(gca,[PathName FileName],'fig')
end
end
function file_print_Callback(hObject, eventdata, handles)
printpreview(handles.figure)
end
function file_exit_Callback(hObject, eventdata, handles)
close(handles.figure)
end

function compare_load_files(handles)
if xor(logical(get(handles.name1,'Value')),logical(get(handles.name2,'Value')))
  if logical(get(handles.name1,'Value'))
    EXPDATA=getappdata(handles.figure,'exp1');
    dataset=1;
  end
  if logical(get(handles.name2,'Value'))
    EXPDATA=getappdata(handles.figure,'exp2');
    dataset=2;
  end
  FD=getappdata(handles.figure,'figuredata');
  darkh=EXPDATA.lights(2)-EXPDATA.lights(1);
  if darkh<0; darkh=24+darkh; end
  fields={'full' 'day' 'total'};
  firstdim=[EXPDATA.days*24*2 24*2 2];
  thirddim=ones(1,FD(1).events);
  thirddim(1)=4;
  for ev=1:FD(1).events
    for f=1:length(fields)
      FD(ev).(fields{f}).means=NaN(firstdim(f),2,thirddim(ev));
      FD(ev).(fields{f}).sems=NaN(firstdim(f),2,thirddim(ev));
      FD(ev).(fields{f}).ttest=NaN(firstdim(f),2,thirddim(ev));
      FD(ev).(fields{f}).kstest=NaN(firstdim(f),2,thirddim(ev));
    end
    FD(ev).days(dataset)=EXPDATA.days;
    FD(ev).hourscycle(dataset,:)=[24-darkh darkh];
  end

  setappdata(handles.figure,'figuredata',FD)

  % Pattern Axes & Background
   set(handles.settings_timeaxis,'Enable','on')
  % ZT
   ZT.full.XLim=[0 EXPDATA.days*24*2];
   ZT.full.XTick=2*[0:6:EXPDATA.days*24];
   ZT.full.XTickLabel=[0 6 12 18];
   ZT.day.XLim=[0 24*2];
   ZT.day.XTick=2*[0:2:24];
   ZT.day.XTickLabel=[0:2:22];
   set(handles.settings_zt,'UserData',[0:23])
  % CT
   zthours=[0:23 0:23];
   cthours=[zthours(EXPDATA.lights(1)+1:end) 0:zthours(EXPDATA.lights(1)+1)];
   CT=ZT;
   CT.full.XTickLabel=cthours(1:6:24);
   CT.day.XTickLabel=cthours(1:2:24);
   set(handles.settings_ct,'UserData',cthours(1:24))
   set([handles.apatterns_full handles.spatterns_full],'YTickMode','auto',ZT.full,'XMinorTick','on','Layer','top','NextPlot','add')
   set([handles.apatterns_day handles.spatterns_day],'YTickMode','auto',ZT.day,'Layer','top','NextPlot','add')
  patterns_background([1 2],handles)
  
  % Turn on Tools Menu
   set(handles.menu_tools,'Enable','on')
end

if logical(get(handles.name1,'Value')) && logical(get(handles.name2,'Value'))
  EXP1=getappdata(handles.figure,'exp1');
  EXP2=getappdata(handles.figure,'exp2');
  FD=getappdata(handles.figure,'figuredata');

  darkh1=EXP1.lights(2)-EXP1.lights(1);
  if darkh1<0; darkh1=24+darkh1; end
  darkh2=EXP2.lights(2)-EXP2.lights(1);
  if darkh2<0; darkh2=24+darkh2; end
  if darkh1~=darkh2
    set(handles.file_load,'UserData','false')
    for handle_axes=[handles.apatterns_full handles.spatterns_full handles.apatterns_day handles.spatterns_day]
      cla(handle_axes)
    end
    h_dlg=warndlg({'The loaded FlySiesta data files'' '; 'light cycles are different!'},'Warning: Analysis Period');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_dlg)
    set(handles.settings_ct,'Enable','off')
  end

  for ev=1:FD(1).events
    FD(ev).days=[EXP1.days EXP2.days];
    FD(ev).hourscycle=[24-darkh1 darkh1; 24-darkh2 darkh2];
  end
  setappdata(handles.figure,'figuredata',FD)

  if EXP1.days~=EXP2.days
    hours_full=max(EXP1.days,EXP2.days)*24;
    h_dlg=warndlg({'The loaded FlySiesta data files have '; 'different number of days of analysis!'},'Warning: Analysis Period');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_dlg)
    old_hours_full=size(FD(2).full.means,1)/2;
    if hours_full>old_hours_full
      fields={'means' 'sems' 'ttest' 'kstest'};
      firstdim=(hours_full-old_hours_full)*2;
      thirddim=ones(1,FD(1).events);
      thirddim(1)=4;
      for ev=1:FD(1).events
        for f=1:length(fields)
          FD(ev).full.(fields{f})=cat(1,FD(ev).full.(fields{f}),NaN(firstdim,2,thirddim(ev)));
        end
      end
      setappdata(handles.figure,'figuredata',FD)
      set([handles.apatterns_full handles.spatterns_full],'XLim',[0 max(FD(1).days)*24*2],'XTick',2*[0:6:max(FD(1).days)*24],'XTickLabel',[repmat([0 6 12 18],1,max(FD(1).days)) 0])
    end
    patterns_background([1 2],handles)
  elseif (EXP1.days==EXP2.days) && (EXP1.days*24*2<size(FD(1).full.means,1))
    fields={'means' 'sems' 'ttest' 'kstest'};
    for ev=1:FD(1).events
      for f=1:length(fields)
        FD(ev).full.(fields{f})=FD(ev).full.(fields{f})(1:EXP1.days*24*2,:,:);
      end
    end
    setappdata(handles.figure,'figuredata',FD)
    set([handles.apatterns_full handles.spatterns_full],'XLim',[0 max(FD(1).days)*24*2],'XTick',2*[0:6:max(FD(1).days)*24],'XTickLabel',[repmat([0 6 12 18],1,max(FD(1).days)) 0])
  end
  
  % Recalculate maximums for y-axes
  ymax_s=30.01;
  ymax_a=max(squeeze(max(FD(1).full.means,[],1)),[],1);
  ymax_a=ymax_a*1.25;
  ymax_a(2)=ymax_s;
  set(handles.spatterns_full,'UserData',ymax_s);
  set(handles.apatterns_full,'UserData',ymax_a);
end

set([handles.tot handles.num handles.dur],'YTickMode','auto','XTickLabel',{get(handles.name1,'String') get(handles.name2,'String')})
end
function string=fly_string(matrix_index,id_index)
string=cell(length(matrix_index),1);
for i=1:length(string)
  string{i}=num2str(id_index(matrix_index(i)));
end
end

% Settings
function menu_settings_Callback(hObject, eventdata, handles)
end
function settings_timeaxis_Callback(hObject, eventdata, handles)
end
function settings_zt_Callback(hObject, eventdata, handles)
hours=get(hObject,'UserData');
set([handles.apatterns_full handles.spatterns_full],'XTickLabel',hours(1:6:end))
set([handles.apatterns_day handles.spatterns_day],'XTickLabel',hours(1:2:end))
for axis_handle=[handles.apatterns_full handles.apatterns_day handles.spatterns_full handles.spatterns_day]
  set(get(axis_handle,'XLabel'),'String','ZT');
end
set(hObject,'Checked','on')
set(handles.settings_ct,'Checked','off')
end
function settings_ct_Callback(hObject, eventdata, handles)
hours=get(hObject,'UserData');
set([handles.apatterns_full handles.spatterns_full],'XTickLabel',hours(1:6:end))
set([handles.apatterns_day handles.spatterns_day],'XTickLabel',hours(1:2:end))
for axis_handle=[handles.apatterns_full handles.apatterns_day handles.spatterns_full handles.spatterns_day]
  set(get(axis_handle,'XLabel'),'String','CT');
end
set(hObject,'Checked','on')
set(handles.settings_zt,'Checked','off')
end
function settings_statopts_Callback(hObject, eventdata, handles)
prompt={'Set significance level \alpha:' ...
        'Set tolerance level for outliers in standar deviations (e.g. 3, or NaN to disable exclusion of outliers):' ...
        'Set default Visibility for statistical test p-value (on/off):'};
defaultanswer={get(handles.statopts,'String'),num2str(get(hObject,'UserData')),get(handles.statopts,'UserData')};
options.Interpreter='tex';
answer=inputdlg(prompt,'Options for statistical test',1,defaultanswer,options);
if ~isempty(answer)
  set(handles.statopts,'String',answer{1})
  set(hObject,'UserData',str2double(answer{2}))
  if any(strcmp({'on' 'off'},answer{3}))
    set(handles.statopts,'UserData',answer{3})
  end
end
end
function settings_colors_Callback(hObject, eventdata, handles)
Style=fscolors(handles.figure);
if ~isempty(Style)
  setappdata(handles.figure,'style',Style)
 % replot everything
  set(handles.name1,'ForegroundColor',Style.DuoColor(1,:))
  set(handles.name2,'ForegroundColor',Style.DuoColor(2,:))
  lightaxes=[handles.apatterns_full ; handles.apatterns_day ; handles.spatterns_full ; handles.spatterns_day ; ...
             handles.tot(:,1) ; handles.num(:,1) ; handles.dur(:,1)] ;
  darkaxes= [handles.tot(:,2) ; handles.num(:,2) ; handles.dur(:,2)] ;
  set(lightaxes,'Color',Style.PeriodColor(1,:))
  set(darkaxes,'Color',Style.PeriodColor(2,:))
  darkbox=findobj(handles.spatterns_day,'Tag','DarkBox');
  if ~isempty(darkbox); patterns_background([1 2],handles); end
  if logical(get(handles.name1,'Value')); plot_patterns(1,handles); end
  if logical(get(handles.name2,'Value')); plot_patterns(2,handles); end
  if get(handles.stattest,'UserData'); plot_starpatterns(handles); end
  if logical(get(handles.name1,'Value')); plot_bars(1,handles); end
  if logical(get(handles.name2,'Value')); plot_bars(2,handles); end
  if get(handles.stattest,'UserData'); plot_starbars(handles); end
  if ~isempty(get(handles.apatterns_full,'UserData'))
    ymax_a=get(handles.apatterns_full,'UserData');
    set([handles.apatterns_full handles.apatterns_day],'YLim',[0 ymax_a(get(handles.activitymenu,'Value'))])
  end
  if ~isempty(get(handles.spatterns_full,'UserData'))
    set([handles.spatterns_full handles.spatterns_day],'YLim',[0 get(handles.spatterns_full,'UserData')])
  end
end
end

% Tools
function menu_tools_Callback(hObject, eventdata, handles)
end
function tools_stattest_Callback(hObject, eventdata, handles)
if logical(get(handles.name1,'Value')) && logical(get(handles.name2,'Value'))
  set(handles.figure,'Pointer','watch')
  set(handles.stattest,'UserData',true)
  if handles.tab==1
    calc_starpatterns(handles)
    plot_patterns(1,handles)
    plot_patterns(2,handles)
    plot_starpatterns(handles)
  else
    calc_starbars(handles)
    plot_bars(1,handles)
    plot_bars(2,handles)
    plot_starbars(handles)
  end
  set(handles.figure,'Pointer','arrow')
end
end
function tools_copyclipboard_Callback(hObject, eventdata, handles)
print -dbitmap
end
function tools_openaxes_Callback(hObject, eventdata, handles)
set(handles.figure,'Pointer','cross')
figurePosition=getpixelposition(gcf);
inputtype=waitforbuttonpress;
while inputtype~=0
  inputtype=waitforbuttonpress;
end
selected_axes=gca;
hf=figure('Name',get(get(selected_axes,'Title'),'String'),'NumberTitle','off','IntegerHandle','off');
tempaxes=axes;
new_axes=copyobj(selected_axes,hf);
set(new_axes,'Units',get(tempaxes,'Units'),'Position',get(tempaxes,'Position'))
delete(tempaxes)
fPosition=getpixelposition(hf);
setpixelposition(hf,[figurePosition(1)+(figurePosition(3)-fPosition(3))/2 figurePosition(2)+(figurePosition(4)-fPosition(4))/2 fPosition(3:4)])
set(hf,'HandleVisibility','callback')
darkboxes=findobj(hf,'Tag','DarkBox');
if ~isempty(darkboxes)
  for i=1:length(darkboxes)
    set(get(get(darkboxes(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end
errorshades=findobj(hf,'Tag','ErrorShade');
if ~isempty(darkboxes)
  for i=1:length(errorshades)
    set(get(get(errorshades(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end
p_star=findobj(hf,'-regexp','Tag','Star_p');
tstars=findobj(hf,'Tag','tStar');
if ~isempty(tstars)
  for i=1:length(tstars)-1
    set(get(get(tstars(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
  set(tstars(end),'DisplayName','t-test','UserData',p_star)
end
ksstars=findobj(hf,'Tag','ksStar');
if ~isempty(ksstars)
  for i=1:length(ksstars)-1
    set(get(get(ksstars(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
  set(ksstars(end),'DisplayName','KS-test','UserData',p_star)
end
nostars=findobj(hf,'Tag','noStar');
if ~isempty(nostars)
  for i=1:length(nostars)
    set(get(get(nostars(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
  if max(size(nostars))==1
    set(get(get(nostars,'Annotation'),'LegendInformation'),'IconDisplayStyle','on')
    set(nostars(end),'DisplayName','Not Sign. Different','UserData',p_star)
  end
end
starlines=findobj(hf,'-regexp','Tag','StarLine');
if ~isempty(starlines)
  for i=1:length(starlines)
    set(get(get(starlines(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end
hl=legend(new_axes,'show');
set(hl,'Interpreter','none')
set(handles.figure,'Pointer','arrow')
end
function tools_opentab_Callback(hObject, eventdata, handles)
figurePosition=getpixelposition(handles.figure);
TabPanel=get(handles.TBP_tabpanel,'UserData');
selected_tabobjs=get(TabPanel.Panel(handles.tab),'Children');
tabPosition=getpixelposition(TabPanel.Panel(handles.tab));
f=figure('Name',[get(TabPanel.Tab(handles.tab),'String') '  ( ' get(handles.name1,'String') ' , ' get(handles.name2,'String') ' )'] ,'NumberTitle','off','IntegerHandle','off','HandleVisibility','callback');
fPosition=getpixelposition(f);
set(f,'Position',[figurePosition(1:2) tabPosition(3:4)]);
new_tabobjs=copyobj(selected_tabobjs,f);
new_axes=get(f,'Children');
for i=1:length(new_axes)
  star_p=findobj(new_axes(i),'-regexp','Tag','Star_p');
  set(findobj(new_axes(i),'Tag','tStar','-or','Tag','ksStar','-or','Tag','noStar'),'UserData',star_p);
end
set(new_tabobjs,'Units','normalized')
set(f,'Position',[figurePosition(1:2) fPosition(3:4)]);
end
function tools_openoverview_Callback(hObject, eventdata, handles)
set(handles.activitymenu,'Value',2)
activitymenu_Callback(handles.activitymenu,eventdata,handles)
figurePosition=getpixelposition(handles.figure);
f=figure('Name',['Overview of Bargraphs  ( ' get(handles.name1,'String') ' , ' get(handles.name2,'String') ' )'],'NumberTitle','off','IntegerHandle','off','HandleVisibility','callback','Position',[figurePosition(1:2) 920 600]);
fPosition=getpixelposition(f);
TabPanel=get(handles.TBP_tabpanel,'UserData');
selected_axes=get(TabPanel.Panel(2:end),'Children');
tabtitle={'Activity' 'Sleep' 'IAIs' 'ISIs'};
w=100;
h=140;
mid=fPosition(3)/2;
xi=[0 0 0 w w w];
xpos=45+[xi ; mid+xi ; 2*w+xi ; mid+2*w+xi];
ypos=30+[400 200 0 400 200 0];
new_axes=zeros(length(selected_axes),6);
ymax=zeros(length(selected_axes),6);
for tab=length(selected_axes):-1:1
  selected_axes{tab}=selected_axes{tab}(end:-1:1);
  for i=6:-1:1
    new_axes(tab,i)=copyobj(selected_axes{tab}(i),f);
    set(new_axes(tab,i),'Units','pixels','Position',[xpos(tab,i) ypos(i) w h])
    title(new_axes(tab,i),tabtitle{tab})
    ymax(tab,i)=max(get(new_axes(tab,i),'YLim'));
    if any(tab==[3 4]) || any(i==[4 5 6])
      set(new_axes(tab,i),'YTickLabel','')
    end
  end
end
set(new_axes(:),'Units','normalized')
switch get(handles.statopts,'UserData')
  case 'on'; p_state=1;
  otherwise, p_state=0;
end
for i=1:3
  set(new_axes(:,[0+i 3+i]),'YLim',[0 max(max(ymax(:,[0+i 3+i])))])
  statobjs=findobj(new_axes(:,[0+i 3+i]),'-regexp','Tag','Star','-and','Type','line');
  ystarsmax=0.95*max(max(ymax(:,[0+i 3+i])));
  for o=1:length(statobjs)
    ydata=get(statobjs(o),'YData');
    ydata=ydata+20.*(1-ydata./ystarsmax)+p_state*0.05*ystarsmax;
    if ~isscalar(ydata) && min(ydata)<max(ydata)
      ydata=[max(ydata)-0.02*ystarsmax max(ydata)];
    end
    set(statobjs(o),'YData',ydata,'HandleVisibility','off')
  end
  statps=findobj(new_axes(:,[0+i 3+i]),'-regexp','Tag','Star_p');
  for p=1:length(statps)
    pos=get(statps(p),'Position');
    pos(2)=pos(2)/0.94 + 20.*(1-pos(2)./ystarsmax)-p_state*0.025*ystarsmax;
    set(statps(p),'Position',pos,'HandleVisibility','off','Visible',get(handles.statopts,'UserData'))
  end
end
set(findobj(f,'Type','hggroup'),'HandleVisibility','off')
end
function tools_burstiness_Callback(hObject, eventdata, handles)
FD=getappdata(handles.figure,'figuredata');
MX=getappdata(handles.figure,'matrices');
Style=getappdata(handles.figure,'style');
dataid=get(handles.plotviewpanel,'UserData');
light=1; dark=2;
ev=handles.tab-1;
if ~logical(ev)
  return
end

% Create Figure and Axes
fields={'B' 'klin' 'knl' 'llin' 'lnl' 'rlin' 'rnl' 'M'};
for f=1:length(fields)
  h.(fields{f})=NaN(1,2);
end
eventstr={'Activity' 'Sleep' 'IAIs' 'ISIs'};
titlestr={'B' 'k lin' 'k non-lin' '\lambda lin' '\lambda non-lin' 'R^2 lin' 'R^2 non-lin' 'M'};
titlecolor=[0 0 0; repmat([Style.Fits(3).Color; Style.Fits(2).Color],[3,1]); 0 0 0];
axw=105; axh=150; space=30;
fw=6*space+8*axw-space/2; fh=3*space+2*axh;
fsviewerPosition=getpixelposition(handles.figure);
h.figure=figure('Name',[eventstr{ev} ' Burst Parameters  ( ' get(handles.name1,'String') ' , ' get(handles.name2,'String') ' )'],'NumberTitle','off','IntegerHandle','off','HandleVisibility','callback','Position',[fsviewerPosition(1)+(fsviewerPosition(3)-fw)/2 fsviewerPosition(2)+(fsviewerPosition(4)-fh)/2 fw fh]);
align([handles.figure h.figure],'center','center');
xPos=space+[0 space+axw space+2*axw 2*space+3*axw 2*space+4*axw 3*space+5*axw 3*space+6*axw 4*space+7*axw];
yPos=0.75*space+[fh/2 0];
for per=light:dark
  for f=1:length(fields)
    h.(fields{f})(per)=axes('Parent',h.figure,'Units','pixels','Position',[xPos(f) yPos(per) axw axh],'FontSize',7,'Color',Style.PeriodColor(per,:),'NextPlot','add');
    title(h.(fields{f})(per),titlestr{f},'FontSize',8,'FontWeight','bold','Color',titlecolor(f,:))
    if any(f==[3 5 7])
      set(h.(fields{f})(per),'YTickLabel','')
    end
    if any(f==[2 3])
      line([0.2 2.8],[1 1],'Parent',h.(fields{f})(per),'Color',[0.5 0.5 0.5],'LineStyle',':')
    end
    if any(f==[6 7])
      line([0.2 2.8],[1 1],'Parent',h.(fields{f})(per),'Color',[0.1 0.1 0.1],'LineStyle',':')
    end
  end
end
set(findobj(h.figure,'Type','axes'),'Units','normalized','XLim',[0.2 2.8],'XTick',[1 2],'XTickLabel',{get(handles.name1,'String') get(handles.name2,'String')},'Box','on','TickLength',[0.006 0.025])

% Plot Bars
x=[1 2];
for per=light:dark
  for f=1:length(fields)
    for dataset=1:2
      y=FD(ev).(fields{f}).means(per,dataset);
      ysem=FD(ev).(fields{f}).sems(per,dataset);
      barerrorbar(y,ysem,h.(fields{f})(per))
    end
  end
  line([0.2 2.8],[0 0],'Parent',h.B(per),'Color',[0.5 0.5 0.5],'LineStyle',':')
  if ~get(handles.stattest,'UserData')
    set([h.klin(per) h.knl(per)],'YLim',[0 max(max( [get(h.klin(per),'YLim') get(h.knl(per),'YLim') ] ))])
    set([h.llin(per) h.lnl(per)],'YLim',[0 max(max( [get(h.llin(per),'YLim') get(h.lnl(per),'YLim')] ))])
    set([h.rlin(per) h.rnl(per)],'YLim',[0 1.005])
  end
end

  function barerrorbar(y,ysem,axishandle)
    hb=bar(x(dataset),y,'Parent',axishandle,'UserData',dataid(dataset));
      set(hb,'FaceColor',Style.DuoColor(dataset,:),Style.Viewer.Bars)
    he=errorbar(x(dataset),y,ysem,'Parent',axishandle,'UserData',dataid(dataset));
      set(he,Style.Viewer.BarsError)
    ylim(axishandle,'auto')
    if ~isnan(y)
      text('Position',[x(dataset),0],'String',sprintf('%1.2f',y),'Parent',axishandle,'UserData',dataid(dataset), ...
           'FontSize',7,'Color','k','HorizontalAlignment','center','VerticalAlignment','bottom') %'FontName','FixedWidth',
    end
  end

%%% Perform Stat-test, if activated %%%
if get(handles.stattest,'UserData')
 % Calculate Stat-test
  for f=1:length(fields)
    [FD(ev).(fields{f}).means FD(ev).(fields{f}).sems FD(ev).(fields{f}).ttest FD(ev).(fields{f}).kstest step] = stattest_pairs(MX(ev).(fields{f})(:,:),handles,0,0);
  end
 % Plot Stat-test Results
  for per=light:dark
    for f=1:length(fields)
      if isfinite(FD(ev).(fields{f}).ttest(per,1))
        if logical(FD(ev).(fields{f}).ttest(per,1))
          y=1.15*max(FD(ev).(fields{f}).means(per,:) + FD(ev).(fields{f}).sems(per,:));
          hp=text('Position',[1.5 0.94*y],'Tag','tStar_p','Parent',h.(fields{f})(per),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).ttest(per,2)),'FontSize',7,'Color',[0 0 0],'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','tStar','Parent',h.(fields{f})(per),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.Ttest)
          plot_starlines(h.(fields{f})(per),y,'tStarLine')
          set(h.(fields{f})(per),'YLim',[0 1.1*y])
        else
          y=1.15*max(FD(ev).(fields{f}).means(per,:) + FD(ev).(fields{f}).sems(per,:));
          hp=text('Position',[1.5 0.94*y],'Tag','noStar_p','Parent',h.(fields{f})(per),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).ttest(per,2)),'FontSize',7,'Color',Style.Stars.NotSignf.Color,'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','noStar','Parent',h.(fields{f})(per),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.NotSignf)
          set(h.(fields{f})(per),'YLim',[0 1.1*max(get(h.(fields{f})(per),'YLim'))])
        end
      elseif isfinite(FD(ev).(fields{f}).kstest(per,1))
        if logical(FD(ev).(fields{f}).kstest(per,1))
          y=1.1*max(FD(ev).(fields{f}).means(per,:) + FD(ev).(fields{f}).sems(per,:));
          hp=text('Position',[1.5 0.94*y],'Tag','ksStar_p','Parent',h.(fields{f})(per),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).kstest(per,2)),'FontSize',7,'Color',[0 0 0],'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','ksStar','Parent',h.(fields{f})(per),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.KStest)
          plot_starlines(h.(fields{f})(per),y,'ksStarLine')
          set(h.(fields{f})(per),'YLim',[0 1.1*y])
        else
          y=1.15*max(FD(ev).(fields{f}).means(per,:) + FD(ev).(fields{f}).sems(per,:));
          hp=text('Position',[1.5 0.94*y],'Tag','noStar_p','Parent',h.(fields{f})(per),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).kstest(per,2)),'FontSize',7,'Color',Style.Stars.NotSignf.Color,'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','noStar','Parent',h.(fields{f})(per),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.NotSignf)
          set(h.(fields{f})(per),'YLim',[0 1.1*max(get(h.(fields{f})(per),'YLim'))])
        end
      end
    end
    set([h.klin(per) h.knl(per)],'YLim',[0 max(max( [get(h.klin(per),'YLim') get(h.knl(per),'YLim') 1.05] ))])
    set([h.llin(per) h.lnl(per)],'YLim',[0 max(max( [get(h.llin(per),'YLim') get(h.lnl(per),'YLim')] ))])
    set([h.rlin(per) h.rnl(per)],'YLim',[0 max([1.05*y 1.005])])
  end
end

set(findobj(h.figure,'Type','line','-or','Type','hggroup','-or','Type','text'),'HandleVisibility','callback')
end

function tools_zoom_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
switch checked
  case 'on'
    set(hObject,'Checked','off')
    set(handles.zoom,'Value',0)
    zoom out
    set(findobj(handles.figure,'Type','axes'),'HandleVisibility','callback')
    set(handles.figure,'RendererMode','auto')
    zoom off
  case 'off'
    set(hObject,'Checked','on')
    set(handles.zoom,'Value',1)
    set(findobj(handles.figure,'Type','axes'),'HandleVisibility','on')
    set(handles.figure,'Renderer','zbuffer')
    zoom on
end
end
function tools_pan_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
switch checked
  case 'on'
    set(hObject,'Checked','off')
    pan off
    set(findobj(handles.figure,'Type','axes'),'HandleVisibility','callback')
    set(handles.figure,'RendererMode','auto')
  case 'off'
    set(hObject,'Checked','on')
    pan on
    set(findobj(handles.figure,'Type','axes'),'HandleVisibility','on')
    set(handles.figure,'Renderer','zbuffer')
end
end

% Programs
function menu_programs_Callback(hObject, eventdata, handles)
end
function programs_flysiesta_Callback(hObject, eventdata, handles)
flysiesta
end
function programs_analyzer_Callback(hObject, eventdata, handles)
fsanalyzer
end
function programs_pooler_Callback(hObject, eventdata, handles)
fspooler
end
function programs_explorer_Callback(hObject, eventdata, handles)
fsexplorer
end
function programs_viewer_Callback(hObject, eventdata, handles)
fsviewer
end
function programs_comparer_Callback(hObject, eventdata, handles)
fscomparer
end

% Help
function menu_help_Callback(hObject, eventdata, handles)
end
function help_help_Callback(hObject, eventdata, handles)
stat=web('http://www.neural-circuits.org/flysiesta/userguide/','-browser');
if logical(stat)
  web('http://www.neural-circuits.org/flysiesta/userguide/')
end
end
function help_license_Callback(hObject, eventdata, handles)
fsaux_path=mfilename('fullpath');
seps=strfind(fsaux_path,filesep);
web(['file:///' fsaux_path(1:seps(end-1)) 'LICENSE.txt'])
end
function help_about_Callback(hObject, eventdata, handles)
fsabout;
end


%% Control Panel %%
% Plot View
function activitymenu_Callback(hObject, eventdata, handles)
set(hObject,'UserData',true)
FD=getappdata(handles.figure,'figuredata');
 ymax_a=max(squeeze(max(FD(1).full.means,[],1)),[],1);
 ymax_a=ymax_a*1.25;
 ymax_a(2)=get(handles.spatterns_full,'UserData');
 set(handles.apatterns_full,'UserData',ymax_a);
update_activityplots(handles)
patterns_background(1,handles)
if get(handles.stattest,'UserData')
  plot_starpatterns(handles)
end
if get(handles.stattest,'UserData')
  plot_starbars(handles)
end
  function update_activityplots(handles)
   % Patterns
    ylabel_activity={'Counts (Beam Breaks) / 30 mins' 'Active minutes / 30 mins' 'Counts / Waking minute' 'Counts / Active minute'};
    set([get(handles.apatterns_full,'YLabel') get(handles.apatterns_day,'YLabel')],'FontSize',8,'String',ylabel_activity{get(hObject,'Value')});
    plot_patterns(1,handles)
    plot_patterns(2,handles)
   % Bars
    ylabel_total={'Counts / Period' 'Minutes / Period' 'Counts / Waking minute' 'Counts / Active minute'};
    set([get(handles.al_tot,'YLabel') get(handles.ad_tot,'YLabel')],'FontSize',8,'String',ylabel_total{get(hObject,'Value')});
    plot_bars(1,handles)
    plot_bars(2,handles)
  end
set(handles.activitymenu,'UserData',false)
end

function stattest_Callback(hObject, eventdata, handles)
tools_stattest_Callback(handles.tools_stattest, eventdata, handles)
end
function statopts_Callback(hObject, eventdata, handles)
% No Commands. This is the edit text box with the alpha value, and as UserData the std-tolerance!
end
function color_Callback(hObject, eventdata, handles)
settings_colors_Callback(handles.settings_colors, eventdata, handles)
end
function copytoclipboard_Callback(hObject, eventdata, handles)
print -dbitmap
end
function openaxes_Callback(hObject, eventdata, handles)
tools_openaxes_Callback(handles.tools_openaxes, eventdata, handles)
end
function zoom_Callback(hObject, eventdata, handles)
tools_zoom_Callback(handles.tools_zoom, eventdata, handles)
end

% Fly Selection
function name1_ButtonDownFcn(hObject,eventdata,handles)
EXPDATA=getappdata(handles.figure,'exp1');
if ~isempty(EXPDATA)
  info_box(EXPDATA)
end
end
function all1_Callback(hObject, eventdata, handles)
set(handles.flylist1,'Value',get(hObject,'UserData'))
flylist1_Callback(handles.flylist1,eventdata,handles)
end
function female1_Callback(hObject, eventdata, handles)
set(handles.flylist1,'Value',get(hObject,'UserData'))
flylist1_Callback(handles.flylist1,eventdata,handles)
end
function male1_Callback(hObject, eventdata, handles)
set(handles.flylist1,'Value',get(hObject,'UserData'))
flylist1_Callback(handles.flylist1,eventdata,handles)
end
function none1_Callback(hObject, eventdata, handles)
set(handles.flylist1,'Value',[])
dataid=get(handles.plotviewpanel,'UserData');
delete(findobj(get(handles.figure,'Children'),'UserData',dataid(1)))
delete(findobj(get(handles.figure,'Children'),'-regexp','Tag','Star'))
end
function flylist1_Callback(hObject, eventdata, handles)
load_M(get(handles.flylist1,'Value'),1,handles)
calc_data(1,handles)
if handles.tab==1
  plot_patterns(1,handles)
else
  plot_bars(1,handles)
end
end

function name2_ButtonDownFcn(hObject,eventdata,handles)
EXPDATA=getappdata(handles.figure,'exp2');
if ~isempty(EXPDATA)
  info_box(EXPDATA)
end
end
function all2_Callback(hObject, eventdata, handles)
set(handles.flylist2,'Value',get(hObject,'UserData'))
flylist2_Callback(handles.flylist2,eventdata,handles)
end
function female2_Callback(hObject, eventdata, handles)
set(handles.flylist2,'Value',get(hObject,'UserData'))
flylist2_Callback(handles.flylist2,eventdata,handles)
end
function male2_Callback(hObject, eventdata, handles)
set(handles.flylist2,'Value',get(hObject,'UserData'))
flylist2_Callback(handles.flylist2,eventdata,handles)
end
function none2_Callback(hObject, eventdata, handles)
set(handles.flylist2,'Value',[])
dataid=get(handles.plotviewpanel,'UserData');
delete(findobj(get(handles.figure,'Children'),'UserData',dataid(2)))
delete(findobj(get(handles.figure,'Children'),'-regexp','Tag','Star'))
end
function flylist2_Callback(hObject, eventdata, handles)
load_M(get(handles.flylist2,'Value'),2,handles)
calc_data(2,handles)
if handles.tab==1
  plot_patterns(2,handles)
else
  plot_bars(2,handles)
end
end

% Info
function info_box(EXPDATA)
% Name
 EXPDATA.name(char(EXPDATA.name)==95)=45;
 Name=['{\fontsize{12}\bf{' EXPDATA.name '}}'];
% Optional Info
 Genotype=['Genotype: ' EXPDATA.info{1}];
 Condition=['Condition: ' EXPDATA.info{2}];
 Description=['Description: ' EXPDATA.info{3}];
 Age=['Age at start: ' EXPDATA.info{4}];
 Temp=['Temperature: ' EXPDATA.info{5}];
 Degrees={' {\circ}C' ' {\circ}F'};
 Degrees=Degrees{find(EXPDATA.info{6}==1)};
% Analysis Info
 Days=['Days of analysis: ' num2str(EXPDATA.days)];
 Lights=['Lights on - off: ' num2str(EXPDATA.lights(1)) ' - ' num2str(EXPDATA.lights(2)) ' h'];
 LightPeriod=['Light period: ' num2str(EXPDATA.setperiods(1,1))  ' - ' num2str(EXPDATA.setperiods(1,2)) ' h'];
 DarkPeriod=['Dark period: ' num2str(EXPDATA.setperiods(2,1))  ' - ' num2str(EXPDATA.setperiods(2,2)) ' h'];
 Threshold='';
 if EXPDATA.sleep_threshold~=5
   Threshold=['Sleep Threshold: ' num2str(EXPDATA.sleep_threshold) ' mins'];
 end
 
Options.WindowStyle='non-modal';
Options.Interpreter='tex';
figurePosition=getpixelposition(gcf);
buttonPosition=getpixelposition(gcbo);
h_info=msgbox({Name '' Genotype Condition Description Age [Temp Degrees] ''  Days Lights LightPeriod DarkPeriod Threshold},'Info',Options);
dlgPosition=getpixelposition(h_info);
setpixelposition(h_info,[figurePosition(1)+buttonPosition(1)+buttonPosition(3) figurePosition(2)+buttonPosition(2)-dlgPosition(4) dlgPosition(3:4)])
end

% About
function about_ButtonDownFcn(hObject,eventdata,handles)
help_about_Callback(handles.help_about, eventdata, handles)
end


%% Tabs %%
function tabpanel_TabSelectionChange_Callback(hObject,eventdata,handles)
handles.tab=eventdata.NewValue;
guidata(handles.figure,handles)
plot_status=get(handles.tabpanel,'UserData');
if eventdata.NewValue==1
  set(handles.tools_burstiness,'Enable','off')
  set([handles.spatterns_full handles.spatterns_day],'YLim',[0 get(handles.spatterns_full,'UserData')])
  ymax_a=get(handles.apatterns_full,'UserData');
  set([handles.apatterns_full handles.apatterns_day],'YLim',[0 ymax_a(get(handles.activitymenu,'Value'))])
  if ~plot_status(1)
    plot_patterns(1,handles)
    plot_patterns(2,handles)
  end
  if get(handles.stattest,'UserData')
    plot_starpatterns(handles)
  end
else
  set(handles.tools_burstiness,'Enable','on')
  if eventdata.OldValue==1 
    if ~plot_status(2)
      plot_bars(1,handles)
      plot_bars(2,handles)
    end
    if get(handles.stattest,'UserData')
      plot_starbars(handles)
    end
  end
end
end


%% Plot Functions %%
function load_M(value,dataset,handles)
MX=getappdata(handles.figure,'matrices');
FD=getappdata(handles.figure,'figuredata');

set(handles.stattest,'UserData',false)
set(handles.tabpanel,'UserData',[false false])
delete(findobj(get(handles.figure,'Children'),'-regexp','Tag','Star'))

ab=uint8(1);
sb=uint8(2);
iai=uint8(3);
isi=uint8(4);
light=uint8(1);
dark=uint8(2);

switch dataset
  case 1
    DISTR=getappdata(handles.figure,'distr1');
    EXPDATA=getappdata(handles.figure,'exp1');
  case 2
    DISTR=getappdata(handles.figure,'distr2');
    EXPDATA=getappdata(handles.figure,'exp2');
end
activity=EXPDATA.activity(:,value);
sleep=EXPDATA.sleep(:,value);

% PATTERNS TAB
 % Activity Counts (ActivityMenu=1)
  acounts_hh_full=reshape(sum(reshape(activity,30,[]),1),EXPDATA.days*48,[]);
  acounts_hh_day=reshape(acounts_hh_full,48,length(value),EXPDATA.days);
 % Activity Minutes (ActivityMenu=2)
  amins_hh_full=reshape(sum(reshape(logical(activity),30,[]),1),EXPDATA.days*48,[]);
  amins_hh_day=reshape(amins_hh_full,48,length(value),EXPDATA.days);
 % Activity Index (ActivityMenu=3)
  wakingmins_hh_full=reshape(sum(reshape(~sleep,30,[]),1),EXPDATA.days*48,[]);
  aindex_hh_full=acounts_hh_full./wakingmins_hh_full;
  aindex_hh_full(isinf(aindex_hh_full))=NaN;
  wakingmins_hh_day=reshape(wakingmins_hh_full,48,length(value),EXPDATA.days);
  aindex_hh_day=acounts_hh_day./wakingmins_hh_day;
  aindex_hh_day(isinf(aindex_hh_day))=NaN;
 % Activity Intensity (ActivityMenu=4)
  aintensity_hh_full=acounts_hh_full./amins_hh_full;
  aintensity_hh_full(isnan(aintensity_hh_full))=0;
  aintensity_hh_day=acounts_hh_day./amins_hh_day;
  aintensity_hh_day(isnan(aintensity_hh_day))=0;
 % Sleep Minutes
  smins_hh_full=reshape(sum(reshape(sleep,30,[]),1),EXPDATA.days*48,[]);
  smins_hh_day=reshape(smins_hh_full,48,length(value),EXPDATA.days);

  MX(ab).full(dataset,:)={acounts_hh_full, amins_hh_full, aindex_hh_full, aintensity_hh_full};
  MX(ab).day(dataset,:)={mean(acounts_hh_day,3), mean(amins_hh_day,3), nanmean(aindex_hh_day,3), mean(aintensity_hh_day,3)};
  MX(sb).full{dataset}=smins_hh_full;
  MX(sb).day{dataset}=mean(smins_hh_day,3);

% EVENT TABS
 % Find Light and Dark Periods
  if isnan(EXPDATA.setperiods(1,1)); EXPDATA.setperiods(1,1)=EXPDATA.lights(1); end
  if isnan(EXPDATA.setperiods(1,2)); EXPDATA.setperiods(1,2)=EXPDATA.lights(2); end
  if isnan(EXPDATA.setperiods(2,1)); EXPDATA.setperiods(2,1)=EXPDATA.lights(2); end
  if isnan(EXPDATA.setperiods(2,2)); EXPDATA.setperiods(2,2)=EXPDATA.lights(1); end
  if EXPDATA.setperiods(1,2)>=EXPDATA.setperiods(1,1)
    hours_light=[EXPDATA.setperiods(1,1):EXPDATA.setperiods(1,2)-1];
  else
    hours_light=[EXPDATA.setperiods(1,1):24 1:EXPDATA.setperiods(1,2)-1];
  end
  if EXPDATA.setperiods(2,2)>EXPDATA.setperiods(2,1)
    hours_dark=[EXPDATA.setperiods(2,1):EXPDATA.setperiods(2,2)-1];
  else
    hours_dark=[EXPDATA.setperiods(2,1):24 1:EXPDATA.setperiods(2,2)-1];
  end
  timeindex=reshape(repmat([EXPDATA.lights(1):24 1:EXPDATA.lights(1)-1],60,1),1,1440);
  lightperiod=repmat(ismember(timeindex,hours_light)',EXPDATA.days,1);
  darkperiod=repmat(ismember(timeindex,hours_dark)',EXPDATA.days,1);
  period={lightperiod darkperiod};

 % Totals
  acounts=NaN(2,length(value));
  amins=NaN(2,length(value));
  wakemins=NaN(2,length(value));
  aindex=NaN(2,length(value));
  aint=NaN(2,length(value));
  smins=NaN(2,length(value));
  iaimins=NaN(2,length(value));
  isimins=NaN(2,length(value));
  for per=light:dark
    acounts(per,:)=sum(activity(period{per},:),1)/EXPDATA.days;
    amins(per,:)=sum(logical(activity(period{per},:)),1)/EXPDATA.days;
    wakemins(per,:)=sum(~sleep(period{per},:),1)/EXPDATA.days;
    aindex(per,:)=acounts(per,:)./wakemins(per,:);
    aint(per,:)=acounts(per,:)./amins(per,:);
    smins(per,:)=sum(sleep(period{per},:),1)/EXPDATA.days;
    iaimins(per,:)=sum(~activity(period{per},:),1)/EXPDATA.days;
    isimins(per,:)=sum(~sleep(period{per},:),1)/EXPDATA.days;
  end
  MX(ab).total(dataset,:)={acounts, amins, aindex, aint};
  MX(sb).total{dataset}=smins;
  MX(iai).total{dataset}=iaimins;
  MX(isi).total{dataset}=isimins;

 % Number and Durations of Bouts, & Burst Parameters
  num=NaN(2,length(value));
  dur=NaN(2,length(value));
  B=NaN(2,length(value));
  M=NaN(2,length(value));
  klin=NaN(2,length(value));
  knl=NaN(2,length(value));
  llin=NaN(2,length(value));
  lnl=NaN(2,length(value));
  rlin=NaN(2,length(value));
  rnl=NaN(2,length(value));
  for ev=1:FD(1).events
    FD(ev).hoursperiod=[length(hours_light) length(hours_dark)];  %(Length of SetPeriods)
    for per=light:dark
      bouts=NaN(size(EXPDATA.activity));
      bouts([DISTR(ev,per).matrix(:,2)])=DISTR(ev,per).matrix(:,1);
      num(per,:)=sum(isfinite(bouts(period{per},value)),1)/EXPDATA.days;
      dur(per,:)=nanmean(bouts(period{per},value),1);
      B(per,:)=DISTR(ev,per).B(value);
      M(per,:)=DISTR(ev,per).M(value);
      knl(per,:)=DISTR(ev,per).wnl.k(value);
      lnl(per,:)=DISTR(ev,per).wnl.lambda(value);
      rnl(per,:)=DISTR(ev,per).wnl.rsquare(2,value);
      klin(per,:)=DISTR(ev,per).wlin.k(value);
      llin(per,:)=DISTR(ev,per).wlin.lambda(value);
      rlin(per,:)=DISTR(ev,per).wlin.rsquare(3,value);
    end
    num(~logical(num))=NaN;
    MX(ev).num{dataset}=num;
    MX(ev).dur{dataset}=dur;
    MX(ev).B{dataset}=B;
    MX(ev).M{dataset}=M;
    MX(ev).knl{dataset}=knl;
    MX(ev).lnl{dataset}=lnl;
    MX(ev).rnl{dataset}=rnl;
    MX(ev).klin{dataset}=klin;
    MX(ev).llin{dataset}=llin;
    MX(ev).rlin{dataset}=rlin;
  end
  
% Save Data
setappdata(handles.figure,'matrices',MX)
setappdata(handles.figure,'figuredata',FD)
end

function calc_data(dataset,handles)
MX=getappdata(handles.figure,'matrices');
FD=getappdata(handles.figure,'figuredata');

ab=uint8(1);
sb=uint8(2);
iai=uint8(3);
isi=uint8(4);
nr_flies=size(MX(sb).total{dataset},2);
% Activity, Patterns & Totals
ev=ab;
for type=1:4
 % Full Pattern
  FD(ev).full.means(1:FD(ev).days(dataset)*48,dataset,type)=nanmean(MX(ev).full{dataset,type},2);
  FD(ev).full.sems(1:FD(ev).days(dataset)*48,dataset,type)=nanstd(MX(ev).full{dataset,type},0,2)/sqrt(nr_flies);
 % Single Day Pattern
  FD(ev).day.means(:,dataset,type)=nanmean(MX(ev).day{dataset,type},2);
  FD(ev).day.sems(:,dataset,type)=nanstd(MX(ev).day{dataset,type},0,2)/sqrt(nr_flies);
 % Totals
  FD(ev).total.means(:,dataset,type)=nanmean(MX(ev).total{dataset,type},2);
  FD(ev).total.sems(:,dataset,type)=nanstd(MX(ev).total{dataset,type},0,2)/sqrt(nr_flies);
end
% Number and Durations of Activity bouts
f={'num' 'dur'};
for i=1:2
  FD(ev).(f{i}).means(:,dataset)=nanmean(MX(ev).(f{i}){dataset},2);
  FD(ev).(f{i}).sems(:,dataset)=nanstd(MX(ev).(f{i}){dataset},0,2)/sqrt(nr_flies);
end
  
% Sleep, Patterns & Totals
ev=sb;
 % Full Pattern
  FD(ev).full.means(1:FD(ev).days(dataset)*48,dataset)=mean(MX(ev).full{dataset},2);
  FD(ev).full.sems(1:FD(ev).days(dataset)*48,dataset)=std(MX(ev).full{dataset},0,2)/sqrt(nr_flies);
 % Single Day Pattern
  FD(ev).day.means(:,dataset)=mean(MX(ev).day{dataset},2);
  FD(ev).day.sems(:,dataset)=std(MX(ev).day{dataset},0,2)/sqrt(nr_flies);
  
% Totals, Number and Durations of Bouts/IBIs, & Burst Parameters
for ev=1:FD(1).events
  f=fieldnames(MX);
  for i=3:length(f)
    FD(ev).(f{i}).means(:,dataset)=nanmean(MX(ev).(f{i}){dataset},2);
    FD(ev).(f{i}).sems(:,dataset)=nanstd(MX(ev).(f{i}){dataset},0,2)./sqrt(sum(isfinite(MX(ev).(f{i}){dataset}),2));
  end
end

setappdata(handles.figure,'figuredata',FD)
end
function plot_patterns(dataset,handles)
FD=getappdata(handles.figure,'figuredata');
Style=getappdata(handles.figure,'style');
dataid=get(handles.plotviewpanel,'UserData');
ab=uint8(1); sb=uint8(2);
h_full=[handles.apatterns_full handles.spatterns_full];
h_day=[handles.apatterns_day handles.spatterns_day];
type=[get(handles.activitymenu,'Value') 1];

generate_patterns(ab)
if ~get(handles.activitymenu,'UserData')
  generate_patterns(sb)
end

plot_status=get(handles.tabpanel,'UserData');
plot_status(1)=true;
set(handles.tabpanel,'UserData',plot_status)

  function generate_patterns(ev)
    delete(findobj([h_full(ev) h_day(ev)],'UserData',dataid(dataset)))
    
    x=0.5:48*FD(1).days(dataset)-0.5;
    Style.Viewer.Pattern.LineWidth=1.5;
    Opts=struct('Parent',h_full(ev),'FaceAlpha',0.5,'LineWidth',Style.Viewer.Pattern.LineWidth);
    h_es=errorshade(x,FD(ev).full.means(x+0.5,dataset,type(ev)),FD(ev).full.sems(x+0.5,dataset,type(ev)),Style.DuoColor(dataset,:),Opts);
    set(h_es(1),'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'))
    set(h_es(2),'UserData',dataid(dataset),'Tag','ErrorShade')
    
    x=0.5:48-0.5;
    Opts=struct('Parent',h_day(ev),'FaceAlpha',0.5,'LineWidth',Style.Viewer.Pattern.LineWidth);
    h_es=errorshade(x,FD(ev).day.means(x+0.5,dataset,type(ev)),FD(ev).day.sems(x+0.5,dataset,type(ev)),Style.DuoColor(dataset,:),Opts);
    set(h_es(1),'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'))
    set(h_es(2),'UserData',dataid(dataset))
  end
end
function plot_bars(dataset,handles)
FD=getappdata(handles.figure,'figuredata');
Style=getappdata(handles.figure,'style');
dataid=get(handles.plotviewpanel,'UserData');
light=uint8(1); dark=uint8(2);
delete(findobj([handles.tot handles.num handles.dur],'UserData',dataid(dataset)))

x=[1 2];
type=ones(1,FD(1).events);
type(1)=get(handles.activitymenu,'Value');
for per=light:dark
  for event=1:FD(1).events
    % Totals
     y=FD(event).total.means(per,dataset,type(event));
     ysem=FD(event).total.sems(per,dataset,type(event));
     barerrorbar(y,ysem,handles.tot(event,per))
    % Numbers
     y=FD(event).num.means(per,dataset);
     ysem=FD(event).num.sems(per,dataset);
     barerrorbar(y,ysem,handles.num(event,per))
    % Durations
     y=FD(event).dur.means(per,dataset);
     ysem=FD(event).dur.sems(per,dataset);
     barerrorbar(y,ysem,handles.dur(event,per))
  end
end

set([handles.tot handles.num handles.dur],'YLimMode','auto')
plot_status=get(handles.tabpanel,'UserData');
plot_status(2)=true;
set(handles.tabpanel,'UserData',plot_status)

  function barerrorbar(y,ysem,axishandle)
    hb=bar(x(dataset),y,'Parent',axishandle,'UserData',dataid(dataset));
      set(hb,'FaceColor',Style.DuoColor(dataset,:),Style.Viewer.Bars)
    he=errorbar(x(dataset),y,ysem,'Parent',axishandle,'UserData',dataid(dataset));
      set(he,Style.Viewer.BarsError)
    ylim(axishandle,'auto')
    if ~isnan(y)
      text('Position',[x(dataset),0],'String',sprintf('%1.1f',y),'Parent',axishandle,'UserData',dataid(dataset), ...
           'FontSize',7,'Color','k','HorizontalAlignment','center','VerticalAlignment','bottom') %'FontName','FixedWidth',
    end
  end

end

function calc_starpatterns(handles)
MX=getappdata(handles.figure,'matrices');
FD=getappdata(handles.figure,'figuredata');

ab=uint8(1);
sb=uint8(2);

step=0;
steps=((min(FD(1).days)+1)*5)*24*2;
handles.waitbar=create_waitbar;
guidata(handles.figure,handles)

% Activity
for type=1:4
  % Full Pattern
  [FD(ab).full.means(:,:,type), FD(ab).full.sems(:,:,type), ...
   FD(ab).full.ttest(:,:,type), FD(ab).full.kstest(:,:,type) step] ...
   = stattest_pairs(MX(ab).full(:,type),handles,steps,step);
  % Single Day Pattern
  [FD(ab).day.means(:,:,type) FD(ab).day.sems(:,:,type), ...
   FD(ab).day.ttest(:,:,type), FD(ab).day.kstest(:,:,type) step] ...
   = stattest_pairs(MX(ab).day(:,type),handles,steps,step);
end
% Sleep
 % Full Pattern
  [FD(sb).full.means FD(sb).full.sems FD(sb).full.ttest FD(sb).full.kstest step] = stattest_pairs(MX(sb).full,handles,steps,step);
 % Single Day Pattern
  [FD(sb).day.means FD(sb).day.sems FD(sb).day.ttest FD(sb).day.kstest step] = stattest_pairs(MX(sb).day,handles,steps,step);

delete(handles.waitbar)
setappdata(handles.figure,'figuredata',FD)
end
function calc_starbars(handles)
MX=getappdata(handles.figure,'matrices');
FD=getappdata(handles.figure,'figuredata');

ab=uint8(1);
sb=uint8(2);
iai=uint8(3);
isi=uint8(4);

step=0;
steps=(4+(FD(1).events-1)+2*FD(1).events)*2;
handles.waitbar=create_waitbar;
guidata(handles.figure,handles)

% Activity Total
for type=1:4
  [FD(ab).total.means(:,:,type) FD(ab).total.sems(:,:,type), ...
   FD(ab).total.ttest(:,:,type), FD(ab).total.kstest(:,:,type) step] ...
   = stattest_pairs(MX(ab).total(:,type),handles,steps,step);
end

% Totals, Number and Durations of Bouts
for ev=1:FD(1).events
  f={'total' 'num' 'dur'};
  for i=1:length(f)
    if ~(ev==1 && i==1)  
       [FD(ev).(f{i}).means FD(ev).(f{i}).sems FD(ev).(f{i}).ttest FD(ev).(f{i}).kstest step] = stattest_pairs(MX(ev).(f{i}),handles,steps,step);
    end
  end
end

delete(handles.waitbar)
setappdata(handles.figure,'figuredata',FD)
end
function plot_starpatterns(handles)
FD=getappdata(handles.figure,'figuredata');
Style=getappdata(handles.figure,'style');
ab=uint8(1); sb=uint8(2);
h_full=[handles.apatterns_full handles.spatterns_full];
h_day=[handles.apatterns_day handles.spatterns_day];
type=[get(handles.activitymenu,'Value') 1];

if get(handles.activitymenu,'Userdata')
  events=ab;
else
  events=[ab sb];
end

delete(findobj(get(handles.figure,'Children'),'-regexp','Tag','Star'))

% Full Patterns
set(0,'CurrentFigure',handles.figure)
x=[0.5:max(FD(1).days)*24*2-0.5];
y=[get(h_full(1),'YLim') ; get(h_full(2),'YLim')];
for hh=1:length(x)
  for ev=events
    if isfinite(FD(ev).full.ttest(hh,1,type(ev)))
      if logical(FD(ev).full.ttest(hh,1,type(ev)))
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).full.ttest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','tStar','Parent',h_full(ev),Style.Stars.Ttest)%'UIContextMenu',pvalue,
      else
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).full.ttest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','noStar','Parent',h_full(ev),Style.Stars.NotSignf)%'UIContextMenu',pvalue,
      end
    elseif isfinite(FD(ev).full.kstest(hh,1,type(ev)))
      if logical(FD(ev).full.kstest(hh,1,type(ev)))
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).full.kstest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','ksStar','Parent',h_full(ev),Style.Stars.KStest)%'UIContextMenu',pvalue,
      else
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).full.kstest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','noStar','Parent',h_full(ev),Style.Stars.NotSignf)%'UIContextMenu',pvalue,
      end
    end
  end
end

% Day Patterns
x=[0.5:24*2-0.5];
y=[get(h_day(1),'YLim') ; get(h_day(2),'YLim')];
for hh=1:length(x)
  for ev=events
    if isfinite(FD(ev).day.ttest(hh,1,type(ev)))
      if logical(FD(ev).day.ttest(hh,1,type(ev)))
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).day.ttest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','tStar','Parent',h_day(ev),Style.Stars.Ttest)%'UIContextMenu',pvalue,
      else
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).day.ttest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','noStar','Parent',h_day(ev),Style.Stars.NotSignf)%'UIContextMenu',pvalue,
      end
    elseif isfinite(FD(ev).day.kstest(hh,1,type(ev)))
      if logical(FD(ev).day.kstest(hh,1,type(ev)))
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).day.kstest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','ksStar','Parent',h_day(ev),Style.Stars.KStest)%'UIContextMenu',pvalue,
      else
        %pvalue=uicontextmenu;
        %uimenu(pvalue,'Label',sprintf('p=%g',FD(ev).day.kstest(hh,2,type(ev))))
        plot(x(hh),y(ev,2),'Tag','noStar','Parent',h_day(ev),Style.Stars.NotSignf)%'UIContextMenu',pvalue,
      end
    end
  end
end

end
function plot_starbars(handles)
FD=getappdata(handles.figure,'figuredata');
Style=getappdata(handles.figure,'style');
light=uint8(1); dark=uint8(2);
delete(findobj(get(handles.figure,'Children'),'-regexp','Tag','Star'))

fields={'total' 'num' 'dur'};
type=ones(length(fields),FD(1).events);
type(1,1)=get(handles.activitymenu,'Value');
for f=1:length(fields)
  for per=light:dark
    for ev=1:FD(1).events
      if isfinite(FD(ev).(fields{f}).ttest(per,1,type(f,ev)))
        if logical(FD(ev).(fields{f}).ttest(per,1,type(f,ev)))
          y=1.15*max(FD(ev).(fields{f}).means(per,:,type(f,ev)) + FD(ev).(fields{f}).sems(per,:,type(f,ev)));
          hp=text('Position',[1.5 0.94*y],'Tag','tStar_p','Parent',handles.bar_axes(ev,per,f),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).ttest(per,2,type(f,ev))),'FontSize',7,'Color',[0 0 0],'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','tStar','Parent',handles.bar_axes(ev,per,f),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.Ttest)
          plot_starlines(handles.bar_axes(ev,per,f),y,'tStarLine')
          set(handles.bar_axes(ev,per,f),'YLim',[0 1.1*y])
        else
          y=1.15*max(FD(ev).(fields{f}).means(per,:,type(f,ev)) + FD(ev).(fields{f}).sems(per,:,type(f,ev)));
          hp=text('Position',[1.5 0.94*y],'Tag','noStar_p','Parent',handles.bar_axes(ev,per,f),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).ttest(per,2,type(f,ev))),'FontSize',7,'Color',Style.Stars.NotSignf.Color,'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','noStar','Parent',handles.bar_axes(ev,per,f),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.NotSignf)
          set(handles.bar_axes(ev,per,f),'YLim',[0 1.1*max(get(handles.bar_axes(ev,per,f),'YLim'))])
        end
      elseif isfinite(FD(ev).(fields{f}).kstest(per,1,type(f,ev)))
        if logical(FD(ev).(fields{f}).kstest(per,1,type(f,ev)))
          y=1.15*max(FD(ev).(fields{f}).means(per,:,type(f,ev)) + FD(ev).(fields{f}).sems(per,:,type(f,ev)));
          hp=text('Position',[1.5 0.94*y],'Tag','ksStar_p','Parent',handles.bar_axes(ev,per,f),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).kstest(per,2,type(f,ev))),'FontSize',7,'Color',[0.2 0.2 0.2],'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','ksStar','Parent',handles.bar_axes(ev,per,f),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.KStest)
          plot_starlines(handles.bar_axes(ev,per,f),y,'ksStarLine')
          set(handles.bar_axes(ev,per,f),'YLim',[0 1.1*y])
        else
          y=1.15*max(FD(ev).(fields{f}).means(per,:,type(f,ev)) + FD(ev).(fields{f}).sems(per,:,type(f,ev)));
          hp=text('Position',[1.5 0.94*y],'Tag','noStar_p','Parent',handles.bar_axes(ev,per,f),'String',sprintf('p=%1.2g',FD(ev).(fields{f}).kstest(per,2,type(f,ev))),'FontSize',7,'Color',Style.Stars.NotSignf.Color,'HorizontalAlignment','center','Visible',get(handles.statopts,'UserData'));
          plot(1.5,y,'Tag','noStar','Parent',handles.bar_axes(ev,per,f),'UserData',hp,'ButtonDownFcn',{@starclick},Style.Stars.NotSignf)
          set(handles.bar_axes(ev,per,f),'YLim',[0 1.1*max(get(handles.bar_axes(ev,per,f),'YLim'))])
        end
      end
    end
  end
end

end

function [h_waitbar]=create_waitbar
figurePosition=getpixelposition(gcf);
h_waitbar=waitbar(0,'','Name','Performing Statistical Test...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)','WindowStyle','modal','Pointer','watch');
dlgPosition=getpixelposition(h_waitbar);
setpixelposition(h_waitbar,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
setappdata(h_waitbar,'canceling',0)
hbar=findobj([get(findobj([get(h_waitbar,'Children')],'Type','axes'),'Children')],'Type','patch');
color=[0.25 0.25 0.75];
set(hbar,'FaceColor',color,'EdgeColor',color);
end
function [mean_X,sem_X,t,ks,step]=stattest_pairs(X,handles,steps,step)
% Check Input %
[r(1),c(1)]=size(X{1});
[r(2),c(2)]=size(X{2});

% Remove outliers and recalculate means and sems %
mean_X=NaN(max(r),2);
sem_X=NaN(max(r),2);
stdtol=get(handles.settings_statopts,'UserData');
for d=1:2
  outliers_X=abs(X{d}-repmat(mean(X{d},2),[1 c(d)])>stdtol*repmat(std(X{d},0,2),[1 c(d)]));
  X{d}(logical(outliers_X))=NaN;
  mean_X(1:r(d),d)=nanmean(X{d},2);
  sem_X(1:r(d),d)=nanstd(X{d},0,2)./sqrt(sum(isfinite(X{d}),2));
end

if all(r) && all(c>1)
  do_test=true;
else
  do_test=false;
end
if any(~logical(r))
  r(~logical(r))=r(logical(r));
end
h_t=NaN(max(r),1);
p_t=NaN(max(r),1);
h_ks=NaN(max(r),1);
p_ks=NaN(max(r),1);
t=[h_t p_t];
ks=[h_ks p_ks];
h_lillie=NaN(2,1);
p_lillie=NaN(2,1);

if do_test
  alpha=str2double(get(handles.statopts,'String'));
  for ri=1:min(r)
    x={X{1}(ri,:) X{2}(ri,:)};
    % Waitbar
    if steps>0
      if getappdata(handles.waitbar,'canceling')
        return
      else
        step=step+1;
      end
      waitbar(step/steps,handles.waitbar,sprintf('%1.0f%% Done',100*step/steps))
    end
    % Check for normality %
    for d=1:2
      warning off stats:lillietest:OutOfRangeP
      try  
        [h_lillie(d),p_lillie(d)]=lillietest(x{d});%,alpha);
      catch
        h_lillie(d)=0;
        p_lillie(d)=NaN;
      end
    end
    % Test if populations are different %
    if any(h_lillie)
      try 
        [h_ks(ri),p_ks(ri)]=kstest2(x{1},x{2},alpha);
      catch
        h_ks(ri)=NaN;
        p_ks(ri)=NaN;
      end
    else
      try 
        [h_t(ri),p_t(ri)]=ttest2(x{1},x{2},alpha);
      catch
        h_t(ri)=NaN;
        p_t(ri)=NaN;
      end
    end
  end
end

% Update calculated output values %
t=[h_t p_t];
ks=[h_ks p_ks];
end
function plot_starlines(target_axes,y,tag)
line([1 1.4],[y y],'Parent',target_axes,'Tag',tag,'Color','k','LineWidth',1)
line([1 1],[y*0.98 y],'Parent',target_axes,'Tag',tag,'Color','k','LineWidth',1)
line([1.6 2],[y y],'Parent',target_axes,'Tag',tag,'Color','k','LineWidth',1)
line([2 2],[y*0.98 y],'Parent',target_axes,'Tag',tag,'Color','k','LineWidth',1)
end
function starclick(source,event)
newstate=setdiff({'on' 'off'},get(get(source,'UserData'),'Visible'));
set(get(source,'UserData'),'Visible',newstate{:})
end

function patterns_background(event,handles)
FD=getappdata(handles.figure,'figuredata');
Style=getappdata(handles.figure,'style');

ZT_light=24*2*[0:max(FD(1).days)];
ZT_dark=ZT_light+2*FD(1).hourscycle(1,2);

ymax_s=get(handles.spatterns_full,'UserData');
ymax_a=get(handles.apatterns_full,'UserData');
ymax=[ymax_a(get(handles.activitymenu,'Value')) ymax_s];

%%% Plot %%%
h_full=[handles.apatterns_full handles.spatterns_full];
h_day=[handles.apatterns_day handles.spatterns_day];
for ev=event
  delete(findobj([h_full(ev) h_day(ev)],'Tag','DarkBox'))
  % Full
  set(h_full(ev),'YLim',[0 ymax(ev)])
  if get(handles.file_load,'UserData')
    for d=1:max(FD(1).days)
      h_shade=fill([ZT_dark(d) ZT_dark(d) ZT_light(d+1) ZT_light(d+1)],[0 ymax(ev) ymax(ev) 0],Style.PeriodColor(2,:),'Parent',h_full(ev),'LineStyle','none','Tag','DarkBox','Clipping','on');
      set(get(get(h_shade,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
    end
    darkboxes=findobj(get(h_full(ev),'Children'),'Tag','DarkBox');
    other_kids=setdiff(get(h_full(ev),'Children'),darkboxes);
    set(h_full(ev),'Children',[other_kids ; darkboxes])
  end
  % Day
  set(h_day(ev),'YLim',[0 ymax(ev)])
  if get(handles.file_load,'UserData')
    h_shade=fill([ZT_dark(1) ZT_dark(1) ZT_light(2) ZT_light(2)],[0 ymax(ev) ymax(ev) 0],Style.PeriodColor(2,:),'Parent',h_day(ev),'LineStyle','none','Tag','DarkBox','Clipping','on');
    set(get(get(h_shade,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
    darkboxes=findobj(get(h_day(ev),'Children'),'Tag','DarkBox');
    other_kids=setdiff(get(h_day(ev),'Children'),darkboxes);
    set(h_day(ev),'Children',[other_kids ; darkboxes])
  end
end


end

