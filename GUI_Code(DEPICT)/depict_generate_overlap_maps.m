function depict_generate_overlap_maps(outfname_overlap,The_files_to_cluster,The_mask,overlap,vol_begin, vol_end)

global winlen

   if(~isempty(The_mask))
     brain = spm_read_vols(The_mask);
     brain=permute(brain,[2 1 3]);
   else
     brain = spm_read_vols(The_files_to_cluster(1));
     brain(brain <=100)=0;	
     brain = permute(brain,[2 1 3]);
   end

   dim = The_files_to_cluster(1).dim;

   out_data=zeros(dim(1),dim(2),dim(3),2);

   count=0;

    for i=1:dim(1)
      for j=1:dim(2)
        for k=1:dim(3)
          if(brain(i,j,k)>0 )
            count=count+1;
            out_data(i,j,k,1)=overlap(1,count);
	    out_data(i,j,k,2)=overlap(2,count);
          end
        end
      end
    end


   for i=1:2
	    output(i)=The_files_to_cluster(1);
       	    outfname1=[outfname_overlap  num2str(i) 'tmp.nii'];
            output(i).fname = outfname1;
            Image = spm_create_vol(output(i));
            Image=spm_write_vol(output(i), out_data(:,:,:,i));
	
    end
    clear matlabbatch;


    [path, name, ext] = fileparts(outfname_overlap);
    name1=[name  '.*.tmp.nii$'];
    temp = cellstr(spm_select('FPList', path, name1));

    matlabbatch{1}.spm.util.cat.vols = temp;
    matlabbatch{1}.spm.util.cat.name = [outfname_overlap 'map.nii'];
    matlabbatch{1}.spm.util.cat.dtype = 0;
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);

    outfname1=[outfname_overlap   num2str(1)  '*'];
    delete(outfname1);

    outfname1=[outfname_overlap   num2str(2)  '*'];
    delete(outfname1);


    outfname1=[outfname_overlap  '*map.mat'];
    delete(outfname1);


end

