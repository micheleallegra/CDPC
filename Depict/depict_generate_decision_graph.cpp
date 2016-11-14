/*
C++ function to generate the decision graph

Call in MATLAB as:

 [density,dist_to_higher,i3_closest]=Generate_decision_graph(coords,scal,intensity,[average_density,coherent_neighbors_cut]);

where:

 -- 'density' is a vector containing the densities of each voxel (output)
 -- 'dist_to_higher' is a vector containing the deltas (distance from voxel with higher density) of each voxel (output)
 -- 'i3_closest' is a vector containing the index of the closest voxel with higher density for each voxel (output) 

 -- 'coords' is a matrix of coordinate data (input): the M x N matrix is vectorized, so that the matrix entry  (i,j)  is stored in array element [i+M*j] 
 -- 'scal' is 3 x 1 vector expressing the voxel sizes
 -- 'intensity' is a matrix of intensity data (input); the M x N matrix is vectorized, so that the matrix entry  (i,j)  is stored in array element [i+M*j] 
 -- 'average_density' is the average number of neighbors (which fixes d_c)
 -- 'coherent_neighbors_cut' is the coherent neighbors threshold to remove noise

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
 double *intensity=mxGetPr(prhs[2]); // input intensity data matrix
 double *constants=mxGetPr(prhs[3]); // input options 


 int Ncut=(int)constants[0]; // average number of neighbors
 int SPATIALCUT=(int)constants[1]; // coherent neighbors threshold


 int NC=mxGetN(prhs[2]);  // number of voxels
 int NT=mxGetM(prhs[2]);  // number of time scans

 plhs[0] = mxCreateDoubleMatrix(1,NC,mxREAL);
 double *NNC=mxGetPr(plhs[0]); // number of neighbors for each voxel

 plhs[1] = mxCreateDoubleMatrix(1,NC,mxREAL);
 double *dist_to_higher=mxGetPr(plhs[1]); // for each voxel, minimum distance from a voxel with higher density

 plhs[2] = mxCreateDoubleMatrix(1,NC,mxREAL);
 double *i3_closest_d=mxGetPr(plhs[2]); //for each voxel, the closest voxel with a higher density


 srand(2);


//************************************** FIXES DC VALUE ********************************************// 

 //mexPrintf("fixing dc based on average density \n");
 //mexEvalString("drawnow;");

 double dist_c=0.1; // dc=distance to be considered neighbors
 int r; // random voxel
 int NNt; // number of neighbors at a distance < dc

 double dist;

 // chooses dc such that the average number of voxels is Ncut

 bool corr_avn=false; // true if the average number of voxels is approximately equal to Ncut

 double coeff1=1.2;   
 double coeff2=1.05;  

 int i1,i2,i3,k,l,ii,it,jj;
 

 while(corr_avn==false) {
 
     NNt=0; // average number of  neighbors
  
     // it takes 500  random voxels, for each one it computes the number of neighbors (at a distance < dc), then it averages this number over the  500 voxels 
 
     for(k=0; k<500; k++) {
         r=rand();
         r=r%NC; // random voxel
         for(i1=0; i1<NC; i1++) {
             dist=0;
             for(i2=0; i2<NT; i2++) {
                 dist=dist+(intensity[NT*r+i2]-intensity[NT*i1+i2])*(intensity[NT*r+i2]-intensity[NT*i1+i2]);
             }
             dist=sqrt(dist/((double)NT));
             if(dist < dist_c) NNt++;
         }
     }

     NNt=(int)((double)NNt/500.0);
     //mexPrintf("dist_c %f\t%d\n", dist_c,NNt);
     //mexEvalString("drawnow;");
     if(NNt > Ncut*coeff1) dist_c=dist_c/coeff2;       // if the average number of nieghbors is too low it raises  dc
     else if(NNt < Ncut/coeff1) dist_c=dist_c*coeff2;  // if the average number of nieghbors is too higher it lowers  dc
     else corr_avn=true;
 }


//************************************** COHERENT NEIGHBORS COMPUTATION ********************************************// 

 //mexPrintf("compute coherent neighbors \n");
 //mexEvalString("drawnow;");

 const int CHUNK=1000;

 int *NNR=new int[NC]; // number of neighbors for each voxel, including only voxels  which are spatially close (r < sqrt(3)+epsilon)

 double ri1i3;  // spatial distance between voxels
 bool kill[NC]; // selects voxels to be killed by coherent neighbors filter

 for(i1=0; i1<NC; i1++) {
     NNR[i1]=0;
     kill[i1]=false;
 }


 scal[0]=scal[0]*2;
 scal[1]=scal[1]*2;

#pragma omp parallel default(none), shared(NC,intensity,NT,dist_c,NNR,scal,coords,stdout), private(i1,i2,i3,dist,ri1i3,l)
 {
#pragma omp for schedule (dynamic,CHUNK) 


 for(i1=0; i1<NC; i1++) {
     for(i3=i1+1; i3<NC; i3++) {
         dist=0;	
         for(i2=0; i2<NT; i2++) {
             dist=dist+(intensity[NT*i3+i2]-intensity[NT*i1+i2])*(intensity[NT*i3+i2]-intensity[NT*i1+i2]);
         }

         dist=sqrt(dist/((double)NT));
          
         if(dist<dist_c) {
             ri1i3=0;
              
             for(l=0; l<3; l++) {
                 ri1i3=ri1i3+(coords[3*i1+l]-coords[3*i3+l])*(coords[3*i1+l]-coords[3*i3+l])/(scal[l]*scal[l]);
             }
             ri1i3=sqrt(ri1i3);
             if(ri1i3<sqrt(3.0)+0.01) {  // it only counts voxels which are spatially close  (r < sqrt(3)+epsilon)
                NNR[i1]++;
                NNR[i3]++;
             }
         } 
     }
 }

 } // end omp parallel


 // it remodulates the number of neighbors  amplifying the signal of spatially close voxels

 for(i1=0; i1<NC; i1++) {
     if(NNR[i1] < SPATIALCUT)  kill[i1]=true; 
 }

//************************************** DENSITY COMPUTATION ********************************************// 

 //mexPrintf("compute local density \n");
 //mexEvalString("drawnow;");


 for(i1=0; i1<NC; i1++) {
     NNC[i1]=0;
 }

 #pragma omp parallel default(none), shared(NC,intensity,NT,dist_c,NNC,stdout,kill), private(i1,i2,i3,dist)
 {
 #pragma omp for schedule (dynamic,CHUNK) 

 for(i1=0; i1<NC; i1++) {
     if(kill[i1]==true) continue; 
     for(i3=i1+1; i3<NC; i3++) {
         if(kill[i3]==true) continue;
         dist=0;	
         for(i2=0; i2<NT; i2++) {
             dist=dist+(intensity[NT*i3+i2]-intensity[NT*i1+i2])*(intensity[NT*i3+i2]-intensity[NT*i1+i2]);
         }
         dist=sqrt(dist/((double)NT));
         if(dist<dist_c) {
             NNC[i1]++;
             NNC[i3]++;
         } 
     }
 }


 } // end omp parallel

 
 //mexPrintf("done\n");
 //mexEvalString("drawnow;");

//************************************** FIND THE DECISION GRAPH ********************************************// 

 //mexPrintf("computing mindist on voxels  \n");
 //mexEvalString("drawnow;");

 int *i3_closest=new int[NC];     //for each voxel, the closest voxel with a higher density

 for(i1=0; i1<NC; i1++) {
     dist_to_higher[i1]=0;
 }


 // to avoid degeneracy  (if two points have same density, then it can be a problem below when looking for nearest points of higher density)  

 double rr; // for randomization on NNC

 for(i1=0; i1<NC; i1++) {
     if(NNC[i1]==0.) continue;
     rr=((double)rand())/RAND_MAX;
     NNC[i1]=NNC[i1]+rr; 
 }

 double dist_m; // minimum distance from voxel with higher density

#pragma omp parallel default(none), shared(NNC,NC,intensity,NT,i3_closest,dist_to_higher,stdout), private(i1,i2,i3,dist_m,dist)
 {
#pragma omp for schedule (dynamic,CHUNK) 

 for(i1=0; i1<NC; i1++) {
     /*if(i1%(NC/20)==0) { mexPrintf(".");  mexEvalString("drawnow;"); }*/
     if(NNC[i1]==0.) {
         i3_closest[i1]=-1;
         continue;
     }
     dist_m=10.;
     for(i3=0; i3<NC; i3++) {
         if(i3==i1) continue;
         else if(NNC[i3]<NNC[i1]) continue;
         dist=0;
         for(i2=0; i2<NT; i2++) {
             dist=dist+(intensity[NT*i3+i2]-intensity[NT*i1+i2])*(intensity[NT*i3+i2]-intensity[NT*i1+i2]);
         }
         dist=sqrt(dist/((double)NT));
         if(dist < dist_m) {
            dist_m=dist;
            i3_closest[i1]=i3;
         }
     }
     dist_to_higher[i1]=dist_m;
 }

 } // end omp parallel


 double dist_to_higher_max=0;    // minimum distance from voxel with higher density, maximized over all voxels 

 for(i1=0; i1<NC; i1++) {
     if(dist_to_higher[i1] > dist_to_higher_max && dist_to_higher[i1]<10.) dist_to_higher_max = dist_to_higher[i1];
 }

 // it arbitrarily defines "minimum distance" for the absolute maximum of density

 for(i1=0; i1<NC; i1++) {
     if(dist_to_higher[i1]==10.) {
         dist_to_higher[i1]=1.1*dist_to_higher_max;
         i3_closest[i1]=i1;
     }
 }

 for(i1=0; i1<NC; i1++) {
     i3_closest_d[i1]=(double)i3_closest[i1];
 } 

 //mexPrintf("done\n");
 //mexEvalString("drawnow;");


//delete NNC, NNR, NN_LIST, dist_to_higher, i3_closest, clust, clustn, nocc, NNC_border, iicenter, NNC_center, inn, visited;


}
