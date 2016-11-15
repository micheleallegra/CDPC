function depict_select(varargin)

global st
global defaults
global The_files_to_cluster
global The_mask
global lstselclusterui
global lstselmaskui

fgFiles = depict_figure('CreateWin','SelectedFiles','File selection');

if(~isempty(The_files_to_cluster))
  filenames=[];
  if(strcmp(The_files_to_cluster(1).descrip, '4D image')==1)
     filenames=The_files_to_cluster(1).fname;
  else
     for ii=1:size(The_files_to_cluster,1)
        filenames=[filenames;The_files_to_cluster(ii).fname];
     end
  end
    lstselclusterui=uicontrol(fgFiles,'Style','ListBox','String',filenames,'Units', 'normalized','Position',[.05 .3 .9 .6],'FontSize',spm('FontSizes',12),'Max',100,'Min',1,'Value',[1:size(filenames,1)]);
else
    lstselclusterui=uicontrol(fgFiles,'Style','ListBox','String','','Units', 'normalized','Position',[.05 .3 .9 .6],'FontSize',spm('FontSizes',12),'Max',100,'Min',1,'Value',1); 
end

selfunctional=uicontrol(fgFiles,'Style','PushButton','Units','normalized','Position',[.05 .90 .9 .055],'Callback','depict_select_input_files;',...
    'String','Select/Change functional images to cluster','FontSize',spm('FontSizes',12));


if(~isempty(The_mask))
    maskname=The_mask.fname;    
    lstselmaskui=uicontrol(fgFiles,'Style','ListBox','String',maskname,'Units', 'normalized','Position',[.05 .1 .9 .1],'FontSize',spm('FontSizes',12),'Max',100,'Min',1,'Value',1);
else
    lstselmaskui=uicontrol(fgFiles,'Style','ListBox','String','','Units', 'normalized','Position',[.05 .1 .9 .1],'FontSize',spm('FontSizes',12),'Max',100,'Min',1,'Value',1); 
end

selmask=uicontrol(fgFiles,'Style','PushButton','Units','normalized','Position',[.05 .2 .9 .055],'Callback','depict_select_mask;',...
    'String','Select/Change brain mask','FontSize',spm('FontSizes',12));


okbutton=uicontrol(fgFiles,'Style','PushButton','Units','normalized','Position',[.05 0.02 .45 0.055],'Callback','uiresume(gcbf)','String','ok','FontSize',spm('FontSizes',12));

uiwait(gcf);

close(fgFiles);

end % end function



