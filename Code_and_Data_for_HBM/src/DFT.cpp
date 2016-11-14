/* 
C++ function to implement discrete Fourier transform (direct and inverse)

 -- NT is the number of time points
 -- frR is the real part of the signal (input)
 -- frI in the imaginary part of the signal (output)
 -- FTR is the real part of the Fourier-tranformed signal (output)
 -- FTI is the imaginary part of the Fourier-tranformed signal (output)
 -- cos_ux is a vector with the values of sines appearing in the DFT
 -- sin_ux is a vector with the values of cosines appearing in the DFT
 -- dir is the direction (direct or inverse) of the Fourier transform
*/



#include <cmath> 

using namespace std;

void DFT(int NT, double *frR, double *frI,double *FTR,double *FTI,double *cos_ux,double *sin_ux,bool dir) {

 if(dir==true) {
     for(int u=0; u<NT; u++) {
         FTR[u]=0;
         FTI[u]=0;
         for(int x=0; x<NT; x++) {
             int ux=(u*x)%NT;
             FTR[u]=FTR[u]+frR[x]*cos_ux[ux]+frI[x]*sin_ux[ux];
             FTI[u]=FTI[u]-frR[x]*sin_ux[ux]+frI[x]*cos_ux[ux];
         }
     }
 }

 else {
     for(int u=0; u<NT; u++) {
         frR[u]=0;
         frI[u]=0;
         for(int x=0; x<NT; x++) {
             int ux=(u*x)%NT;
             frR[u]=frR[u]+FTR[x]*cos_ux[ux]-FTI[x]*sin_ux[ux];
             frI[u]=frI[u]+FTR[x]*sin_ux[ux]+FTI[x]*cos_ux[ux];
         }
     frR[u]=frR[u]/NT;
     frI[u]=frI[u]/NT;
     }
 }


}
