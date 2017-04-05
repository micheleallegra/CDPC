function depict_generate_output_timecourse_images(outfname,The_files_to_cluster,The_mask,data_intensity,final_assignation,density,vol,winlen)

%global winlen

    true_NCLUST=max(final_assignation);
    dmax=max(density);

   if(~isempty(The_mask))
     brain = spm_read_vols(The_mask);
     brain=permute(brain,[2 1 3]);
   else
     brain = spm_read_vols(The_files_to_cluster(1));
     brain(brain <=100)=0;	
     brain = permute(brain,[2 1 3]);
   end

   dim = The_files_to_cluster(1).dim;

   %out_data=zeros(dim(1),dim(2),dim(3),true_NCLUST);

   for cl=1:true_NCLUST   	
      if(length(find(final_assignation==cl))>50)
          fsignal=figure('Visible','Off');
          set(gca,'FontSize',30);
          axis([-0 12 -inf inf]);
          hold on
	  max_density=max(density(find(final_assignation==cl)));
          vv=find(final_assignation == cl & density/max_density > 0.5);
          length(vv)
          vol
          winlen
          vol+winlen-1
	  if(length(vv) > 0)
	        plot(1:winlen,data_intensity(:,vv),'Linewidth',1,'Color',[0.8, 0.8, 0.8]); 		
	  end
          vv=find(final_assignation == cl & density/max_density > 0.75);
          if(length(vv) > 0)
          	plot(1:winlen,data_intensity(:,vv),'Linewidth',1,'Color','green');
	  end	
          vv=find(final_assignation == cl & density/max_density > 0.9);
          if(length(vv) > 0)
                plot(1:winlen,data_intensity(:,vv),'Linewidth',1,'Color','blue');
	  end
          vv=find(final_assignation == cl & density/max_density == 1);
          plot(1:winlen,data_intensity(:,vv),'Linewidth',2,'Color','red');	 		
          figname=[outfname, '_timecourses_',num2str(vol),'_',num2str(vol+winlen-1),'_cl',num2str(cl),'.eps'];
          print(fsignal,figname,'-depsc');
          hold off
          delete(fsignal);
       end
    end

end

