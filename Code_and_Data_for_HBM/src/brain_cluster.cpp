/* MAIN PROGRAM TO CLUSTER BRAIN VOXELS ACCORDING TO COHERENT TIME SERIES */

#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include "omp.h"

using namespace std;

int main(int argc, char **argv) {

 srand(1);

 string filecoords_name;
 string fileintensity_name;

 int SPATIALCUT=5; // coherent spatial neighbors threshold 

 int Ncut=200; // verage number of neighbors in intensity space (which fixes d_c)

 int NCLUST;  // number of clusters

 double NNC_min;  // excludes as cluster centers points with density lower than a threshold

 bool connectedcut=false; // option to exclude small disconnected regions from clusters

 bool interactive=true; // allow user to select number of clusters upon inspection of decision graph

 char *outfilename;

 // updates parameters by user call

 for(int a=0; a<argc; a++) {
 
     string arg=argv[a];
     if(arg=="-C") { string argplus=argv[a+1]; filecoords_name=argplus; }
     if(arg=="-I") { string argplus=argv[a+1]; fileintensity_name=argplus; }


     if(arg=="-SPATIALCUT") {
         char *argplus=argv[a+1];
         Ncut=atoi(argplus);
     }

     if(arg=="-NCUT") {
         char *argplus=argv[a+1];
         Ncut=atoi(argplus);
     }
     if(arg=="-NCLUST") {
         char *argplus=argv[a+1];
         NCLUST=atoi(argplus);
         interactive=false;
     }
     if(arg=="-RHOMIN") {
         char *argplus=argv[a+1];
         NNC_min=atoi(argplus);
         interactive=false;
    }
     if(arg=="-OUTPUTNAME") {
         outfilename=argv[a+1];	 
    } 
 }


 // subroutines
 void FT_intensity(double *, int, int); 
 void generate_decision_graph(double *, double *, int *, double *, double *, double *, int , int, int, int);
 void compute_clusters(int *, double *,double *,int *,double *,  double *, int , int , int , int ,bool); 



/************************** READING  COORDINATE INPUT ************************************************************/ 

 cout << "reading coordinate data" << endl;

 ifstream filecoords(filecoords_name.c_str());

 // counts number of lines in coords file
 string line;
 int NC=0; // number of voxels
 while (getline(filecoords, line)) {NC++;}
 filecoords.close();
 filecoords.open(filecoords_name.c_str());

 double *coords=new double[3*NC]; // coordinates

 // read voxel coordinates

 for(int i1=0; i1<NC; i1++) {
     for(int i2=0; i2<3; i2++)  filecoords >> coords[3*i1+i2]; 
 }

 filecoords.close();

 // compute grid spacing

 double scal[3]={10.,10.,10.};    // grid spacing

 for(int i1=0; i1<NC; i1++) {
     for(int i2=0; i2<3; i2++) {
         if(coords[3*i1+i2]==coords[3*0+i2]) continue;
         else if(abs(coords[3*i1+i2]-coords[3*0+i2])<scal[i2]) scal[i2]=abs(coords[3*i1+i2]-coords[3*0+i2]);   
     }
 }

/*********************************** READ INTENSITY INPUT *******************************************************************/

 cout << "reading intensity data" << endl;

 ifstream fileintensity(fileintensity_name.c_str());

 // counts number of time points NT
 int NT=0; // number of time points
 while (getline(fileintensity, line)) {NT++;}
 fileintensity.close();
 fileintensity.open(fileintensity_name.c_str());

 double *intensity=new double[NT*NC]; 


 for(int i2=0; i2<NT; i2++) {

     int count=0;

     for(int i1=0; i1<NC; i1++) {
         fileintensity >> intensity[NT*count+i2];
             count++;
     }
 }

 fileintensity.close();
 
//************************************** RENORMALIZE INTENSITIES ***************************************************// 

 cout << "renormalizing intensities" << endl;

 FT_intensity(intensity, NC,NT); 

 // save renormalized intensities
 char outfilename_renintensity[100];
 strcpy(outfilename_renintensity,outfilename);
 strcat(outfilename_renintensity,"_renormalized_intensities.txt");
 ofstream filerenintensity(outfilename_renintensity);

 for(int i2=0; i2<NT; i2++) {
     for(int i1=0; i1<NC; i1++) {
           filerenintensity << intensity[NT*i1+i2] << "\t";
     }
      filerenintensity << endl;
 }

 filerenintensity.close();


//************************************** COMPUTE DECISION GRAPH ***************************************************// 

 cout << "computing decision graph" << endl;

 double *NNC=new double[NC]; // number of coherent neighbors in intensity space (density)
 double *dist_to_higher=new double[NC]; // minimum distance from a voxelsa with higher density
 int *i3_closest=new int[NC];     // nearest voxel with higher density

 generate_decision_graph(NNC, dist_to_higher, i3_closest, coords, scal, intensity, NC, NT, Ncut, SPATIALCUT);

 // renormalizes density
 double NNC_max=0;
 for(int i1=0; i1<NC; i1++) {
	if(NNC[i1]>NNC_max) NNC_max=NNC[i1];
 }
 for(int i1=0; i1<NC; i1++) NNC[i1]=NNC[i1]/NNC_max;


 // saves decision graph data
 char outfilename_decision[100];
 strcpy(outfilename_decision,outfilename);
 strcat(outfilename_decision,"_decision_graph.txt");
 ofstream filedecision(outfilename_decision);

 for(int i1=0; i1<NC; i1++) {
     int i3r;
     if(i3_closest[i1]==0) i3r=0;
     else i3r=i3_closest[i1]+1; 
     filedecision << i1+1 << "\t" << i3r << "\t" << NNC[i1] << "\t" << dist_to_higher[i1]<< endl;
 }


 // selects number of clusters and minimum density of cluster points based on decision graph

 if(interactive==true) {
     char plotname[100];
     strcpy(plotname,outfilename);
     strcat(plotname,"_plot_decision_graph.gpl");
     char command[200];
     strcpy(command, "rm "); 
     strcat(command,plotname);        
     system(command);
     strcpy(command,"(echo set grid)>");
     strcat(command,plotname);       	
     system(command);	
     strcpy(command, "(echo p \" '");	
     strcat(command,outfilename);
     strcat(command,"_decision_graph.txt' \" u 3:4  pt 7 ps 2 t \" '' \") > ");
     strcat(command,plotname);
     system(command);
     strcpy(command, "gnuplot -persist "); 
     strcat(command,plotname);	 
     system(command);
     cout << "N_CLUSTERS=?" << "\t" << "MIN_DENSITY=?" << endl;
     cin >> NCLUST >> NNC_min; 
 }

 filedecision << "# NCLUSTERS= " << NCLUST << " MINDENSITY= " << NNC_min << endl;

 filedecision.close(); 

 NNC_min=NNC_max*NNC_min;

/************************************** FIND CLUSTERS**************************************/

 cout << "finding clusters" << endl;

 int *clust=new int[NC]; // cluster assignation of each voxel
 int *nocc=new int[NCLUST];  // number of voxels assigned to each cluster


 compute_clusters(clust, NNC, dist_to_higher,i3_closest,coords, scal, NC,NT, int(NNC_min), NCLUST,connectedcut);

 for(int i1=0; i1<NC; i1++) {
     if(clust[i1]>0)   nocc[clust[i1]-1]++;
 }

 // save cluster data

 char outfilename_coordswithclust[100];
 strcpy(outfilename_coordswithclust,outfilename);
 strcat(outfilename_coordswithclust,"_coords_with_clust.txt");
 ofstream filecwc(outfilename_coordswithclust);

 for(int i1=0; i1<NC; i1++) {
     for(int i2=0; i2<3; i2++) {
         filecwc << coords[3*i1+i2] << "\t";
     }
     filecwc << clust[i1] << endl;
 }

 filecwc.close();


/************************* create plotting script ******************************************/

 char plotname[100];
 strcpy(plotname,outfilename);
 strcat(plotname,"_plot_clusters.gpl");
 char command[200];
 strcpy(command, "rm ");  
 strcat(command,plotname);
 system(command);
 strcpy(command,"(echo sp \" '");
 strcat(command, outfilename_coordswithclust);
 strcat(command,"' \" ev 4, \\\\  ) >> ");
 strcat(command,plotname);
 system(command);
 int nclust_eff=0;
 for(int i1=0; i1 < NCLUST; i1++) {
     if(nocc[i1]>50) nclust_eff++;
 }
 int sizable_clus=0;
 for(int i1=0; i1 < NCLUST; i1++) {
     if(nocc[i1]>50) {
           sizable_clus++;        
	   strcpy(command,"(echo \\\"\\< awk \\\'\\$4==");
	   char nn[3];
	   sprintf(nn,"%d",i1+1);
           strcat(command,nn); 
           strcat(command,"\\\'  ");
	   strcat(command, outfilename_coordswithclust);
           strcat(command, " \\\" ps 2 pt 7 title \\\"cl");
           strcat(command,nn); 
           if(sizable_clus < nclust_eff) strcat(command,"\\\", \\\\   ) >> ");
           else strcat(command,"\\\"    ) >> ");
           strcat(command,plotname);
           system(command);
     }
 }	

return 0;

}
