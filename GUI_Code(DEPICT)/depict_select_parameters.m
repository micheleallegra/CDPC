function depict_select_parameters(varargin)

global st
global defaults
global The_files_to_cluster
global The_mask

global CONNECTEDCUT
global interactive
global vol_begin
global vol_end
global winlen
global NCUT
global SPATIALCUT
global RHO
global NCLUST_MAX

if(isempty(The_files_to_cluster)) 
  strerr=strcat('Please select input files before');
  herror1 = errordlg(strerr,'error1');
else


N_win_min=6;

try
  if(size(The_files_to_cluster,1) >= N_win_min)
    nvols=size(The_files_to_cluster,1);
  elseif(size(The_files_to_cluster,1) ==1)
    a=The_files_to_cluster.n(1)
    if(The_files_to_cluster.n(1) >= N_win_min)
      nvols=The_files_to_cluster.n(1)
    else
      disp('error')
      nvols=0
    end
  else
    disp('error')
    nvols=0
  end
catch
   nvols=0
end



list=num2str(1:200);
list=cellstr(list);



 
fgSel = depict_figure('GetWin','SelectPar');

sinit=strcat('Initial volume (1-',num2str(nvols),')');
send=strcat('Final volume (1-',num2str(nvols),')');
slen=strcat('Sliding window length (1-',num2str(nvols),')');

%f = figure('Visible','off','name','Select options','Position',[360,500,450,285]);


%hvol_begin = uicontrol('Style', 'popup','String',list,'Position', [100 220 120 20]); 

%uicontrol('Style', 'slider','String','initial volume','Min',1,'Max',210,'Value',1,'Position', [100 220 120 20]); 

txt1 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.05 0.8 0.2 0.05],'String',sinit);
hvol_begin_val=uicontrol('Style','edit','string',num2str(vol_begin),'Units','normalized','Position',[0.125 0.7 0.05 0.05]);
hvol_begin=uicontrol('Style', 'slider','Callback',@(hvol_begin,eventdata)slider_moved(hvol_begin,eventdata,hvol_begin_val), 'String',num2str(vol_begin),'Units','normalized','Position',[0.05 0.75 0.2 0.05],'Min',1,'Max',nvols,'Value',vol_begin,'SliderStep',[1/(nvols-1),1]);
hvol_begin_min=uicontrol('Style','text','string',num2str(get(hvol_begin,'min')),'Units','normalized','Position',[0.05 0.7 0.05 0.05]);
hvol_begin_max=uicontrol('Style','text','string',num2str(get(hvol_begin,'max')),'Units','normalized','Position',[0.20 0.7 0.05 0.05]);

%hvol_begin=uicontrol('Style', 'edit','String','1','Units','normalized','Position',[0.05 0.75 0.2 0.05]);

txt2 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.40 0.8 0.2 0.05],'String',send);
hvol_end_val=uicontrol('Style','edit','string',num2str(vol_end),'Units','normalized','Position',[0.475 0.7 0.05 0.05]);
hvol_end=uicontrol('Style', 'slider','Callback',@(hvol_end,eventdata)slider_moved(hvol_end,eventdata,hvol_end_val), 'String',num2str(vol_end),'Units','normalized','Position',[0.4 0.75 0.2 0.05],'Min',1,'Max',nvols,'Value',vol_end,'SliderStep',[1/(nvols-1),1]);
hvol_end_min=uicontrol('Style','text','string',num2str(get(hvol_end,'min')),'Units','normalized','Position',[0.4 0.7 0.05 0.05]);
hvol_end_max=uicontrol('Style','text','string',num2str(get(hvol_end,'max')),'Units','normalized','Position',[0.55 0.7 0.05 0.05]);

%hvol_end=uicontrol('Style', 'edit','String','1','Units','normalized','Position',[0.40 0.75 0.2 0.05]);

txt3 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.75 0.8 0.2 0.05],'String',slen);
hvol_len_val=uicontrol('Style','edit','string',num2str(winlen),'Units','normalized','Position',[0.825 0.7 0.05 0.05]);
hvol_len=uicontrol('Style', 'slider','Callback',@(hvol_len,eventdata)slider_moved(hvol_len,eventdata,hvol_len_val), 'String',num2str(winlen),'Units','normalized','Position',[0.75 0.75 0.2 0.05],'Min',1,'Max',nvols,'Value',winlen,'SliderStep',[1/(nvols-1),1]);
hvol_len_min=uicontrol('Style','text','string',num2str(get(hvol_len,'min')),'Units','normalized','Position',[0.75 0.7 0.05 0.05]);
hvol_len_max=uicontrol('Style','text','string',num2str(get(hvol_len,'max')),'Units','normalized','Position',[0.90 0.7 0.05 0.05]);

%  function slider_moved(varargin)    %(inputslider)
%     set(hvol_begin_val,'string',num2str(get(hvol_begin,'value')));
%  end



txt4 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.05 0.6 0.2 0.05],'String','Average Density');
NCUT_val=uicontrol('Style','edit','string',num2str(NCUT),'Units','normalized','Position',[0.125 0.55 0.05 0.05]);

txt5 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.40 0.6 0.2 0.05],'String','Neighbor filter');
SPATIALCUT_val=uicontrol('Style','edit','string',num2str(SPATIALCUT),'Units','normalized','Position',[0.475 0.55 0.05 0.05]);

txt6 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.75 0.6 0.2 0.05],'String','Density filter');
RHO_val=uicontrol('Style','edit','string',num2str(RHO),'Units','normalized','Position',[0.825 0.55 0.05 0.05]);

txt7 = uicontrol(fgSel,'Style','text','Units','normalized','Position',[0.05 0.4 0.2 0.05],'String','Maximum number of clusters');
NCLUST_MAX_val=uicontrol('Style','edit','string',num2str(NCLUST_MAX),'Units','normalized','Position',[0.125 0.35 0.05 0.05]);


hinteractive = uicontrol(fgSel,'Style','checkbox','String','Interactive','Units','normalized','Position',[0.05,0.25,0.2,0.05],'Value',interactive);

hconnectedcut = uicontrol(fgSel,'Style','checkbox','String','Cut isolated regions','Units','normalized','Position',[0.05,0.15,0.3,0.05],'Value',CONNECTEDCUT);


%hdecimate = uicontrol(fgSel,'Style','checkbox','String','Decimate','Position',[315,170,90,25],'Value',0);
%hborder = uicontrol(fgSel,'Style','checkbox','String','Border Filter','Position',[315,120,120,25],'Value',1);


okbutton = uicontrol(fgSel,'Position',[315,50,70,25],'String','Ok','Callback','uiresume(gcbf)');

uiwait(gcf);

CONNECTEDCUT=get(hconnectedcut,'Value');
interactive=get(hinteractive,'Value');
vol_begin=get(hvol_begin_val,'String');
vol_begin=str2num(vol_begin);
vol_end=get(hvol_end_val,'String');
vol_end=str2num(vol_end);
winlen=get(hvol_len_val,'String');
winlen=str2num(winlen);
NCUT=get(NCUT_val,'String');
NCUT=str2num(NCUT);
SPATIALCUT=get(SPATIALCUT_val,'String');
SPATIALCUT=str2num(SPATIALCUT);
RHO=get(RHO_val,'String');
RHO=str2num(RHO);
NCLUST_MAX=get(NCLUST_MAX_val,'String');
NCLUST_MAX=str2num(NCLUST_MAX);



close(fgSel);

end

  function slider_moved(input_slider,eventdata,input_edit)
      set(input_edit,'string',num2str(get(input_slider,'value')));
  end


end
