%Clustering script
%***************************************************************************
addpath('/scratch/mallegra/spm12/toolbox/Depict');
addpath('/scratch/mallegra/spm12');

The_files_to_cluster=[];
  The_files_to_cluster=[The_files_to_cluster;spm_vol(spm_select('Fplist','/scratch/mallegra/clenching_final/s0','^4Dras.nii$'))]; 

CONNECTEDCUT=0;
NCUT=200;
SPATIALCUT=5;
RHO=0;
NCLUST_MAX=10;
vol_begin=1;
vol_end=1;
winlen=12;

[data_coord,brind,scal]=depict_generate_coord_input_data(The_mask,The_files_to_cluster);

for vol=vol_begin:vol_end
	[data_intensity]=depict_generate_intensity_input_data(The_files_to_cluster,brind,vol,winlen);
	[data_intensity]=depict_FT_intensity(data_intensity,[0]);
	[density,dist_to_higher,i3_closest]=depict_generate_decision_graph(data_coord,scal,data_intensity,[NCUT,SPATIALCUT]);
	[final_assignation]=depict_compute_clusters(data_coord,scal,density,dist_to_higher,i3_closest,[RHO,NCLUST_MAX,CONNECTEDCUT]);
	depict_generate_output_nifti(final_assignation,The_files_to_cluster);
end
