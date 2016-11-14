SUPPORTING CODE AND DATA FOR "SINGLE-TRIAL FMRI DISCOVERY OF SPATIOTEMPORAL BRAIN ACTIVITY PATTERNS"

2016-09-23

Author: Michele Allegra


************ C++ CODE **********************************************************************

The source code can be found in "src/". It consists of:

* The main program ("brain_cluster.cpp")
* Two subroutines to renormalize/clean the signal ("FT_intensity.cpp") and ("DFT.cpp")
* A subroutine to compute the decision graph ("generate_decision_graph.cpp")
* S subroutine to compute clusters ("compute_clusters.cpp"). 

The code can be compiled by running the make command.
Edit the Makefile in order to customize the compilation options.


************* INPUT DATA *********************************************

The data can be found in "data/". 

The nifti files of the simulations are "data/nifti/simulated_data_snr*.nii"

The nifti files of the two windows 19-30 and 43-54 are "data/nifti/real_data_*.nii"

The brain mask used is "data/nifti/mask.nii"

The nifti files are converted to txt format before entering the clustering procedure.
The conversion can be perfomed by the MATLAB script "nifti2txt.m", which requires the
FieldTrip Toolbox (Donders Institute for Brain, Cognition and Behaviour, 
http://fieldtrip.fcdonders.nl/). Before running the script, change the FieldTrip_path 
variable in "nifti2txt.m" to your local FieldTrip path

The conversion yields two output files:
 - the voxel timeseries in the format number of timepoints x number of voxels, 
   as in "data/txt/*data*.txt"
 - the voxel coordinates in the format number of voxels x 3,  
   as in "data/txt/coordinates.txt"

************* RUN THE CLUSTERING *****************************************************************

The clustering program can be called by the script "run.sh"

The program will show the decision graph; the user is prompted to insert 
two numbers upon inspection of the graph:
 - the number of clusters, k
 - the minimum density for a point to be considered as cluster center, rho_min 
The program will select as cluster centers the k points with highest values of delta with
rho > rho_min.  Reference values are k=10 and rho_min=0.

*********** OUTPUT FILES *********************************************************************

The programs gives five output files: 

- a file with the filtered time series ("data/txt/*data*_renormalized_intensities.txt"). 
  The format is number of timepoints x number of voxels.
  The metric d_ij is an Euclidean metric on this time series.

- the decision graph data, ("data/txt/*data*_decision_graph.txt"). 
  Column#1 is the voxel number  
  Column#2 is the voxel nomber of the nearest voxel with a higher density
  Column#3 is the voxel density (rho)
  Column#4 is the voxel distance from the nearest voxel with a higher density (delta) 

- the clustering data ("data/txt/*data*_coords_with_clust.txt").
  The format is number of voxels x 4. Columns #1,#2,#3 are the voxels coordinates,
  column#4 is the cluster assignation

- a gnuplot plotting script to visualize the decision graph ("data/txt/*data*_plot_decision_graph.gpl")

- a gnuplot plotting script to visualize the clusters ("data/txt/*data*_plot_clusters.gpl")

********************************************************************************************************

For all questions, contact mallegra@sissa.it
