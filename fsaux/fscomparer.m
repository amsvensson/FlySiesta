function varargout = fscomparer(varargin)
% FlySiesta Comparer - Compare activity and sleep parameters, including 
% 'burst parameters', between several FlySiesta files in customly 
% defined groups through bar graphs and statistical tests. 
% Seperate figure windows are created for each event type and light cycle
% period, which provides an overview for comparison of all the avaliable 
% parameters. Saves to disk the figures and an output structure suited to
% be used with Matlab Statistics Toolbox, especially the ANOVA and 
% Kruskal-Wallis tests.
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
                   'gui_OpeningFcn', @fscomparer_OpeningFcn, ...
                   'gui_OutputFcn',  @fscomparer_OutputFcn, ...
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
function varargout = fscomparer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end

function fscomparer_OpeningFcn(hObject, eventdata, handles, varargin)
% Version
FlySiesta_version=fsabout('version');

% Tweak initiation
 set(handles.figure,'Name','FlySiesta Comparer','UserData',FlySiesta_version)
 set(handles.namebox,'String','Title Name','FontSize',9,'FontWeight','normal')
 set(handles.filelist,'Value',0)
 set(handles.flylist,'Min',0,'Max',2)
 set(handles.testmode,'UserData',[1 0 0])
 set(handles.testparam,'UserData',{'0.05' '0.05' '10000' 'NaN'})
 movegui(handles.figure,'center')

% Load Button Icons & Colors
try load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'])
end
set(handles.help,'CData',help_mine,'ToolTip','Online User Guide','Background',get(handles.bottompanel,'BackgroundColor'))
set(handles.info,'CData',about_mine,'ToolTip','About','Background',get(handles.bottompanel,'BackgroundColor'))
set(handles.add,'CData',fs_add)
set(handles.moveup,'CData',move_up)
set(handles.movedown,'CData',move_down)
set(handles.remove,'CData',fs_remove)
set(handles.save,'CData',fs_save)
set(handles.colors,'CData',color_swatch)
set(handles.female,'CData',female)
set(handles.male,'CData',male)
set(handles.colors,'UserData',MyStyle)
 
% Create File Structure
FILES=struct('EXPDATA',[],'DISTR',[],'selection',[],'statgen',1,'statcond',1,'statgroup',1,'statdate',1);
handles.barfields={'total' 'num' 'dur' 'klin' 'knl' 'B' 'llin' 'lnl' 'M'};

setappdata(handles.figure,'files',FILES)
handles.output = hObject;  % Choose default command line output for fscomparer
guidata(hObject, handles);  % Update handles structure
end


%% Create Functions %%
function namebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to namebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function flylist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flylist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function statgen_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function statcond_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function statgroup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function statdate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function dispname_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function savebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%% File Selection %%
function namebox_Callback(hObject, eventdata, handles)
if strcmp(get(hObject,'String'),'Title Name')
  set(handles.namebox,'String','')
end
end
function filelist_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
if ~isempty(value) && ~isempty(FILES(value).EXPDATA)
  set(handles.flylist,'String',FILES(value).EXPDATA.id_index,'Value',FILES(value).selection)
  set(handles.all,'UserData',FILES(value).EXPDATA.matrix_index{1})
  set(handles.female,'UserData',FILES(value).EXPDATA.matrix_index{2})
  set(handles.male,'UserData',FILES(value).EXPDATA.matrix_index{3})
  nr_real_files=sum(~strcmp(get(hObject,'String'),'---') & ~strcmp(get(hObject,'String'),''));
  statstring=cell(nr_real_files+1,1);
  statstring{1}=' ';
  for i=1:nr_real_files
    statstring{i+1}=num2str(i);
  end
  set(handles.statgen,'String',statstring,'Value',FILES(value).statgen)
  set(handles.statcond,'String',statstring,'Value',FILES(value).statcond)
  set(handles.statgroup,'String',statstring,'Value',FILES(value).statgroup)
  set(handles.statdate,'String',statstring,'Value',FILES(value).statdate)
  set(handles.dispname,'String',FILES(value).EXPDATA.name)
  h_info=[handles.genotype handles.condition handles.description handles.age handles.temp];
  for i=1:5
    set(h_info(i),'String',FILES(value).EXPDATA.info{i})
  end
  set(handles.days,'String',num2str(FILES(value).EXPDATA.days))
  set(handles.lights,'String',[num2str(FILES(value).EXPDATA.lights(1)) ' - ' num2str(FILES(value).EXPDATA.lights(2)) ' h']);
  set(handles.light_period,'String',[num2str(FILES(value).EXPDATA.setperiods(1,1))  ' - ' num2str(FILES(value).EXPDATA.setperiods(1,2)) ' h']);
  set(handles.dark_period,'String',[num2str(FILES(value).EXPDATA.setperiods(2,1))  ' - ' num2str(FILES(value).EXPDATA.setperiods(2,2)) ' h']);
else
  set(handles.flylist,'String','','Value',[])
  set(handles.all,'UserData',[])
  set(handles.female,'UserData',[])
  set(handles.male,'UserData',[])
  set(handles.statgen,'String',' ','Value',1)
  set(handles.statcond,'String',' ','Value',1)
  set(handles.statgroup,'String',' ','Value',1)
  set(handles.statdate,'String',' ','Value',1)
  h_info=[handles.dispname handles.genotype handles.condition handles.description handles.age handles.temp ...
          handles.days handles.lights handles.light_period handles.dark_period];
  for i=1:10
    set(h_info(i),'String','')
  end
end
set(handles.start,'UserData',true)  % Perform statistical test, since files may have changed!
end
function add_Callback(hObject, eventdata, handles)
set(handles.start,'UserData',true)
if hObject==handles.add
  [input_file,input_dir]=uigetfile('*.mat','Select FlySiesta File','MultiSelect','on');
  if ~iscell(input_file) && ischar(input_file)
    input_file={input_file};
  end
else
  input_file='---';
  input_dir='separator';
  add_entry(input_dir,input_file,[],[],[],[],[],handles)
end
if iscell(input_file) && hObject==handles.add
  load([input_dir input_file{1}])
  if exist('EXPDATA','var')
    add_entry(input_dir,input_file{1},[],EXPDATA,DISTR,[],[],handles)
    for i=2:length(input_file)
      load([input_dir input_file{i}])
      add_entry(input_dir,input_file{i},[],EXPDATA,DISTR,[],[],handles)
    end
  elseif exist('FSCOMP','var')
    set(handles.namebox,'String',FSCOMP.name)
    set(handles.savebox,'String',[input_dir input_file{1}])
    set(handles.add,'UserData',[input_dir input_file{1}])
    set(handles.testparam,'UserData',{num2str(PRM.alphanorm) num2str(PRM.alphatest) num2str(PRM.bsamp) num2str(PRM.stdtol)})
    if PRM.pairedtest
      testmode=[0 1 0];
    else
      if PRM.calc_diffs
        testmode=[0 0 1];
        FSCOMP.x=find(PRM.truefiles)';
        FSCOMP.names=reshape([FSCOMP.names ; FSCOMP.names],1,[]);
      else
        testmode=[1 0 0];
      end
    end
    set(handles.testmode,'UserData',testmode)

    for i=1:length(PRM.truefiles)
      if PRM.truefiles(i)
        fsnr=find(FSCOMP.x==i);
        load(FSCOMP.files{fsnr})
        EXPDATA.name=FSCOMP.names{fsnr};
        [input_dir,input_file]=fileparts(FSCOMP.files{fsnr});
        add_entry([input_dir filesep],input_file,fsnr,EXPDATA,DISTR,FSCOMP,PRM,handles)
      else
        input_file='---';
        input_dir='separator';
        add_entry(input_dir,input_file,[],[],[],[],[],handles)
      end
    end
    
    FILES=getappdata(handles.figure,'files');
    for i=1:length(PRM.truefiles)
      if PRM.truefiles(i)
        fsnr=find(FSCOMP.x==i);
        FILES(i).statgen=PRM.factors(1,fsnr)+1;
        FILES(i).statcond=PRM.factors(2,fsnr)+1;
        FILES(i).statgroup=PRM.factors(3,fsnr)+1;
        FILES(i).statdate=PRM.factors(4,fsnr)+1;
      end
    end
    setappdata(handles.figure,'files',FILES)
    set(handles.start,'UserData',false)
    
  else
    disp_errordlg([input_file ' is not a FlySiesta file!']);
    return
  end
end
  set(handles.figure,'Pointer','arrow')
end
function add_entry(input_dir,input_file,fsnr,EXPDATA,DISTR,FSCOMP,PRM,handles)
eventdata=[];
set(handles.figure,'Pointer','watch')
drawnow
oldfiles=get(handles.filelist,'String');
olddirs=get(handles.filelist,'UserData');
value=get(handles.filelist,'Value');
if ~iscell(oldfiles)
  if isempty(value) || value<=0
    set(handles.filelist,'String',input_file,'UserData',input_dir,'Value',1)
  else
    set(handles.filelist,'String',{oldfiles ; input_file},'UserData',{olddirs ; input_dir},'Value',2)
  end
else
  set(handles.filelist,'String',[oldfiles ; {input_file}],'UserData',[olddirs ; {input_dir}],'Value',size(oldfiles,1)+1)
end
newfile_value=get(handles.filelist,'Value');

% Load file into last position
FILES=getappdata(handles.figure,'files');
FILES(newfile_value).EXPDATA=EXPDATA;
FILES(newfile_value).DISTR=DISTR;
if ~strcmp(input_file,'---')
  if isempty(fsnr)
    FILES(newfile_value).selection=EXPDATA.matrix_index{1};
  else
    FILES(newfile_value).selection=FSCOMP.selection{fsnr};
  end
  FILES(newfile_value).statgen=1;
  FILES(newfile_value).statcond=1;
  FILES(newfile_value).statgroup=1;
  FILES(newfile_value).statdate=1;
else
  FILES(newfile_value).selection=[];
end
setappdata(handles.figure,'files',FILES)

% Rearrange if necessary
if iscell(oldfiles) && value~=size(oldfiles,1)
  target_value=value+1;
  while newfile_value~=target_value
    if newfile_value>target_value
      moveup_Callback(handles.moveup,eventdata,handles)
    elseif newfile_value<target_value
      movedown_Callback(handles.movedown,eventdata,handles)
    end
    newfile_value=get(handles.filelist,'Value');
  end
end

% Load file into Details box
filelist_Callback(handles.filelist,eventdata,handles)

end
function separator_Callback(hObject, eventdata, handles)
add_Callback(hObject,eventdata,handles)
end
function moveup_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
if value>1
  newpos=[value-1 value];
  oldpos=[value value-1];
  FILES(newpos)=FILES(oldpos);
  files=get(handles.filelist,'String');
  dirs=get(handles.filelist,'UserData');
  files(newpos)=files(oldpos);
  dirs(newpos)=dirs(oldpos);
  set(handles.filelist,'String',files,'UserData',dirs,'Value',value-1)
  setappdata(handles.figure,'files',FILES)
  set(handles.start,'UserData',true)
end
end
function movedown_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
maxvalue=size(get(handles.filelist,'String'),1);
if value<maxvalue
  newpos=[value+1 value];
  oldpos=[value value+1];
  FILES(newpos)=FILES(oldpos);
  files=get(handles.filelist,'String');
  dirs=get(handles.filelist,'UserData');
  files(newpos)=files(oldpos);
  dirs(newpos)=dirs(oldpos);
  set(handles.filelist,'String',files,'UserData',dirs,'Value',value+1)
  setappdata(handles.figure,'files',FILES)
  set(handles.start,'UserData',true)
end
end
function remove_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
files=get(handles.filelist,'String');
dirs=get(handles.filelist,'UserData');
value=get(handles.filelist,'Value');
FILES(value)=[];
if size(files,1)==1
  files=[];
  dirs=[];
  value=[];
else
  files(value)=[];
  dirs(value)=[];
  if value==1
    value=2;
  end
end
set(handles.filelist,'String',files,'UserData',dirs,'Value',value-1)
setappdata(handles.figure,'files',FILES)
filelist_Callback(handles.filelist,eventdata,handles)
end


%% File Info %%
function all_Callback(hObject, eventdata, handles)
set(handles.flylist,'Value',get(hObject,'UserData'))
flylist_Callback(handles.flylist,eventdata,handles)
end
function female_Callback(hObject, eventdata, handles)
set(handles.flylist,'Value',get(hObject,'UserData'))
flylist_Callback(handles.flylist,eventdata,handles)
end
function male_Callback(hObject, eventdata, handles)
set(handles.flylist,'Value',get(hObject,'UserData'))
flylist_Callback(handles.flylist,eventdata,handles)
end
function none_Callback(hObject, eventdata, handles)
set(handles.flylist,'Value',[])
flylist_Callback(handles.flylist,eventdata,handles)
end
function flylist_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
if logical(value)
  FILES(value).selection=get(hObject,'Value');
  setappdata(handles.figure,'files',FILES)
  set(handles.start,'UserData',true)
end
end
function statgen_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
FILES(value).statgen=get(hObject,'Value');
setappdata(handles.figure,'files',FILES)
set(handles.start,'UserData',true)
end
function statcond_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
FILES(value).statcond=get(hObject,'Value');
setappdata(handles.figure,'files',FILES)
set(handles.start,'UserData',true)
end
function statgroup_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
FILES(value).statgroup=get(hObject,'Value');
setappdata(handles.figure,'files',FILES)
set(handles.start,'UserData',true)
end
function statdate_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
FILES(value).statdate=get(hObject,'Value');
setappdata(handles.figure,'files',FILES)
set(handles.start,'UserData',true)
end
function dispname_Callback(hObject, eventdata, handles)
FILES=getappdata(handles.figure,'files');
value=get(handles.filelist,'Value');
if ~isempty(FILES(value).EXPDATA)
  FILES(value).EXPDATA.name=get(hObject,'String');
  setappdata(handles.figure,'files',FILES)
  set(handles.start,'UserData',true)
end
end


%% Save & Options %%
function savebox_Callback(hObject, eventdata, handles)
string=get(handles.savebox,'String');
if strcmp(string,'Browse or type save path!')
  set(handles.savebox,'String','')
end
end
function save_Callback(hObject, eventdata, handles)
defaultstr='Browse or type save path!';
currentstring=get(handles.savebox,'String');
namestring=get(handles.namebox,'String');
if isempty(currentstring) || strcmp(currentstring,defaultstr)
  currentstr_valid=false;
  if isempty(namestring) || strcmp(namestring,'Title Name')
    showname='comparison_file';
  else
    showname=namestring;
  end
else
  currentstr_valid=true;
  [showpath,showname]=fileparts(currentstring);
end
[savename,savepath]=uiputfile('*.mat','Save File As..',showname);
if ~ischar(savename)
  if currentstr_valid
    savename=showname;
    savepath=showpath;
  else
    savename='';
    savepath='';
  end
end
set(handles.savebox,'String',[savepath savename])
end

function colors_Callback(hObject, eventdata, handles)
end
function testmode_Callback(hObject, eventdata, handles)
selection=select_testmode(get(hObject,'UserData'));
if ~isempty(selection)
  set(hObject,'UserData',selection)
  set(handles.start,'UserData',true)
  guidata(hObject, handles);
end
end
function [selection]=select_testmode(input_selection)
figurePosition=getpixelposition(gcf);
fighandles.figure=figure('Name','Test Mode','NumberTitle','off','IntegerHandle','off','Color',get(0,'defaultUicontrolBackgroundColor'),'Resize','off',...
                         'WindowStyle','modal','CloseRequestFcn',{@cancel_Callback},'MenuBar','none','ToolBar','none','Position',[400,300,300,330],'Visible','off');
dlgPosition=getpixelposition(fighandles.figure);
setpixelposition(fighandles.figure,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])

fighandles.title=uicontrol('Style','text','Units','pixels','Position',[12 295 280 20],'String','Select Test Mode for Comparisons','HorizontalAlignment','left','FontSize',10,'FontWeight','bold');

fighandles.unpaired=uicontrol('Style','radiobutton','Units','pixels','Position',[20 265 200 15],'String','  Unpaired Comparison','Value',input_selection(1),'HorizontalAlignment','left','FontSize',9,'Callback',{@modes_Callback});
fighandles.paired = uicontrol('Style','radiobutton','Units','pixels','Position',[20 200 200 15],'String','  Paired Comparison','Value',input_selection(2),'HorizontalAlignment','left','FontSize',9,'Callback',{@modes_Callback});
fighandles.combined=uicontrol('Style','radiobutton','Units','pixels','Position',[20 135 250 15],'String','  Combined Comparison of Differences','Value',input_selection(3),'HorizontalAlignment','left','FontSize',9,'Callback',{@modes_Callback});

fighandles.textup= uicontrol('Style','text','Units','pixels','Position',[50 230 250 30],'String',{'For e.g. Genotype or Date Effects.' 'Data can be grouped in variable group sizes.'},'HorizontalAlignment','left','FontSize',8,'ForegroundColor',[.5 .5 .5]);
fighandles.textp = uicontrol('Style','text','Units','pixels','Position',[50 165 250 30],'String',{'For e.g. Condition Effects.' 'Data must be grouped in groups of two.'},'HorizontalAlignment','left','FontSize',8,'ForegroundColor',[.5 .5 .5]);
fighandles.textcmb=uicontrol('Style','text','Units','pixels','Position',[50  70 200 60],'String',{'Performs unpaired comparisons of differences between paired data.' 'Group data pairwise, and use two separators to define the result groups.'},'HorizontalAlignment','left','FontSize',8,'ForegroundColor',[.5 .5 .5]);

fighandles.ok  =  uicontrol('Style','pushbutton','Units','pixels','Position',[ 65 15 70 28],'String','OK','FontSize',9,'Callback',{@ok_Callback});
fighandles.cancel=uicontrol('Style','pushbutton','Units','pixels','Position',[165 15 70 28],'String','Cancel','FontSize',9,'Callback',{@cancel_Callback});
fighandles.modes=[fighandles.unpaired fighandles.paired fighandles.combined];

set(fighandles.figure,'Visible','on')
uiwait(fighandles.figure)
delete(fighandles.figure)

  function modes_Callback(source,event)
    set(fighandles.modes,'Value',0)
    set(source,'Value',1)
  end
  function ok_Callback(source,event)
    selection=[get(fighandles.unpaired,'Value') get(fighandles.paired,'Value') get(fighandles.combined,'Value')];
    uiresume(fighandles.figure)
  end
  function cancel_Callback(source,event)
    selection=[];
    uiresume(fighandles.figure)
  end
end

function testparam_Callback(hObject, eventdata, handles)
prompt={'Significance level \alpha for normality tests:' ...
        'Significance level \alpha for pairwise tests:' ...
        'Bootstrap iterations for non-parametric t-tests:' ...
        'Tolerance level for outliers in standar deviations (e.g. 3, or NaN to disable exclusion of outliers):'};
defaultanswer=get(handles.testparam,'UserData')';
options.Interpreter='tex';
answer=inputdlg(prompt,'Parameters for statistical test',1,defaultanswer,options);
if ~isempty(answer) && ~isequal(answer,defaultanswer) && isnumeric(str2double(answer{1})) && isnumeric(str2double(answer{2})) && isnumeric(str2double(answer{3}))
  set(handles.testparam,'UserData',answer)
  set(handles.start,'UserData',true)
end
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


%% Start Comparison %%
function start_Callback(hObject, eventdata, handles)

% Remove Possibly Any Old, Cancelled Waitbars
set(0,'ShowHiddenHandles','on')
chroot=get(0,'Children');
try delete(findobj(chroot,'Name','Statistical Test and Plotting...')); end
try delete(findobj(chroot,'Name','Analyzing Data...')); end
set(0,'ShowHiddenHandles','off')

% Control & Retrieve Input Values and Return FSCOMP-Structure
if get(handles.start,'UserData')
  % (Re)analyze
  [all_ok,FSCOMP,PRM]=read_input_data(handles);
else
  % Load Preanalyzed File
  all_ok=true;
  load(get(handles.add,'UserData'))
end

%%% START %%%z
if all_ok
  set(handles.figure,'Pointer','watch')
  drawnow expose

 % Load Files
  if get(handles.start,'UserData')
    FSCOMP.patterns=load_patterns(PRM,FSCOMP.selection,handles);
    FSCOMP.bars=load_bars(PRM,FSCOMP.selection,handles);
    if PRM.calc_diffs
      [FSCOMP,PRM]=diff_bars(FSCOMP,PRM,handles);
    end
    FSCOMP=calc_factors(FSCOMP,PRM);
    FSCOMP=remove_separators(FSCOMP);
  end
  
 % Plot Pattern Figures
  if ~PRM.calc_diffs
    handles.patfigs=make_patfigure(FSCOMP,handles);
    guidata(handles.figure,handles);
    plot_patterns(FSCOMP,PRM,handles)
  end

 % Plot Bar Graph Figures
  handles.barfigs=make_barfigures(FSCOMP,PRM,handles);
  guidata(handles.figure,handles);
  FSCOMP=plot_n_test_bars(FSCOMP,PRM,handles);
  
 % Show Figures when Done
  try
    for fig=1:length(handles.patfigs)
      set(handles.patfigs(fig),'Visible','on')
    end
  end
  set(handles.barfigs','Visible','on')
  drawnow

  % Save to Memory & Disk
  setappdata(handles.figure,'fscomp',FSCOMP)
  save(get(handles.savebox,'String'),'FSCOMP','PRM')

  
  % Save Figures to disk (Slow!)
  %savepath=fileparts(get(handles.savebox,'String'));
  %for i=1:8, saveas(handles.barfigs(i),[savepath filesep get(handles.barfigs(i),'Name') '.fig']); end

  % Clear Memory 
  %rmappdata(handles.figure,'files');
  %rmappdata(handles.figure,'fscomp');
  
  set(handles.figure,'Pointer','arrow')
end

end

function [all_ok,FSCOMP,PRM]=read_input_data(handles)
FILES=getappdata(handles.figure,'files');
FSCOMP=struct('name',[],'names',[],'files',[],'selection',[],'flyid',[],'group',[],'x',[],'bars',[],'bfactors',[],'bfactnames',[],'patterns',[],'pfactors',[],'pfactnames',[]);
all_ok=false;

%%% Find Dimensions and Input Values %%%
filestring=get(handles.filelist,'String');
dirstring=get(handles.filelist,'UserData');
entries=size(filestring,1);
if entries==1
  filestring={filestring};
  dirstring={dirstring};
end
truefiles=~strcmp(filestring,'---') & ~strcmp(filestring,'');
nrfiles=sum(truefiles);
if nrfiles==0
  return
end
groupcounter=1;
group=cell(1);
xbars=1:entries;
for file=1:entries
  if truefiles(file)
    group{groupcounter}=[group{groupcounter} file-(groupcounter-1)];
  else
    groupcounter=groupcounter+1;
    group{groupcounter}=[];
  end
end
if isempty(group{groupcounter})
  group=group(1:end-1);
end
FILES(~truefiles)=[];
filestring(~truefiles)=[];
dirstring(~truefiles)=[];
xbars(~truefiles)=[];

names=cell(1,nrfiles);
files=cell(1,nrfiles);
selection=cell(1,nrfiles);
flyid=cell(1,nrfiles);
nrflies=NaN(1,nrfiles);
events=NaN(1,nrfiles);
nrdays=NaN(1,nrfiles);
factors=NaN(5,nrfiles);
sex=cell(1,nrfiles);
for file=1:nrfiles
  names{file}=FILES(file).EXPDATA.name;
  files{file}=[dirstring{file} filestring{file}];
  selection{file}=FILES(file).selection;
  flyid{file}=FILES(file).EXPDATA.id_index(selection{file});
  nrflies(file)=max([flyid{file} length(flyid{file})]);
  events(file)=size(FILES(file).DISTR,1);
  nrdays(file)=FILES(file).EXPDATA.days;
  factors(1,file)=FILES(file).statgen-1;
  factors(2,file)=FILES(file).statcond-1;
  factors(3,file)=FILES(file).statgroup-1;
  factors(4,file)=FILES(file).statdate-1;
  sexesfile=NaN(length(FILES(file).EXPDATA.matrix_index{1}),1);
  if ~isempty(FILES(file).EXPDATA.matrix_index{2}) && ~isempty(FILES(file).EXPDATA.matrix_index{3})
    sexesfile(FILES(file).EXPDATA.matrix_index{2})=1;
    sexesfile(FILES(file).EXPDATA.matrix_index{3})=2;
    factors(5,file)=1;
  else
    sexesfile(:)=1;
    factors(5,file)=0;
  end
  sex{file}=sexesfile(selection{file});
end


%%% Control Start Conditions %%%
ok=false(6,1);
% Save Path
SaveNamePath=get(handles.savebox,'String');
if ~isempty(SaveNamePath) && ~strcmp(SaveNamePath,'Browse or type save path!')
  ok(1)=true;
else
  disp_errordlg('You must choose a Save Path before proceeding!');
  return
end
% Size of DISTR Structure
if all(events==4)
  ok(2)=true;
else
  disp_errordlg('All the files must have been created with FlySiesta Analyzer (Regular)!');
  return
end
% Factor Assignments
for i=1:4
  if all(factors(i,:))
    ok(i+2)=true;
  elseif all(~factors(i,:))
    ok(i+2)=true;
  else
    disp_errordlg(['Each assigned factor must be assigned to either all files or none!']);
    break
  end
end


%%% Retrieve Remaining Input Variables %%%
% Title Name
name=get(handles.namebox,'String');
if isempty(name) || strcmp(name,'Title Name')
  [path,name]=fileparts(get(handles.savebox,'String'));
end
% Test Parameters
param=get(handles.testparam,'UserData');
alphanorm=str2double(param{1});
alphatest=str2double(param{2});
bsamp=str2double(param{3});
stdtol=str2double(param{4});

% Test Mode
mode=find(get(handles.testmode,'UserData'));
switch mode
  case 1
    pairedtest=false;
    calc_diffs=false;
  case 2
    pairedtest=true;
    calc_diffs=false;
  case 3
    pairedtest=false;
    calc_diffs=true;
end


%%% Create Supporting Parameter Structure %%%
PRM.truefiles=truefiles;
PRM.nrdays=max(nrdays);
PRM.nrflies=max(nrflies);
PRM.nrfiles=nrfiles;
PRM.factors=factors;
PRM.sex=sex;
PRM.pairedtest=pairedtest;
PRM.calc_diffs=calc_diffs;
PRM.alphanorm=alphanorm;
PRM.alphatest=alphatest;
PRM.bsamp=bsamp;
PRM.stdtol=stdtol;

%%% Recompile Structure %%%
FSCOMP.name=name;
FSCOMP.names=names;
FSCOMP.files=files;
FSCOMP.selection=selection;
FSCOMP.flyid=flyid;
FSCOMP.group=group;
FSCOMP.x=xbars;

all_ok=all(ok);

end

function [patterns]=load_patterns(PRM,selection,handles)
FILES=getappdata(handles.figure,'files');
FILES(~PRM.truefiles)=[];

patterns(1:2)=struct('full',NaN(PRM.nrdays*24*2,PRM.nrflies,PRM.nrfiles),'day',NaN(24*2,PRM.nrflies,PRM.nrfiles));
for f=1:PRM.nrfiles
  if ~isempty(FILES(f).EXPDATA)
    activity=FILES(f).EXPDATA.activity(:,selection{f});
    sleep=FILES(f).EXPDATA.sleep(:,selection{f});
    days=FILES(f).EXPDATA.days;

    amins_hh_full=reshape(sum(reshape(logical(activity),30,[]),1),days*48,[]);
    amins_hh_day=reshape(amins_hh_full,48,length(selection{f}),days);

    smins_hh_full=reshape(sum(reshape(sleep,30,[]),1),days*48,[]);
    smins_hh_day=reshape(smins_hh_full,48,length(selection{f}),days);

    patterns(1).full(1:days*48,selection{f},f)=amins_hh_full;
    patterns(1).day(1:48,selection{f},f)=mean(amins_hh_day,3);

    patterns(2).full(1:days*48,selection{f},f)=smins_hh_full;
    patterns(2).day(1:48,selection{f},f)=mean(smins_hh_day,3);
  end
end
end
function [bars]=load_bars(PRM,selection,handles)
FILES=getappdata(handles.figure,'files');
FILES(~PRM.truefiles)=[];

mbars=NaN(PRM.nrflies,PRM.nrfiles);
p_t=NaN(PRM.nrfiles,PRM.nrfiles,length(handles.barfields));
for f=1:PRM.nrfiles
  p_t(f,f,:)=1;
end
bars(1:4,1:2)=struct('total',mbars,'num',mbars,'dur',mbars,'klin',mbars,'knl',mbars,'B',mbars,'llin',mbars,'lnl',mbars,'M',mbars,'norm_p',NaN(length(handles.barfields),PRM.nrfiles),'p_t',p_t);
warning off stats:lillietest:OutOfRangeP

for f=1:PRM.nrfiles
  if ~isempty(FILES(f).EXPDATA)
    period=get_periods(FILES(f).EXPDATA);
    activity=FILES(f).EXPDATA.activity(:,selection{f});
    sleep=FILES(f).EXPDATA.sleep(:,selection{f});
    days=FILES(f).EXPDATA.days;
    for per=1:2
      % Total
      bars(1,per).total(selection{f},f)=sum(logical(activity(period{per},:)),1)/days;
      bars(2,per).total(selection{f},f)=sum(sleep(period{per},:),1)/days;
      bars(3,per).total(selection{f},f)=sum(~activity(period{per},:),1)/days;
      bars(4,per).total(selection{f},f)=sum(~sleep(period{per},:),1)/days;
      for ev=1:4
        distr=FILES(f).DISTR(ev,per);
        % Number, Durations and Fragmentation of bouts/ibis
        bouts=NaN(days*24*60,FILES(f).EXPDATA.number_of_flies(1));
        bouts([distr.matrix(:,2)])=distr.matrix(:,1);
        bouts=bouts(:,selection{f});
        num=sum(isfinite(bouts(period{per},:)),1)/days;
        num(~logical(num))=NaN;
        bars(ev,per).num(selection{f},f)=num';
        bars(ev,per).dur(selection{f},f)=nanmean(bouts(period{per},:),1);
        %bars(ev,per).frag(selection{f},f)=num'./bars(ev,per).total(selection{f},f);
        % Burst Parameters
        bars(ev,per).B(selection{f},f)=distr.B(selection{f});
        bars(ev,per).knl(selection{f},f)=distr.wnl.k(selection{f});
        bars(ev,per).klin(selection{f},f)=distr.wlin.k(selection{f});
        
        %%% FRAGMENTATION TEMPORARY !!! %%%
        bars(ev,per).lnl(selection{f},f)=num'./bars(ev,per).total(selection{f},f);
        %=distr.wnl.lambda(selection{f});
        
        bars(ev,per).llin(selection{f},f)=distr.wlin.lambda(selection{f});
        bars(ev,per).M(selection{f},f)=distr.M(selection{f});
        
        
        % Remove Outliers (NaN them) & Run Lilliefors Test of Normality on Remaining Values
        if ~PRM.calc_diffs
          for ifield=1:length(handles.barfields)
            [bars(ev,per).(handles.barfields{ifield})(:,f),bars(ev,per).norm_p(ifield,f)]=values_norm(bars(ev,per).(handles.barfields{ifield})(:,f),PRM);
          end
        end
      end
    end
  end
end

  function [period]=get_periods(EXPDATA)
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
  end

end
function [FSCOMP,PRM]=diff_bars(FSCOMP,PRM,handles)
mbars=NaN(PRM.nrflies,length(FSCOMP.group));
norm_p=NaN(length(handles.barfields),length(FSCOMP.group));
p_t=NaN(PRM.nrfiles/2,PRM.nrfiles/2,length(handles.barfields));
for f=1:PRM.nrfiles/2
  p_t(f,f,:)=1;
end
diffbars(1:4,1:2)=struct('total',mbars,'num',mbars,'dur',mbars,'klin',mbars,'knl',mbars,'B',mbars,'llin',mbars,'lnl',mbars,'M',mbars,'norm_p',norm_p,'p_t',p_t);

isseparator=false(1,length(FSCOMP.group));
for g=1:length(FSCOMP.group)
  if ~isempty(FSCOMP.group{g})
    for ev=1:4
      for per=1:2
        for ax=1:length(handles.barfields)
          diffbars(ev,per).(handles.barfields{ax})(:,g)=diff(FSCOMP.bars(ev,per).(handles.barfields{ax})(:,FSCOMP.group{g})',1)';
          [diffbars(ev,per).(handles.barfields{ax})(:,g),diffbars(ev,per).norm_p(ax,g)]=values_norm(diffbars(ev,per).(handles.barfields{ax})(:,g),PRM);
        end
      end
    end
  else
    isseparator(g)=true;
  end
end

groupcounter=1;
group=cell(1);
names=cell(1,length(isseparator));
xbars=1:length(isseparator);
for g=1:length(isseparator)
  if ~isseparator(g)
    group{groupcounter}=[group{groupcounter} g-(groupcounter-1)];
    names{g}=FSCOMP.names{FSCOMP.group{g}(1)};
  else
    groupcounter=groupcounter+1;
    group{groupcounter}=[];
  end
end
if isempty(group{groupcounter})
  group=group(1:end-1);
end
names(isseparator)=[];
xbars(isseparator)=[];
for ev=1:4
  for per=1:2
    for ax=1:length(handles.barfields)
      diffbars(ev,per).(handles.barfields{ax})(:,isseparator)=[];
    end
    diffbars(ev,per).norm_p(:,isseparator)=[];
  end
end

% Reassign Supporting Parameters New Values
PRM.nrfiles=sum(~isseparator);

% Reassign FSCOMP-Structure New Values
FSCOMP.group=group;
FSCOMP.names=names;
FSCOMP.x=xbars;
FSCOMP.bars=diffbars;

end
function [FSCOMP,PRM]=calc_factors(FSCOMP,PRM)
unassigned=[];
bfactors=cell(5,1);
pfactors=cell(6,1);
bfactnames={'Genotype' 'Condition' 'Group' 'Date' 'Sex'}';
pfactnames={'Genotype' 'Condition' 'Group' 'Date' 'Day' 'Period'}';

if PRM.calc_diffs
  factors=NaN(5,PRM.nrfiles);
  for file=1:PRM.nrfiles
    for fctr=1:5
      if PRM.factors(fctr,(file*2-1))==PRM.factors(fctr,file*2)
        factors(fctr,file)=PRM.factors(fctr,(file*2-1));
      else
        factors(fctr,file)=0;
      end
    end
  end
else
  factors=PRM.factors;
end

for i=1:4
  if all(factors(i,:))
    bfactors{i}=repmat(factors(i,:),[PRM.nrflies,1]);
     bfactors{i}=bfactors{i}(:);
    tempfact(1,1,1:PRM.nrfiles)=factors(i,:);
    pfactors{i}=repmat(tempfact,[PRM.nrdays*24*2,PRM.nrflies,1]);
     pfactors{i}=pfactors{i}(:);
  elseif all(~factors(i,:))
    bfactors{i}=[];
    pfactors{i}=[];
    unassigned=[unassigned i];
  end
end

sexes=NaN(PRM.nrflies,length(FSCOMP.selection));
for file=1:length(FSCOMP.selection)
  sexes(FSCOMP.selection{file},file)=PRM.sex{file};
end

if PRM.calc_diffs
  newsexes=NaN(PRM.nrflies,PRM.nrfiles);
  for file=1:PRM.nrfiles
    newsexes(sexes(:,(file*2-1))==sexes(:,file*2),file)=sexes(sexes(:,(file*2-1))==sexes(:,file*2),file*2);
  end
  sexes=newsexes;
end

if all(factors(5,:))
  bfactors{5}=sexes(:);
else
  bfactors{5}=[];
end

pfactors{5}=repmat(reshape(repmat(1:PRM.nrdays,[24*2,1]),[24*2*length(1:PRM.nrdays) 1]),[1 PRM.nrflies PRM.nrfiles]);
pfactors{6}=repmat(reshape(repmat([1 2],[12*2 1]),[24*2,1]),[PRM.nrdays PRM.nrflies PRM.nrfiles]);
bfactnames(unassigned)=[];
pfactnames(unassigned)=[];
bfactors(unassigned)=[];
pfactors(unassigned)=[];


%%% Recompile Structure %%%
FSCOMP.bfactors=bfactors;
FSCOMP.bfactnames=bfactnames;
FSCOMP.pfactors=pfactors;
FSCOMP.pfactnames=pfactnames;
end
function [FSCOMP]=remove_separators(FSCOMP)
isseparator=false(1,length(FSCOMP.group));
for g=1:length(FSCOMP.group)
  if isempty(FSCOMP.group{g})
    isseparator(g)=true;
  end
end
FSCOMP.group(isseparator)=[];
end

function [patfig]=make_patfigure(FSCOMP,handles)
MyStyle=get(handles.colors,'UserData');
fspos=get(handles.figure,'Position');
fscenter=[fspos(1)+fspos(3)/2 fspos(2)+fspos(4)/2];

xfull=size(FSCOMP.patterns(1,1).full,1)/2;
xday=size(FSCOMP.patterns(1,1).day,1)/2;
xmaxlim=[xfull xday xfull xday] + 0.25;
xticks={[0:6:xfull] [0:2:24] [0:6:xfull] [0:2:24]};
xlabels={{'0' '' '12' ''} {'0' '' '' '6' '' '' '12' '' '' '18' '' ''} {'0' '' '12' ''} {'0' '' '' '6' '' '' '12' '' '' '18' '' ''}};
evlabel={'Activity' 'Activity' 'Sleep' 'Sleep'};
titlestring={'%s Profile, Full Analysis Period' 'Mean %s Profile' '%s Profile, Full Analysis Period' 'Mean %s Profile' };

patfig=zeros(1,length(FSCOMP.group));
for g=1:length(FSCOMP.group)
  % figure
  patfig(g)=figure('Name',sprintf([FSCOMP.name ' - Patterns, Group %d'],g),'IntegerHandle','on','NumberTitle','off','MenuBar','none','Color',get(0,'defaultUicontrolBackgroundColor'),'Visible','off');
  patfigpos=get(patfig(g),'Position');
  posfig=[fscenter(1)-patfigpos(3)/2 fscenter(2)-patfigpos(4)/2 patfigpos(3) patfigpos(4)];
  set(patfig(g),'Position',posfig)

  for ax=1:4
    fighandles.axes(ax)=subplot(2,2,ax);
    set(fighandles.axes(ax),'NextPlot','add','FontSize',8,'XLim',[0 xmaxlim(ax)],'XTick',xticks{ax},'XTickLabel',xlabels{ax})
    title(sprintf(titlestring{ax},evlabel{ax}),'FontSize',9)
    xlabel('ZT','FontSize',9)
    ylabel(sprintf('%s (min)',evlabel{ax}),'FontSize',9)
  end
  
  % menus
  fighandles.menu_file=uimenu('Parent',patfig(g),'Tag','menu_file','Label','&File','Callback',[]);
    fighandles.file_savefigs=uimenu('Parent',fighandles.menu_file,'Tag','menu_savefigs','Label','&Save Figures','Callback','fscomparer(''file_savefigs_Callback'',gcbo)');
    fighandles.file_save=uimenu('Parent',fighandles.menu_file,'Tag','menu_save','Label','&Save This Figure..','Callback','fscomparer(''file_save_Callback'')');
    fighandles.file_print=uimenu('Parent',fighandles.menu_file,'Tag','menu_print','Label','&Print..','Callback','fscomparer(''file_print_Callback'',gcbo)');
    fighandles.file_close=uimenu('Parent',fighandles.menu_file,'Tag','menu_close','Label','&Close Figure','Callback','fscomparer(''file_close_Callback'',gcbo)','Separator','on');

  fighandles.menu_tools=uimenu('Parent',patfig(g),'Tag','menu_tools','Label','&Tools','Callback',[]);
    fighandles.tools_copy=uimenu('Parent',fighandles.menu_tools,'Tag','tools_copy','Label','&Copy View to Clipboard','Callback','fscomparer(''tools_copy_Callback'',gcbo)','Separator','on');
    fighandles.tools_openaxes=uimenu('Parent',fighandles.menu_tools,'Tag','tools_openaxes','Label','&Open Axes in New Window','Callback','fscomparer(''tools_openaxes_Callback'',gcbo)');
    fighandles.tools_zoom=uimenu('Parent',fighandles.menu_tools,'Tag','tools_zoom','Label','&Zoom','Callback','fscomparer(''tools_zoom_Callback'',gcbo)','Separator','on');
    fighandles.tools_pan=uimenu('Parent',fighandles.menu_tools,'Tag','tools_pan','Label','&Pan','Callback','fscomparer(''tools_pan_Callback'',gcbo)');

  fighandles.menu_programs=uimenu('Parent',patfig(g),'Tag','menu_programs','Label','&Programs','Callback',[]);
    fighandles.programs_flysiesta=uimenu('Parent',fighandles.menu_programs,'Tag','programs_flysiesta','Label','FlySiesta Welcome Center','Callback','flysiesta');
    fighandles.programs_analyzer =uimenu('Parent',fighandles.menu_programs,'Tag','programs_analyzer' ,'Label','FlySiesta Analyzer','Callback','fsanalyzer','Separator','on');
    fighandles.programs_pooler   =uimenu('Parent',fighandles.menu_programs,'Tag','programs_pooler'   ,'Label','FlySiesta Pooler','Callback','fspooler');
    fighandles.programs_explorer =uimenu('Parent',fighandles.menu_programs,'Tag','programs_explorer' ,'Label','FlySiesta Explorer','Callback','fsexplorer','Separator','on');
    fighandles.programs_viewer   =uimenu('Parent',fighandles.menu_programs,'Tag','programs_viewer'   ,'Label','FlySiesta Viewer','Callback','fsviewer');
    fighandles.programs_comparer =uimenu('Parent',fighandles.menu_programs,'Tag','programs_comparer' ,'Label','FlySiesta Comparer','Callback','fscomparer');

  fighandles.menu_help=uimenu('Parent',patfig(g),'Tag','menu_help','Label','&Help','Callback',[]);
    fighandles.help_help=uimenu('Parent',fighandles.menu_help,'Tag','help_help','Label','Online User Guide','Callback','fscomparer(''help_help_Callback'')');
    fighandles.help_license=uimenu('Parent',fighandles.menu_help,'Tag','help_license','Label','License','Callback','fscomparer(''help_license_Callback'')','Separator','on');
    fighandles.help_about=uimenu('Parent',fighandles.menu_help,'Tag','help_about','Label','About','Callback','fscomparer(''help_about_Callback'')');
  
  % Save handles-structure in figure
  fighandles.Colors=MyStyle.Comparer.Colors;
  fighandles.fscomp=get(handles.savebox,'String');
  set(patfig(g),'UserData',fighandles)
end
end
function [barfigs]=make_barfigures(FSCOMP,PRM,handles)
MyStyle=get(handles.colors,'UserData');
 % Calculate dimensions for axes and figure
  spacer=35;
  wax=25*(max(FSCOMP.x)+1);
  hax=120;
  xax=repmat([spacer 2*spacer+wax 3*spacer+2*wax],[1 3]);
  xax=[xax xax(end)];
  yax=repmat([3*spacer+2*hax 2*spacer+hax spacer],[3 1]);
  yax=[yax(:)' yax(end)];
  wfig=4*spacer+3*wax;
  hfig=3.5*spacer+3*hax;
  screen=get(0,'ScreenSize');
  if wfig <= screen(3)
    fspos=get(handles.figure,'Position');
    fscenter=[fspos(1)+fspos(3)/2 fspos(2)+fspos(4)/2];
    posfig=[fscenter(1)-wfig/2 fscenter(2)-hfig/2 wfig hfig];
  else
    posfig=[1 (screen(4)-hfig)/2 wfig hfig];
  end

 % Axes colors & settings
  axescolor=MyStyle.PeriodColor;
  gsize=zeros(size(FSCOMP.group,2),1);
  for gi=1:size(FSCOMP.group,2)
    gsize(gi)=size(FSCOMP.group{gi},2);
  end
  gsize=max(gsize);
 % Create figures
  barfigs=NaN(4,2);
  evstring={'Activity Bouts' 'Sleep Bouts' 'IAIs' 'ISIs'};
  perstring={'Light' 'Dark'};
  titlestring={'Total Time per Period (min)' 'Number of Events per Period' 'Mean Duration of Events (min)' 'k, linear Weibull fit' 'k, non-linear Weibull fit' 'B  (Burst Parameter)' '\lambda, linear Weibull fit' 'Fragmentation Index' 'M (Memory Parameter)'};%'\lambda, non-linear Weibull fit' 
  for ev=1:4
    for per=1:2
     % figure
      barfigs(ev,per)=figure('Name',[FSCOMP.name ' - ' evstring{ev} ', ' perstring{per}],'Position',posfig,'IntegerHandle','on','NumberTitle','off','MenuBar','none','Color',get(0,'defaultUicontrolBackgroundColor'),'Visible','off');
      for ax=1:length(handles.barfields)
       % axes
        ymaxaxes=max(nanmean(FSCOMP.bars(ev,per).(handles.barfields{ax}),1)+nanstd(FSCOMP.bars(ev,per).(handles.barfields{ax}),0,1)./sqrt(sum(isfinite(FSCOMP.bars(ev,per).(handles.barfields{ax})),1)));
        if isnan(ymaxaxes)
          ymaxaxes=1;
        end
        yminaxes=0;
        if ymaxaxes<=yminaxes
          yminaxes=-Inf;
        end
        fighandles.axes(ax)=axes('Parent',barfigs(ev,per),'Units','pixels','Position',[xax(ax) yax(ax) wax hax],'NextPlot','add','Box','on','TickLength',[0.005 0.025],'FontSize',7,'XLim',[0.2 max(FSCOMP.x)+0.8],'XTick',FSCOMP.x,'XTickLabel',FSCOMP.names,'Color',axescolor(per,:),'YLim',[yminaxes ymaxaxes*(1+gsize*0.1)]);
        title(fighandles.axes(ax),titlestring{ax},'FontSize',8,'Units','normalized','Position',[0.5 1 0]);
      end
      if ~PRM.calc_diffs
        for iline=[4 5]
          line([0.2 max(FSCOMP.x)+0.8],[1 1],'Parent',fighandles.axes(iline),'Color',[0.5 0.5 0.5],'LineStyle',':')
        end
      end
      set(fighandles.axes,'Units','normalized')
     % menus
      fighandles.menu_file=uimenu('Parent',barfigs(ev,per),'Tag','menu_file','Label','&File','Callback',[]);
        fighandles.file_savefigs=uimenu('Parent',fighandles.menu_file,'Tag','menu_savefigs','Label','&Save Figures','Callback','fscomparer(''file_savefigs_Callback'',gcbo)');
        fighandles.file_save=uimenu('Parent',fighandles.menu_file,'Tag','menu_save','Label','&Save This Figure..','Callback','fscomparer(''file_save_Callback'')');
        fighandles.file_print=uimenu('Parent',fighandles.menu_file,'Tag','menu_print','Label','&Print..','Callback','fscomparer(''file_print_Callback'',gcbo)');
        fighandles.file_close=uimenu('Parent',fighandles.menu_file,'Tag','menu_close','Label','&Close Figure','Callback','fscomparer(''file_close_Callback'',gcbo)','Separator','on');
      
      fighandles.menu_tools=uimenu('Parent',barfigs(ev,per),'Tag','menu_tools','Label','&Tools','Callback',[]);
        fighandles.tools_hist=uimenu('Parent',fighandles.menu_tools,'Tag','tools_histograms','Label','&View Histograms','Callback',[],'Enable','on');
          fighandles.tools_hist_tot= uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_tot' ,'Label','Total minutes per Period'   ,'UserData','total','Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_num= uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_num' ,'Label','Number of Events per Period','UserData','num'  ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_dur= uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_dur' ,'Label','Mean Duration of Events'    ,'UserData','dur'  ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_klin=uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_klin','Label','k, linear fit'              ,'UserData','klin' ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_knl= uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_knl' ,'Label','k, non-linear fit'          ,'UserData','knl'  ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_B=   uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_B'   ,'Label','B, ''Burst Parameter'''     ,'UserData','B'    ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_llin=uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_llin','Label','lambda, linear fit'         ,'UserData','llin' ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_lnl= uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_lnl' ,'Label','lambda, non-linear fit'     ,'UserData','lnl'  ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
          fighandles.tools_hist_M=   uimenu('Parent',fighandles.tools_hist,'Tag','tools_hist_M'   ,'Label','M, ''Memory Parameter'''    ,'UserData','M'    ,'Callback','fscomparer(''tools_histfield_Callback'',gcbo)');
        fighandles.tools_showonbars=uimenu('Parent',fighandles.menu_tools,'Tag','tools_showonbars','Label','Display On Bars','Callback',[],'Separator','on');
          fighandles.tools_showmeans=uimenu('Parent',fighandles.tools_showonbars,'Tag','tools_showmeans','Label','Show Mean Values','Callback','fscomparer(''tools_showmeans_Callback'',gcbo)','UserData','nr');
          fighandles.tools_showflies=uimenu('Parent',fighandles.tools_showonbars,'Tag','tools_showflies','Label','Show Number of Flies','Callback','fscomparer(''tools_showflies_Callback'',gcbo)');
          fighandles.tools_hideonbars=uimenu('Parent',fighandles.tools_showonbars,'Tag','tools_hideonbars','Label','Hide Text on Bars','Callback','fscomparer(''tools_hideonbars_Callback'',gcbo)','Separator','on');
        fighandles.tools_showstats=uimenu('Parent',fighandles.menu_tools,'Tag','tools_showstats','Label','Display Stat-tests','Callback',[]);
          fighandles.tools_showps=uimenu('Parent',fighandles.tools_showstats,'Tag','tools_showps','Label','Show p-Values','Callback','fscomparer(''tools_showps_Callback'',gcbo)');
          fighandles.tools_hideps=uimenu('Parent',fighandles.tools_showstats,'Tag','tools_hideps','Label','Hide p-Values','Callback','fscomparer(''tools_hideps_Callback'',gcbo)');
          fighandles.tools_showstars=uimenu('Parent',fighandles.tools_showstats,'Tag','tools_showstars','Label','Show Stat-tests','Callback','fscomparer(''tools_showstars_Callback'',gcbo)','Separator','on');
          fighandles.tools_hidestars=uimenu('Parent',fighandles.tools_showstats,'Tag','tools_hidestars','Label','Hide Stat-tests','Callback','fscomparer(''tools_hidestars_Callback'',gcbo)');
        fighandles.tools_copy=uimenu('Parent',fighandles.menu_tools,'Tag','tools_copy','Label','&Copy View to Clipboard','Callback','fscomparer(''tools_copy_Callback'',gcbo)','Separator','on');
        fighandles.tools_openaxes=uimenu('Parent',fighandles.menu_tools,'Tag','tools_openaxes','Label','&Open Axes in New Window','Callback','fscomparer(''tools_openaxes_Callback'',gcbo)');
        fighandles.tools_zoom=uimenu('Parent',fighandles.menu_tools,'Tag','tools_zoom','Label','&Zoom','Callback','fscomparer(''tools_zoom_Callback'',gcbo)','Separator','on');
        fighandles.tools_pan=uimenu('Parent',fighandles.menu_tools,'Tag','tools_pan','Label','&Pan','Callback','fscomparer(''tools_pan_Callback'',gcbo)');
      
      fighandles.menu_anova=uimenu('Parent',barfigs(ev,per),'Tag','menu_anova','Label','&Analysis of Variance','Callback',[]);
        fighandles.anova_test=uimenu('Parent',fighandles.menu_anova,'Tag','anova_test','Label','&Test','Callback',[],'UserData',1);  
          fighandles.anova_test_anovan=uimenu('Parent',fighandles.anova_test,'Tag','anova_test_anovan','Label','N-Way ANOVA','Callback','fscomparer(''anova_test_anovan_Callback'')','Checked','on');
          fighandles.anova_test_kruswall=uimenu('Parent',fighandles.anova_test,'Tag','anova_test_kruswall','Label','Kruskal-Wallis','Callback','fscomparer(''anova_test_kruswall_Callback'')');
        
        factors={'Genotype' 'Condition' 'Group' 'Date' 'Sex'};
        fselect=false(size(factors)); 
        for s=1:length(factors); fselect(s)=ismember(factors{s},FSCOMP.bfactnames); end
        state={'off' 'on'};
        fighandles.anova_factors=uimenu('Parent',fighandles.menu_anova,'Tag','anova_test','Label','&Factors','Callback',[],'UserData',fselect);  
          s=1; fighandles.anova_factors_genotype= uimenu('Parent',fighandles.anova_factors,'Tag','anova_factors_genotype' ,'Label','Genotype' ,'Callback','fscomparer(''anova_factor_Callback'',gcbo)','UserData',s,'Checked',state{fselect(s)+1},'Enable',state{fselect(s)+1});
          s=2; fighandles.anova_factors_condition=uimenu('Parent',fighandles.anova_factors,'Tag','anova_factors_condition','Label','Condition','Callback','fscomparer(''anova_factor_Callback'',gcbo)','UserData',s,'Checked',state{fselect(s)+1},'Enable',state{fselect(s)+1});
          s=3; fighandles.anova_factors_group=    uimenu('Parent',fighandles.anova_factors,'Tag','anova_factors_group'    ,'Label','Group'    ,'Callback','fscomparer(''anova_factor_Callback'',gcbo)','UserData',s,'Checked',state{fselect(s)+1},'Enable',state{fselect(s)+1});
          s=4; fighandles.anova_factors_date=     uimenu('Parent',fighandles.anova_factors,'Tag','anova_factors_date'     ,'Label','Date'     ,'Callback','fscomparer(''anova_factor_Callback'',gcbo)','UserData',s,'Checked',state{fselect(s)+1},'Enable',state{fselect(s)+1});
          s=5; fighandles.anova_factors_sex=      uimenu('Parent',fighandles.anova_factors,'Tag','anova_factors_sex'      ,'Label','Sex'      ,'Callback','fscomparer(''anova_factor_Callback'',gcbo)','UserData',s,'Checked',state{fselect(s)+1},'Enable',state{fselect(s)+1});
        fighandles.anova_tot= uimenu('Parent',fighandles.menu_anova,'Tag','anova_tot' ,'Label','Total minutes per Period'   ,'UserData','total','Callback','fscomparer(''anovamultcompare_Callback'',gcbo)','Separator','on');
        fighandles.anova_num= uimenu('Parent',fighandles.menu_anova,'Tag','anova_num' ,'Label','Number of Events per Period','UserData','num'  ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_dur= uimenu('Parent',fighandles.menu_anova,'Tag','anova_dur' ,'Label','Mean Duration of Events'    ,'UserData','dur'  ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_klin=uimenu('Parent',fighandles.menu_anova,'Tag','anova_klin','Label','k, linear fit'              ,'UserData','klin' ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_knl= uimenu('Parent',fighandles.menu_anova,'Tag','anova_knl' ,'Label','k, non-linear fit'          ,'UserData','knl'  ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_B=   uimenu('Parent',fighandles.menu_anova,'Tag','anova_B'   ,'Label','B, ''Burst Parameter'''     ,'UserData','B'    ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_llin=uimenu('Parent',fighandles.menu_anova,'Tag','anova_llin','Label','lambda, linear fit'         ,'UserData','llin' ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_lnl= uimenu('Parent',fighandles.menu_anova,'Tag','anova_lnl' ,'Label','lambda, non-linear fit'     ,'UserData','lnl'  ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
        fighandles.anova_M=   uimenu('Parent',fighandles.menu_anova,'Tag','anova_M'   ,'Label','M, ''Memory Parameter'''    ,'UserData','M'    ,'Callback','fscomparer(''anovamultcompare_Callback'',gcbo)');
      
      fighandles.menu_programs=uimenu('Parent',barfigs(ev,per),'Tag','menu_programs','Label','&Programs','Callback',[]);
        fighandles.programs_flysiesta=uimenu('Parent',fighandles.menu_programs,'Tag','programs_flysiesta','Label','FlySiesta Welcome Center','Callback','flysiesta');
        fighandles.programs_analyzer =uimenu('Parent',fighandles.menu_programs,'Tag','programs_analyzer' ,'Label','FlySiesta Analyzer','Callback','fsanalyzer','Separator','on');
        fighandles.programs_pooler   =uimenu('Parent',fighandles.menu_programs,'Tag','programs_pooler'   ,'Label','FlySiesta Pooler','Callback','fspooler');
        fighandles.programs_explorer =uimenu('Parent',fighandles.menu_programs,'Tag','programs_explorer' ,'Label','FlySiesta Explorer','Callback','fsexplorer','Separator','on');
        fighandles.programs_viewer   =uimenu('Parent',fighandles.menu_programs,'Tag','programs_viewer'   ,'Label','FlySiesta Viewer','Callback','fsviewer');
        fighandles.programs_comparer =uimenu('Parent',fighandles.menu_programs,'Tag','programs_comparer' ,'Label','FlySiesta Comparer','Callback','fscomparer');
      
      fighandles.menu_help=uimenu('Parent',barfigs(ev,per),'Tag','menu_help','Label','&Help','Callback',[]);
        fighandles.help_help=uimenu('Parent',fighandles.menu_help,'Tag','help_help','Label','Online User Guide','Callback','fscomparer(''help_help_Callback'')');
        fighandles.help_license=uimenu('Parent',fighandles.menu_help,'Tag','help_license','Label','License','Callback','fscomparer(''help_license_Callback'')','Separator','on');
        fighandles.help_about=uimenu('Parent',fighandles.menu_help,'Tag','help_about','Label','About','Callback','fscomparer(''help_about_Callback'')');
        
        % Save handles-structure in figure
        fighandles.Colors=MyStyle.Comparer.Colors;
        fighandles.evper=[ev per];
        fighandles.fscomp=get(handles.savebox,'String');
        set(barfigs(ev,per),'UserData',fighandles)
    end
  end
end

function plot_patterns(FSCOMP,PRM,handles)
MyStyle=get(handles.colors,'UserData');
CmpColors=MyStyle.Comparer.Colors;
if PRM.nrfiles>size(CmpColors,1)
  CmpColors=repmat(CmpColors,[ceil(PRM.nrfiles/size(CmpColors,1)) 1]);
end

xfull=[0.25:0.5:size(FSCOMP.patterns(1,1).full,1)/2];
xday=[0.25:0.5:size(FSCOMP.patterns(1,1).day,1)/2];
for g=1:length(FSCOMP.group)
  files_group=length(FSCOMP.group{g});
  figure(handles.patfigs(g))
  fighandles=get(handles.patfigs(g),'UserData');
  for ev=1:2
    % Plot each pattern
    for fg=1:files_group
      f=FSCOMP.group{g}(fg);
      % Full Pattern
      means=squeeze(nanmean(FSCOMP.patterns(ev).full(:,:,f),2));
      sems=squeeze(nanstd(FSCOMP.patterns(ev).full(:,:,f),0,2)/sqrt(length(FSCOMP.selection{f})));
      errorbar(fighandles.axes(ev*2-1),xfull,means,sems,'Color',CmpColors(fg,:))
      plot(fighandles.axes(ev*2-1),xfull,means,'Color',CmpColors(fg,:),'LineWidth',2)
      % Mean Pattern
      means=squeeze(nanmean(FSCOMP.patterns(ev).day(:,:,f),2));
      sems=squeeze(nanstd(FSCOMP.patterns(ev).day(:,:,f),0,2)/sqrt(length(FSCOMP.selection{f})));
      errorbar(fighandles.axes(ev*2),xday,means,sems,'Color',CmpColors(fg,:))
      plot(fighandles.axes(ev*2),xday,means,'Color',CmpColors(fg,:),'LineWidth',2)
    end
  end
end
end
function [FSCOMP]=plot_n_test_bars(FSCOMP,PRM,handles)

% Colors & formatting
MyStyle=get(handles.colors,'UserData');
CmpColors=MyStyle.Comparer.Colors;
if PRM.nrfiles>size(CmpColors,1)
  CmpColors=repmat(CmpColors,[ceil(PRM.nrfiles/size(CmpColors,1)) 1]);
end
pw=[1 1 2 2 2 2 2 2 2];
bartextstate={'off' 'on'};
stargap=min(0.025*max(FSCOMP.x),0.275);   % Space Between Stars
NSgap=0.15;                               % Space Between Lines and 'NS'

barclick=['valuetext=findobj(get(gcbo,''Parent''),''Tag'',''valuetext'',''-and'',''UserData'',get(gcbo,''UserData''));' ...
  'nrtext=findobj(get(gcbo,''Parent''),''Tag'',''nrtext'',''-and'',''UserData'',get(gcbo,''UserData''));' ...
  'state_value=get(valuetext,''Visible'');' ...
  'state_nr=get(nrtext,''Visible'');' ...
  'set(valuetext,''Visible'',state_nr);' ...
  'set(nrtext,''Visible'',state_value); clear valuetext nrtext state_value state_nr'];

starclick=['ptext=findobj(get(gcbo,''Parent''),''Tag'',''p_star'',''-and'',''UserData'',get(gcbo,''UserData''));' ...
    'newstate=setdiff({''on'' ''off''},get(ptext,''Visible''));' ...
    'set(ptext,''Visible'',newstate{:}); clear ptext newstate'];

% Waitbar
step=0;
steps=0;
for igr=1:length(FSCOMP.group);
  steps=steps+(2*length(FSCOMP.group{igr})+sum(1:length(FSCOMP.group{igr})-1))*length(handles.barfields)*4*2;
end
handles.waitbar=create_waitbar;
guidata(handles.figure,handles)

% Start Looping Through Events, Periods and Axes
for g=1:length(FSCOMP.group)
  files_group=length(FSCOMP.group{g});
  ymaxbars=zeros(files_group,1);
  yminbars=zeros(files_group,1);
  for ev=1:4
    for per=1:2
      fighandles=get(handles.barfigs(ev,per),'UserData');
      for ax=1:length(handles.barfields)
        %%% Plot each bar %%%
        for fg=1:files_group
          f=FSCOMP.group{g}(fg);
          % Select flies
          if PRM.pairedtest
            if files_group==2
              flies=isfinite(diff(FSCOMP.bars(ev,per).(handles.barfields{ax})(:,FSCOMP.group{g}(1:files_group))',1)');
            else
              disp_errordlg('Cannot Proceed: All groups must be of size two!');
              delete(handles.waitbar)
              delete(handles.patfigs)
              return
            end
          else
            flies=1:length(FSCOMP.bars(ev,per).(handles.barfields{ax})(:,f));
          end
          % Plot
          y=nanmean(FSCOMP.bars(ev,per).(handles.barfields{ax})(flies,f));
          ysem=nanstd(FSCOMP.bars(ev,per).(handles.barfields{ax})(flies,f))/sqrt(sum(isfinite(FSCOMP.bars(ev,per).(handles.barfields{ax})(flies,f))));
          ymaxbars(fg)=max([y+ysem 0]);
          yminbars(fg)=min([y-ysem 0]);
          bar(FSCOMP.x(f),y,'Parent',fighandles.axes(ax),'Tag','bar','UserData',f,'FaceColor',CmpColors(fg,:),'ButtonDownFcn',barclick)
          errorbar(FSCOMP.x(f),y,ysem,'Parent',fighandles.axes(ax),'UserData',f,'LineWidth',1.2,'LineStyle','none','Color','k')
          % Text Bar-values
          if y>0, valign='bottom';
          else    valign='top';
          end
          if ~isnan(y)
            text('Position',[FSCOMP.x(f),0],'String',sprintf('%.*f',pw(ax),y),'Parent',fighandles.axes(ax),'Tag','valuetext','UserData',f,'FontSize',7,'Color','k','HorizontalAlignment','center','VerticalAlignment',valign,'Visible',bartextstate{1},'ButtonDownFcn',barclick)
            text('Position',[FSCOMP.x(f),0],'String',sprintf('%d',sum(isfinite(FSCOMP.bars(ev,per).(handles.barfields{ax})(flies,f)))),'Parent',fighandles.axes(ax),'Tag','nrtext','UserData',f,'FontSize',7,'Color','k','HorizontalAlignment','center','VerticalAlignment',valign,'Visible',bartextstate{2},'ButtonDownFcn',barclick)
          end
          if ~PRM.calc_diffs && (ax==6 || ax==9)
            line([0.2 max(FSCOMP.x)+0.8],[0 0],'Parent',fighandles.axes(ax),'Color',[0.5 0.5 0.5],'LineStyle',':')
          end
          % Update waitbar
          if getappdata(handles.waitbar,'canceling')
            return
          else
            step=step+2;
          end
          waitbar(step/steps,handles.waitbar,sprintf('%1.0f%% Done',100*step/steps))
        end

        %%% Stat-test %%%
        stattest
      end

      %%% Fix Y-Limits %%%
      if ~PRM.calc_diffs
        % set y-axes for k and lambda for each fitting method the same
        set([fighandles.axes(4) fighandles.axes(5)],'YLim',[0 max(max( [1.05 get(fighandles.axes(4),'YLim') get(fighandles.axes(5),'YLim')] ))])
        %%% FRAGMENTATION TEMPORARY !!! %%%
        %set([fighandles.axes(7) fighandles.axes(8)],'YLim',[0 max(max( [get(fighandles.axes(7),'YLim') get(fighandles.axes(8),'YLim')] ))])
        set([fighandles.axes(6) fighandles.axes(9)],'YLimMode','auto')
      else
        set(fighandles.axes,'YLimMode','auto')
      end

    end
  end
end

delete(handles.waitbar)

  function stattest
    statpairs=zeros(sum([1:files_group-1]),2);
    x=zeros(sum([1:files_group-1]),2);
    ymax=zeros(sum([1:files_group-1]),1);
    pairs=0;
    for fst=1:files_group-1
      for snd=fst+1:files_group
        pairs=pairs+1;
        statpairs(pairs,:)=[FSCOMP.group{g}(fst) FSCOMP.group{g}(snd)];
        x(pairs,:)=[FSCOMP.x(FSCOMP.group{g}(fst)) FSCOMP.x(FSCOMP.group{g}(snd))];
        ymax(pairs)=max(ymaxbars(fst:snd));
      end
    end
    [layer,order]=sort(statpairs(:,2)-statpairs(:,1));
    statpairs=statpairs(order,:);
    x=x(order,:);
    ymax=ymax(order);
    yaxint=abs(diff([max(ymaxbars) min(yminbars)]));
    increment=yaxint*cumsum(0.075*ones(1,files_group));

    for pair=1:pairs
      % Decide Which Type of Test:
      % Parametric or Bootstrapped (Non-Parametric) Student-t Test
      parametric=~any([FSCOMP.bars(ev,per).norm_p(ax,statpairs(pair,1)),FSCOMP.bars(ev,per).norm_p(ax,statpairs(pair,2))]<PRM.alphanorm);
      if get(handles.start,'UserData')
        set1=FSCOMP.bars(ev,per).(handles.barfields{ax})(:,statpairs(pair,1));
        set2=FSCOMP.bars(ev,per).(handles.barfields{ax})(:,statpairs(pair,2));
        if PRM.pairedtest
          set1=set2-set1;
          set2=zeros(size(set1));
        end
        if parametric
          try
            vartype='unequal';
            hvar=vartest2(set1,set2);
            if ~PRM.pairedtest && logical(hvar) && ~hvar
              vartype='equal';
            end
            [h,p]=ttest2(set1,set2,PRM.alphatest,[],vartype);
          catch h=0; p=NaN;
          end
          if isnan(h), h=0; p=NaN; end
        else
          try
            bootstat=bootstrp(PRM.bsamp,@studt,set1,set2);
            p=2*min(sum(bootstat<=0),sum(bootstat>0))/PRM.bsamp;
            h=double(p<=PRM.alphatest);
          catch h=0; p=NaN;
          end
        end
        FSCOMP.bars(ev,per).p_t(statpairs(pair,1),statpairs(pair,2),ax)=p;
        FSCOMP.bars(ev,per).p_t(statpairs(pair,2),statpairs(pair,1),ax)=p;
      else
        p=FSCOMP.bars(ev,per).p_t(statpairs(pair,1),statpairs(pair,2),ax);
        h=double(p<=PRM.alphatest);
      end
      
      % Plot Result Stars
      if logical(h)
        if p<0.001
          stars=3;
          starxs=mean(x(pair,:))+[-stargap 0 +stargap];
          linegap=stargap+0.1;
        elseif p<0.01
          stars=2;
          starxs=mean(x(pair,:))+[-stargap/2 +stargap/2];
          linegap=stargap/2+0.1;
        else
          stars=1;
          starxs=mean(x(pair,:));
          linegap=0.1;
        end
        if parametric, plot_stars(MyStyle.Stars.Ttest)
        else           plot_stars(MyStyle.Stars.KStest)
        end
      else
        linegap=NSgap;
        plot_stars(MyStyle.Stars.NotSignf)
      end

      % Waitbar
      if getappdata(handles.waitbar,'canceling')
        return
      else
        step=step+1;
      end
      waitbar(step/steps,handles.waitbar,sprintf('%1.0f%% Done',100*step/steps))
    end
    
    function plot_stars(Style)
      if any(ymax(pair)>0)
        ystar=ymax(pair)+increment(layer(pair));  % ymax(pair)*(1+0.025*pair*(layer(pair)-1))
      else
        ystar=abs(increment(layer(pair)));
      end
      text('Position',[mean(x(pair,:)) ystar-yaxint*0.04],'Parent',fighandles.axes(ax),'Tag','p_star','UserData',ystar,'String',sprintf('p=%1.2g',p),'FontSize',7,'Color',[0 0 0],'HorizontalAlignment','center','ButtonDownFcn',starclick,'Visible','off');
      if logical(h)
        for str=1:stars
          plot(starxs(str),ystar,'Parent',fighandles.axes(ax),'Tag','Star','UserData',ystar,'ButtonDownFcn',starclick,Style)
        end
      else
        text('Position',[mean(x(pair,:)) ystar],'Parent',fighandles.axes(ax),'Tag','Star','UserData',ystar,'String','NS','FontSize',5,'Color',[0 0 0],'HorizontalAlignment','center','ButtonDownFcn',starclick)
      end
      line([x(pair,1)+0.025 mean(x(pair,:))-linegap],[ystar ystar],'Parent',fighandles.axes(ax),'Tag','StarLine','Color','k','LineWidth',1)
      line([x(pair,1) x(pair,1)]+0.025,[ystar-yaxint*0.01 ystar],'Parent',fighandles.axes(ax),'Tag','StarLine','Color','k','LineWidth',1)
      line([mean(x(pair,:))+linegap x(pair,2)-0.025],[ystar ystar],'Parent',fighandles.axes(ax),'Tag','StarLine','Color','k','LineWidth',1)
      line([x(pair,2) x(pair,2)]-0.025,[ystar-yaxint*0.01 ystar],'Parent',fighandles.axes(ax),'Tag','StarLine','Color','k','LineWidth',1)
      if any(ymax(pair)>0)
        set(fighandles.axes(ax),'YLimMode','auto')
      end
    end
    
    function tstat=studt(x,y)
      tstat=(nanmean(x)-nanmean(y)) ./ sqrt( nanvar(x)/sum(~isnan(x)) + nanvar(y)/sum(~isnan(y)) );
    end
    
  end

  function [h_waitbar]=create_waitbar
    figurePosition=getpixelposition(gcf);
    h_waitbar=waitbar(0,'','Name','Statistical Test and Plotting...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)','Pointer','watch');
    dlgPosition=getpixelposition(h_waitbar);
    setpixelposition(h_waitbar,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    setappdata(h_waitbar,'canceling',0)
    hbar=findobj([get(findobj([get(h_waitbar,'Children')],'Type','axes'),'Children')],'Type','patch');
    color=[0.25 0.25 0.75];
    set(hbar,'FaceColor',color,'EdgeColor',color);
  end

end

function [values,p]=values_norm(values,PRM)
  % Remove Outliers
  if isfinite(PRM.stdtol)
    outliers=abs(values-repmat(nanmean(values),size(values))>PRM.stdtol*repmat(nanstd(values,0),size(values)));
    values(logical(outliers))=NaN;
  end
  % Test for Normality
  try [h,p]=lillietest(values,PRM.alphanorm);
  catch p=NaN;
  end
end
function disp_errordlg(message)
h_dlg=errordlg(message,'Error: Cannot Proceed','modal');
figurePosition=getpixelposition(gcf); dlgPosition=getpixelposition(h_dlg);
setpixelposition(h_dlg,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
uiwait(h_dlg)
end


%%% Figures' Menu %%%
function file_save_Callback
[FileName,PathName]=uiputfile('*.fig','Save Entire Figure As');
if FileName~=0
  saveas(gca,[PathName FileName],'fig')
end
end
function file_savefigs_Callback(hObject)
  figs=get(0,'Children');
  figname=get(get(get(hObject,'Parent'),'Parent'),'Name');
  figname=figname(1:findstr(' - ',figname)+2);
  for i=1:length(figs)
    if ~isempty(strmatch(figname,get(figs(i),'Name')))
      disp(['Saving ' get(figs(i),'Name') ' ...'])
      saveas(figs(i),[get(figs(i),'Name') '.fig'])
    end
  end
  disp('Done!')
end
function file_print_Callback(hObject)
printpreview(get(get(hObject,'Parent'),'Parent'))
end
function file_close_Callback(hObject)
close(get(get(hObject,'Parent'),'Parent'))
end

function tools_histfield_Callback(hObject)
parentfigure=gcf;
fighandles=get(parentfigure,'UserData');
field=get(hObject,'UserData');
try load(fighandles.fscomp)
  load_ok=true;
catch
  load_ok=false;
  disp('Error / File not found!')
end
if load_ok
  CmpColors=fighandles.Colors;
  EV={'Activity Bouts' 'Sleep Bouts' 'IAIs' 'ISIs'};
  PER={'Light' 'Dark'};
  for g=1:length(FSCOMP.group)
    if length(FSCOMP.group)==1, groupstr=[];
    else groupstr=sprintf('Group %d: ',g);
    end
    figure('Name',[groupstr EV{fighandles.evper(1)} ' ' PER{fighandles.evper(2)} ' Histograms, ' get(hObject,'Label')],'IntegerHandle','on','NumberTitle','off')
    
    values=FSCOMP.bars(fighandles.evper(1),fighandles.evper(2)).(field)(:,FSCOMP.group{g});
    [n_comp,x_comp]=hist(values);
    if size(values,2)==1
      n_comp=n_comp';
    end
    n_comp=n_comp./repmat(sum(n_comp,1),[size(n_comp,1),1]);
    files_group=length(FSCOMP.group{g});
    m=zeros(1,files_group);
    for fg=1:files_group
      if files_group>size(CmpColors,1)
        CmpColors=repmat(CmpColors,[ceil(files_group/size(CmpColors,1)) 1]);
      end
      subplot(2,files_group,fg)
       set(gca,'Box','on','TickLength',[0.005 0.025],'FontSize',8)
       [n,x]=hist(values(:,fg));
       n=n/sum(n);
       bar(x,n,'FaceColor',CmpColors(fg,:))
       xlabel(get(hObject,'Label'))
       ylabel('P')
       hl=legend(FSCOMP.names{FSCOMP.group{g}(fg)});
       set(hl,'Interpreter','none')
       m(fg)=nanmean(values(:,fg));
       sd=nanstd(values(:,fg));
       sm=sd/sqrt(sum(~isnan(values(:,fg))));
       title(sprintf('mean=%1.4f\nstd=%1.4f\nsem=%1.4f',m(fg),sd,sm))
      subplot(2,files_group,[files_group+1:files_group*2])
       set(gca,'Box','on','TickLength',[0.005 0.025],'FontSize',8)
       hold on
       plot(x_comp,n_comp(:,fg),'Color',CmpColors(fg,:),'LineWidth',3)
       xlabel(get(hObject,'Label'))
       ylabel('P')
    end
    ylimits=ylim;
    for fg=1:files_group
      subplot(2,files_group,[files_group+1:files_group*2])
       line([m(fg) m(fg)],ylimits,'Color',CmpColors(fg,:),'LineStyle','--')
    end
    title([EV{fighandles.evper(1)} ', ' PER{fighandles.evper(2)}],'FontSize',9)
    hl=legend(FSCOMP.names{FSCOMP.group{g}});
    set(hl,'Interpreter','none')
  end
end
end
function tools_showmeans_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','valuetext'),'Visible','on')
set(findobj(fighandles.axes,'Tag','nrtext'),'Visible','off')
end
function tools_showflies_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','valuetext'),'Visible','off')
set(findobj(fighandles.axes,'Tag','nrtext'),'Visible','on')
end
function tools_hideonbars_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','nrtext'),'Visible','off')
set(findobj(fighandles.axes,'Tag','valuetext'),'Visible','off')
end
function tools_showps_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','p_star'),'Visible','on')
end
function tools_hideps_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','p_star'),'Visible','off')
end
function tools_showstars_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','Star'),'Visible','on')
set(findobj(fighandles.axes,'Tag','StarLine'),'Visible','on')
end
function tools_hidestars_Callback(hObject)
fighandles=get(gcf,'UserData');
set(findobj(fighandles.axes,'Tag','p_star'),'Visible','off')
set(findobj(fighandles.axes,'Tag','Star'),'Visible','off')
set(findobj(fighandles.axes,'Tag','StarLine'),'Visible','off')
end
function tools_copy_Callback(hObject)
print -dbitmap
end
function tools_openaxes_Callback(hObject, eventdata, handles)
parentfigure=gcf;
set(parentfigure,'Pointer','cross')
figurePosition=getpixelposition(parentfigure);
inputtype=waitforbuttonpress;
while inputtype~=0
  inputtype=waitforbuttonpress;
end
selected_axes=gca;
hf=figure('Name',get(get(selected_axes,'Title'),'String'),'NumberTitle','off','IntegerHandle','on');
tempaxes=axes;
new_axes=copyobj(selected_axes,hf);
set(new_axes,'Units',get(tempaxes,'Units'),'Position',get(tempaxes,'Position'))
delete(tempaxes)
fPosition=getpixelposition(hf);
setpixelposition(hf,[figurePosition(1)+(figurePosition(3)-fPosition(3))/2 figurePosition(2)+(figurePosition(4)-fPosition(4))/2 fPosition(3:4)])
set(hf,'HandleVisibility','on')
figureTitle=get(parentfigure,'Name');
axesTitle=get(get(new_axes,'Title'),'String');
title(new_axes,[figureTitle ': ' axesTitle])
stars=findobj(hf,'Tag','Star');
if ~isempty(stars)
  for i=1:length(stars)
    set(get(get(stars(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end
starlines=findobj(hf,'Tag','StarLine');
if ~isempty(starlines)
  for i=1:length(starlines)
    set(get(get(starlines(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
end
set(parentfigure,'Pointer','arrow')
end
function tools_zoom_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
switch checked
  case 'on'
    set(hObject,'Checked','off')
    zoom out
    zoom off
  case 'off'
    set(hObject,'Checked','on')
    zoom on
end
end
function tools_pan_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
switch checked
  case 'on'
    set(hObject,'Checked','off')
    pan off
  case 'off'
    set(hObject,'Checked','on')
    pan on
end
end

function anova_test_anovan_Callback
fighandles=get(gcf,'UserData');
checked=get(fighandles.anova_test_anovan,'Checked');
switch checked
  case 'off'
    set(fighandles.anova_test_anovan,'Checked','on')
    set(fighandles.anova_test_kruswall,'Checked','off')
    set(fighandles.anova_test,'UserData',1)
end
end
function anova_test_kruswall_Callback
fighandles=get(gcf,'UserData');
checked=get(fighandles.anova_test_kruswall,'Checked');
switch checked
  case 'off'
    set(fighandles.anova_test_kruswall,'Checked','on')
    set(fighandles.anova_test_anovan,'Checked','off')
    set(fighandles.anova_test,'UserData',2)
end
end
function anovamultcompare_Callback(hObject)
parentfigure=gcf;
fighandles=get(parentfigure,'UserData');
field=get(hObject,'UserData');
try load(fighandles.fscomp)
  load_ok=true;
catch
  load_ok=false;
  disp('Error / File not found!')
end
if load_ok
  if get(fighandles.anova_test,'UserData')==1
    [p,table,stats,terms]=anovan(FSCOMP.bars(fighandles.evper(1),fighandles.evper(2)).(field)(:),FSCOMP.bfactors,'varnames',FSCOMP.bfactnames, ...
                                 'model',1,'display','off');
  elseif get(fighandles.anova_test,'UserData')==2
    [p,table,stats]=kruskalwallis(FSCOMP.bars(fighandles.evper(1),fighandles.evper(2)).(field),FSCOMP.names');
  end
  
  factors={'Genotype' 'Condition' 'Group' 'Date' 'Sex'}';
  analyze_dims=factors(get(fighandles.anova_factors,'UserData'));
  
  mcdims=[];
  for i=1:length(FSCOMP.bfactnames)
    pos=strcmpi(FSCOMP.bfactnames{i},analyze_dims);
    if any(pos)
      mcdims=[mcdims i];
    end
  end
  figure;
  [c,m,h]=multcompare(stats,'ctype','bonferroni','dimension',mcdims);
  title([get(parentfigure,'Name') ': ' get(hObject,'Label')])
end
end
function anova_factor_Callback(hObject)
factors=get(get(hObject,'Parent'),'UserData');
checked=get(hObject,'Checked');
switch checked
  case 'on'
    set(hObject,'Checked','off')
    factors(get(hObject,'UserData'))=false;
  case 'off'
    set(hObject,'Checked','on')
    factors(get(hObject,'UserData'))=true;
end
set(get(hObject,'Parent'),'UserData',factors)
end

function help_help_Callback
stat=web('http://www.neural-circuits.org/flysiesta/userguide/','-browser');
if logical(stat)
  web('http://www.neural-circuits.org/flysiesta/userguide/')
end
end
function help_license_Callback
fsaux_path=mfilename('fullpath');
seps=strfind(fsaux_path,filesep);
web(['file:///' fsaux_path(1:seps(end-1)) 'LICENSE.txt'])
end
function help_about_Callback
fsabout;
end


