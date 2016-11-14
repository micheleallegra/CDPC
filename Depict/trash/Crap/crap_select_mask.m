function crap_select_mask(varargin)

global st
global defaults
global The_mask

gctrl=0;

function buttonCallback(varargin)
  uiresume(gcbf)
  gctrl=0;
  The_files_to_cluster=[]
end


while(gctrl==0)

  The_mask

  if(isempty(The_mask)) 
    
  %try
  %    The_files_to_cluster.mat;
  %    if isnan(The_files_to_cluster.mat)
  %        files_to_cluster = spm_select(Inf,'any','Select files to cluster',[],pwd,'.*.nii$');
  %    end
  %catch

  ctrl=0;

  prompt_select='Select brain mask';

  count=0;

  while(ctrl==0 && count < 2)

     count=count+1;

     file_names_cell=spm_select(Inf,'any',prompt_select,[],pwd,'.*.nii$');
     if(isempty(file_names_cell)==1) 
         strerr=strcat('You did not select any file. Please Select 3D NIfTI');
         herror1 = errordlg(strerr,'error1');
         uiwait(herror1); 
         continue; 
     end
 
     file_names=cellstr(file_names_cell);

     ctrl2=1;
     for ii=1:size(file_names)
        [tok,rem]=strtok(file_names{ii},'.');
        if(strcmp(rem,'.nii')==0) 
           strerr=strcat('You selected a file which is not NIfTI. Please Select 3D NIfTI');
           herror1 = errordlg(strerr,'error1');
           uiwait(herror1); 
           ctrl2=0; 
        end
     end
 
     if(ctrl2==0) 
        continue; 
     end

     if(size(file_names,1)==1)
          mask=spm_vol(file_names{1})
          if(size(mask,1)>1)
            strerr=strcat('The file you chose is a 4D NIfTI. Please Select 3D NIfTI');
            herror1 = errordlg(strerr,'error1');
            uiwait(herror1); 
          else
             ctrl2=1;
             for ii=1:size(mask,1)
                mask=mask(ii);
                if(strcmp(mask.descrip, '4D image')==1)
                   ctrl2=0;
                   break;
                end
             end
             if(ctrl2==1)        
                ctrl=1;
             else
               strerr=strcat('The file you chose does not have the correct format. Please select a 3D NIfTI');
               herror1 = errordlg(strerr,'error1');
               uiwait(herror1); 
             end
          end 
     elseif(size(file_names,1)>1)
          strerr=strcat('You chose a list of  ', num2str(size(file_names,1)),' NIfTi files. Please select only one (3D) NIfTI files');
          herror1 = errordlg(strerr,'error1');
          uiwait(herror1); 
     end

  end

  end % end ifisempty

  %files_to_cluster

  try, The_mask=mask; end

  gctrl=1;

  file_name=The_mask.fname

  fgMask = crap_figure('CreateWin','SelectedFiles','List of selected files');

  lstselui=uicontrol(fgMask,'Style','ListBox','String',file_name,'Units', 'normalized','Position',[.05 .05 .9 .8],'FontSize',spm('FontSizes',12),'Max',100,'Min',1,'Value',[1:size(file_name,1)]);

  okbutton=uicontrol(fgMask,'Style','PushButton','Units','normalized','Position',[.05 0.02 .45 0.055],'Callback','uiresume(gcbf)','String','ok','FontSize',spm('FontSizes',12));

  changebutton=uicontrol(fgMask,'Style','PushButton','Units','normalized','Position',[.5 0.02 .45 0.055],'Callback',@buttonCallback,'String','Change files','FontSize',spm('FontSizes',12));

  %okbutton = uicontrol(fgMask,'Position',[315,50,70,25],'String','Ok','Callback','uiresume(gcbf)');

  uiwait(gcf);

%  changefiles=get(changebutton,'Value')

%  if(changefiles==1)
%    gctrl=0
%  end

  close(fgMask);


end % end gctrl


end % end function



