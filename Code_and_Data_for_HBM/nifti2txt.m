FieldTrip_path='/scratch/mallegra/matlab_nifti';
addpath(FieldTrip_path);

nifti_dir='data/nifti/';
txt_dir='data/txt/';

name_file = 'simulated_data_snr20.nii';

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


coordinates=[];
timeseries=[];

count=0;
vol_begin=1;
vol_end=nvols;

for i=1:s1
  for j=1:s2
    for k=1:s3
        if (mask_data(i,j,k) > 0)
        count=count+1;
        coordinates(1,count)=i*nifti_data.xsize;
        coordinates(2,count)=j*nifti_data.ysize;
        coordinates(3,count)=k*nifti_data.zsize;
        timeseries(:,count)=data(i,j,k,vol_begin:vol_end);
      end
    end
  end
end

dlmwrite([txt_dir,'coordinates.txt'],coordinates','\t');
dlmwrite([txt_dir,name_file_short,'.txt'],timeseries,'\t');
