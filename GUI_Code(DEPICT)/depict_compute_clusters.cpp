/*

C++ function to compute clusters

Call in MATLAB as:

 [final_assignation]=Cluster_brain(density,dist_to_higher,[density_cut,max_number_clusters,interactive,connected_cut]);

where:

 -- 'final_assignation' is a vector containing cluster assignations of each voxel (output)
 -- 'density' is a vector containing the densities of each voxel (input)
 -- 'dist_to_higher' is a vector containing the deltas (distance from voxel with higher density) of each voxel (input)
 -- 'density_cut' excludes as cluster centers points with density lower than this threshold
 -- 'max_number_clusters' fixes the maximum number of clusters
 -- 'interactive' is an option to display the decision graph and allow the user to choose the number of clusters the minimum density of cluster centers accordingly
 -- 'connected_cut' is an option to exclude small disconnected regions from clusters

*/


#include "stdio.h"
#include "mex.h"
#include <cmath>
#include <cstdlib>
#include <cstring>
#include "omp.h"


using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

 double *coords=mxGetPr(prhs[0]);   // input coordinate data matrix
 double *scal=mxGetPr(prhs[1]); // input voxel size matrix
 double *NNC=mxGetPr(prhs[2]);   // input density vector
 double *dist_to_higher=mxGetPr(prhs[3]); // input minimum distance from a voxel with higher density vector
 double *i3_closest=mxGetPr(prhs[4]); // input index of the closest voxel with higher density vector

 double *constants=mxGetPr(prhs[5]); // input options 


 int NNC_min=(int)constants[0]; // minimum density for cluster centers
 int NCLUST=(int)constants[1]; // number of clusters
 bool connectedcut=(bool)constants[2]; // cut small disconected regions from clusters

 int NC=mxGetN(prhs[2]);  // number of voxels


 plhs[0] = mxCreateDoubleMatrix(1,NC,mxREAL);
 double *final_assignation=mxGetPr(plhs[0]); // output cluster assignations

 // initialize random seed
 srand(2);

/************************************** FIND CLUSTERS**************************************/

 int i1,i2,i3,k,l,ii,it,jj;

 int *NN_LIST=new int[27*NC];   // list of spatially close voxels belonging to the same cluster, for each voxel
 double ri1i3;  // spatial distance between voxels

 int *NNR=new int[NC]; // number of spatially close voxels belonging to the same cluster

 int *clust=new int[NC]; // cluster to which each voxel belongs
 double *NNCclust=new double[NCLUST];  // average density each cluster
 int *nocc=new int[NCLUST];  // number of voxels assigned to each cluster
 int *iicenter=new int[NCLUST]; // voxels  corresponding to cluster centers
 int *NNC_center=new int[NCLUST]; // density in the cluster centers
 double dhcenter[NC]; // dist_to_higher for cluster centers  

 double dist_to_higher_max;

 int count=0;

 // finds cluster centers

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


// mexPrintf("assigning voxels \n");
// mexEvalString("drawnow;");


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

 // it determines fro each voxel the spatially close voxels belonging to the same cluster

//     mexPrintf("excluding small disconnected regions\n");
//     mexEvalString("drawnow;"); 
 
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
                     NNR[i1]=NNR[i1]+1;
                 }
             }
         } 
     }

 //    mexPrintf("done\n");
 //    mexEvalString("drawnow;"); 

 //  compute the dimension of a connected region of voxels assigned to the same cluster

 //    mexPrintf("compute connected regions \n");
 //    mexEvalString("drawnow;"); 


     int tot_vis;  // dimension of connected region of voxels assigned to the same cluster

     int Niter=200000;

     for(i1=0; i1<NC; i1++) {
         inn[i1]=0;
     }

     for(i1=0; i1<NC; i1++) {
         if(clust[i1]==-1) continue;
         else if(inn[i1]> 0) continue;
         for(i3=0; i3<NC; i3++) {
             visited[i3]=0;
         }
         int i3=i1;
         for(it=0; it<Niter; it++) {
             visited[i3]=1;
             int r=rand();
             r=r%((int)NNR[i3]);
             i3=NN_LIST[27*i3+r];
         }
         tot_vis=0;
         for(i3=0; i3<NC; i3++) {
             tot_vis=tot_vis+(int)visited[i3];
         }
         for(i3=0; i3<NC; i3++) {     
             inn[i3]=inn[i3]+tot_vis*visited[i3];
         }
     }

 //    mexPrintf("done\n");
 //    mexEvalString("drawnow;"); 

     //  exclude the voxels belonging to connected regions smaller than thresold

     int NCUT_conn=5; 


     for(i1=0; i1<NC; i1++) { 
         if(inn[i1]<NCUT_conn) clust[i1]=-1;
     }

 }

 //mexPrintf("reorder clusters \n");
 //mexEvalString("drawnow;"); 

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
     //mexPrintf("cluster of average density %d found. clust=%d\n", NNCclust_max, max_loc+1);
     NNCclust[max_loc]=0; 
     clustn[max_loc]=ii;
 }

 // update assignation according to new ordering

 count=0;

 for(i1=0; i1<NC; i1++) {
     if(clust[i1]>-1)  final_assignation[i1]=clustn[clust[i1]]+1;
     else  final_assignation[i1]=0;
 }


}
