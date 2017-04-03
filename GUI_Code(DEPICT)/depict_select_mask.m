function depict_select_mask(varargin)

global st
global defaults
global The_mask
global lstselmaskui
global use_mask

if(use_mask==0)
     strerr=strcat('If you wish to use a mask, please select the ''use mask'' option');
     herrormask = errordlg(strerr,'errormask');
     
  
else


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
          mask=spm_vol(file_names{1});
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

  %files_to_cluster

  try, The_mask=mask; end

  maskname=The_mask.fname;

  set(lstselmaskui,'string',maskname);
  set(lstselmaskui,'Value',1);
  %set(lstselmaskui,'Value',[1:size(maskname,1)]);

end %endif


end % end function



