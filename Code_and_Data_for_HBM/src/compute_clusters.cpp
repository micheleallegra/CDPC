/*

C++ function to compute clusters

Call in main as:

 compute_clusters(final_assignation,density,dist_to_higher,i3_closest,coords,scal,density_cut,max_number_clusters,connected_cut);

where:

 -- 'final_assignation' is a vector containing cluster assignations of each voxel (output)
 -- 'density' is a vector containing the densities of each voxel (input)
 -- 'dist_to_higher' is a vector containing the deltas (distance from voxel with higher density) of each voxel (input)
 -- 'i3_closest' is a vector containing the index of the closest voxel with higher density for each voxel (input) 
 -- 'coords' is a matrix of coordinate data (input): the M x N matrix is vectorized, so that the matrix entry  (i,j)  is stored in array element [i+M*j] 
 -- 'scal' is 3 x 1 vector expressing the voxel sizes
 -- 'density_cut' excludes as cluster centers points with density lower than a threshold
 -- 'max_number_clusters' fixes the maximum number of clusters
 -- 'connected_cut' is an option to exclude small disconnected regions from clusters
 -- NC is the number of voxels
 -- NT is the number of time points
*/


#include <iostream>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include "omp.h"


using namespace std;

void compute_clusters(int *final_assignation, double *NNC,double *dist_to_higher,int *i3_closest,double *coords,  double *scal, int NC, int NT, int NNC_min, int NCLUST,bool connectedcut) {

 // initialize random seed
 srand(2);

/************************************** FIND CLUSTERS**************************************/

 int i1,i2,i3,k,l,ii,it,jj;

 int *NN_LIST=new int[27*NC];   // list of spatially close voxels belonging to the same cluster, for each voxel
 double ri1i3;  // spatial distance between voxels

 int *NNR=new int[NC]; // number of spatially close belonging to same cluster

 int *clust=new int[NC]; // cluster to which each voxel belongs
 double *NNCclust=new double[NCLUST];  // average density each cluster
 int *nocc=new int[NCLUST];  // number of voxels assigned to each cluster
 int *iicenter=new int[NCLUST]; // voxels  corresponding to cluster centers
 int *NNC_center=new int[NCLUST]; // density in the cluster centers
 double dhcenter[NC]; // dist_to_higher for cluster centers  

 double dist_to_higher_max;

 int count=0;

 // finds cluster centers

  cout << "finding centers" << endl;

 while(count < NCLUST) {
     
     dist_to_higher_max=0;
     int max_loc;

     for(i1=0; i1<NC; i1++) {
         if(dist_to_higher[i1]> dist_to_higher_max && NNC[i1]>=NNC_min) {
             dist_to_higher_max=dist_to_higher[i1];
             max_loc=i1;
         }
     }
     iicenter[count]=max_loc;
     dhcenter[count]=dist_to_higher[max_loc];
     dist_to_higher[max_loc]=0;
     count++;
 }


 for(ii=0; ii<NCLUST; ii++) {
     dist_to_higher[iicenter[ii]]=dhcenter[ii];
 }


// assign the centers to different clusters

 for(i1=0; i1<NC; i1++) {
     clust[i1]=-1;
 }

 for(ii=0; ii<NCLUST; ii++) {
     clust[iicenter[ii]]=ii;
 }


 cout << "assigning voxels" << endl;

//   assign each voxel to the same cluster of its nearest neighbour of higher density

 for(i1=0; i1<NC; i1++) {
     if(clust[i1]>-1) continue;
     if(NNC[i1]==0) continue;
     int i3=i1;

     while(clust[i1]==-1) {
         i3=i3_closest[i3];
         if(clust[i3]>-1) clust[i1]=clust[i3];
     }
 }


// mexPrintf("done\n");
// mexEvalString("drawnow;");

/******************************************* CONNECTED REGION DIMENSION ***********************************************************************/

 int *inn=new int[NC]; // number of spatial first neighbours belonging to the same cluster     
 bool *visited=new bool[NC];

 if(connectedcut==true) {

     cout << "excluding small disconnected regions" << endl;

 

 // it determines for each voxel the spatially close voxels belonging to the same cluster

     for(i1=0; i1<NC; i1++) {
         NNR[i1]=0;
         for(i2=0; i2<27;i2++) {
             NN_LIST[27*i1+i2]=-1;
         }
         if(clust[i1]==-1) continue;
         for(i3=0; i3<NC; i3++) {
             if(clust[i1]==clust[i3]) { 
                 ri1i3=0;
                 for(l=0; l<3; l++) {
                     ri1i3=ri1i3+(coords[3*i1+l]-coords[3*i3+l])*(coords[3*i1+l]-coords[3*i3+l])/(scal[l]*scal[l]);
                 }
                 ri1i3=sqrt(ri1i3);
                 if(ri1i3 <sqrt(2)+0.01) {              // sqrt(2) --> up to 2nd neighbors 
                     NN_LIST[27*i1+NNR[i1]]=i3;
                     NNR[i1]++;
                 }
             }
         } 
     }
	

 //  compute the dimension of a connected region of voxels assigned to the same cluster

     int tot_vis;  // dimension of connected region of voxels assigned to the same cluster

     int Niter=200000;

     for(i1=0; i1<NC; i1++) {
         inn[i1]=0;
     }

     for(i1=0; i1<NC; i1++) {
         if(i1%(NC/50)==0) { cout << "."; cout.flush(); }
         if(clust[i1]==-1) continue;
         else if(inn[i1]> 0) continue;
         for(i3=0; i3<NC; i3++) {
     	        visited[i3]=false;
         }

         int i3=i1;
         for(it=0; it<Niter; it++) {
             visited[i3]=true;
             int r=rand();
             r=r%(NNR[i3]);
             i3=NN_LIST[27*i3+r];
         }
         tot_vis=0;
         for(i3=0; i3<NC; i3++) {
             if(visited[i3]==true) tot_vis++;
         }
         for(i3=0; i3<NC; i3++) {
	     if(visited[i3]==true)  inn[i3]=inn[i3]+tot_vis;
         }
     }

     cout << endl;

     //  exclude the voxels belonging to connected regions smaller than thresold

     int NCUT_conn=5; 

     for(i1=0; i1<NC; i1++) { 
         if(inn[i1]<NCUT_conn) clust[i1]=-1;
     }

 }


// ******** REORDER CLUSTERS ACCORDING TO AVERAGE DENSITY ******************************************************


  // count average density of each cluster

 

 for(ii=0; ii<NCLUST; ii++) { 
     NNCclust[ii]=0;
     nocc[ii]=0;
 }

 for(i1=0; i1<NC; i1++) { 
     if(clust[i1]>-1) { 
         nocc[clust[i1]]++;
         NNCclust[clust[i1]]=NNCclust[clust[i1]]+NNC[i1];
     }
 }

 for(ii=0; ii<NCLUST; ii++) {
     if(nocc[ii]>0) NNCclust[ii]=NNCclust[ii]/nocc[ii];
     else NNCclust[ii]=0;   
 }

 //  reorder clusters according to their size


 int *clustn=new int[NCLUST];  // new index of cluster after cluster reordering 
 
 for(ii=0; ii<NCLUST; ii++) { 
     clustn[ii]=0;
 }

 for (ii=0; ii<NCLUST; ii++) {

     int max_loc;
     double NNCclust_max=0;

     for(jj=0; jj<NCLUST; jj++) {
         if(NNCclust[jj]> NNCclust_max) {
             NNCclust_max=NNCclust[jj];
             max_loc=jj;
         }
     }
     NNCclust[max_loc]=0; 
     clustn[max_loc]=ii;
 }

 // updated assignation according to new ordering

 count=0;

 for(i1=0; i1<NC; i1++) {
     if(clust[i1]>-1)  final_assignation[i1]=clustn[clust[i1]]+1;
     else  final_assignation[i1]=0;
 }


}
