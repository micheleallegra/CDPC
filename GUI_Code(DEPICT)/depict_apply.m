function depict_apply(varargin)

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
 elseif(busy==1)
   strerr=strcat('A clustering process is already ongoing. Please wait');
   herror2 = errordlg(strerr,'error2');
 else

   fgApply = depict_figure('GetWin','Apply');

   txt1 = uicontrol(fgApply,'Style','text','Units','normalized','Position',[0.05 0.9 0.9 0.05],'String','Clustering maps name');

   [path, name, ext] = fileparts(The_files_to_cluster(1).fname);
   outfname=[path '/depict_' name];

   script_name_ui=uicontrol('Style','edit','string',outfname,'Units','normalized','Position',[0.05 0.85 0.7 0.05]);
   txt12 = uicontrol(fgApply,'Style','text','Units','normalized','Position',[0.75 0.855 0.2 0.03],'String',strcat('_xx_yy', '_zz', '.nii'),'HorizontalAlignment','Left');

   okbutton1 = uicontrol(fgApply,'Units','Normalized','Position',[.2,.7,.3,.05],'String','Start clustering','Callback',@okbuttonaction);

   cancelbutton1 = uicontrol(fgApply,'Units','Normalized','Position',[.55,.7,.1,.05],'String','Cancel','Callback',@cancelbuttonaction);

   uiwait(gcf);

   close(fgApply);
 
   busy=0;

 end  % endif

 function okbuttonaction(varargin)

   uiresume(gcf);

   delete(okbutton1);
   delete(cancelbutton1);

   delete(script_name_ui);
   delete(txt12);

   drawnow;

   busy=1; 

   set(txt1,'String',strcat('Computing clusters for window : ',' ', num2str(vol_begin)',' - ',num2str(vol_begin+winlen-1))  );

   drawnow;

   ax = axes('Parent',fgApply,'Position',[.2 .5 .6 .35]);

   [data_coord,brind,scal]=depict_generate_coord_input_data(The_mask,The_files_to_cluster);

   overlap=zeros(2,size(data_coord,2));

   for vol=vol_begin:vol_end

      set(txt1,'String',strcat('Computing clusters for window : ',' ', num2str(vol)',' - ',num2str(vol+winlen-1)) );
 
      drawnow;

      [data_intensity]=depict_generate_intensity_input_data(The_files_to_cluster,brind,vol);

      [data_intensity]=depict_FT_intensity(data_intensity,[0]);

      [density,dist_to_higher,i3_closest]=depict_generate_decision_graph(data_coord,scal,data_intensity,[NCUT,SPATIALCUT]);

    
      plot(density/max(density),dist_to_higher,'o');

      if(interactive==1)
 
        txt4 = uicontrol(fgApply,'Style','text','Units','normalized','Position',[0.2 0.375 0.6 0.05],'String','Select number of clusters and minimum density');
     
        txt2 = uicontrol(fgApply,'Style','text','Units','normalized','Position',[0.2 0.3 0.2 0.05],'String','Density filter');
        RHO_val=uicontrol('Style','edit','string',num2str(RHO),'Units','normalized','Position',[0.275 0.25 0.05 0.05]);

        txt3 = uicontrol(fgApply,'Style','text','Units','normalized','Position',[0.6 0.3 0.2 0.05],'String','Maximum number of clusters');
        NCLUST_MAX_val=uicontrol('Style','edit','string',num2str(NCLUST_MAX),'Units','normalized','Position',[0.675 0.25 0.05 0.05]);

        okbutton2 = uicontrol(fgApply,'Units','Normalized','Position',[.45,.15,.1,.05],'String','Ok','Callback','uiresume(gcbf)');
 
        uiwait(gcf);

        RHO=get(RHO_val,'String');
        RHO=str2num(RHO);
        NCLUST_MAX=get(NCLUST_MAX_val,'String');
        NCLUST_MAX=str2num(NCLUST_MAX);

        delete(txt4);
        delete(txt2);
        delete(RHO_val);
        delete(txt3);
        delete(NCLUST_MAX_val);
        delete(okbutton2)
        drawnow;      
  
      end
 
      [final_assignation]=depict_compute_clusters(data_coord,scal,density,dist_to_higher,i3_closest,[RHO,NCLUST_MAX,CONNECTEDCUT]);
 
      overlap(1,:)=overlap(1,:)+(density > 0);
      overlap(2,:)=overlap(2,:)+density/max(density)*100;


      depict_generate_output_maps(outfname,The_files_to_cluster,The_mask,final_assignation,density,vol)

      depict_generate_output_timecourse_images(outfname,The_files_to_cluster,The_mask,data_intensity,final_assignation,density,vol,winlen)

   end

   overlap(1,:)=overlap(1,:)/(vol_end-vol_begin+1);
   overlap(2,:)=overlap(2,:)/(vol_end-vol_begin+1);

   outfname_overlap = [outfname '_overlap_'];

   depict_generate_overlap_maps(outfname_overlap,The_files_to_cluster,The_mask,overlap,vol_begin, vol_end);

   txt6 = uicontrol(fgApply,'Style','text','Units','normalized','Position',[0.2 0.2 0.6 0.05],'String','Clustering successfully completed.');

   okbutton1 = uicontrol(fgApply,'Units','Normalized','Position',[.45,.1,.1,.05],'String','Close','Callback','uiresume(gcbf)');

   uiwait(gcf);

 end % end okbuttonaction


 function cancelbuttonaction(varargin)
   uiresume(gcf);
 end


end % end function
