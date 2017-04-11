function [data_coord,brind,scal]=depict_generate_coord_input_data(The_mask,The_files_to_cluster)

 disp('Generating coordinate input data');
 if(~isempty(The_mask))
   brain = spm_read_vols(The_mask);
   brain=permute(brain,[2 1 3]);

   brain=permute(brain,[3 2 1]);

   brind=find(brain);

   brain=permute(brain,[3 2 1]);
 else
   brain = spm_read_vols(The_files_to_cluster(1));
   brain = permute(brain,[2 1 3]);
   brain = permute(brain,[3 2 1]);

   brind=find(brain > 100);
   brain(brain <= 100)=0;

   brain=permute(brain,[3 2 1]);
 end


 data_coord = [];

 MM = The_files_to_cluster(1).mat; % voxel-to-coord matrix
 dim = The_files_to_cluster(1).dim;


 scal=zeros(1,3);
 scal(1)=sqrt(MM(1,1:3)*MM(1,1:3)');
 scal(2)=sqrt(MM(2,1:3)*MM(2,1:3)');
 scal(3)=sqrt(MM(3,1:3)*MM(3,1:3)');

 count=0;

 for i=1:dim(2)
   for j=1:dim(1)
     for k=1:dim(3)
       if(brain(i,j,k)>0)
         count=count+1;
%         data_coord(1,count)=MM(1,1)*i+MM(1,2)*j+MM(1,3)*k+MM(1,4);
%         data_coord(2,count)=MM(2,1)*i+MM(2,2)*j+MM(2,3)*k+MM(2,4);
%         data_coord(3,count)=MM(3,1)*i+MM(3,2)*j+MM(3,3)*k+MM(3,4);
         data_coord(1,count)=scal(1)*i;
         data_coord(2,count)=scal(2)*j;
         data_coord(3,count)=scal(3)*k;

       end
     end
   end
 end
end
