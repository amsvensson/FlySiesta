function varargout = fsbatch
% FlySiesta Batch - Batch Analyze FlySiesta .settings files.
% Requires FlySiesta settings files, previously created with FlySiesta Analyzer.
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
handles.figure=figure('Name','FlySiesta Batch Analyzer','NumberTitle','off','UserData',FlySiesta_version,'IntegerHandle','off','Color',get(0,'defaultUicontrolBackgroundColor'),...
  'HandleVisibility','callback','MenuBar','none','ToolBar','none','Position',[400,300,450,300],'Resize','off','Visible','off');

handles.inputpanel=uipanel('Parent',handles.figure,'Title','Select FlySiesta Settings Files Batch Process','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'),'BorderType','etchedin','Units','normalized','Position',[0.025 0.185 0.95 0.795]);
handles.bottompanel=uipanel('Parent',handles.figure,'BackgroundColor',[0.2353 0.3922 0.8627],'BorderType','beveledout','Units','normalized','Position',[0 0 1 0.15]);

fs_add=[]; fs_remove=[]; help_mine=[]; about_mine=[];
load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'],'fs_add','recfolder_add','fs_remove','help_mine','about_mine')
handles.filelist=uicontrol('Style','listbox','Parent',handles.inputpanel,'BackgroundColor','white','FontSize',8,'Units','pixels','Position',[20 17 310 195],'Min',0,'Max',2);
handles.adddir=uicontrol('Style','pushbutton','String','','Callback',{@adddir_Callback},'Parent',handles.inputpanel,'Units','pixels','Position',[342 150 25 25],'CData',recfolder_add,'Tooltip','Add All FlySiesta Settings Files in Sub-Directories');
handles.add=uicontrol('Style','pushbutton','String','','Callback',{@add_Callback},'Parent',handles.inputpanel,'Units','pixels','Position',[342 105 25 25],'CData',fs_add,'Tooltip','Select FlySiesta Settings Files to Batch Process');
handles.remove=uicontrol('Style','pushbutton','String','','Callback',{@remove_Callback},'Parent',handles.inputpanel,'Units','pixels','Position',[342 60 25 25],'CData',fs_remove,'Tooltip','Remove File from List');
handles.adddirtext=uicontrol('Style','text','String',{'Add All' 'in Sub' 'Folders'},'Parent',handles.inputpanel,'FontSize',8,'Units','pixels','Position',[375 141 45 45],'HorizontalAlignment','left');
handles.addtext=uicontrol('Style','text','String','Add Files','Parent',handles.inputpanel,'FontSize',8,'Units','pixels','Position',[375 96 50 30],'HorizontalAlignment','left');
handles.removetext=uicontrol('Style','text','String','Remove Files','Parent',handles.inputpanel,'FontSize',8,'Units','pixels','Position',[375 56 50 30],'HorizontalAlignment','left');

handles.help=uicontrol('Style','radiobutton','CData',help_mine,'Callback',{@help_Callback},'Parent',handles.bottompanel,'Background',[0.2353 0.3922 0.8627],'Units','pixels','Position',[16 12 20 20],'Tooltip','Online User Guide');
handles.about=uicontrol('Style','radiobutton','CData',about_mine,'Callback',{@about_Callback},'Parent',handles.bottompanel,'Background',[0.2353 0.3922 0.8627],'Units','pixels','Position',[46 12 20 20],'Tooltip','About');
handles.gobutton=uicontrol('Style','pushbutton','String','Start','FontSize',9,'FontWeight','bold','Callback',{@gobutton_Callback},'Parent',handles.bottompanel,'Units','pixels','Position',[360 10 75 30],'Tooltip','Start Analysis!');


%%% Initialize GUI %%%
if nargout>0
  varargout{1}=handles.figure;
end
movegui(handles.figure,'center')
set(handles.figure,'Visible','on')



% Callback functions
  function adddir_Callback(source,eventdata)
    if isempty(get(handles.filelist,'UserData'))
      set(handles.filelist,'String','')
    end
    rootdir=uigetdir(cd,'Select Folder for Recursive Add of *.settings Files');
    if ~isempty(rootdir) && ischar(rootdir)
      resultdirfiles=exe_subdir('{sprintf(''%s'',cd) dir(''*.settings'')}',rootdir);
      input_dirs=cell(size(resultdirfiles));
      filesindir=cell(size(resultdirfiles));
      for i=1:size(input_dirs,1)
        input_dirs{i}=resultdirfiles{i}{1};
        filesindir{i}=resultdirfiles{i}{2};
      end
      nrfiles=sum(cellfun(@length,filesindir));
      if nrfiles>0
        truefiles=logical(cellfun(@length,filesindir));
        input_dirs(~truefiles)=[];
        filesindir(~truefiles)=[];
        newdirs=cell(nrfiles,1);
        input_files=cell(nrfiles,1);
        file=1;
        for g=1:size(input_dirs,1)
          for f=1:size(filesindir{g},1)
            newdirs{file}=input_dirs{g};
            settingsfiles=filesindir{g};
            input_files{file}=settingsfiles(f).name;
            file=file+1;
          end
        end
        oldfiles=get(handles.filelist,'String');
        olddirs=get(handles.filelist,'UserData');
        set(handles.filelist,'String',[oldfiles ; input_files],'UserData',[olddirs ; newdirs])
      else
        % Dialog Box: Could not find any settings files!
      end
    end
  end
  function add_Callback(source,eventdata)
    if isempty(get(handles.filelist,'UserData'))
      set(handles.filelist,'String','')
    end
    [input_files,input_dir]=uigetfile({'*.settings'; '*.txt'},'Select FlySiesta File(s)','MultiSelect','on');
    if iscell(input_files); input_files=input_files';
    else input_files={input_files};
    end
    if ~isequal(input_files{1},0)
      newdirs=cell(size(input_files,1),1);
      for i=1:size(input_files,1)
        newdirs{i}=input_dir;
      end
      oldfiles=get(handles.filelist,'String');
      olddirs=get(handles.filelist,'UserData');
      set(handles.filelist,'String',[oldfiles ; input_files],'UserData',[olddirs ; newdirs])
    end
  end
  function remove_Callback(source,eventdata)
    selected=get(handles.filelist,'Value');
    files=get(handles.filelist,'String');
    dirs=get(handles.filelist,'UserData');
    set(handles.filelist,'String',files(setdiff([1:length(files)],selected)),'Value',[],'UserData',dirs(setdiff([1:length(dirs)],selected)));
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
  function gobutton_Callback(source,eventdata)
    
    set([handles.filelist handles.add handles.remove handles.gobutton],'Enable','inactive')
    set(handles.figure,'Pointer','watch')
    pause(1)
    
    files=get(handles.filelist,'String');
    dirs=get(handles.filelist,'UserData');
    
    % Initialize FlySiesta Analyzer
    hfig_analyzer=fsanalyzer('Visible','off');
    analyzer_handles=guidata(hfig_analyzer);
    for i=1:length(files)
      % Load Settings File
      hObj=analyzer_handles.infofile;
      set(hObj,'String',[dirs{i} filesep files{i}]);
      hObjCb=get(hObj,'Callback');
      hObjCb(hObj,[])
      
      % Change to tab 5 (which updates info)
      hObj=analyzer_handles.next;
      hObjCb=get(hObj,'Callback');
      for tab=2:5
        hObjCb(hObj,[])
      end
      
      % Start Analyze
      hObj=analyzer_handles.analyze;
      hObjCb=get(hObj,'Callback');
      hObjCb(hObj,'KeepOpen')
    end
    
    set([handles.filelist handles.add handles.remove handles.gobutton],'Enable','on')
    set(handles.figure,'Pointer','arrow')
    
    % Ok/Done Button
    h_finished=msgbox({'' '     FlySiesta Batch Analysis Successful!'  ''},'Done','modal');
    figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_finished);
    setpixelposition(h_finished,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
    tic, uiwait(h_finished,30)
    if toc>30,
      delete(h_finished)
      fprintf('FlySiesta Batch Analysis Successful!\n');
    end
    close(hfig_analyzer)
    close(handles.figure)
    flysiesta
    
  end

end

function function_result=exe_subdir(function_string,firstdir)
% Executes "function_string" in all of "firstdir"'s subfolders. If no 
% directory is specified, it is executed in the current directory and
% all its subfolders.

callingdir=cd;
if nargin<2
  firstdir=cd;
else
  cd(firstdir)
end
treelevel=1;
nrsubdirs=NaN;
subdirlist=cell(1);
exe_count=1;
function_result=cell(100,1);

while treelevel>0

  if length(nrsubdirs)<treelevel
    nrsubdirs=[nrsubdirs NaN];
  end

  if isnan(nrsubdirs(treelevel))
    currentdir=[cd filesep];
    dir_cd=dir;
    nrdirs=0;
    for i=1:length(dir_cd)
      if dir_cd(i).isdir && ~any(strcmp(dir_cd(i).name,{'.' '..'}))
        nrdirs=nrdirs+1;
        subdirlist{nrdirs,treelevel}=[currentdir filesep dir_cd(i).name];
      end
    end
    nrsubdirs(treelevel)=nrdirs;
    
  else
    if nrsubdirs(treelevel)==0
      %disp(sprintf('%s',cd))
      function_result{exe_count}=eval(function_string);
      exe_count=exe_count+1;
      nrsubdirs(treelevel)=nrsubdirs(treelevel)-1;

    elseif nrsubdirs(treelevel)>0
      cd(subdirlist{nrsubdirs(treelevel),treelevel})
      subdirlist{nrsubdirs(treelevel),treelevel}=[];
      nrsubdirs(treelevel)=nrsubdirs(treelevel)-1;
      treelevel=treelevel+1;

    elseif nrsubdirs(treelevel)<0
      cd('..')
      nrsubdirs(treelevel)=[];
      treelevel=treelevel-1;
    end
    
  end
end

function_result=function_result(1:exe_count-1);
cd(callingdir)
%disp('Finished!')
end
