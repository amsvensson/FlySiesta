function varargout = fsanalyzer(varargin)
% FlySiesta Analyzer - Create FlySiesta files from DAMS recordings 
% and calculate activity and sleep parameters.
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
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fsanalyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @fsanalyzer_OutputFcn, ...
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
function varargout = fsanalyzer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
end

function fsanalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% Version
FlySiesta_version=fsabout('version');

% Tweak initiation
 set(handles.figure,'Name','FlySiesta Analyzer','UserData',FlySiesta_version)
 handles.tab=1;
 set(handles.enddate,'Enable','off')
 set(handles.analyze,'Visible','off','UserData',true)                                       % Indicates if Analysis finished OK
 if ispref('FlySiesta_Analyzer','lightson')                                                 % Retreive Light cycle, if stored as Pref.
   set(handles.lightson,'Value',getpref('FlySiesta_Analyzer','lightson')); end              % - " -
 if ispref('FlySiesta_Analyzer','lightsoff')                                                % - " -
   set(handles.lightsoff,'Value',getpref('FlySiesta_Analyzer','lightsoff')); end            % - " -
  times=get(handles.lightson,'String');
  set(handles.textstarttime1,'String',['at ' times{get(handles.lightson,'Value')} ' h'])
  set(handles.textstarttime2,'String',['at ' times{get(handles.lightson,'Value')} ' h'])
 set(handles.advancedoptions,'Value',0)                                                     % Turn Advanced Panel OFF as default
  state={'off','on'};
  set(handles.advancedpanel,'Visible',state{get(handles.advancedoptions,'Value')+1})        % - " -
  set(handles.s_advancedpanel,'Visible',state{get(handles.advancedoptions,'Value')+1})      % - " -
 set(handles.method,'UserData',1)                                                           % Default nr of reps for non-linear Weibull fit
  handles.fitmethods=true(3,1);                                                             % Default, perform all fit methods
 movegui(handles.figure,'center')
 set(findobj(handles.figure,'Units','pixels'),'Units','characters')
 set(get(handles.figure,'Children'),'HandleVisibility','callback')
 
% Load Button Icons
try load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'])
end
set(handles.help,'CData',help_mine,'ToolTip','Online User Guide','Background',get(handles.bottompanel,'BackgroundColor'))
set(handles.info,'CData',about_mine,'ToolTip','About','Background',get(handles.bottompanel,'BackgroundColor'))
set(handles.infodirbutton,'CData',settings)
set(handles.adddirbutton,'CData',recfolder_add)
set(handles.addbutton,'CData',recfile_add)
set(handles.removebutton,'CData',recfile_delete)
if exist('uicalendar')==0; set(handles.calendar,'Visible','off')
else set(handles.calendar,'CData',open_calendar); end
set(handles.savebutton,'CData',fs_save)

% Assure tabpanel works properly
TabPanel=get(handles.TBP_tabpanel,'UserData');
TabPanel.Filename='fsanalyzer.fig';
TabPanel.Color{1}=get(0,'defaultUicontrolBackgroundColor');
set(handles.TBP_tabpanel,'UserData',TabPanel)

% Create structures
EXPDATA=struct('name',[],'number_of_flies',NaN(1,3),'sleep_threshold',NaN(1),'lights',NaN(1,2),'setperiods',NaN(2,2),'days',NaN(1),'activity',[],'sleep',[],'id_index',[],'monitor_index',[],'matrix_index',[],'FlySiesta_version',FlySiesta_version);
SETTINGS=struct('savename',[],'filelist',[],'dirlist',[], ...
                'alist',[],'flist',[],'mlist',[],'olist',[], ...
                'lights',[],'daysindex',[],'setperiods',[],'threshold',[], ...
                'analysis_points',[],'valid_dates',[], 'info',[]);

% Save Init Data
setappdata(handles.figure,'exp',EXPDATA)
setappdata(handles.figure,'settings',SETTINGS)
handles.output = hObject;   % Choose default command line output for FlySiesta
guidata(hObject, handles);  % Update handles structure
end


%% Create Functions %%
% tab 1
function damsfiles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% tab 2
function alist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function flist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function mlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function olist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% tab 3
function lightson_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function lightsoff_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function daysmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function advancedoptions_CreateFcn(hObject, eventdata, handles)
end
function lightbegin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function lightend_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function darkbegin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function darkend_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function threshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% tab 4
function info_genotype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function info_description_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function info_condition_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function info_age_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function info_temp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% tab 5
function saveinput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%% COMMON BUTTONS & FUNCTIONS %%
function tabpanel_TabSelectionChange_Callback(hObject,eventdata,handles)
if eventdata.OldValue==1
  set(handles.prev,'Enable','on')
end
if eventdata.NewValue==1
  set(handles.prev,'Enable','off')
end
if eventdata.NewValue==5
  set(handles.next,'Enable','off')
  set(handles.analyze,'Visible','on')
  update_summary(handles)
end
if eventdata.OldValue==5 && eventdata.NewValue~=5
  set(handles.next,'Enable','on')
  set(handles.analyze,'Visible','off')
end
handles.tab=eventdata.NewValue;
guidata(handles.figure,handles)
end
function change_tabs(new_tab,handles)
TabPanel.H = get(handles.TBP_tabpanel,'UserData');
TabPanel.old = get(TabPanel.H.TopPanel,'UserData');
if TabPanel.H.Tab(TabPanel.old)~=TabPanel.H.Tab(new_tab)
  TabPanel.h = [TabPanel.H.Main TabPanel.H.Panel TabPanel.H.TopPanel TabPanel.H.Tab TabPanel.H.TopTab];
  TabPanel.units = get(TabPanel.h,'units');
  set(TabPanel.h,'units','pixel');
  TabPanel.p = get(TabPanel.H.Tab(new_tab),'pos');
  TabPanel.pTP = get(TabPanel.H.TopPanel,'pos');
  set(TabPanel.H.Tab(TabPanel.old),'pos',[TabPanel.pTP(1) TabPanel.p(2) TabPanel.pTP(3) TabPanel.p(4)],'back',TabPanel.H.Color{3},'fore',TabPanel.H.Color{4});
  TabPanel.pP = get(TabPanel.H.Panel(1),'pos');
  set(TabPanel.H.TopPanel,'pos',[TabPanel.p(1) TabPanel.pP(4) TabPanel.p(3) TabPanel.pTP(4)],'UserData',new_tab);
  set(TabPanel.H.TopTab  ,'pos',[TabPanel.p(1)+1 TabPanel.pP(4) TabPanel.p(3)-2 1]);
  set(TabPanel.H.Tab(new_tab),'pos',TabPanel.p+[1 floor(-diff(TabPanel.H.TabHeight(2:3))/2-.5) -2 0],'back',TabPanel.H.Color{1},'fore',TabPanel.H.Color{2},'enable','inactive');
  set(TabPanel.h,{'units'},TabPanel.units);
  set(TabPanel.H.Panel(TabPanel.H.Tab~=TabPanel.H.Tab(new_tab)),'Visible','off');
  set(TabPanel.H.Panel(TabPanel.H.Tab==TabPanel.H.Tab(new_tab)),'Visible','on');
  try
    tmp.EventName = 'TabSelectionChanged';
    tmp.OldValue = TabPanel.old;
    tmp.NewValue = new_tab;
    eval(sprintf('%s(''%s_TabSelectionChange_Callback'',gcbf,tmp,guidata(gcbf))',TabPanel.H.Filename(1:end-4),TabPanel.H.Tag));
  end
  drawnow
end
end

function about_ButtonDownFcn(hObject,eventdata,handles)
fsabout;
end
function help_Callback(hObject, eventdata, handles)
stat=web('http://www.neural-circuits.org/flysiesta/userguide/','-browser');
if logical(stat)
  web('http://www.neural-circuits.org/flysiesta/userguide/')
end
end
function info_Callback(hObject, eventdata, handles)
fsabout;
end
function prev_Callback(hObject, eventdata, handles)
% Browsing
if handles.tab==5
  set(handles.next,'Enable','on')
  set(handles.analyze,'Visible','off')
end
if handles.tab>1
  change_tabs(handles.tab-1,handles)
  handles.tab=handles.tab-1;
end
if handles.tab==1
  set(handles.prev,'Enable','off')
end
guidata(handles.figure,handles)
end
function next_Callback(hObject, eventdata, handles)
% Browsing
if handles.tab<5
  change_tabs(handles.tab+1,handles)
  handles.tab=handles.tab+1;
  set(handles.prev,'Enable','on')
end
if handles.tab==5
  set(handles.next,'Enable','off')
  set(handles.analyze,'Visible','on')
  update_summary(handles)
end
guidata(handles.figure,handles)
end


%% TAB 1 %%
function infofile_Callback(hObject, eventdata, handles)
set(handles.tab1radio1,'Value',1)
set(handles.tab1radio2,'Value',0)
load_settings(hObject,handles)
end
function infodirbutton_Callback(hObject, eventdata, handles)
set(handles.tab1radio1,'Value',1)
set(handles.tab1radio2,'Value',0)
if isempty(eventdata)
  [FSfile,FSpath]=uigetfile({'*.settings' ; '*.txt'});
else
  FSpath=eventdata{1};
  FSfile=eventdata{2};
end
if ~isequal(FSfile,0)
  set(handles.infofile,'String',[FSpath FSfile]);
  load_settings(hObject,handles)
end
end
function load_settings(hObject,handles)
SettingsNamePath=get(handles.infofile,'String');
if ~isempty(SettingsNamePath)
  [Path,Name,Ext]=fileparts(SettingsNamePath);
  if strcmp(Ext,'.settings')
    load('-mat',SettingsNamePath);
    true_settings=true;
  elseif strcmp(Ext,'.txt')
    SETTINGS=load_resumefile(SettingsNamePath,handles);
    true_settings=false;
  end
end
if exist('SETTINGS','var')
  set(handles.infodirbutton,'UserData',cd)  % Save initial path
  cd(Path)
  try fgetl(fopen([SETTINGS.dirlist{1} filesep SETTINGS.filelist{1}]));
    files_exist=true;
  catch
    answer=questdlg({'Outdated or corrupted settings file: Cannot open target files!' 'This can happen if the directory of the DAMS' 'recording files has been moved or renamed.' '' 'Do you want to select the new location of the files?' ''},'Recording Files Not Found','Yes','No','Yes');
    switch answer
      case 'Yes'
        newpath=uigetdir('',['Select Directory for ' Name]);
        newpath=relative_path(Path,newpath);
        % Test if files exist in new path
        fid=fopen([newpath filesep SETTINGS.filelist{1}]);
        if fid ~= -1
          fclose(fid);
          if ischar(newpath)
            for i=1:size(SETTINGS.dirlist,1)
              SETTINGS.dirlist{i}=newpath;
            end
            files_exist=true;
          else
            files_exist=false;
          end
        else
          h_dlg=warndlg({'Error - Files not found!' '' 'Target DAMS files could not be' 'found in the selected directory.' ''},'Error: File not found','modal');
          figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
          uiwait(h_dlg)
          set(handles.infofile,'String','')
          files_exist=false;
        end
      case 'No'
        set(handles.infofile,'String','')
        files_exist=false;
    end
  end

  if files_exist
    % Common
    % SETTINGS.analysis_points (No Target)
    % SETTINGS.valid_dates     (No Target)

    % Tab 1
    set(handles.damsfiles,'String',SETTINGS.filelist,'UserData',SETTINGS.dirlist)

    guidata(handles.figure,handles)
    read_activity_matrix(hObject,handles)
    % Tab 2
    set(handles.alist,'String',SETTINGS.alist{1},'UserData',SETTINGS.alist{2})
    set(handles.flist,'String',SETTINGS.flist{1},'UserData',SETTINGS.flist{2})
    set(handles.mlist,'String',SETTINGS.mlist{1},'UserData',SETTINGS.mlist{2})
    set(handles.olist,'String',SETTINGS.olist{1},'UserData',SETTINGS.olist{2})
    % Tab 3
    set(handles.lightson,'Value',SETTINGS.lights(1))
    set(handles.lightsoff,'Value',SETTINGS.lights(2))
    if SETTINGS.lights(1)==SETTINGS.lights(2)
      set(handles.darkdark,'Value',1)
      darkdark_Callback(handles.darkdark,[],handles)
    end
    set(handles.startdate,'String',datestr(SETTINGS.valid_dates(SETTINGS.daysindex(1))),'UserData',SETTINGS.daysindex(1))
    set(handles.daysmenu,'String',num2str([1:length(SETTINGS.valid_dates)-SETTINGS.daysindex(1)]'),'Value',SETTINGS.daysindex(2)-SETTINGS.daysindex(1))
    set(handles.enddate,'String',datestr(SETTINGS.valid_dates(SETTINGS.daysindex(2))),'UserData',SETTINGS.daysindex(2))
    if all(SETTINGS.setperiods(1,:)~=SETTINGS.lights([1 2])) || all(SETTINGS.setperiods(2,:)~=SETTINGS.lights([2 1]))
      set(handles.advancedoptions,'Value',1)
      set(handles.advancedpanel,'Visible','on')
      set(handles.s_advancedpanel,'Visible','on')
    end
    set(handles.lightbegin,'Value',SETTINGS.setperiods(1,1))
    set(handles.lightend,'Value',SETTINGS.setperiods(1,2))
    set(handles.darkbegin,'Value',SETTINGS.setperiods(2,1))
    set(handles.darkend,'Value',SETTINGS.setperiods(2,2))
    set(handles.threshold,'Value',SETTINGS.threshold)
    % Tab 4
    set(handles.info_genotype,'String',SETTINGS.info{1})
    set(handles.info_condition,'String',SETTINGS.info{2})
    set(handles.info_description,'String',SETTINGS.info{3})
    set(handles.info_age,'String',SETTINGS.info{4})
    set(handles.info_temp,'String',SETTINGS.info{5})
    set(handles.radiocelcius,'Value',SETTINGS.info{6}(1))
    set(handles.radiofarenheit,'Value',SETTINGS.info{6}(2))
    % Tab 5
    if true_settings
      SETTINGS.savename=[SettingsNamePath(1:end-8) 'mat'];
      set(handles.saveinput,'String',SETTINGS.savename)
    end

    setappdata(handles.figure,'settings',SETTINGS)
  end

else
  h_dlg=errordlg('Error: No Settings File Found!','Error','modal');
  figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
  setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
  uiwait(h_dlg)
end

end
function SETTINGS=load_resumefile(stringinfo,handles)
% Load Files
filepaths='./';
fid=fopen(stringinfo);
fgetl(fid);
file_common=fgetl(fid);
nr_all=sscanf(fgetl(fid),'%f');
channels=[nr_all(1):nr_all(2)];
files=cell(length(channels),1);
dirs=cell(length(channels),1);
for i=1:length(channels)
  if channels(i)<10
    files{i}=[file_common 'C0' num2str(channels(i)) '.txt'];
  else
    files{i}=[file_common 'C' num2str(channels(i)) '.txt'];
  end
  dirs{i}=filepaths;
end
set(handles.damsfiles,'String',files,'UserData',dirs)
guidata(handles.figure,handles)
read_activity_matrix(handles.addbutton,handles)

SETTINGS=getappdata(handles.figure,'settings');
SETTINGS.threshold=5;
SETTINGS.savename='Browse or type save path!';

% Fly Selection
f_boundaries=sscanf(fgetl(fid),'%f');
m_boundaries=sscanf(fgetl(fid),'%f');
[fch,fi]=intersect(channels,[f_boundaries(1):f_boundaries(2)]);
[mch,mi]=intersect(channels,[m_boundaries(1):m_boundaries(2)]);
fmales={fi mi};
list={'flist' 'mlist'};
for ilist=1:2
  if ~isempty(fmales{ilist})
    [inlist,blah,listindex]=intersect(fmales{ilist},get(handles.alist,'UserData'));
    if ~isempty(listindex)
      set(handles.alist,'Value',listindex)
      move_files_between_lists('alist',list{ilist},handles)
    end
  end
end
exclude=sscanf(fgetl(fid),'%f');
if ~isempty(exclude)
  list={'alist' 'flist' 'mlist'};
  for ilist=1:3
    [inlist,blah,listindex]=intersect(exclude,get(handles.(list{ilist}),'UserData'));
    if ~isempty(listindex)
      set(handles.(list{ilist}),'Value',listindex)
      move_files_between_lists(list{ilist},'olist',handles)
    end
  end
end
SETTINGS.alist={get(handles.alist,'String') get(handles.alist,'UserData')};
SETTINGS.flist={get(handles.flist,'String') get(handles.flist,'UserData')};
SETTINGS.mlist={get(handles.mlist,'String') get(handles.mlist,'UserData')};
SETTINGS.olist={get(handles.olist,'String') get(handles.olist,'UserData')};

% Light Cycles
SETTINGS.lights(1)=abs(sscanf(fgetl(fid),'%f'));
SETTINGS.lights(2)=abs(sscanf(fgetl(fid),'%f'));

% Analysis Period
hours_start_analysis=sscanf(fgetl(fid),'%f');
days_of_analysis=sscanf(fgetl(fid),'%f');
SETTINGS.daysindex(1)=find(hours_start_analysis*60==(SETTINGS.analysis_points-1));
SETTINGS.daysindex(2)=SETTINGS.daysindex(1)+days_of_analysis;

variable_line=abs(sscanf(fgetl(fid),'%f'))';
if ~isempty(variable_line)
  SETTINGS.setperiods(1,:)=variable_line;
  SETTINGS.setperiods(2,:)=abs(sscanf(fgetl(fid),'%f'))';
  set(handles.advancedoptions,'Value',1)
  set(handles.advancedpanel,'Visible','on')
  fgetl(fid);
  fgetl(fid);
else
  SETTINGS.setperiods(1,:)=SETTINGS.lights([1 2]);
  SETTINGS.setperiods(2,:)=SETTINGS.lights([2 1]);
  fgetl(fid);
end

% Optional Info
readline=fgetl(fid); SETTINGS.info{1}=readline(10:end);
readline=fgetl(fid); SETTINGS.info{4}=readline(5:end);
readline=fgetl(fid); SETTINGS.info{5}=readline(13:end);
SETTINGS.info{6}=[1 0];

set(handles.info_genotype,'String',SETTINGS.info{1})
set(handles.info_age,'String',SETTINGS.info{4})
set(handles.info_temp,'String',SETTINGS.info{5})

fclose(fid);

setappdata(handles.figure,'settings',SETTINGS)
end
function damsfiles_Callback(hObject, eventdata, handles)
end
function adddirbutton_Callback(hObject, eventdata, handles)
set(handles.tab1radio1,'Value',0)
set(handles.tab1radio2,'Value',1)
if isempty(get(handles.damsfiles,'UserData'))
  set(handles.damsfiles,'String','')
end
damsdir=uigetdir('','Select Directory Containing the DAMS Files');
if ~isequal(damsdir,0)
  dirfiles=dir(damsdir);
  files=cell(size(dirfiles,1),1);
  dirs=cell(size(dirfiles,1),1);
  dams_file=false(size(dirfiles,1),1);
  for i=1:size(dirfiles,1)
    namei=regexp(dirfiles(i).name,'.*M\d\d\dC\d\d.txt','match');
    if ~isempty(namei)
      dams_file(i)=true;
      files(i)=namei;
      dirs{i}=damsdir;
    end
  end
  files=files(dams_file);
  dirs=dirs(dams_file);
  oldfiles=get(handles.damsfiles,'String');
  olddirs=get(handles.damsfiles,'UserData');
  set(handles.damsfiles,'String',[oldfiles ; files],'Value',[],'UserData',[olddirs ; dirs])
end
guidata(handles.figure,handles)
read_activity_matrix(hObject,handles)
end
function addbutton_Callback(hObject, eventdata, handles)
set(handles.tab1radio1,'Value',0)
set(handles.tab1radio2,'Value',1)
if isempty(get(handles.damsfiles,'UserData'))
  set(handles.damsfiles,'String','')
end
[input_files,input_dir]=uigetfile('*.txt','Select DAMS File(s)','MultiSelect','on');

if iscell(input_files); input_files=input_files';
else input_files={input_files};
end
if ~isequal(input_files{1},0)
  newfiles=cell(size(input_files,1),1);
  newdirs=cell(size(input_files,1),1);
  dams_file=false(size(input_files,1),1);
  for i=1:size(input_files,1)
    namei=regexp(input_files{i},'.*M\d\d\dC\d\d.txt','match');
    if ~isempty(namei)
      dams_file(i)=true;
      newfiles(i)=namei;
      newdirs{i}=input_dir;
    end
  end
  newfiles=newfiles(dams_file);
  newdirs=newdirs(dams_file);
  oldfiles=get(handles.damsfiles,'String');
  olddirs=get(handles.damsfiles,'UserData');
  set(handles.damsfiles,'String',[oldfiles ; newfiles],'UserData',[olddirs ; newdirs])
end
guidata(handles.figure,handles)
read_activity_matrix(hObject,handles)
end
function removebutton_Callback(hObject, eventdata, handles)
set(handles.tab1radio1,'Value',0)
set(handles.tab1radio2,'Value',1)

selected=get(handles.damsfiles,'Value');
files=get(handles.damsfiles,'String');
dirs=get(handles.damsfiles,'UserData');
set(handles.damsfiles,'String',files(setdiff([1:length(files)],selected)),'Value',[],'ListboxTop',1,'UserData',dirs(setdiff([1:length(dirs)],selected)));
guidata(handles.figure,handles)
read_activity_matrix(hObject,handles)
end


%% TAB 2 %%
function alist_Callback(hObject, eventdata, handles)
end
function flist_Callback(hObject, eventdata, handles)
end
function mlist_Callback(hObject, eventdata, handles)
end
function olist_Callback(hObject, eventdata, handles)
end

function af_Callback(hObject, eventdata, handles)
move_files_between_lists('alist','flist',handles)
end
function fa_Callback(hObject, eventdata, handles)
move_files_between_lists('flist','alist',handles)
end
function am_Callback(hObject, eventdata, handles)
move_files_between_lists('alist','mlist',handles)
end
function ma_Callback(hObject, eventdata, handles)
move_files_between_lists('mlist','alist',handles)
end
function ao_Callback(hObject, eventdata, handles)
move_files_between_lists('alist','olist',handles)
end
function oa_Callback(hObject, eventdata, handles)
move_files_between_lists('olist','alist',handles)
end

function move_files_between_lists(fromlist,tolist,handles)
% get tolist old info
 tolist_strings=get(handles.(tolist),'String')';
 tolist_matrix_index=get(handles.(tolist),'UserData');
% get fromlist old info
 fromlist_strings=get(handles.(fromlist),'String')';
 fromlist_matrix_index=get(handles.(fromlist),'UserData');
 fromlist_selected=get(handles.(fromlist),'Value');
 fromlist_allvalues=[1:size(fromlist_strings,2)];
% set tolist new info
if ~isempty(fromlist_strings)
 tolist_strings=[tolist_strings fromlist_strings(fromlist_selected)];
 tolist_matrix_index=[tolist_matrix_index fromlist_matrix_index(fromlist_selected)];
 [tolist_matrix_index,sortindex]=sort(tolist_matrix_index);
 tolist_strings=tolist_strings(sortindex);
 set(handles.(tolist),'String',tolist_strings,'UserData',tolist_matrix_index)
% set fromlist new info
 fromlist_strings=fromlist_strings(setdiff(fromlist_allvalues,fromlist_selected));
 fromlist_matrix_index=fromlist_matrix_index(setdiff(fromlist_allvalues,fromlist_selected));
 set(handles.(fromlist),'Value',[],'String',fromlist_strings,'UserData',fromlist_matrix_index)
end
end


%% TAB 3 %%
function lightson_Callback(hObject, eventdata, handles)
setpref('FlySiesta_Analyzer','lightson',get(handles.lightson,'Value'))
times=get(handles.lightson,'String');
set(handles.textstarttime1,'String',['at ' times{get(handles.lightson,'Value')} ' h'])
set(handles.textstarttime2,'String',['at ' times{get(handles.lightson,'Value')} ' h'])
set(handles.lightbegin,'Value',get(handles.lightson,'Value'))
set(handles.lightend,'Value',get(handles.lightsoff,'Value'))
set(handles.darkbegin,'Value',get(handles.lightsoff,'Value'))
set(handles.darkend,'Value',get(handles.lightson,'Value'))
analysis_times(handles)
end
function lightsoff_Callback(hObject, eventdata, handles)
setpref('FlySiesta_Analyzer','lightsoff',get(handles.lightsoff,'Value'))
set(handles.lightbegin,'Value',get(handles.lightson,'Value'))
set(handles.lightend,'Value',get(handles.lightsoff,'Value'))
set(handles.darkbegin,'Value',get(handles.lightsoff,'Value'))
set(handles.darkend,'Value',get(handles.lightson,'Value'))
end
function darkdark_Callback(hObject, eventdata, handles)
lightlist={'lightson' 'lightsoff' 'lightbegin' 'lightend' 'darkbegin' 'darkend'};
switch get(hObject,'Value')
  case 0
    for i=1:6; set(handles.(lightlist{i}),'Enable','on'); end
    set(handles.lightsoff,'Value',getpref('FlySiesta_Analyzer','lightsoff'))
    set(handles.lightend,'Value',getpref('FlySiesta_Analyzer','lightsoff'))
    set(handles.darkbegin,'Value',getpref('FlySiesta_Analyzer','lightsoff'))    
  case 1
    for i=1:6; set(handles.(lightlist{i}),'Value',get(handles.lightson,'Value'),'Enable','off'); end
end
end

function startdate_Callback(hObject, eventdata, handles)
check_inputstartdate(handles)
end
function calendar_Callback(hObject, eventdata, handles)
SETTINGS=getappdata(handles.figure,'settings');
if ~isempty(SETTINGS.valid_dates)
  current_startdate=get(handles.startdate,'String');
  h_dlg=uicalendar('SelectionType',1,'InitDate',get(handles.startdate,'String'),'Holiday',SETTINGS.valid_dates(1:end-1),'DateStrColor',[SETTINGS.valid_dates(end) 0.5 0.1 0.1],'DestinationUI',handles.startdate,'WindowStyle','modal');
  figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
  set(h_dlg,'Name','Set Start Analysis Date','Units','pixels','Position',[figurePosition(1)+150 figurePosition(2)+75 dlgPosition(3:4)])
  uiwait(h_dlg)
  if ~isempty(get(handles.startdate,'String'))
    check_inputstartdate(handles)
  else
    set(handles.startdate,'String',current_startdate)
  end
end
end
function check_inputstartdate(handles)
SETTINGS=getappdata(handles.figure,'settings');
input_startdate=datenum(get(handles.startdate,'String'));
valid_startdates=SETTINGS.valid_dates(1:end-1);
[input_date_valid,dateindex]=ismember(input_startdate,valid_startdates);
if input_date_valid
  set(handles.daysmenu,'String',num2str([1:length(SETTINGS.valid_dates)-dateindex]'),'Value',SETTINGS.valid_dates(end)-input_startdate)
  set(handles.startdate,'UserData',dateindex)
  daysmenu_Callback(handles.daysmenu,[],handles)
else
  if input_startdate==SETTINGS.valid_dates(end)
    h_dlg=warndlg('Error: Start and End date cannot be the same!','Date Out of Range','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
  else
    h_dlg=warndlg({'Error: Selected start date is out of range' 'of the DAMS experiment''s data recording!'},'Date Out of Range','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
  end
  set(handles.startdate,'String',datestr(SETTINGS.valid_dates(1)),'UserData',1)
  set(handles.daysmenu,'String',num2str([1:length(SETTINGS.valid_dates)-1]'),'Value',length(SETTINGS.valid_dates)-1)
  set(handles.enddate,'String',datestr(SETTINGS.valid_dates(end)),'UserData',length(SETTINGS.valid_dates))
  daysmenu_Callback(handles.daysmenu,[],handles)
end
end
function daysmenu_Callback(hObject, eventdata, handles)
SETTINGS=getappdata(handles.figure,'settings');
valid_enddates=[datenum(get(handles.startdate,'String'))+1 : SETTINGS.valid_dates(end)];
set(handles.enddate,'String',datestr(valid_enddates(get(handles.daysmenu,'Value'))),'UserData',find(valid_enddates(get(handles.daysmenu,'Value'))==SETTINGS.valid_dates))
end
function enddate_Callback(hObject, eventdata, handles)
end

function advancedoptions_Callback(hObject, eventdata, handles)
state={'off','on'};
set(handles.advancedpanel,'Visible',state{get(handles.advancedoptions,'Value')+1})
set(handles.s_advancedpanel,'Visible',state{get(handles.advancedoptions,'Value')+1})
end

function lightbegin_Callback(hObject, eventdata, handles)
end
function lightend_Callback(hObject, eventdata, handles)
end
function darkbegin_Callback(hObject, eventdata, handles)
end
function darkend_Callback(hObject, eventdata, handles)
end
function threshold_Callback(hObject, eventdata, handles)
end


%% TAB 4 %%
function info_genotype_Callback(hObject, eventdata, handles)
end
function info_description_Callback(hObject, eventdata, handles)
end
function info_condition_Callback(hObject, eventdata, handles)
end
function info_age_Callback(hObject, eventdata, handles)
end
function info_temp_Callback(hObject, eventdata, handles)
end
function radiocelcius_Callback(hObject, eventdata, handles)
set(hObject,'Value',1)
set(handles.radiofarenheit,'Value',0)
end
function radiofarenheit_Callback(hObject, eventdata, handles)
set(hObject,'Value',1)
set(handles.radiocelcius,'Value',0)
end


%% TAB 5 %%

function savebutton_Callback(hObject, eventdata, handles)
defaultstr='Browse or type save path!';
currentstring=get(handles.saveinput,'String');
if isempty(currentstring) || strcmp(currentstring,defaultstr)
  currentstr_valid=false;
  filedirs=get(handles.damsfiles,'UserData');
  if ischar(filedirs{1})
    filedirs=filedirs{1};
    slashes=strfind(filedirs,filesep);
    showname=[filedirs(slashes(end)+1:end) '.mat'];
  else
    showname='experiment_name';
  end
else
  currentstr_valid=true;
  [showpath,showname]=fileparts(currentstring);
end
[savename,savepath]=uiputfile('*.mat','Save File Name',showname);
if ~ischar(savename)
  if currentstr_valid
    savename=showname;
    savepath=showpath;
  else
    savename='';
    savepath='';
  end
end
set(handles.saveinput,'String',[savepath savename])
end
function saveinput_Callback(hObject, eventdata, handles)
string=get(hObject,'String');
if strcmp(string,'Browse or type save path!')
  set(hObject,'String','')
end
end
function preview_Callback(hObject, eventdata, handles)
SETTINGS=getappdata(handles.figure,'settings');
EXPDATA=getappdata(handles.figure,'exp');
if ~isempty(EXPDATA.activity)
  analysisrange=[SETTINGS.analysis_points(get(handles.startdate,'UserData')) SETTINGS.analysis_points(get(handles.enddate,'UserData'))-1];
  excluded=get(handles.olist,'UserData');
  exclude_index=preview_rawdata(EXPDATA.activity,analysisrange,EXPDATA.id_index,excluded);
  if ~isempty(exclude_index)
    % Possibly Include any previously excluded flies
    if ~isempty(excluded)
      % Include chosen excluded
      allolist=1:length(excluded);
      selectolist=allolist(exclude_index(excluded)==0);
      set(handles.olist,'Value',selectolist)
      move_files_between_lists('olist','alist',handles)
      % Mark flies already on the exclude-list, to not try to exclude them again in the next step
      exclude_index(excluded(setdiff(allolist,selectolist)))=0;
    end
    % Possibly Exclude any previously included flies
    exclude=find(exclude_index);
    if ~isempty(exclude)
      list={'alist' 'flist' 'mlist'};
      for ilist=1:3
        [inlist,blah,listindex]=intersect(exclude,get(handles.(list{ilist}),'UserData'));
        if ~isempty(listindex)
          set(handles.(list{ilist}),'Value',listindex)
          move_files_between_lists(list{ilist},'olist',handles)
        end
      end
    end
  end
  update_summary(handles)
end

  function [output]=preview_rawdata(activity,analysis_range,id_index,exclude)
    %%% Create GUI %%%
    analyzerPosition=getpixelposition(gcf);
    preview.figure=figure('Name','Preview Raw Activity Data','NumberTitle','off','IntegerHandle','off','Color',get(0,'defaultUicontrolBackgroundColor'),...
      'Resize','on','MenuBar','none','ToolBar','none','Position',[analyzerPosition(1)-100,analyzerPosition(2)-60,800,480],'Visible','off');%,'WindowStyle','modal');
    preview.axes=axes('Parent',preview.figure,'Color',[0.4 0.4 0.4],'Box','on','XLim',[1 size(activity,1)],'FontSize',8,   ...
      'Layer','top','Units','pixels','Position',[45 95 730 375],'NextPlot','add');
    set(get(preview.axes,'XLabel'),'String','Time (Days)','FontSize',8)
    set(get(preview.axes,'YLabel'),'String','Counts','FontSize',8)
    preview.textwhite=uicontrol('Style','text','Parent',preview.figure,'String','[White Area=Analysis Period]','Units','pixels','Position',[600 60 200 15]);
    zoomCData=[]; load(fullfile(matlabroot,'toolbox\matlab\icons\zoom.mat'));
    preview.zoom=uicontrol('Style','Togglebutton','Callback',{@zoom_Callback},'CData',zoomCData,'ToolTip','Toggle Zoom','Units','pixels','Position',[15 33 23 23]);
    cdata=[]; load(fullfile(matlabroot,'toolbox\matlab\icons\pan.mat'));
    preview.pan=uicontrol('Style','Togglebutton','Callback',{@pan_Callback},'CData',cdata,'ToolTip','Toggle Pan','Units','pixels','Position',[15 9 23 23]);
    preview.controlpanel=uipanel('Parent',preview.figure,'Units','pixels','Position',[45 10 550 45]);
    preview.textcurrent=uicontrol('Style','text','Parent',preview.controlpanel,'String','Current Fly:','Units','pixels','Position',[30 10 60 15]);
    preview.flynr=uicontrol('Style','text','Parent',preview.controlpanel,'String','1','Units','pixels','Position',[90 10 20 15]);
    preview.slider=uicontrol('Style','slider','Parent',preview.controlpanel,'Min',1,'Max',size(activity,2),'Value',1,'SliderStep',[1/size(activity,2) 3/size(activity,2)],'Callback',{@slider_Callback}, ...
      'Units','pixels','Position',[130 10 220 20],'BackgroundColor',[1 1 1]);
    preview.exclude=uicontrol('Style','checkbox','Parent',preview.controlpanel,'String',' Exclude from Analysis','Callback',{@exclude_Callback}, ...
      'Units','pixels','Position',[375 10 135 20],'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    preview.buttonpanel=uipanel('Parent',preview.figure,'Units','pixels','Position',[610 10 165 45]);
    preview.ok=uicontrol('Style','Pushbutton','Parent',preview.buttonpanel,'String','OK','Callback',{@ok_Callback}, ...
      'Units','pixels','Position',[12 10 60 23]);
    preview.cancel=uicontrol('Style','Pushbutton','Parent',preview.buttonpanel,'String','Cancel','Callback',{@cancel_Callback}, ...
      'Units','pixels','Position',[88 10 60 23]);
    set([preview.axes preview.controlpanel preview.textwhite preview.textcurrent preview.flynr preview.slider preview.exclude preview.buttonpanel preview.ok preview.cancel],'Units','normalized');
    set(preview.figure,'Visible','on','Units','characters')
    %     pause(1)

    %%% Initialize GUI %%%
    output=[];
    exindex=zeros(1,size(activity,2));
    exindex(exclude)=1;
    slider_Callback(preview.slider,[])
    uiwait(preview.figure)

    %%% Callback Fncs %%%
    function zoom_Callback(source,event)
      set(preview.pan,'Value',0)
      zoom
    end
    function pan_Callback(source,event)
      set(preview.zoom,'Value',0)
      pan
    end
    function slider_Callback(source,event)
      value=round(get(source,'Value'));
      set(source,'Value',value)
      set(preview.flynr,'String',num2str(id_index(value)))
      set(preview.exclude,'Value',exindex(value))
      plotraw(value)
    end
    function exclude_Callback(source,event)
      value=get(preview.slider,'Value');
      exindex(value)=get(source,'Value');
      plotraw(round(get(preview.slider,'Value')));
    end
    function ok_Callback(source,event)
      output=exindex;
      uiresume(preview.figure)
      delete(preview.figure)
    end
    function cancel_Callback(source,event)
      uiresume(preview.figure)
      delete(preview.figure)
    end

    function plotraw(value)
      delete(findobj([preview.axes],'Tag','flyplot'))
      delete(findobj([preview.axes],'Tag','whitebox'))
      if ~logical(exindex(value))
        fill([analysis_range(1) analysis_range(1) analysis_range(2)+1 analysis_range(2)+1],[0.001 max([1.15*max(activity(:,value)) 1]) max([1.15*max(activity(:,value)) 1]) 0.001],[1 1 1],'Parent',preview.axes,'Tag','whitebox','LineStyle','-','Clipping','on')
      end
      [xstairs,ystairs]=stairs([1 1:size(activity,1) size(activity,1)],[0; activity(:,value); 0]);
      fill(xstairs,ystairs,[0.1 0.1 0.5],'Tag','flyplot','EdgeColor',[0.1 0.1 0.5])
      try set(preview.axes,'XMinorTick','on','XTick',[analysis_range(1)-14400*2:720:size(activity,1)],'XTickLabel',[-20:0.5:ceil(size(activity,1)/1440)],'YLim',[-0.1 max([1.15*max(activity(:,value))+0.1 1])]); end
    end

  end

end
function method_Callback(hObject, eventdata, handles)
[selection,nlreps]=select_fitmethods(handles.fitmethods,get(handles.method,'UserData'));
if ~isempty(selection)
  handles.fitmethods=selection;
  set(handles.method,'UserData',nlreps)
  guidata(hObject, handles);
end
end
function [selection,nlreps]=select_fitmethods(input_selection,input_reps)
figurePosition=getpixelposition(gcf);
fighandles.figure=figure('Name','Fit Methods','NumberTitle','off','IntegerHandle','off','Color',get(0,'defaultUicontrolBackgroundColor'),'Resize','off',...
  'WindowStyle','modal','CloseRequestFcn',{@cancel_Callback},'MenuBar','none','ToolBar','none','Position',[400,300,210,250],'Visible','off');
dlgPosition=getpixelposition(fighandles.figure);
setpixelposition(fighandles.figure,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])

fighandles.title=uicontrol('Style','text','String','Methods Used in Analysis','HorizontalAlignment','left','FontSize',10,'FontWeight','bold','Units','pixels','Position',[10 210 200 20]);
fighandles.wB=uicontrol('Style','checkbox','String',             '  B Parameter','Value',input_selection(1),'HorizontalAlignment','left','FontSize',9,'Units','pixels','Position',[20 175 200 15]);
fighandles.wnl=uicontrol('Style','checkbox','String', '  Weibull Non-Linear Fit','Value',input_selection(2),'HorizontalAlignment','left','FontSize',9,'Units','pixels','Position',[20 145 200 15],'Callback',{@wnl_Callback});
fighandles.nlreps=uicontrol('Style','edit','String',num2str(input_reps),'BackgroundColor','w','FontSize',8,'Units','pixels','Position',[45 115 40 20]);
fighandles.reptext=uicontrol('Style','text','String','Iteration for Best Fit','HorizontalAlignment','left','FontSize',8,'Units','pixels','Position',[90 116 150 15]);
fighandles.wlin=uicontrol('Style','checkbox','String',    '  Weibull Linear Fit','Value',input_selection(3),'HorizontalAlignment','left','FontSize',9,'Units','pixels','Position',[20 85 200 15]);
fighandles.ok=uicontrol('Style','pushbutton','String','OK','FontSize',9,'Callback',{@ok_Callback},'Units','pixels','Position',[25 15 70 28]);
fighandles.cancel=uicontrol('Style','pushbutton','String','Cancel','FontSize',9,'Callback',{@cancel_Callback},'Units','pixels','Position',[110 15 70 28]);

set(fighandles.figure,'Visible','on')
uiwait(fighandles.figure)
delete(fighandles.figure)

  function wnl_Callback(source,event)
    state={'off' 'on'};
    set(fighandles.nlreps,'Enable',state{get(source,'Value')+1})
  end
  function ok_Callback(source,event)
    selection=logical([get(fighandles.wB,'Value') get(fighandles.wnl,'Value') get(fighandles.wlin,'Value')]);
    nlrepstemp=str2double(get(fighandles.nlreps,'String'));
    if ~isempty(nlrepstemp) && isfinite(nlrepstemp)
      nlreps=nlrepstemp;
    else
      nlreps=input_reps;
    end
    uiresume(fighandles.figure)
  end
  function cancel_Callback(source,event)
    selection=[];
    nlreps=[];
    uiresume(fighandles.figure)
  end
end
function analyze_Callback(hObject, eventdata, handles)
ready=check_ready_for_analysis(handles);
if ready
  save_settings(handles)
  main_analysis(handles)
  if get(handles.analyze,'UserData')
    if isempty(eventdata)
      % Clear Memory
      rmappdata(handles.figure,'exp');
      rmappdata(handles.figure,'settings');

      % Ok Button
      h_finished=msgbox({'' '     FlySiesta Analysis Successful!'  ''},'Done','modal');
      figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_finished);
      setpixelposition(h_finished,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
      uiwait(h_finished)

      % Close and Open Welcome Center
      close(handles.figure)
      flysiesta

    else
      if strcmpi(eventdata,'KeepOpen')
        % Do nothing, keep fsanalyzer open
      else
        close(handles.figure)
      end
    end
  else
    h_warn=warndlg({'' '              Analysis Aborted!'  '    Please Restart Analysis to Obtain Results.' ''},'Failed Analysis','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_warn);
    setpixelposition(h_warn,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_warn)
    set(handles.analyze,'UserData',true)
    return
  end
end
end


%% HELP FUNCTIONS %%

function rpath=relative_path(matdir,damsdir)
dirs={[filesep matdir filesep] [filesep damsdir filesep]};
fseps=cell(1,2);
for f=1:2
  fseps{f}=strfind(dirs{f},filesep);
end
dirparts=cell(max(length(fseps{1}),length(fseps{2}))-1,2);
sameparts=false(size(dirparts,1),1);

for i=1:size(dirparts,1)
  for f=1:2
    try dirparts{i,f}=dirs{f}(fseps{f}(i)+1:fseps{f}(i+1)); end
  end
  try
    if strcmp(dirparts{i,1},dirparts{i,2})
      sameparts(i)=true;
    end
  end
end

dirparts=dirparts(~sameparts,:);
for i=1:size(dirparts,1)
  if ~isempty(dirparts{i,1})
    dirparts{i,1}=['..' filesep];
  else
    dirparts{i,1}='';
  end
end

dirparts=dirparts(:);
rpath=['.' filesep];
for i=1:size(dirparts,1)
  rpath=[rpath dirparts{i}];
end
rpath=rpath(1:end-1);
end
function read_activity_matrix(hObject,handles)
filelist=get(handles.damsfiles,'String');
dirlist=get(handles.damsfiles,'UserData');

EXPDATA=getappdata(handles.figure,'exp');
EXPDATA.number_of_flies(1)=size(filelist,1);
EXPDATA.id_index=NaN(1,size(filelist,1));

if hObject~=handles.infodirbutton
  SETTINGS=getappdata(handles.figure,'settings');
  SETTINGS.filelist=filelist;
  SETTINGS.dirlist=dirlist;
end

% Call Toolbox Function
[EXPDATA.activity,IDs,envVars]=readDamsData(filelist,dirlist,EXPDATA.number_of_flies(1));

% #TODO To be changed in future versions(?) - Join into one id matrix! 
% (Complicated because it creates compatibility issues with other FS apps - have to change them all at once.
% That in turn will create broken backwards compatibility - would have to reanalyze all files!)
EXPDATA.id_index=IDs(1,:);
EXPDATA.monitor_index=IDs(2,:);

% If loaded from a settings-file, return to original path
if ~isempty(get(handles.infodirbutton,'UserData'))
  cd(get(handles.infodirbutton,'UserData'))
end

channels=cell(EXPDATA.number_of_flies(1),1);
monitors=cell(EXPDATA.number_of_flies(1),1);

if ~isempty(EXPDATA.activity)
  % Create Strings from Channel and Monitor info
  for id=1:EXPDATA.number_of_flies(1)
    channels{id}=sprintf('Channel %02.0f',EXPDATA.id_index(id));
    monitors{id}=sprintf('Monitor %03.0f',EXPDATA.monitor_index(id));
  end
  
  % Control Recording Info  
  same_data_rec=false(1,3);
  if any(diff(envVars.date))
    h_dlg=msgbox({'' '   Note: Not all files have the same date of recording.   ' ''},'Information','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_dlg)
  else same_data_rec(1)=true;
  end
  if any(diff(envVars.entries)) || any(diff(envVars.time))
    h_dlg=warndlg({'Selected files cannot be analyzed together because the' 'recording period of one or more files differs from the rest!' 'Please choose files with the same recording periods!'},'Warning: Recording Period','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_dlg)
    return;
  else same_data_rec(2)=true;
  end
  if any(diff(envVars.binsize))
    h_dlg=warndlg({'Selected files cannot be analyzed together because the' 'recording binsize of one or more files differs from the rest!' 'Please choose files with the same recording binsize!'},'Warning: Binsize','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_dlg)
    return;
  else same_data_rec(3)=true;
    if envVars.binsize(1)~=1
      h_dlg=warndlg({'Error - Cannot Proceed. This version of FlySiesta' 'only supports DAMS data recorded with binsize=1 min!'},'Error: Binsize','modal');
      figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
      setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
      uiwait(h_dlg)
      return;
    end
  end
  if all(same_data_rec)
    timestr=num2str(envVars.time(1));
    while length(timestr)<4
      timestr=['0' timestr];
    end
    recstartvec=datevec([datestr(envVars.date(1)) ' ' timestr(1:2) ':' timestr(3:4)]);
  else
    recstartvec=[];
  end
else
  recstartvec=[];
end
EXPDATA.matrix_index{1}=[1:size(EXPDATA.id_index,2)];

set(handles.includepanel,'UserData',EXPDATA.id_index)
set(handles.alist,'String',channels,'UserData',EXPDATA.matrix_index{1})
set(handles.flist,'String','','UserData',[])
set(handles.mlist,'String','','UserData',[])
set(handles.olist,'String','','UserData',[])
set(handles.dayspanel,'UserData',recstartvec)
setappdata(handles.figure,'exp',EXPDATA)
guidata(handles.figure,handles);
if hObject~=handles.infodirbutton
  setappdata(handles.figure,'settings',SETTINGS)
  analysis_times(handles)
end

% Automatically exclude flies with no activity the last day (and beyond)
SETTINGS=getappdata(handles.figure,'settings');
beginlastday=SETTINGS.analysis_points(get(handles.enddate,'UserData')-1);
if ~isempty(beginlastday)
  no_activity=find(~any(EXPDATA.activity(beginlastday:end,:)));
  if ~isempty(no_activity)
    set(handles.alist,'Value',no_activity)
    move_files_between_lists('alist','olist',handles)
  end
end

% #TOOLBOX
function [onoffMatrix,IDindex,envVars]=readDamsData(filelist,dirlist,nrflies)
  IDindex=NaN(2,nrflies);
  envVars=struct('date',NaN(1,nrflies),'entries',NaN(1,nrflies),'binsize',NaN(1,nrflies),'time',NaN(1,nrflies));
  if ~isempty(filelist)
    % Determine size of Activity Matrix
    fid=fopen([dirlist{1} filesep filelist{1}]);
    fgetl(fid);
    first_entries=str2double(fgetl(fid));
    fclose(fid);
    onoffMatrix=zeros(first_entries,nrflies,'uint8');
    % Read files and get Activity Matrix
    for i=1:nrflies
      fid=fopen([dirlist{i} filesep filelist{i}]);
      if fid ~= -1
        info=fgetl(fid);
        fly_activity=fscanf(fid,'%d');
        onoffMatrix(:,i)=fly_activity(4:end);
        fclose(fid);
        IDindex(:,i)=[str2double(filelist{i}(end-5:end-4)) str2double(filelist{i}(end-9:end-7))];

        % Get Data Recording Info
        envVars.date(i)=datenum(info(end-10:end),'dd mmm yyyy');
        envVars.entries(i)=fly_activity(1);
        envVars.binsize(i)=fly_activity(2);
        envVars.time(i)=fly_activity(3);
      else
        h_dlg=warndlg({'Error - Cannot Proceed. One or more DAMS data files are missing.' 'Please start over, reselecting the data files.'},'Error: MissingFile','modal');
        try
          figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
        end
        uiwait(h_dlg)
        return;
      end
    end
  else
    onoffMatrix=[];
  end
end

end
function analysis_times(handles)
recstartvec=get(handles.dayspanel,'UserData');
SETTINGS=getappdata(handles.figure,'settings');
EXPDATA=getappdata(handles.figure,'exp');

% Find Date Range Avaliable for Analysis
if ~isempty(EXPDATA.activity) && ~isempty(recstartvec)
  offset=[-1 0 1];
  seconds_between=zeros(1,3);
  for i=1:3
    testday_lightson=datevec(datenum([recstartvec(1:3) get(handles.lightson,'Value') 0 0])+offset(i));
    seconds_between(i)=etime(testday_lightson,recstartvec);
  end
  positive_secs=seconds_between(seconds_between>=0);
  first_startpoint=(positive_secs(1)/60)+1;
  available_length=size(EXPDATA.activity(first_startpoint:end,:),1);
  max_days=floor(available_length/(24*60));
  SETTINGS.analysis_points=first_startpoint+[0:max_days]*24*60';
  SETTINGS.valid_dates=[datenum(recstartvec(1:3))+offset(logical(seconds_between==positive_secs(1))) : datenum(recstartvec(1:3))+offset(logical(seconds_between==positive_secs(1)))+max_days]';
  set(handles.daysmenu,'String',num2str([1:max_days]'),'Value',max_days)
  set(handles.startdate,'String',datestr(SETTINGS.valid_dates(1)),'UserData',1)
  set(handles.enddate,'String',datestr(SETTINGS.valid_dates(end)),'UserData',length(SETTINGS.valid_dates))
else
  SETTINGS.analysis_points=[];
  SETTINGS.valid_dates=[];
  set(handles.daysmenu,'String',' ','Value',1)
  set(handles.startdate,'String',' ','UserData',[])
  set(handles.enddate,'String',' ','UserData',[])
end
setappdata(handles.figure,'settings',SETTINGS)
end
function update_summary(handles)
EXPDATA=getappdata(handles.figure,'exp');
% Number of flies
alist=get(handles.alist,'String');
flist=get(handles.flist,'String');
mlist=get(handles.mlist,'String');
EXPDATA.number_of_flies(1)=length(alist)+length(flist)+length(mlist);
 set(handles.s_nr_all,'String',num2str(EXPDATA.number_of_flies(1))); 
EXPDATA.number_of_flies(2)=length(flist);
 set(handles.s_nr_f,'String',num2str(EXPDATA.number_of_flies(2)))
EXPDATA.number_of_flies(3)=length(mlist);
 set(handles.s_nr_m,'String',num2str(EXPDATA.number_of_flies(3)))
% Analysis Period
EXPDATA.days=get(handles.daysmenu,'Value');
 set(handles.s_analysisperiod,'String',[get(handles.startdate,'String') '    --    ' get(handles.enddate,'String')])  %['from    ' get(handles.startdate,'String') ' ' get(handles.textstarttime1,'String') '     to     ' get(handles.enddate,'String') ' ' get(handles.textstarttime2,'String')]
% Light Cycle
EXPDATA.lights=[get(handles.lightson,'Value') get(handles.lightsoff,'Value')];
 times=get(handles.lightson,'String');
 set(handles.s_lightson,'String',times{EXPDATA.lights(1)})
 set(handles.s_lightsoff,'String',times{EXPDATA.lights(2)})
% Analysis Periods
EXPDATA.setperiods(1,:)=[get(handles.lightbegin,'Value') get(handles.lightend,'Value')];
 set(handles.s_lightperiod,'String',[times{EXPDATA.setperiods(1,1)} ' - ' times{EXPDATA.setperiods(1,2)}])
EXPDATA.setperiods(2,:)=[get(handles.darkbegin,'Value') get(handles.darkend,'Value')];
 set(handles.s_darkperiod,'String',[times{EXPDATA.setperiods(2,1)} ' - ' times{EXPDATA.setperiods(2,2)}])
% Sleep Threshold
EXPDATA.sleep_threshold=get(handles.threshold,'Value');
 set(handles.s_threshold,'String',num2str(EXPDATA.sleep_threshold))

setappdata(handles.figure,'exp',EXPDATA)
end

function answer=check_ready_for_analysis(handles)
EXPDATA=getappdata(handles.figure,'exp');

SaveNamePath=get(handles.saveinput,'String');
if strcmp(SaveNamePath,'Browse or type save path!')
  SaveNamePath='';
  EXPDATA.name=[];
end
if ~isempty(SaveNamePath)
  filename_backwards=strtok(SaveNamePath(end:-1:1),filesep);
  EXPDATA.name=filename_backwards(end:-1:5);
  setappdata(handles.figure,'exp',EXPDATA)
end


ok=false(8,1);
ok(1)=~isempty(EXPDATA.name);
ok(2)=any(EXPDATA.number_of_flies);
ok(3)=~isnan(EXPDATA.sleep_threshold);
ok(4)=~any(isnan(EXPDATA.lights));
ok(5)=~any(any(isnan(EXPDATA.setperiods)));
ok(6)=~isnan(EXPDATA.days);
ok(7)=~isempty(EXPDATA.activity);
ok(8)=~isempty(EXPDATA.id_index);
answer=all(ok);
if ~all(ok)
  if ok==logical([0 0 1 1 1 1 0 0]')
    disp_errordlg('      Choose Files to Analyze!');
  else
    if ~ok(1); disp_errordlg('You must choose a Save name before proceeding!'); end
    if ~ok(2); disp_errordlg('There are not enough flies to analyze!'); end
    if ~ok(3); disp_errordlg('Sleep Threshold is not set!'); end
    if ~ok(4); disp_errordlg('Experiment Lights ON and OFF are not set!'); end
    if ~ok(5); disp_errordlg('Beginning and End of Light and/or Dark Period are not set!'); end
    if ~ok(6); disp_errordlg('The number of days of analysis is not set!'); end
    if ~ok(7); disp_errordlg('Choose Flies to Analyze!'); end
    if ~ok(8); disp_errordlg('Choose Flies to Analyze!'); end
  end
end

  function disp_errordlg(message)
    h_dlg=errordlg(message,'Error: Missing Information','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
    setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    uiwait(h_dlg)
  end

end
function save_settings(handles)
SETTINGS=getappdata(handles.figure,'settings');
% Common
 % SETTINGS.analysis_points (Already set)
 % SETTINGS.valid_dates     (Already set)

% Tab 1
% SETTINGS.filelist         (Already set)
% Convert dirlist to relative paths
if ~strcmp(SETTINGS.dirlist{1}(1),'.')
  for i=1:length(SETTINGS.dirlist)
    SETTINGS.dirlist{i}=relative_path(fileparts(get(handles.saveinput,'String')),SETTINGS.dirlist{i});
  end
end

% Tab 2
SETTINGS.alist={get(handles.alist,'String') get(handles.alist,'UserData')};
SETTINGS.flist={get(handles.flist,'String') get(handles.flist,'UserData')};
SETTINGS.mlist={get(handles.mlist,'String') get(handles.mlist,'UserData')};
SETTINGS.olist={get(handles.olist,'String') get(handles.olist,'UserData')};

% Tab 3
SETTINGS.lights=[get(handles.lightson,'Value') get(handles.lightsoff,'Value')];
SETTINGS.daysindex=[get(handles.startdate,'UserData') get(handles.enddate,'UserData')];
SETTINGS.setperiods=[get(handles.lightbegin,'Value') get(handles.lightend,'Value'); get(handles.darkbegin,'Value') get(handles.darkend,'Value')];
SETTINGS.threshold=get(handles.threshold,'Value');

% Tab 4
SETTINGS.info={get(handles.info_genotype,'String') get(handles.info_condition,'String') get(handles.info_description,'String') get(handles.info_age,'String') get(handles.info_temp,'String') [get(handles.radiocelcius,'Value') get(handles.radiofarenheit,'Value')]};

% Tab 5
[savepath,savename,ext]=fileparts(get(handles.saveinput,'String'));
SETTINGS.savename=[savename ext];
set(handles.saveinput,'UserData',savepath)

save([savepath filesep savename '.settings'],'SETTINGS','-mat')
setappdata(handles.figure,'settings',SETTINGS)
end

function main_analysis(handles)
SETTINGS=getappdata(handles.figure,'settings');
EXPDATA=getappdata(handles.figure,'exp');

% Get Current matrix_index's %
EXPDATA.matrix_index{1}=sort([get(handles.alist,'UserData') get(handles.flist,'UserData') get(handles.mlist,'UserData')]);
EXPDATA.matrix_index{2}=get(handles.flist,'UserData');
EXPDATA.matrix_index{3}=get(handles.mlist,'UserData');

% Trim Activity Matrix to Chosen Analysis Period and to Chosen Flies %
EXPDATA.activity=EXPDATA.activity(SETTINGS.analysis_points(SETTINGS.daysindex(1)):SETTINGS.analysis_points(SETTINGS.daysindex(2))-1,EXPDATA.matrix_index{1});
EXPDATA.id_index=EXPDATA.id_index(EXPDATA.matrix_index{1});

% Find New matrix_index's %
[belongs,EXPDATA.matrix_index{3}]=ismember(EXPDATA.matrix_index{3},EXPDATA.matrix_index{1});
[belongs,EXPDATA.matrix_index{2}]=ismember(EXPDATA.matrix_index{2},EXPDATA.matrix_index{1});
[belongs,EXPDATA.matrix_index{1}]=ismember(EXPDATA.matrix_index{1},EXPDATA.matrix_index{1});

% Calculate Sleep Matrix %
quiescence_bouts=[];
no_activity_index=[];
for nr_fly=1:EXPDATA.number_of_flies(1)
  event_times=find([1; EXPDATA.activity(:,nr_fly); 1]>0);
  if ~isempty(event_times)
    iais_temp=diff(event_times);
    iais=iais_temp(logical(iais_temp-1))-1;
    iais_start_minutes=event_times(iais_temp>1);
    quiescence_bouts=[quiescence_bouts; iais (iais_start_minutes + size(EXPDATA.activity,1)*(nr_fly-1))];
  else
    no_activity_index=[no_activity_index nr_fly];
  end
end
EXPDATA.sleep=zeros(size(EXPDATA.activity),'uint8');
for i=1:size(quiescence_bouts,1)
  if quiescence_bouts(i,1)>=EXPDATA.sleep_threshold
    boutsize=quiescence_bouts(i,2):quiescence_bouts(i,2)+quiescence_bouts(i,1)-1;
    EXPDATA.sleep(boutsize)=1;
  end
end

% Warn about potentially empty channel(s)
if ~isempty(no_activity_index)
  h_dlg=warndlg({'There seems to be empty channel(s) included in the analysis!' ['(Ch: ' num2str(no_activity_index) ')']},'Emtpy Channels','modal');
  figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
  setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
  uiwait(h_dlg)
end

% Save Experiment Info in EXPDATA for Future Calls
EXPDATA.info=SETTINGS.info;

% Calculate BOUTS & IBIs
DISTR=IbiBoutAnalysis_Regular(EXPDATA,handles.analyze,handles.fitmethods,get(handles.method,'UserData'));

% If Analysis OK, save Results
if get(handles.analyze,'UserData')
  setappdata(handles.figure,'exp',EXPDATA)
  save([get(handles.saveinput,'UserData') filesep SETTINGS.savename],'EXPDATA','DISTR')
end

end
function [DISTR]=IbiBoutAnalysis_Regular(EXPDATA,h_analyze,fitmethods,nlreps)
%%%% DEFINITIONS %%%%
ab=uint8(1);
sb=uint8(2);
iai=uint8(3);
isi=uint8(4);

light=uint8(1);
dark=uint8(2);

all_flies=uint8(1);
female=uint8(2);
male=uint8(3);
%%%%%%%%%%%%%%%%%%%%%

% Find number of hours with lights on and off
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
hours_period=[length(hours_light) length(hours_dark)];

% Construct logical array of light and dark periods
logical_periods=false(1440,2);
timeindex=reshape(repmat([EXPDATA.lights(1):24 1:EXPDATA.lights(1)-1],60,1),1,1440);
logical_periods(:,1)=ismember(timeindex,hours_light);
logical_periods(:,2)=ismember(timeindex,hours_dark);

% Find start and end positions (right before and after) of periods
before_period=zeros(EXPDATA.days,2);
after_period=zeros(EXPDATA.days,2);
for period=1:2
  if hours_period(period)>0
    before_period(:,period)=find(logical_periods(:,period),1,'first')-1 + [0:EXPDATA.days-1]*1440 +1;
    after_period(:,period)=find(logical_periods(:,period),1,'last')+1 + [0:EXPDATA.days-1]*1440 +1;
  end
end

% Expand logical_periods to cover all days of analysis, and append one bin before and after as well
logical_periods=[[false false] ; repmat(logical_periods,[EXPDATA.days,1]) ; [false false]];
for period=1:2
  if hours_period(period)>0
    logical_periods(before_period(:,period),period)=true;
    logical_periods(after_period(:,period),period)=true;
  end
end

% Create waitbar (but first delete any previous (from debugging usually)) %
set(0,'ShowHiddenHandles','on')
chroot=get(0,'Children');
chName=get(chroot,'Name');
if ~iscell(chName), chName={chName}; end
delete(chroot(~cellfun(@isempty,strfind(chName,'Analyzing '))))
set(0,'ShowHiddenHandles','off')

figurePosition=getpixelposition(gcf);
h_waitbar=waitbar(0,'','Name',sprintf('Analyzing %s',EXPDATA.name),'CreateCancelBtn','setappdata(gcbf,''canceling'',1)','Pointer','watch');%,'WindowStyle','modal');
dlgPosition=getpixelposition(h_waitbar);
setpixelposition(h_waitbar,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
setappdata(h_waitbar,'canceling',0)
hbar=findobj([get(findobj([get(h_waitbar,'Children')],'Type','axes'),'Children')],'Type','patch');
color=[0.25 0.25 0.75];
set(hbar,'FaceColor',color,'EdgeColor',color);
steps=8; step=0;
drawnow

parameters=[100 1]; % parameters=[max(length(STRUCT.histogram)), minimum number of points in the tail]
warning('off','curvefit:fit:noStartPoint')

for period=1:2
  for event=1:4
    if ishandle(h_waitbar)
      switch event
        case ab;  matrix=~EXPDATA.activity;
        case sb;  matrix=~EXPDATA.sleep;
        case iai; matrix=EXPDATA.activity;
        case isi; matrix=EXPDATA.sleep;
      end
      matrix=[ones(1,size(matrix,2)) ; matrix ; ones(1,size(matrix,2))];
      if hours_period(period)>0
        matrix(before_period(:,period),:)=1;
        matrix(after_period(:,period),:)=1;
      end
      matrix=matrix(logical_periods(:,period),:);
      real_indices=[1:size(logical_periods,1)]';
      real_indices=reshape(real_indices(logical_periods(:,period)),[],EXPDATA.days);
      DISTR(event,period)=distrfits(matrix);
    else
      break
    end
  end
end
try delete(h_waitbar), end
warning('on','curvefit:fit:noStartPoint')

% Correct if Dark-Dark was selected %
if all(hours_period==[0 24])
  for event=1:4
    DISTR(event,1)=DISTR(event,2);
  end
end


function [STRUCT]=distrfits(input_matrix)

STRUCT=distrStruct(EXPDATA.number_of_flies(1));

if event==sb; STRUCT.startpoint=EXPDATA.sleep_threshold;
else STRUCT.startpoint=1;
end
STRUCT.minEps=STRUCT.startpoint; % Depends on resolution! (Here, 1 min = 1 binstep)
STRUCT.okindex=EXPDATA.matrix_index;

if hours_period(period)>0   % Not in Light During DD Analysis

%%% Calculate BOUTS/IBIS %%%

ibis_sorted=cell(1,EXPDATA.number_of_flies(1));
nlargest=NaN(1,EXPDATA.number_of_flies(1));
mean_ibis=NaN(1,EXPDATA.number_of_flies(1));

for fly=1:EXPDATA.number_of_flies(1)

  % Find bouts
  % Same as calling "tState2ievs", but in-script calculation is much faster.
  diffmat=diff(logical(input_matrix(:,fly)));
  start_ibis=find(diffmat(1:end-1)==-1);
  end_ibis=find(diffmat(2:end)==1);
  ibis=end_ibis-start_ibis+1;
  start_ibis=real_indices(start_ibis);

  % Filter out non-valid bouts
  ibis=ibis(ibis<=hours_period(period)*60);
  start_ibis=start_ibis(ibis<=hours_period(period)*60);
  if STRUCT.startpoint>1
    keep=(ibis>=STRUCT.startpoint);
    ibis=ibis(keep);
    start_ibis=start_ibis(keep);
  end
  
  % Find Day-index
  day_index=NaN(size(ibis));
  for d=1:EXPDATA.days
    day_index(ismember(start_ibis,real_indices(:,d)))=d;
  end
  
  % Save in STRUCT
  STRUCT.Eps{fly}=ibis;
  if ~isempty(ibis)
    STRUCT.matrix=[STRUCT.matrix; ibis (start_ibis + (60*24*EXPDATA.days)*(fly-1)) day_index fly*ones(size(ibis))];
  else
    for g=[all_flies female male]
      STRUCT.okindex{g}=setdiff(STRUCT.okindex{g},fly);
    end
  end
  
  
  %%% Calculate BOUTS/IBIS Parameters %%%
  if ~isempty(ibis)
    
    % Calculate Episode Totals, Numbers, Means and Fragmentation.
    % Same as in Bursts Toolbox, but in-script calculation is much faster.
    STRUCT.sumEps(fly)=sum(ibis)/EXPDATA.days;
    STRUCT.nrEps(fly)=length(ibis)/EXPDATA.days;
    STRUCT.meanEps(fly)=mean(ibis);
    STRUCT.F(fly)=length(ibis)/sum(ibis);
    
    % Calculate B, M and DFA
    dur_corr=ibis-STRUCT.startpoint;
    mean_ibis(fly)=mean(dur_corr,1);
    
    % Burstiness B 
    % Same as in Bursts Toolbox, but in-script calculation is much faster.
    STRUCT.B(fly)=(std(dur_corr,0,1)-mean(dur_corr,1))/(std(dur_corr,0,1)+mean(dur_corr,1));
    if isinf(STRUCT.B(fly))
      STRUCT.B(fly)=NaN;
    end
    
    % Short-Term Memory M (Correlation) and Long-Term Memory DFA.
    % Must be calculated per day, otherwise the stacking of bouts from different
    % days produce false values. The mean daily value is then calculated.
    if length(unique(day_index))==EXPDATA.days
      mem=NaN(1,EXPDATA.days);
      dfa=NaN(1,EXPDATA.days);
      try
        for d=1:EXPDATA.days
          dur_corr_day=dur_corr(day_index==d);
          
          % Same as in Bursts Toolbox, but in-script calculation is much faster.
          mem(d)=1/(length(dur_corr_day)-1) * ...
                 sum( ...
                      (dur_corr_day(1:end-1)-mean(dur_corr_day(1:end-1))) .* ...
                      (dur_corr_day(2:end)-mean(dur_corr_day(2:end))) / ...
                      ( std(dur_corr_day(1:end-1))*std(dur_corr_day(2:end)) ) ...
                     );
          % Call to Bursts Toolbox function
          dfa(d)=DFA(dur_corr_day,false);
        end
        
        STRUCT.M(fly)=mean(mem);
        if isinf(STRUCT.M(fly))
          STRUCT.M(fly)=NaN;
        end
        
        STRUCT.DFA(fly)=mean(dfa);
        if isinf(STRUCT.DFA(fly))
          STRUCT.DFA(fly)=NaN;
        end
        
      catch
        for g=[all_flies female male]
          STRUCT.okindex{g}=setdiff(STRUCT.okindex{g},fly);
        end
      end
    end
    
    % Precalculation for Histogram Calculations
    ibis_sorted{fly}=sort(ibis);
    nlargest(fly)=ibis_sorted{fly}(end-(parameters(2)-1));
  end
 
end


%%% Calculate HISTOGRAMS %%%

halfbin=1/2; % To compensate for binsize effects on survival histograms
STRUCT.histogram=NaN(min([parameters(1) max(nlargest)]),EXPDATA.number_of_flies(1));
STRUCT.survival_histogram=NaN(max([STRUCT.startpoint+1 max(nlargest)]),EXPDATA.number_of_flies(1));
for fly=1:EXPDATA.number_of_flies(1)
  if isfinite(nlargest(fly))
    h=hist(ibis_sorted{fly},[1:nlargest(fly)]);
    if event==sb && STRUCT.startpoint>1
      if length(h)>=(STRUCT.startpoint-1)
        h(1:STRUCT.startpoint-1)=0;
      end
    end
    h=h/sum(h);
    STRUCT.histogram(1:min([parameters(1) nlargest(fly)]),fly)=h(1:min([parameters(1) nlargest(fly)]));
    STRUCT.survival_histogram(nlargest(fly):-1:1,fly)=cumsum(h(end:-1:1));
  end
end


%%% Calculate WEIBULL parameters from BURST PARAMETER B %%%
if fitmethods(1)
  STRUCT.wB.okfit=STRUCT.okindex;
  k=[0.1:0.001:10];
  s=sqrt( gamma(1+2./k) - (gamma(1+1./k)).^2 );
  m=gamma(1+1./k);
  B=(s-m)./(s+m);
  STRUCT.wB.k(STRUCT.wB.okfit{all_flies})=interp1(B,k,STRUCT.B(STRUCT.wB.okfit{all_flies}));
  STRUCT.wB.lambda(STRUCT.wB.okfit{all_flies})=mean_ibis(STRUCT.wB.okfit{all_flies})./gamma(1+1./STRUCT.wB.k(STRUCT.wB.okfit{all_flies}));
else
  STRUCT.wB.okfit={[] [] []};
end

%%% WEIBULL NONLINEAR FIT to individual flies %%%
if fitmethods(2)
  STRUCT.wnl.okfit=STRUCT.okindex;
  f_Weibull_survival=fittype('-(x/lambda)^k');
  opts=fitoptions('Method','NonlinearLeastSquares','Display','off','MaxFunEvals',1000,'MaxIter',600);
  for fly=STRUCT.okindex{all_flies}
    if ishandle(h_waitbar)
      k=NaN(nlreps,1);
      lambda=NaN(nlreps,1);
      counter=NaN(nlreps,1);
      r2fit=NaN(nlreps,1);
      for rep=1:nlreps
        fit_ok=false;
        reshortened=false;
        fly_survival_histogram=STRUCT.survival_histogram(isfinite(STRUCT.survival_histogram(:,fly)),fly);
        if length(fly_survival_histogram(STRUCT.startpoint:end))>2
          while ~fit_ok && ~isempty(fly_survival_histogram) && ~reshortened
            try [fit_Weibull_survival,gof] = fit([0 halfbin:length(fly_survival_histogram)-STRUCT.startpoint-halfbin]', log(fly_survival_histogram(STRUCT.startpoint:end)), f_Weibull_survival, opts);
              k(rep)=fit_Weibull_survival.k;
              lambda(rep)=fit_Weibull_survival.lambda;
              counter(rep)=length(fly_survival_histogram);
              r2fit(rep)=gof.rsquare;
              fit_ok=true;
            catch
              reshortened=true;
              fly_survival_histogram_shorter=fly_survival_histogram(logical(fly_survival_histogram>fly_survival_histogram(end)));
              if ~isempty(fly_survival_histogram_shorter)
                fly_survival_histogram_shorter(logical(fly_survival_histogram_shorter==fly_survival_histogram_shorter(end)))=fly_survival_histogram_shorter(end)+fly_survival_histogram(end);
              end
              fly_survival_histogram=fly_survival_histogram_shorter;
            end
          end
          update_waitbar(1/(nlreps*length(STRUCT.okindex{all_flies})))
        end
      end
      if all(isnan(r2fit))
        for g=[all_flies female male]
          STRUCT.wnl.okfit{g}=setdiff(STRUCT.wnl.okfit{g},fly);
        end
      else
        [r2max,bestfit]=max(r2fit);
        STRUCT.wnl.k(fly)=k(bestfit);
        STRUCT.wnl.lambda(fly)=lambda(bestfit);
        STRUCT.wnl.counter(fly)=counter(bestfit);
      end
    else
      break
    end
  end
else
  STRUCT.wnl.okfit={[] [] []};
  update_waitbar(1)
end

%%% WEIBULL LINEAR FIT to individual flies %%%
if fitmethods(3) && ishandle(h_waitbar)
  STRUCT.wlin.okfit=STRUCT.okindex;
  y=STRUCT.survival_histogram(STRUCT.startpoint+1:end,STRUCT.okindex{all_flies});
  y(y>0.9999)=NaN;
  y=log(-log(y));
  x=repmat([halfbin:size(y,1)-halfbin]',[1 size(y,2)]);
  x(isnan(y))=NaN;
  x=log(x);
  STRUCT.wlin.k(STRUCT.okindex{all_flies})=nansum((x-repmat(nanmean(x,1),[size(x,1) 1])).*(y-repmat(nanmean(y,1),[size(y,1) 1])))./nansum((x-repmat(nanmean(x,1),[size(x,1) 1])).^2);
  STRUCT.wlin.lambda(STRUCT.okindex{all_flies})=exp(-(nanmean(y,1)-STRUCT.wlin.k(STRUCT.okindex{all_flies}).*nanmean(x,1))./STRUCT.wlin.k(STRUCT.okindex{all_flies}));
  STRUCT.wlin.lambda(isinf(STRUCT.wlin.lambda))=NaN;
  no_fit=intersect(find(STRUCT.wlin.k==0),find(STRUCT.wlin.lambda==0));
  if ~isempty(no_fit)
    STRUCT.wlin.k(no_fit)=NaN;
    STRUCT.wlin.lambda(no_fit)=NaN;
    for g=[all_flies female male]
      STRUCT.wlin.okfit{g}=setdiff(STRUCT.wlin.okfit{g},no_fit);
    end
  end
else
  STRUCT.wlin.okfit={[] [] []};
end

%%% Calculate R-SQUARE values %%%
if ishandle(h_waitbar)
  wtype={'wB' 'wnl' 'wlin'};
  % Calculate R-square in S1 (lin-lin space)
  space=1;
  for i=1:3
    if fitmethods(i) && ~isempty(STRUCT.(wtype{i}).okfit{all_flies})
      y=STRUCT.histogram(STRUCT.startpoint+1:end,STRUCT.(wtype{i}).okfit{all_flies}); STRUCT.(wtype{i}).rsquare(space,STRUCT.(wtype{i}).okfit{all_flies})=calc_rsquare(y,STRUCT.(wtype{i}).k(STRUCT.(wtype{i}).okfit{all_flies}),STRUCT.(wtype{i}).lambda(STRUCT.(wtype{i}).okfit{all_flies}));
    end
  end
  % Calculate R-square in S2 (log-lin space)
  space=2;
  for i=1:3
    if fitmethods(i) && ~isempty(STRUCT.(wtype{i}).okfit{all_flies})
      y=log(STRUCT.survival_histogram(STRUCT.startpoint:end,STRUCT.(wtype{i}).okfit{all_flies})); STRUCT.(wtype{i}).rsquare(space,STRUCT.(wtype{i}).okfit{all_flies})=calc_rsquare(y,STRUCT.(wtype{i}).k(STRUCT.(wtype{i}).okfit{all_flies}),STRUCT.(wtype{i}).lambda(STRUCT.(wtype{i}).okfit{all_flies}));
    end
  end
  % Calculate R-square in S3 (loglog-log space)
  space=3;
  for i=1:3
    if fitmethods(i) && ~isempty(STRUCT.(wtype{i}).okfit{all_flies})
      y=STRUCT.survival_histogram(STRUCT.startpoint+1:end,STRUCT.(wtype{i}).okfit{all_flies});
      y(y>0.9999)=NaN;
      y=log(-log(y));
      STRUCT.(wtype{i}).rsquare(space,STRUCT.(wtype{i}).okfit{all_flies})=calc_rsquare(y,STRUCT.(wtype{i}).k(STRUCT.(wtype{i}).okfit{all_flies}),STRUCT.(wtype{i}).lambda(STRUCT.(wtype{i}).okfit{all_flies}));
    end
  end
end

else
  update_waitbar(1)
end

  function [r2]=calc_rsquare(y,k,lambda)
    switch space
      case 1
        y_fit=STRUCT.weibull_pdf([1:size(y,1)]',k,lambda);
      case 2
        y_fit=STRUCT.weibull_survival([0 halfbin:size(y,1)-1]',k,lambda);
      case 3
        y_fit=STRUCT.weibull_lin(log([halfbin:size(y,1)])',k,lambda);
    end
    y_fit(isnan(y))=NaN;
    r2= 1 - ( nansum( (y - y_fit).^2 ) ./ nansum( (y-repmat(nanmean(y,1),[size(y,1) 1])).^2 ) );
    r2(isnan(k))=NaN;
    r2(isnan(lambda))=NaN;
    % Remove fits that produce R^2=-Inf, as that is the result of the underlying vector only having 1 or 2 points!
    r2(isinf(r2))=NaN;
  end


end

function update_waitbar(deltastep)
  if getappdata(h_waitbar,'canceling')
    set(h_analyze,'UserData',false)
    delete(h_waitbar)
    return
  else step=step+deltastep;
  end
  waitbar(step/steps,h_waitbar,sprintf('%1.0f%% Done',100*step/steps));
end


end


