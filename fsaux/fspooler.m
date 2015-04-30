function varargout = fspooler
% FlySiesta Pooler - Pool FlySiesta files for joint analysis. 
% Requires FlySiesta files, previously created with FlySiesta Analyzer.
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
handles.figure=figure('Name','FlySiesta Pooler','NumberTitle','off','UserData',FlySiesta_version,'IntegerHandle','off','Color',get(0,'defaultUicontrolBackgroundColor'),...
                      'HandleVisibility','callback','MenuBar','none','ToolBar','none','Position',[400,300,450,350],'Resize','off','Visible','off');

handles.inputpanel=uipanel('Parent',handles.figure,'Title','Select FlySiesta Files to Pool','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'),'BorderType','etchedin','Units','normalized','Position',[0.025 0.4 0.95 0.55]);
handles.outputpanel=uipanel('Parent',handles.figure,'Title','Save New FlySiesta File','BackgroundColor',get(0,'defaultUicontrolBackgroundColor'),'BorderType','etchedin','Units','normalized','Position',[0.025 0.185 0.95 0.17]);
handles.bottompanel=uipanel('Parent',handles.figure,'BackgroundColor',[0.2353 0.3922 0.8627],'BorderType','beveledout','Units','normalized','Position',[0 0 1 0.15]);

fs_add=[]; fs_remove=[]; fs_save=[]; help_mine=[]; about_mine=[];
load('-mat',[fileparts(mfilename('fullpath')) filesep 'fsinit.dat'],'fs_add','fs_remove','fs_save','help_mine','about_mine')
handles.filelist=uicontrol('Style','listbox','Parent',handles.inputpanel,'BackgroundColor','white','FontSize',8,'Units','pixels','Position',[20 17 310 150],'Min',0,'Max',2);
handles.add=uicontrol('Style','pushbutton','String','','Callback',{@add_Callback},'Parent',handles.inputpanel,'Units','pixels','Position',[342 110 25 25],'CData',fs_add,'Tooltip','Select FlySiesta Files for Joint Analysis');
handles.remove=uicontrol('Style','pushbutton','String','','Callback',{@remove_Callback},'Parent',handles.inputpanel,'Units','pixels','Position',[342 65 25 25],'CData',fs_remove,'Tooltip','Remove File from List');
handles.addtext=uicontrol('Style','text','String','Add Files','Parent',handles.inputpanel,'FontSize',8,'Units','pixels','Position',[375 106 25 30],'HorizontalAlignment','left');
handles.removetext=uicontrol('Style','text','String','Remove Files','Parent',handles.inputpanel,'FontSize',8,'Units','pixels','Position',[375 61 50 30],'HorizontalAlignment','left');

handles.savebox=uicontrol('Style','edit','String','Browse or type save path!','Callback',{@savebox_Callback},'Parent',handles.outputpanel,'BackgroundColor','white','Fontsize',8,'Units','pixels','Position',[20 15 310 20]);
handles.savebutton=uicontrol('Style','pushbutton','String','','Callback',{@savebutton_Callback},'Parent',handles.outputpanel,'Units','pixels','Position',[342 12 25 25],'CData',fs_save,'Tooltip','Select Save Location for New File');
handles.savetext=uicontrol('Style','text','String','Save File','Parent',handles.outputpanel,'FontSize',8,'Units','pixels','Position',[375 8 28 30],'HorizontalAlignment','left');

handles.help=uicontrol('Style','radiobutton','CData',help_mine,'Callback',{@help_Callback},'Parent',handles.bottompanel,'Background',[0.2353 0.3922 0.8627],'Units','pixels','Position',[16 12 20 20],'Tooltip','Online User Guide');
handles.about=uicontrol('Style','radiobutton','CData',about_mine,'Callback',{@about_Callback},'Parent',handles.bottompanel,'Background',[0.2353 0.3922 0.8627],'Units','pixels','Position',[46 12 20 20],'Tooltip','About');
handles.gobutton=uicontrol('Style','pushbutton','String','Start','FontSize',9,'FontWeight','bold','Callback',{@gobutton_Callback},'Parent',handles.bottompanel,'Units','pixels','Position',[360 10 75 30],'Tooltip','Start Joining Files');


%%% Initialize GUI %%%
if nargout>0
  varargout{1}=handles.figure;
end
movegui(handles.figure,'center')
set(handles.figure,'Visible','on')



% Callback functions
  function add_Callback(source,eventdata)
    if isempty(get(handles.filelist,'UserData'))
      set(handles.filelist,'String','')
    end
    [input_files,input_dir]=uigetfile('*.mat','Select FlySiesta File(s)','MultiSelect','on');
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

  function savebox_Callback(source,eventdata)
    string=get(handles.savebox,'String');
    if strcmp(string,'Browse or type save path!')
      set(handles.savebox,'String','')
    end
  end
  function savebutton_Callback(source,eventdata)
    defaultstr='Browse or type save path!';
    currentstring=get(handles.savebox,'String');
    if isempty(currentstring) || strcmp(currentstring,defaultstr)
      currentstr_valid=false;
      showname='pooled_files';
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
   % Check save name
    SaveNamePath=get(handles.savebox,'String');
    if isempty(SaveNamePath) || strcmp(SaveNamePath,'Browse or type save path!')
      SaveNamePath='';
      POOLEXP.name=[];
      h_dlg=errordlg('You must choose a Save name before proceeding!','Error: Missing Information','modal');
      callerPosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
      setpixelposition(h_dlg,[callerPosition(1)+(callerPosition(3)-dlgPosition(3))/2 callerPosition(2)+(callerPosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
      uiwait(h_dlg)
    else
      set([handles.filelist handles.add handles.remove handles.savebox handles.savebutton handles.gobutton],'Enable','inactive')
      set(handles.figure,'Pointer','watch')
      pause(1)
      
      files=get(handles.filelist,'String');
      dirs=get(handles.filelist,'UserData');
      [EXPDATA,DISTR,Info,pooling_ok]=load_n_pool(files,dirs);
      
      set([handles.filelist handles.add handles.remove handles.savebox handles.savebutton handles.gobutton],'Enable','on')
      set(handles.figure,'Pointer','arrow')

      if pooling_ok
        filename_backwards=strtok(SaveNamePath(end:-1:1),filesep);
        EXPDATA.name=filename_backwards(end:-1:5);
        for f=1:length(files)-1
          for i=1:5
            if ~strcmp(Info{f:f+1,i})
              EXPDATA.info{i}='';
            end
          end
        end
        poolname='Pooled files: ';
        for i=1:length(files); poolname=[poolname ', ']; end
        EXPDATA.info{3}=poolname(1:end-2);

        save(SaveNamePath,'EXPDATA','DISTR')
        h_finished=msgbox({'' '         Pooling Successful!'  ''},'Done','modal');
        figurePosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_finished);
        setpixelposition(h_finished,[figurePosition(1)+(figurePosition(3)-dlgPosition(3))/2 figurePosition(2)+(figurePosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
        uiwait(h_finished)
        close(handles.figure)
        flysiesta

      end
    end

  end

  function [POOLEXP,POOLDISTR,Info,poolok]=load_n_pool(files,dirs)
    % Create Structures
    POOLEXP=[]; POOLDISTR=[];
    EXPDATA=[]; DISTR=[];
    file=[];
    
    % Load files & Pool
    poolok=false;
    all_ok=false(1,3);
    for i=1:length(files)
      load([dirs{i} filesep files{i}])
      if i==1
        POOLEXP=EXPDATA;
        POOLDISTR=DISTR;
        Info=EXPDATA.info;
      else
        % Control files for fields that NEED to be the same
        if POOLEXP.sleep_threshold==EXPDATA.sleep_threshold
          all_ok(1)=true;
        else
          all_ok(1)=false;
          pooledstr=sprintf('Sleep Threshold=%d mins: ',POOLEXP.sleep_threshold);
          for j=1:i-1
            pooledstr=[pooledstr files{j} ', '];
          end
          notfitting=sprintf(['Sleep Threshold=%d mins: ' files{i}],EXPDATA.sleep_threshold);
          h_dlg=errordlg([{'Error: Cannot Proceed!' 'The Sleep Threshold Must Be the Same in All Files!' pooledstr notfitting}],'Pooling Aborted','modal');
          callerPosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[callerPosition(1)+(callerPosition(3)-dlgPosition(3))/2 callerPosition(2)+(callerPosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
          uiwait(h_dlg)
          return
        end
        if POOLEXP.days==EXPDATA.days
          all_ok(2)=true;
        else
          all_ok(2)=false;
          pooledstr=sprintf('Days of Analysis=%d : ',POOLEXP.days);
          for j=1:i-1
            pooledstr=[pooledstr files{j} ', '];
          end
          notfitting=sprintf(['Days of Analysis=%d : ' files{i}],EXPDATA.days);
          h_dlg=errordlg({'Error: Cannot Proceed!' 'The Number of Days of Analysis Must Be the Same in All Files!' pooledstr notfitting},'Pooling Aborted','modal');
          callerPosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[callerPosition(1)+(callerPosition(3)-dlgPosition(3))/2 callerPosition(2)+(callerPosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
          uiwait(h_dlg)
          return
        end
        if size(DISTR,1)==4  % Change for BASIC version! Also change Error Message!
          all_ok(3)=true;
        else
          all_ok(3)=false;
          h_dlg=errordlg({'Error: Cannot Proceed!' 'The FlySiesta files to be pooled must have been created with FlySiesta Analyzer (Regular)!'},'Pooling Aborted','modal');
          callerPosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[callerPosition(1)+(callerPosition(3)-dlgPosition(3))/2 callerPosition(2)+(callerPosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
          uiwait(h_dlg)
          return
        end
        if ~all(POOLEXP.lights==EXPDATA.lights)
          h_dlg=warndlg({'Warning: All light cycles are not the same. Results might not fit well together! For plotting purposes the first file''s light cycle will be used.'},'Infomation','modal');
          callerPosition=getpixelposition(handles.figure); dlgPosition=getpixelposition(h_dlg);
          setpixelposition(h_dlg,[callerPosition(1)+(callerPosition(3)-dlgPosition(3))/2 callerPosition(2)+(callerPosition(4)-dlgPosition(4))/2 dlgPosition(3:4)])
          uiwait(h_dlg)
        end
        if all_ok
          % Save info
          Info(i,:)=EXPDATA.info;
          % Pool
          % DISTR
          for per=1:2
            for ev=1:size(DISTR,1)
              % matrix
              POOLDISTR(ev,per).matrix=[POOLDISTR(ev,per).matrix ; [DISTR(ev,per).matrix(:,1) DISTR(ev,per).matrix(:,2)+POOLEXP.number_of_flies(1)*POOLEXP.days*24*60 DISTR(ev,per).matrix(:,3) DISTR(ev,per).matrix(:,4)+POOLEXP.number_of_flies(1)]];
              % histogram
              lengthpool=size(POOLDISTR(ev,per).histogram,1);
              lengthbi=size(DISTR(ev,per).histogram,1);
              if lengthpool>lengthbi
                DISTR(ev,per).histogram=cat(1,DISTR(ev,per).histogram,NaN(lengthpool-lengthbi,size(DISTR(ev,per).histogram,2)));
              elseif lengthbi>lengthpool
                POOLDISTR(ev,per).histogram=cat(1,POOLDISTR(ev,per).histogram,NaN(lengthbi-lengthpool,size(POOLDISTR(ev,per).histogram,2)));
              end
              POOLDISTR(ev,per).histogram=[POOLDISTR(ev,per).histogram DISTR(ev,per).histogram];
              % survival_histogram
              lengthpool=size(POOLDISTR(ev,per).survival_histogram,1);
              lengthbi=size(DISTR(ev,per).survival_histogram,1);
              if lengthpool>lengthbi
                DISTR(ev,per).survival_histogram=cat(1,DISTR(ev,per).survival_histogram,NaN(lengthpool-lengthbi,size(DISTR(ev,per).survival_histogram,2)));
              elseif lengthbi>lengthpool
                POOLDISTR(ev,per).survival_histogram=cat(1,POOLDISTR(ev,per).survival_histogram,NaN(lengthbi-lengthpool,size(POOLDISTR(ev,per).survival_histogram,2)));
              end
              POOLDISTR(ev,per).survival_histogram=[POOLDISTR(ev,per).survival_histogram DISTR(ev,per).survival_histogram];
              % okindex
              for group=1:3
                POOLDISTR(ev,per).okindex{group}=[POOLDISTR(ev,per).okindex{group} DISTR(ev,per).okindex{group}+POOLEXP.number_of_flies(1)];
              end
              % fits
              method={'wB' 'wnl' 'wlin'};
              parameters={'k' 'lambda' 'rsquare'};
              for m=1:3
                for prm=1:3
                  POOLDISTR(ev,per).(method{m}).(parameters{prm})=[POOLDISTR(ev,per).(method{m}).(parameters{prm}) DISTR(ev,per).(method{m}).(parameters{prm})];
                end
                for group=1:3
                  POOLDISTR(ev,per).(method{m}).okfit{group}=[POOLDISTR(ev,per).(method{m}).okfit{group} DISTR(ev,per).(method{m}).okfit{group}+POOLEXP.number_of_flies(1)];
                end
              end
              POOLDISTR(ev,per).B=[POOLDISTR(ev,per).B DISTR(ev,per).B];
              POOLDISTR(ev,per).M=[POOLDISTR(ev,per).M DISTR(ev,per).M];
              POOLDISTR(ev,per).wnl.counter=[POOLDISTR(ev,per).wnl.counter DISTR(ev,per).wnl.counter];
            end
          end
          % EXPDATA
          for group=1:3
            POOLEXP.matrix_index{group}=[POOLEXP.matrix_index{group} EXPDATA.matrix_index{group}+POOLEXP.number_of_flies(1)];
          end
          POOLEXP.id_index=[POOLEXP.id_index EXPDATA.id_index+max(POOLEXP.id_index)];
          POOLEXP.sleep=[POOLEXP.sleep EXPDATA.sleep];
          POOLEXP.activity=[POOLEXP.activity EXPDATA.activity];
          POOLEXP.number_of_flies=POOLEXP.number_of_flies+EXPDATA.number_of_flies;
        end
      end
    end
    poolok=true;
  end



  end




