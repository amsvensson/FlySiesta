function varargout = fsexplorer(varargin)
% FlySiesta Explorer - Explore the event-time distributions for activity
% and sleep events, and the 'burst parameters'. Requires FlySiesta
% files, previously created with FlySiesta Analyzer.
%
% Copyright (C) 2007-2012 Amanda Sorribes, Universidad Autonoma de Madrid, and
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
%
%   A Sorribes, BG Armendariz, D Lopez-Pigozzi, C Murga, GG de Polavieja 
%   'The Origin of Behavioral Bursts in Decision-Making Circuitry'. 
%   PLoS Comp. Biol. 7(6): e1002075 (2011)
%
% Please see the FlySiesta homepage for updated reference. 
% Suggestions of improvements or corrections are gratefully received.
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fsexplorer_OpeningFcn, ...
                   'gui_OutputFcn',  @fsexplorer_OutputFcn, ...
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
function varargout = fsexplorer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end

function fsexplorer_OpeningFcn(hObject, eventdata, handles, varargin)
% Version 
FlySiesta_version=fsabout('version');

% Tweak initiation
set(handles.figure,'Name','FlySiesta Explorer','UserData',FlySiesta_version)
 handles.tab=1;
  set(handles.fittype1,'String','Individual Fits','Enable','on')
  set(handles.fittype2,'String','Mean of Fits','Enable','on')
 set(handles.ab_event,'Value',1)                                           % Start-up selection (Activity Light, pdf)
  set(handles.eventpanel,'UserData',1)                                     % Save event-index in its panel
 set(handles.light_period,'Value',1)                                       % Start-up selection (Activity Light, pdf)
  set(handles.periodpanel,'UserData',1)                                    % Save period-index in its panel
 set(handles.pdf_distr,'Value',1)                                          % Start-up selection (Activity Light, pdf)
  set(handles.distrpanel,'UserData',1)                                     % Save distribution-index in its panel
 set(handles.fittype1,'Value',1)                                           % Start-up selection (Individual traces)
  set(handles.methodsep,'UserData',1)                                      % Save fittype in its panel
set(handles.name1,'Value',0)                                               % File loaded or not
 set(handles.name2,'Value',0)                                              % File loaded or not
 set(handles.plotviewpanel,'UserData',rand(1,2))                           % Unique dataset plot identification
 set(handles.flylist1,'Value',[],'String','')
 set(handles.flylist2,'Value',[],'String','')
set(handles.wBbox,'Min',1,'Max',2,'Value',2)                               % Toggling checkboxes changes the 'Value' between off=1 & on=2, 
 set(handles.wnlbox,'Min',1,'Max',2,'Value',2)                             % such that 'Value' works directly as an index into a e.g. 
 set(handles.wlinbox,'Min',1,'Max',2,'Value',2)                            % cell string, usually: state={'off' 'on'};
set(handles.name1,'Enable','inactive')                                     % To activate ButtonDownFcn
 set(handles.name2,'Enable','inactive')                                    % To activate ButtonDownFcn
 set(handles.menu_tools,'Enable','off')                                    % Turn off Tools if no dataset has been loaded
set(handles.tools_min_mean,'UserData',3);                                     % Only include in mean tab, durations that have at least n values
set([handles.eventpanel handles.periodpanel ...                            % Make beveledin panels color slightly lighter (to create contrast w/ pushed in button)
     handles.distrpanel handles.ytext handles.xtext], ...
    'BackgroundColor',1.03*get(0,'defaultUicontrolBackgroundColor'))
movegui(handles.figure,'center')
 set(findobj(handles.figure,'HandleVisibility','on'),'HandleVisibility','callback')
warning('off','MATLAB:divideByZero')
warning('off','curvefit:fit:noStartPoint')
warning('off','MATLAB:Axes:NegativeDataInLogAxis')
 
% Load Button Icons & Get Style-structure for Plots
load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'])
set(handles.light_period,'UserData',MyStyle.PeriodColor(1,:))
set(handles.dark_period,'UserData',MyStyle.PeriodColor(2,:))
set(handles.female1,'ToolTip','Select all Female flies','CData',female)
set(handles.male1,'ToolTip','Select all Male flies','CData',male)
set(handles.female2,'ToolTip','Select all Female flies','CData',female)
set(handles.male2,'ToolTip','Select all Male flies','CData',male)
set(handles.name1,'ForegroundColor',MyStyle.DuoColor(1,:),'String','')
set(handles.name2,'ForegroundColor',MyStyle.DuoColor(2,:),'String','')

% Prepare Axes
 handles.tabaxes=[handles.axes_scatter handles.axes_mean handles.axes_superfly handles.axes_dev handles.axes_lambdak handles.axes_mstd];
 handles.resultaxes=[handles.p_axes handles.B_axes handles.k_axes handles.l_axes handles.r_axes];
 set([handles.tabaxes handles.resultaxes],'NextPlot','add','Color',MyStyle.PeriodColor(1,:),'UserData',[0 0])
 % tabs
  for ax=1:4
    xlabel(handles.tabaxes(ax),'time (min)','FontSize',8)
    ylabel(handles.tabaxes(ax),'P(Activity)','FontSize',8)
  end
  ylabel(handles.tabaxes(4),'P(Activity): fit - data','FontSize',8)
  xlabel(handles.tabaxes(5),'Weibull k','FontSize',8)
  ylabel(handles.tabaxes(5),'Weibull \lambda','FontSize',8)
  xlabel(handles.tabaxes(6),'Standard Deviation of Event Lengths','FontSize',8)
  ylabel(handles.tabaxes(6),'Mean Length of Events','FontSize',8)
 % result
  set([handles.p_axes handles.B_axes],'XLim',[0.3 2.7],'YLimMode','auto')
  set([handles.k_axes handles.l_axes handles.r_axes],'XLim',[0.4 4.6],'YLimMode','auto')
  line([0.4 4.6],[1 1],'Parent',handles.k_axes,'LineStyle',':','Color',[0.3 0.3 0.3],'Tag','nolegend');
  line([0.4 4.6],[1 1],'Parent',handles.r_axes,'LineStyle',':','Color',[0.3 0.3 0.3],'Tag','nolegend');
  title(handles.p_axes,'Nr. Points','Units','normalized','Position',[0.5 1 1],'FontSize',8)
  title(handles.B_axes,'B','Units','normalized','Position',[0.5 1 1],'FontSize',8)
  title(handles.k_axes,'Weibull k','Units','normalized','Position',[0.5 1 1],'FontSize',8)
  title(handles.l_axes,'Weibull \lambda','Units','normalized','Position',[0.5 1 1],'FontSize',8)
  title(handles.r_axes,'Weibull R^2','Units','normalized','Position',[0.5 1 1],'FontSize',8)

% Assure tabpanel works properly
TabPanel=get(handles.TBP_tabpanel,'UserData');
TabPanel.Filename='fsexplorer.fig';
TabPanel.Color{1}=get(0,'defaultUicontrolBackgroundColor');
set(handles.TBP_tabpanel,'UserData',TabPanel)

% Save Init Data
setappdata(handles.figure,'style',MyStyle)
handles.output = hObject;  % Choose default command line output for fsviewer
guidata(hObject, handles);  % Update handles structure
end


%% Create Functions %%
function xscale_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function yscale_CreateFcn(hObject, eventdata, handles)
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
    
    % Control for Same Start Points (i.e. Binning & Sleep Threshold)
    events={'ab' 'sb' 'iai' 'isi'};
    for ev=1:4
      startpoint=get(handles.([events{ev} '_event']),'UserData');
      if isempty(startpoint)
        set(handles.([events{ev} '_event']),'UserData',DISTR(ev,1).startpoint)
      else
        if startpoint~=DISTR(ev,1).startpoint
          h_dlg=errordlg({'The loaded FlySiesta data files'' binning'; 'or sleep threshold are different!'},'Error: Cannot Proceed');
          figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
          uiwait(h_dlg)
          return
        end
      end
    end
    
    % If Control OK, Load into GUI
    points=calc_distrpoints(EXPDATA,DISTR);
    STRUCT=DISTR(get(handles.eventpanel,'UserData'),get(handles.periodpanel,'UserData'));
    STRUCT.points=points{get(handles.eventpanel,'UserData'),get(handles.periodpanel,'UserData')};
    setappdata(handles.figure,sprintf('exp%d',dataset),EXPDATA)
    setappdata(handles.figure,sprintf('distr%d',dataset),DISTR)
    setappdata(handles.figure,sprintf('points%d',dataset),points)
    setappdata(handles.figure,sprintf('struct%d',dataset),STRUCT)
    
    set(handles.(sprintf('name%d',dataset)),'Value',1,'String',EXPDATA.name)
    set(handles.(sprintf('all%d',dataset)),'UserData',EXPDATA.matrix_index{1})
    set(handles.(sprintf('female%d',dataset)),'UserData',EXPDATA.matrix_index{2})
    set(handles.(sprintf('male%d',dataset)),'UserData',EXPDATA.matrix_index{3})
    set(handles.(sprintf('flylist%d',dataset)),'UserData',EXPDATA.id_index,'Value',[],'Min',min(EXPDATA.matrix_index{1}),'Max',max(EXPDATA.matrix_index{1}),'String',fly_string(EXPDATA.matrix_index{1},EXPDATA.id_index))
    
    set(handles.tabaxes,'XTickMode','auto','YTickMode','auto')
    set(handles.resultaxes,'YTickMode','auto')
    set(handles.menu_tools,'Enable','on')
  end
end
end
function file_save_Callback(hObject, eventdata, handles)
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

function string=fly_string(matrix_index,id_index)
string=cell(length(matrix_index),1);
for i=1:length(string)
  string{i}=num2str(id_index(matrix_index(i)));
end
end
function points=calc_distrpoints(EXPDATA,DISTR)
% Test if fields are compatible with newer analysis versions
if isfield(DISTR(1,1),'Eps')
  points=cell(4,2);
  for ev=1:4
    for per=1:2
      points{ev,per}=DISTR(ev,per).nrEps;
    end
  end
else
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
  
  % Find number of ibis/bouts
  points=cell(4,2);
  for ev=1:4
    for per=1:2
      bouts=NaN(size(EXPDATA.activity));
      bouts([DISTR(ev,per).matrix(:,2)])=DISTR(ev,per).matrix(:,1);
      points{ev,per}=sum(isfinite(bouts(period{per},:)),1); % NB: NOT normalized over days!! (/EXPDATA.days);
    end
  end
end
end

% Tools
function menu_tools_Callback(hObject, eventdata, handles)
end
function tools_min_mean_Callback(hObject, eventdata, handles)
prompt={'Set minimum number of flies (data) in each point: '};
defaultanswer={num2str(get(handles.tools_min_mean,'UserData'))};
options.Interpreter='tex';
answer=str2double(inputdlg(prompt,'Options for tab 2',1,defaultanswer,options));
if ~isempty(answer) && ~isnan(answer)
  set(handles.tools_min_mean,'UserData',answer)
end
guidata(hObject, handles);
load_n_plot_struct(handles)
end
function tools_copy_Callback(hObject, eventdata, handles)
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
evstr={'Activity Bouts' 'Sleep Bouts' 'Inter-Activity Intervals' 'Inter-Sleep Intervals'};
perstr={'Light' 'Dark'};
titlestr=[evstr{get(handles.eventpanel,'UserData')} ' Distribution, ' perstr{get(handles.periodpanel,'UserData')} ' Period'];
hf=figure('Name',titlestr,'NumberTitle','off','IntegerHandle','off');
tempaxes=axes;
new_axes=copyobj(selected_axes,hf);
set(new_axes,'Units',get(tempaxes,'Units'),'Position',get(tempaxes,'Position'))
delete(tempaxes)
fPosition=getpixelposition(hf);
setpixelposition(hf,[figurePosition(1)+(figurePosition(3)-fPosition(3))/2 figurePosition(2)+(figurePosition(4)-fPosition(4))/2 fPosition(3:4)])

for dataset=1:2
  dataobj=findobj(new_axes,'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'));
  if ~isempty(dataobj)
    for i=1:length(dataobj)
      set(get(get(dataobj(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
    end
    set(get(get(dataobj(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','children')
    datapatch=get(dataobj(1),'Children');
    if ~isempty(datapatch) && length(datapatch)==1
      fitcolor=get(datapatch,'EdgeColor');
      set(datapatch,'EdgeColor','k','LineWidth',0.5,'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'))
      hl=legend(new_axes);
      set(hl,'Interpreter','none')
      set(datapatch,'EdgeColor',fitcolor)
    end
  else
    dataid=get(handles.plotviewpanel,'UserData');
    dataobj=findobj(new_axes,'Type','hggroup','-and','UserData',dataid(dataset));
    kids=get(dataobj,'Children');
    if ~isempty(kids)
      set(kids(1),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'))
      set(get(get(dataobj,'Annotation'),'LegendInformation'),'IconDisplayStyle','children')
    end
  end
end
wfit={'wB' 'wnl' 'wlin'};
dispnamefit={'Weibull from B parameter' 'Weibull Non-Linear Fit' 'Weibull Linear Fit'};
for fitmethod=1:3
  dataobj=findobj(new_axes,'DisplayName',wfit{fitmethod});
  if ~isempty(dataobj)
    for i=1:length(dataobj)
      set(get(get(dataobj(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
    end
    if get(handles.([wfit{fitmethod} 'box']),'Value')==2
      set(get(get(dataobj(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','on')
      set(dataobj(1),'DisplayName',dispnamefit{fitmethod})
    end
  end
end
dataobj=findobj(new_axes,'Tag','nolegend');
if ~isempty(dataobj)
  for i=1:length(dataobj)
    set(get(get(dataobj(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end
dataobj=findobj(new_axes,'DisplayName','B=0');
if ~isempty(dataobj)
  for i=1:length(dataobj)-1
    set(get(get(dataobj(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end

hl=legend(new_axes,'show');
set(hl,'Interpreter','none')

set(hf,'HandleVisibility','on')
set(handles.figure,'Pointer','arrow')
end
function tools_zoom_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
switch checked
  case 'on'
    set(hObject,'Checked','off')
    zoom out
    set(findobj(handles.figure,'Type','axes'),'HandleVisibility','callback')
    set(handles.figure,'RendererMode','auto')
    startpoint=get(findobj(handles.eventpanel,'Value',1),'UserData');
    set(handles.tabaxes(handles.tab),'XTickLabel',get(handles.tabaxes(handles.tab),'XTick')+startpoint)
    zoom off
  case 'off'
    set(hObject,'Checked','on')
    set(findobj(handles.figure,'Type','axes'),'HandleVisibility','on')
    set(handles.figure,'Renderer','zbuffer')
    set(handles.tabaxes(handles.tab),'XTickLabelMode','auto')
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
%%% Plot View %%%
% Event
function ab_event_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'event',1)
update_ylabel(handles)
load_n_plot_struct(handles)
end
function sb_event_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'event',2)
update_ylabel(handles)
load_n_plot_struct(handles)
end
function iai_event_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'event',3)
update_ylabel(handles)
load_n_plot_struct(handles)
end
function isi_event_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'event',4)
update_ylabel(handles)
load_n_plot_struct(handles)
end
% Period
function light_period_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'period',1)
set([handles.tabaxes handles.resultaxes],'Color',get(hObject,'UserData'))
load_n_plot_struct(handles)
end
function dark_period_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'period',2)
set([handles.tabaxes handles.resultaxes],'Color',get(hObject,'UserData'))
load_n_plot_struct(handles)
end
% Distribution
function pdf_distr_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'distr',1)
update_ylabel(handles)
distr_change(handles)
end
function cdf_distr_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'distr',2)
update_ylabel(handles)
distr_change(handles)
end
function logcdf_distr_Callback(hObject, eventdata, handles)
plotview_togglefcn(hObject,'distr',3)
update_ylabel(handles)
distr_change(handles)
end
function xscale_Callback(hObject, eventdata, handles)
scale={'lin' 'log'};
set(handles.tabaxes(1:3),'XScale',scale{get(hObject,'Value')},'XTickMode','auto')
if any(get(handles.tabaxes(handles.tab),'UserData'))
 tabxtick(handles)
end
end
function yscale_Callback(hObject, eventdata, handles)
scale={'lin' 'log'};
set(handles.tabaxes(1:3),'YScale',scale{get(hObject,'Value')},'YLimMode','auto')
end
% Common functions
function plotview_togglefcn(hObject,type,value)
set(findobj(get(hObject,'Parent'),'-regexp','Tag',['_' type]),'Value',0)
set(hObject,'Value',1)
set(get(hObject,'Parent'),'UserData',value)
end
function update_ylabel(handles)
eventstr=get(findobj(handles.eventpanel,'Value',1),'String');
y_label={['P(' eventstr ')'] ['P(' eventstr ' \geq time)'] ['-log( P(' eventstr ' \geq time) )']};
for ax=handles.tabaxes(1:3)
  ylabel(ax,y_label{get(handles.distrpanel,'UserData')},'FontSize',8);
end
ylabel(handles.tabaxes(4),[y_label{get(handles.distrpanel,'UserData')} ': fit - data'],'FontSize',8);
end
function distr_change(handles)
for dataset=1:2
  if logical(get(handles.(sprintf('name%d',dataset)),'Value'))
    flylist_Callback=[sprintf('flylist%d',dataset) '_Callback(handles.' sprintf('flylist%d',dataset) ',[],handles)'];
    eval(flylist_Callback)
  end
end
end
function load_n_plot_struct(handles)
for dataset=1:2
  if logical(get(handles.(sprintf('name%d',dataset)),'Value'))
   % Load
    DISTR=getappdata(handles.figure,sprintf('distr%d',dataset));
    points=getappdata(handles.figure,sprintf('points%d',dataset));
    STRUCT=DISTR(get(handles.eventpanel,'UserData'),get(handles.periodpanel,'UserData'));
    STRUCT.points=points{get(handles.eventpanel,'UserData'),get(handles.periodpanel,'UserData')};
    setappdata(handles.figure,sprintf('struct%d',dataset),STRUCT)
   % Plot
    flylist_Callback=[sprintf('flylist%d',dataset) '_Callback(handles.' sprintf('flylist%d',dataset) ',[],handles)'];
    eval(flylist_Callback)
  end
end
end

%%% Fly Selection %%%
% File 1
function name1_ButtonDownFcn(hObject, eventdata, handles)
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
for ax=handles.tabaxes
  max_dataset=get(ax,'UserData');
  max_dataset(1)=0;
  set(ax,'UserData',max_dataset);
end
end
function flylist1_Callback(hObject, eventdata, handles)
value=get(handles.flylist1,'Value');
if ~isempty(value)
  plottoaxestab(value,1,handles)
end
end
% File 2
function name2_ButtonDownFcn(hObject, eventdata, handles)
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
for ax=handles.tabaxes
  max_dataset=get(ax,'UserData');
  max_dataset(2)=0;
  set(ax,'UserData',max_dataset);
end
end
function flylist2_Callback(hObject, eventdata, handles)
value=get(handles.flylist2,'Value');
if ~isempty(value)
  plottoaxestab(value,2,handles)
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

%%% Fit Method %%%
% Fit Methods (Check Boxes)
function wBbox_Callback(hObject, eventdata, handles)
wboxes_commonfcn(hObject,handles)
end
function wnlbox_Callback(hObject, eventdata, handles)
wboxes_commonfcn(hObject,handles)
end
function wlinbox_Callback(hObject, eventdata, handles)
wboxes_commonfcn(hObject,handles)
end
function wboxes_commonfcn(hObject,handles)
state={'off' 'on'};
fittype={'type1' 'type2'};
box_str=get(hObject,'Tag');
box_str=box_str(1:end-3);
set(findobj(handles.tabaxes(handles.tab),'DisplayName',box_str,'-and','Tag',fittype{get(handles.methodsep,'UserData')}),'Visible',state{get(hObject,'Value')})
end
% Fit Types (Radio Buttons)
function fittype1_Callback(hObject, eventdata, handles)
set(handles.fittype1,'Value',1)
set(handles.fittype2,'Value',0)
fittype_commonfcn(1,handles)
end
function fittype2_Callback(hObject, eventdata, handles)
set(handles.fittype2,'Value',1)
set(handles.fittype1,'Value',0)
fittype_commonfcn(2,handles)
end
function fittype_commonfcn(value,handles)
set(handles.methodsep,'UserData',value)
fittype={'type1' 'type2'};
% tabaxes
try
  set(findobj(handles.tabaxes,'Tag',fittype{value+1}),'Visible','off')
catch
  set(findobj(handles.tabaxes,'Tag',fittype{value-1}),'Visible','off')
end
set(findobj(handles.tabaxes,'Tag',fittype{value}),'Visible','on');
if get(handles.wBbox,'Value')==1; set(findobj(handles.tabaxes,'DisplayName','wB'),'Visible','off'); end
if get(handles.wnlbox,'Value')==1; set(findobj(handles.tabaxes,'DisplayName','wnl'),'Visible','off'); end
if get(handles.wlinbox,'Value')==1; set(findobj(handles.tabaxes,'DisplayName','wlin'),'Visible','off'); end
% resultaxes
if any(handles.tab==[2 3])
  try
    set(findobj(handles.resultaxes,'Tag',fittype{value+1}),'Visible','off')
  catch
    set(findobj(handles.resultaxes,'Tag',fittype{value-1}),'Visible','off')
  end
  set(findobj(handles.resultaxes,'Tag',fittype{value}),'Visible','on')
end
end


%% Tabs %%
function tabpanel_TabSelectionChange_Callback(hObject,eventdata,handles)
handles.tab=eventdata.NewValue;
guidata(handles.figure,handles)

set([handles.yscale handles.xscale],'Enable','on')
switch eventdata.NewValue
  case 1
    set(handles.fittype1,'String','Individual Fits','Enable','on')
    set(handles.fittype2,'String','Mean of Fits','Enable','on')
  case 2
    set(handles.fittype1,'String','Fit to Mean','Enable','on')
    set(handles.fittype2,'String','Mean of Fits','Enable','on')
  case 3
    set(handles.fittype1,'String','Fit to SuperFly','Enable','on')
    set(handles.fittype2,'String','Mean of Fits','Enable','on')
  case 4
    set([handles.yscale handles.xscale],'Enable','off')
    set(handles.fittype1,'String','Individual Traces','Enable','on')
    set(handles.fittype2,'String','Mean of Traces','Enable','on')
  case 5
    set([handles.yscale handles.xscale],'Enable','off')
    set(handles.fittype1,'String','Individual Fits','Enable','on')
    set(handles.fittype2,'String','Mean of Fits','Enable','on')
  case 6
    set([handles.yscale handles.xscale],'Enable','off')
    set(handles.fittype1,'String','Individual Values')
    set(handles.fittype2,'String','Mean Values')
end

for dataset=1:2
  if logical(get(handles.(sprintf('name%d',dataset)),'Value'))
    value=get(handles.(sprintf('flylist%d',dataset)),'Value');
    if ~isempty(value)
      plottoaxestab(value,dataset,handles)
    end
  end
end

end


%% Plot Functions %%
function plottoaxestab(value,dataset,handles)
% Delete previous plot objects from dataset
dataid=get(handles.plotviewpanel,'UserData');
delete(findobj([handles.tabaxes handles.resultaxes],'UserData',dataid(dataset)))

% Execute tabplot for active tab
tabplot=sprintf('tab%dplot(value,dataset,handles)',handles.tab);
eval(tabplot)

% Toggle visibility of fits and fittypes
 % Checkboxes
state={'off' 'on'};
for fitname={'wB' 'wnl' 'wlin'};
  set(findobj(handles.tabaxes,'DisplayName',fitname{:}),'Visible',state{ get(handles.([fitname{:} 'box']),'Value') })
end
 % Radiobuttons
 fittype={'type1' 'type2'};
 try
   set(findobj(handles.tabaxes,'Tag',fittype{get(handles.methodsep,'UserData')+1}),'Visible','off')
 catch
   set(findobj(handles.tabaxes,'Tag',fittype{get(handles.methodsep,'UserData')-1}),'Visible','off')
 end
 if any(handles.tab==[2 3])
   try
     set(findobj(handles.resultaxes,'Tag',fittype{get(handles.methodsep,'UserData')+1}),'Visible','off')
   catch
     set(findobj(handles.resultaxes,'Tag',fittype{get(handles.methodsep,'UserData')-1}),'Visible','off')
   end
 end
 
end

function tab1plot(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
ax=handles.axes_scatter;

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fitname={'wB' 'wnl' 'wlin'};
fittype={'type1' 'type2'};

% Plot
[x,y,xfit,fitfcn]=load_data(value,STRUCT,handles);
line(x,y,'Parent',ax,'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'), ...
  'Color',Style.DuoColor(dataset,:),'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.Scatter);

%{
% Plot Style, Alternative 2 (Stair Plots)
Style.Scatter(dataset).LineWidth=2;
Style.Scatter(dataset).LineStyle='-';
Style.Scatter(dataset).MarkerSize=3;
%x=[0:size(y,1)-1]'; x=[] ... ; Change for case 2 and 3 in load_data !
hs=stairs(x-1,y,'Parent',ax,'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'));
set(hs,Style.Scatter(dataset));
%}

plotfits(STRUCT.wB,1)
plotfits(STRUCT.wnl,2)
plotfits(STRUCT.wlin,3)
resultplot_type2(value,dataset,handles)
  function plotfits(w,f)
   % Individual Fits (fittype 1)
    yfit=fitfcn(xfit,w.k(value),w.lambda(value));
    for i=1:length(value)
      try
        yend=find(xfit==x(sum(isfinite(y(:,i)))));
      catch
        yend=1;
      end
      try
        yfit(yend+2:end,i)=NaN;
      catch
        yfit(yend:end,i)=NaN;
      end
    end
    line(xfit,yfit,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{1}, ...
      Style.Fits(f));
    
   % Mean of Fits (fittype 2)
    yfit=fitfcn(xfit,nanmean(w.k(value)),nanmean(w.lambda(value)));
    line(xfit,yfit,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{2}, ...
      Style.Fits(f));
  end

% Relabel x-axis
max_dataset=get(ax,'UserData');
max_dataset(dataset)=max(sum(~isnan(y),1));
set(ax,'UserData',max_dataset)
tabxtick(handles)
end
function tab2plot(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
ax=handles.axes_mean;

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fitname={'wB' 'wnl' 'wlin'};
fittype={'type1' 'type2'};

% Plot
[x,y,xfit,fitfcn]=load_data(value,STRUCT,handles);
n=get(handles.tools_min_mean,'UserData');   % Only includes in mean, durations that have at least n values
if length(value)>=n
  y_n=sum(~isnan(y),2);
  x=x(y_n>=n,:);
  y=y(y_n>=n,:);
  x_n=sum(~isnan(y),2);
  if any(get(handles.distrpanel,'UserData') == [1,2])
    y(isnan(y))=0;
  end
  he=errorbar(x,nanmean(y,2),nanstd(y,0,2)./x_n,'Parent',ax,'UserData',dataid(dataset));
  set(he,'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'),'Color',Style.DuoColor(dataset,:),'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.Mean)

  distr=eventmatrix(value,STRUCT,dataset,handles);
  mu=nanmean(distr-STRUCT.startpoint,1);
  sigma=nanstd(distr-STRUCT.startpoint,0,1);

  B=nan(1,3);
  k=nan(1,3);
  lambda=nan(1,3);
  
  plotfits(STRUCT.wB,1)
  plotfits(STRUCT.wnl,2)
  plotfits(STRUCT.wlin,3)
  
  r2=calc_rsquare(nanmean(y,2),k,lambda,value,dataset,handles);
  resultplot_type1(value,dataset,B,k,lambda,r2,handles)
  resultplot_type2(value,dataset,handles)

else
  text('Units','normalized','Position',[0.025,0.95],'String',sprintf('Select More Flies (at least %d)',n),'Parent',ax, ...
       'UserData',dataid(dataset),'FontSize',8,'Color',[0.5 0.5 0.5],'HorizontalAlignment','left','VerticalAlignment','bottom')
  x_n=1;
end
  function plotfits(w,f)
   % Fit to Mean (fittype 1)
    [B(f),k(f),lambda(f)]=fit_supermean(STRUCT.survival_histogram(STRUCT.startpoint:end,value),n,mu,sigma,f);
    yfit=fitfcn(xfit,k(f),lambda(f));
    yend=find(xfit==x(sum(y_n>=n)));
    try
      yfit(yend+2:end)=NaN;
    catch
      yfit(yend:end)=NaN;
    end
    line(xfit,yfit,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{1}, ...
      Style.Fits(f));

   % Mean of Fits (fittype 2)
    yfit=fitfcn(xfit,nanmean(w.k(value)),nanmean(w.lambda(value)));
    line(xfit,yfit,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{2}, ...
      Style.Fits(f));
  end

% Relabel x-axis
max_dataset=get(ax,'UserData');
max_dataset(dataset)=length(x_n);
set(ax,'UserData',max_dataset)
tabxtick(handles)
end
function tab3plot(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
ax=handles.axes_superfly;

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fitname={'wB' 'wnl' 'wlin'};
fittype={'type1' 'type2'};

% Create SuperFly histograms
distr=eventmatrix(value,STRUCT,dataset,handles);
distr=sort(distr(~isnan(distr)));

if ~isempty(distr)
  histogram=hist(distr,[1:max(distr)])';
  if STRUCT.startpoint>1
    histogram(1:STRUCT.startpoint-1)=0;
  end
  histogram=histogram/sum(histogram);
  survival=nan(size(histogram));
  survival(end:-1:1)=cumsum(histogram(end:-1:1));
end

% Plot
[x,y,xfit,fitfcn]=load_superflydata(histogram,survival,STRUCT.startpoint,handles);
line(x,y,'Parent',ax,'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'), ...
    'Color',Style.DuoColor(dataset,:),'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.SuperFly);

mu=nanmean(distr-STRUCT.startpoint,1);
sigma=nanstd(distr-STRUCT.startpoint,0,1);

B=nan(1,3);
k=nan(1,3);
lambda=nan(1,3);

plotfits(STRUCT.wB,1)
plotfits(STRUCT.wnl,2)
plotfits(STRUCT.wlin,3)

r2=calc_rsquare(y,k,lambda,value,dataset,handles);
resultplot_type1(value,dataset,B,k,lambda,r2,handles)
resultplot_type2(value,dataset,handles)

  function plotfits(w,f)
    % Fit to Mean (fittype 1)
    [B(f),k(f),lambda(f)]=fit_supermean(survival(STRUCT.startpoint:end,:),1,mu,sigma,f);
    yfit=fitfcn(xfit,k(f),lambda(f));
    line(xfit,yfit,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{1}, ...
      Style.Fits(f));
    
    % Mean of Fits (fittype 2)
    yfit=fitfcn(xfit,nanmean(w.k(value)),nanmean(w.lambda(value)));
    line(xfit,yfit,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{2}, ...
      Style.Fits(f));
  end

% Relabel x-axis
max_dataset=get(ax,'UserData');
max_dataset(dataset)=max(sum(~isnan(y),1));
set(ax,'UserData',max_dataset)
tabxtick(handles)
end
function tab4plot(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
ax=handles.axes_dev;

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fitname={'wB' 'wnl' 'wlin'};
fittype={'type1' 'type2'};

% Plot
[x,y,xfit,fitfcn]=load_data(value,STRUCT,handles);
plotfits(STRUCT.wB,1)
plotfits(STRUCT.wnl,2)
plotfits(STRUCT.wlin,3)
resultplot_type2(value,dataset,handles)

  function plotfits(w,f)
    yfit=fitfcn(x,w.k(value),w.lambda(value));

   % Individual Traces (fittype 1)
    line(x,yfit-y,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{1}, ...
      Style.Fits(f));
    line(x,yfit-y,'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{1}, ...
      'Color',Style.DuoColor(dataset,:),Style.Explorer.Dev);

    % Mean Trace (fittype 2)
    line(x,nanmean(yfit-y,2),'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{2}, ...
      Style.Fits(f));
    line(x,nanmean(yfit-y,2),'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{2}, ...
      'Color',Style.DuoColor(dataset,:),Style.Explorer.Dev);
  end

% Relabel x-axis
max_dataset=get(ax,'UserData');
max_dataset(dataset)=max(sum(~isnan(y),1));
set(ax,'UserData',max_dataset)
tabxtick(handles)
end
function tab5plot(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
ax=handles.axes_lambdak;

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
id_index=get(handles.(sprintf('flylist%d',dataset)),'UserData');
fitname={'wB' 'wnl' 'wlin'};
fittype={'type1' 'type2'};

% Plot
plotfits(STRUCT.wB,1)
plotfits(STRUCT.wnl,2)
plotfits(STRUCT.wlin,3)
resultplot_type2(value,dataset,handles)
  function plotfits(w,f)
    % Individual Fits (fittype 1)
    for fly=value
      fly_id=uicontextmenu;
      uimenu(fly_id,'Label',sprintf('Fly Nr: %d',id_index(fly)))
      line(w.k(fly),w.lambda(fly),'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{1},'UIContextMenu',fly_id, ...
        'Color',Style.Fits(f).Color,'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.LambdaK)
    end
    
    % Mean of Fits (fittype 2)
    line(nanmean(w.k(value)),nanmean(w.lambda(value)),'Parent',ax,'UserData',dataid(dataset),'DisplayName',fitname{f},'Tag',fittype{2}, ...
      'Color',Style.Fits(f).Color,'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.LambdaK,'MarkerSize',8,'LineWidth',2)
  end
end
function tab6plot(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
ax=handles.axes_mstd;

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fittype={'type1' 'type2'};

% Calculate mean and standard deviation
distr=eventmatrix(value,STRUCT,dataset,handles);
mu=nanmean(distr-STRUCT.startpoint,1);
sigma=nanstd(distr-STRUCT.startpoint,0,1);
B=(sigma-mu)./(sigma+mu);

% Plot
xy_max=1.05*max([max(mu) max(sigma)]);
line([0 xy_max],[0 xy_max],'Parent',ax,'UserData',dataid(dataset),'DisplayName','B=0','Color','k','LineWidth',1);
 % Individual Fits (fittype 1)
  for i=1:length(value)
    B_value=uicontextmenu;
    uimenu(B_value,'Label',sprintf('B=%1.3f',B(i)))
    line(sigma(i),mu(i),'Parent',ax,'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'),'Tag',fittype{1},'UIContextMenu',B_value, ...
      'Color',Style.DuoColor(dataset,:),'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.Mstd)
  end
 % Mean of Fits (fittype 2)
  line(nanmean(sigma),nanmean(mu),'Parent',ax,'UserData',dataid(dataset),'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'),'Tag',fittype{2}, ...
    'Color',Style.DuoColor(dataset,:),'MarkerFaceColor',Style.DuoColor(dataset,:),Style.Explorer.Mstd)

resultplot_type2(value,dataset,handles)

% Relabel y-axis
set(ax,'YTickLabel',get(ax,'YTick')+STRUCT.startpoint)
end

function tabxtick(handles)
ax=handles.tabaxes(handles.tab);
startpoint=get(findobj(handles.eventpanel,'Value',1),'UserData');
if get(handles.xscale,'Value') == 1
  % Reset
  set(ax,'XLim',[-0.1 max(get(ax,'UserData'))],'XTickMode','auto','XTickLabelMode','auto')
  % Adjust
  ticklabels=get(ax,'XTick');
  if max(ticklabels)>startpoint
    ticklabels(1)=startpoint;
    newticks=ticklabels-startpoint;
    set(ax,'XTick',newticks,'XTickLabel',ticklabels)
  end
else
  set(ax,'XLim',[0.4 max(get(ax,'UserData'))],'XTickMode','auto','XTickLabelMode','auto')
end

% Set xlabel
xtime={'time (min)' 'time - startpoint  (min)'};
for ax=1:4
  xlabel(handles.tabaxes(ax),xtime{get(handles.xscale,'Value')},'FontSize',8)
end
end
function resultplot_type1(value,dataset,B,k,lambda,r2,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
linewidth=[1 2 2 2 2];
decimals=[1 2 2 1 2];
if length(value)==1
  decimals(1)=0;
end

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fittype={'type1' 'type2'};

% x-positions
pBpos=dataset;
wpos={[NaN 1 2] [NaN 3 4]};
wpos=wpos{dataset};

% Number of points & B parameter
data={STRUCT.points(value) B};
f=1;
for ax=1:2 
  barerrorbar(pBpos,data{ax},handles.resultaxes(ax))
end

% Weibull parameters
param={[] [] k lambda r2};
for ax=3:5
  for f=2:3
    barerrorbar(wpos(f),param{ax}(f),handles.resultaxes(ax))
  end
end

  function barerrorbar(x,data,axishandle)
    y=nanmean(data);
    ystd=nanstd(data);
    ysem=ystd/sqrt(sum(~isnan(data)));
    
    textvalue=uicontextmenu;
    if ~isnan(ystd) && logical(ystd)
      uimenu(textvalue,'Label',sprintf('mean=%1.4f',y))
      uimenu(textvalue,'Label',sprintf('std=%1.4f',ystd))
      uimenu(textvalue,'Label',sprintf('sem=%1.4f',ysem))
    else
      uimenu(textvalue,'Label',sprintf('value=%1.4f',y))
    end
    bar(x,y,'Parent',axishandle,'UserData',dataid(dataset),'Tag',fittype{1},'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'),'UIContextMenu',textvalue, ...
        'FaceColor',Style.DuoColor(dataset,:),'EdgeColor',Style.Fits(f).Color,'LineWidth',linewidth(ax))
    errorbar(x,y,ysem,'Parent',axishandle,'UserData',dataid(dataset),'Tag',fittype{1}, ...
        'Color',Style.Fits(f).Color,'LineWidth',1.2,'LineStyle','none')
    ylim(axishandle,'auto')
    if ~isnan(y)
      if y>0; valign='bottom';
      else valign='top';
      end
      text('Position',[x,0],'String',sprintf('%1.*f',decimals(ax),y),'Parent',axishandle,'UserData',dataid(dataset),'Tag',fittype{1},'UIContextMenu',textvalue, ...
           'FontSize',7,'Color','w','HorizontalAlignment','center','VerticalAlignment',valign) %'FontName','FixedWidth',
    end
  end

set(handles.k_axes,'YLim',[0 max([max(get(handles.k_axes,'YLim')) 1.05])])
set(handles.r_axes,'YLim',[0 1.01])
end
function resultplot_type2(value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
Style=getappdata(handles.figure,'style');
linewidth=[1 2 2 2 2];
decimals=[1 2 2 1 2];
if length(value)==1
  decimals(1)=0;
end

% Tags for plot-objects
dataid=get(handles.plotviewpanel,'UserData');
fittype={'type1' 'type2'};

% x-positions
pBpos=dataset;
wpos={[NaN 1 2] [NaN 3 4]};
wpos=wpos{dataset};

% Number of points & B parameter
data={STRUCT.points(value) STRUCT.B(value)};
fits={'wB' 'wnl' 'wlin'};
f=1;
for ax=1:2 
  barerrorbar(pBpos,data{ax},handles.resultaxes(ax))
end

% Weibull parameters
param={'k' 'lambda' 'rsquare'};
row=[1 1 get(handles.distrpanel,'UserData')];
for ax=3:5
  for f=2:3
    data=STRUCT.(fits{f}).(param{ax-2})(row(ax-2),value);
    barerrorbar(wpos(f),data,handles.resultaxes(ax))
  end
end

  function barerrorbar(x,data,axishandle)
    y=nanmean(data);
    ystd=nanstd(data);
    ysem=ystd/sqrt(sum(~isnan(data)));
    textvalue=uicontextmenu;
    uimenu(textvalue,'Label',sprintf('mean=%1.4f',y))
    uimenu(textvalue,'Label',sprintf('std=%1.4f',ystd))
    uimenu(textvalue,'Label',sprintf('sem=%1.4f',ysem))
    bar(x,y,'Parent',axishandle,'UserData',dataid(dataset),'Tag',fittype{2},'DisplayName',get(handles.(sprintf('name%d',dataset)),'String'),'UIContextMenu',textvalue, ...
       'FaceColor',Style.DuoColor(dataset,:),'EdgeColor',Style.Fits(f).Color,'LineWidth',linewidth(ax))
    errorbar(x,y,ysem,'Parent',axishandle,'UserData',dataid(dataset),'Tag',fittype{2}, ...
       'Color',Style.Fits(f).Color,'LineWidth',1.2,'LineStyle','none')
    ylim(axishandle,'auto')
    if ~isnan(y)
      if y>0; valign='bottom';
      else valign='top';
      end
      text('Position',[x,0],'String',sprintf('%1.*f',decimals(ax),y),'Parent',axishandle,'UserData',dataid(dataset),'Tag',fittype{2},'UIContextMenu',textvalue, ...
           'FontSize',7,'Color','w','HorizontalAlignment','center','VerticalAlignment',valign) %'FontName','FixedWidth',
    end
  end

set(handles.k_axes,'YLim',[0 max([max(get(handles.k_axes,'YLim')) 1.05])])
set(handles.r_axes,'YLim',[0 1.01])
end

function [x,y,xfit,fitfcn]=load_data(value,STRUCT,handles)
halfbin=0.5;
% Determine distribution
switch get(handles.distrpanel,'UserData')
  case 1
    y=STRUCT.histogram(STRUCT.startpoint:end,value);
    x=[0:size(y,1)-1]';
    xfit=[0:0.05:size(y,1)-halfbin]';
    fitfcn=@(x,k,lambda)( (repmat(k./lambda,[size(x,1) 1]).*(x*(1./lambda)).^repmat(k-1,[size(x,1) 1])) .* exp(- (x*(1./lambda)) .^repmat(k,[size(x,1) 1])) );
    set(handles.yscale,'Value',1)
    set(handles.xscale,'Value',1)
  case 2
    y=STRUCT.survival_histogram(STRUCT.startpoint:end,value);
    x=[0 halfbin:size(y,1)-1]';
    xfit=[0:0.05:size(y,1)-halfbin]';
    fitfcn=@(x,k,lambda)(exp(-(x*(1./lambda)).^repmat(k,[size(x,1) 1])));
    set(handles.yscale,'Value',2)
    set(handles.xscale,'Value',1)
  case 3
    y=-log(STRUCT.survival_histogram(STRUCT.startpoint+1:end,value));
    x=[halfbin:size(y,1)-halfbin]';
    xfit=[halfbin-0.05:0.05:size(y,1)+halfbin]';
    fitfcn=@(x,k,lambda)((x*(1./lambda)).^repmat(k,[size(x,1) 1]));
    set(handles.yscale,'Value',2)
    set(handles.xscale,'Value',2)
end
% Set y- and x-axes to appropriate scales
yscale_Callback(handles.yscale,[],handles)
xscale_Callback(handles.xscale,[],handles)
end
function [x,y,xfit,fitfcn]=load_superflydata(histogram,survival_histogram,startpoint,handles)
halfbin=0.5;
% Determine distribution
switch get(handles.distrpanel,'UserData')
  case 1
    y=histogram(startpoint:end);
    x=[0:size(y,1)-1]';
    xfit=[0:0.05:size(y,1)-0.5]';
    fitfcn=@(x,k,lambda)( (repmat(k./lambda,[size(x,1) 1]).*(x*(1./lambda)).^repmat(k-1,[size(x,1) 1])) .* exp(- (x*(1./lambda)) .^repmat(k,[size(x,1) 1])) );
    set(handles.yscale,'Value',1)
    set(handles.xscale,'Value',1)
  case 2
    y=survival_histogram(startpoint:end);
    x=[0 halfbin:size(y,1)-1]';
    xfit=[0:0.05:size(y,1)-0.5]';
    fitfcn=@(x,k,lambda)(exp(-(x*(1./lambda)).^repmat(k,[size(x,1) 1])));
    set(handles.yscale,'Value',2)
    set(handles.xscale,'Value',1)
  case 3
    y=-log(survival_histogram(startpoint+1:end));
    x=[halfbin:size(y,1)-halfbin]';
    xfit=[halfbin-0.05:0.05:size(y,1)+0.5]';
    fitfcn=@(x,k,lambda)((x*(1./lambda)).^repmat(k,[size(x,1) 1]));
    set(handles.yscale,'Value',2)
    set(handles.xscale,'Value',2)
end
% Set y- and x-axes to appropriate scales
yscale_Callback(handles.yscale,[],handles)
xscale_Callback(handles.xscale,[],handles)
end

function [distr]=eventmatrix(value,STRUCT,dataset,handles)
EXPDATA=getappdata(handles.figure,sprintf('exp%d',dataset));
distr=NaN(size(EXPDATA.activity));
distr([STRUCT.matrix(:,2)])=STRUCT.matrix(:,1);
distr=distr(:,value);
end
function [B,k,lambda]=fit_supermean(y_surv,n,mu,sigma,f)
switch f
  case 1
    %%% B %%%
    B=(nanmean(sigma)-nanmean(mu))/(nanmean(sigma)+nanmean(mu));
    k_int=[0.1:0.001:10];
    B_int=-(gamma(1+1./k_int)-sqrt(gamma(1+2./k_int)-(gamma(1+1./k_int).^2)))./sqrt(gamma(1+2./k_int)-(gamma(1+1./k_int).^2));
    k=interp1(B_int,k_int,B);
    lambda=nanmean(mu)/gamma(1+1/k);
    
  case 2
    %%% Weibull non-linear fit %%%
    warning 'off' curvefit:fit:noStartPoint

    halfbin=1/2; % To compensate for binsize effects on survival histograms
    f_Weibull_survival=fittype('-(x/lambda)^k');
    opts=fitoptions('Method','NonlinearLeastSquares');
    fit_ok=false;
    
    x=[0 halfbin:size(y_surv,1)-halfbin-1]';
    y_n=sum(logical(~isnan(y_surv)),2);
    x=x(y_n>=n,:);
    y_surv=y_surv(y_n>=n,:);
    
    y0=y_surv;
    y0(isnan(y0))=0;
    y=mean(y0,2);
    while ~fit_ok && ~isempty(y)
      try [fit_Weibull_survival] = fit(x, log(y), f_Weibull_survival, opts);
        k=fit_Weibull_survival.k;
        lambda=fit_Weibull_survival.lambda;
        fit_ok=true;
      catch
        y_shorter=y(logical(y>y(end)));
        if ~isempty(y_shorter)
          y_shorter(logical(y_shorter==y_shorter(end)))=y_shorter(end)+y(end);
        end
        y=y_shorter;
      end
    end
    if ~fit_ok
      k=NaN;
      lambda=NaN;
    end
    B=NaN;
    
  case 3
    %%% Weibull linear fit %%%
    y_surv=y_surv(2:end,:);
    y_surv(y_surv>0.9999)=NaN;
    halfbin=1/2; % To compensate for binsize effects on survival histograms
    x=[halfbin:size(y_surv,1)-halfbin]';
    y_n=sum(logical(~isnan(y_surv)),2);
    x=x(y_n>=n,:);
    y_surv=y_surv(y_n>=n,:);
    
    y0=y_surv;
    y0(isnan(y0))=0;
    y=log(-log(mean(y0,2)));
    x(~isfinite(y))=NaN;
    x=log(x);
    k=nansum((x-repmat(nanmean(x,1),[size(x,1) 1])).*(y-repmat(nanmean(y,1),[size(y,1) 1])))./nansum((x-repmat(nanmean(x,1),[size(x,1) 1])).^2);
    lambda=exp(-(nanmean(y,1)-k*nanmean(x,1))/k);
    if all([k lambda]==0)
      k=NaN;
      lambda=NaN;
    end
    B=NaN;

end

end
function r2=calc_rsquare(y,k,lambda,value,dataset,handles)
% Load data
STRUCT=getappdata(handles.figure,sprintf('struct%d',dataset));
r2=nan(1,3);
halfbin=0.5;
switch get(handles.distrpanel,'UserData')
  case 1
    y=y(2:end); 
    for f=2:3
      y_fit=STRUCT.weibull_pdf([1:size(y,1)]',k(f),lambda(f));
      y_fit(isnan(y))=NaN;
      r2(f)= 1 - ( nansum( (y - y_fit).^2 ) ./ nansum( (y-repmat(nanmean(y,1),[size(y,1) 1])).^2 ) );
    end
    
  case 2
    y=log(y(2:end));
    for f=2:3
      y_fit=STRUCT.weibull_survival([halfbin:size(y,1)]',k(f),lambda(f));
      y_fit(isnan(y))=NaN;
      r2(f)= 1 - ( nansum( (y - y_fit).^2 ) ./ nansum( (y-repmat(nanmean(y,1),[size(y,1) 1])).^2 ) );
    end

  case 3
    y=log(y(1:end)); % y is already from (startpoint+1)!
    for f=2:3
      y_fit=STRUCT.weibull_lin(log([halfbin:size(y,1)])',k(f),lambda(f));
      y_fit(isnan(y))=NaN;
      r2(f)= 1 - ( nansum( (y - y_fit).^2 ) ./ nansum( (y-repmat(nanmean(y,1),[size(y,1) 1])).^2 ) );
    end
   
end
end

