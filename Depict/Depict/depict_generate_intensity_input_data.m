function [data_intensity]=depict_generate_intensity_input_data(The_files_to_cluster,brind,vol)

global winlen
  
    data_intensity = [];

    for ind=1:winlen
       dat = spm_read_vols(The_files_to_cluster(vol+ind-1)); % reads the data from the structure
       dat=permute(dat,[2 1 3]);
       dat=permute(dat,[3 2 1]);
       dat=dat(brind);
       data_intensity(ind,:) = dat(:)'; %%% to have data in the format nvolumes x number of voxels
    end

end
