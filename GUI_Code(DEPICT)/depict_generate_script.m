function depict_generate_script(varargin)

global The_files_to_cluster
global The_mask

global busy
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

 fgScript = depict_figure('GetWin','Script');

 txt2 = uicontrol(fgScript,'Style','text','Units','normalized','Position',[0.05 0.9 0.8 0.05],'String','Script name');

 scriptname=[pwd '/' 'depict_script.m'];

 script_name_ui=uicontrol('Style','edit','string',scriptname,'Units','normalized','Position',[0.05 0.85 0.8 0.05]);

 okbutton1 = uicontrol(fgScript,'Units','Normalized','Position',[.2,.7,.3,.05],'String','Generate script','Callback',@okbuttonaction);

 cancelbutton1 = uicontrol(fgScript,'Units','Normalized','Position',[.55,.7,.1,.05],'String','Cancel','Callback',@cancelbuttonaction);


%%%% SCIRPT NAME

 uiwait(gcf);

 close(fgScript);

end % endif


 function okbuttonaction(varargin)

   uiresume(gcf);

   scriptname=get(script_name_ui,'String');

   delete(okbutton1);

   filenames=[];
   if(strcmp(The_files_to_cluster(1).descrip, '4D image')==1)
      filenames=The_files_to_cluster(1).fname;
   else
      for ii=1:size(The_files_to_cluster,1)
         filenames=[filenames;The_files_to_cluster(ii).fname];
      end
   end

   maskname=[];
   if(~isempty(The_mask))
      maskname=The_mask.fname;
   end

   scriptfile = fopen(scriptname,'w');

   dt=datestr(datetime);
   fprintf(scriptfile,'%%Depict script generated on %s\n',dt);
   fprintf(scriptfile,'%%***************************************************************************\n');
   fprintf(scriptfile,'\n'); 
   fprintf(scriptfile,'%%update MATLAB path\n'); 
   spmdir=pwd;
   fprintf(scriptfile,'addpath(''%s'');\n',spmdir); 
   spmdir=spmdir(1:end-15);
   fprintf(scriptfile,'addpath(''%s'');\n',spmdir); 
   fprintf(scriptfile,'\n'); 
   fprintf(scriptfile,'%%global variables\n'); 
   fprintf(scriptfile,'global The_files_to_cluster\n');
   fprintf(scriptfile,'global The_mask\n');
   fprintf(scriptfile,'global CONNECTEDCUT\n');
   fprintf(scriptfile,'global vol_begin\n');
   fprintf(scriptfile,'global vol_end\n');
   fprintf(scriptfile,'global winlen\n');
   fprintf(scriptfile,'global NCUT\n');
   fprintf(scriptfile,'global SPATIALCUT\n');
   fprintf(scriptfile,'global RHO\n');
   fprintf(scriptfile,'global NCLUST_MAX\n');
   fprintf(scriptfile,'\n'); 
   fprintf(scriptfile,'%% Functional images to cluster\n'); 
   fprintf(scriptfile,'The_files_to_cluster=[];\n'); 
   for ii=1:size(filenames,1) 
     [direc,name,ext]=fileparts(filenames(ii,:));
     fprintf(scriptfile,'  The_files_to_cluster=[The_files_to_cluster;spm_vol(spm_select(''FPlist'',''%s'',''^%s%s$''))]; \n', direc,name,ext); 
   end
   fprintf(scriptfile,'\n'); 
   fprintf(scriptfile,'%% Brain mask \n'); 
   [direc,name,ext]=fileparts(maskname);
   fprintf(scriptfile,'The_mask=spm_vol(spm_select(''FPlist'',''%s'', ''^%s%s$''));\n', direc,name,ext); 
   fprintf(scriptfile,'\n'); 
   fprintf(scriptfile,'%%Clustering parameters\n'); 
   fprintf(scriptfile,'CONNECTEDCUT=%d;\n',CONNECTEDCUT);
   fprintf(scriptfile,'NCUT=%d;\n',NCUT);
   fprintf(scriptfile,'SPATIALCUT=%d;\n',SPATIALCUT);
   fprintf(scriptfile,'RHO=%d;\n',RHO);
   fprintf(scriptfile,'NCLUST_MAX=%d;\n',NCLUST_MAX);
   fprintf(scriptfile,'vol_begin=%d;\n',vol_begin);
   fprintf(scriptfile,'vol_end=%d;\n',vol_end);
   fprintf(scriptfile,'winlen=%d;\n',winlen);
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'%% Clustering maps name \n'); 
   fprintf(scriptfile,'[path, name, ext] = fileparts(The_files_to_cluster(1).fname);\n');
   fprintf(scriptfile,'outfname=[path ''/depict_'' name];\n');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'%%Clustering ');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'[data_coord,brind,scal]=depict_generate_coord_input_data(The_mask,The_files_to_cluster);\n');
   fprintf(scriptfile,'overlap=zeros(size(data_coord,1),2);\n');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile, 'for vol=vol_begin:(vol_end-winlen+1)\n');
   fprintf(scriptfile,'\t[data_intensity]=depict_generate_intensity_input_data(The_files_to_cluster,brind,vol);\n');
   fprintf(scriptfile,'\t[data_intensity]=depict_FT_intensity(data_intensity,[0]);\n');
   fprintf(scriptfile,'\t[density,dist_to_higher,i3_closest]=depict_generate_decision_graph(data_coord,scal,data_intensity,[NCUT,SPATIALCUT]);\n');
   fprintf(scriptfile,'\t[final_assignation]=depict_compute_clusters(data_coord,scal,density,dist_to_higher,i3_closest,[RHO,NCLUST_MAX,CONNECTEDCUT]);\n');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'overlap(:,1)=overlap(:,1)+(density > 0);\n');
   fprintf(scriptfile,'overlap(:,2)=overlap(:,2)+density;');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'\tdepict_generate_output_maps(outfname,The_files_to_cluster,The_mask,final_assignation,density,vol);\n');
   fprintf(scriptfile,'\tdepict_generate_output_timecourse_images(outfname,The_files_to_cluster,The_mask,data_intensity,final_assignation,density,vol,winlen);\n');
   fprintf(scriptfile,'end\n');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'overlap(:,1)=overlap(:,1)/(vol_end-vol_begin+1);');
   fprintf(scriptfile,'overlap(:,2)=overlap(:,2)/(vol_end-vol_begin+1);');
   fprintf(scriptfile,'\n');
   fprintf(scritpfile,'outfname_overlap = [outfname 'overlap_']');
   fprintf(scriptfile,'\n');
   fprintf(scriptfile,'depict_generate_overlap_maps(outfname_overlap,The_files_to_cluster,The_mask,overlap,vol_begin, vol_end);');
   fclose(scriptfile);

 end

 function cancelbuttonaction(varargin)
   uiresume(gcf);
 end


end
