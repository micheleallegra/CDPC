FieldTrip_path='/scratch/mallegra/matlab_nifti';
addpath(FieldTrip_path);


nifti_dir='data/nifti/';
txt_dir='data/txt/';

name_file ='simulated_data_snr20.nii';

name_file_short=strtok(name_file, '.');


nifti_data=MRIread([nifti_dir,name_file]);
data=nifti_data.vol;

s1=size(data,1);
s2=size(data,2);
s3=size(data,3);
nvols=size(data,4);

name_file_mask = 'mask.nii';

mask_nifti_data=MRIread([nifti_dir,name_file_mask]);
mask_data=mask_nifti_data.vol;

cluster_file=[txt_dir,name_file_short,'_COORDS_WITH_CLUST.txt'];
decision_file=[txt_dir,name_file_short,'_DECISION_GRAPH.txt'];

cluster_data=dlmread(cluster_file);
decision_data=dlmread(cluster_file);

nclust=max(cluster_data(:,4));
dmax=max(decision_data(:,3));


count=0;



out_data=zeros(s1,s2,s3,nclust);

for i=1:s1
   for j=1:s2  
      for k=1:s3
         if(mask_data(i,j,k)>0)
            count=count+1;            
            cc=cluster_data(count,4);
	    if(cc>0)
	      dd=decision_data(count,3);
              out_data(i,j,k,cc)=dd; 
	    end	
         end
      end
   end
end
 
outfile_name=[nifti_dir,name_file_short,'_CLUSTERS.nii'];

out_nifti_data=nifti_data;
out_nifti_data.nframes=nclust;
out.nifti_data.vol=out_data;

MRIwrite(out_nifti_data,outfile_name);
