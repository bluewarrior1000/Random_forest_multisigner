#include "mex.h" 
void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {
    
  if ( nrhs!=1 )
        mexErrMsgTxt("There must be one input argument");
  if ( nlhs!=1 )
        mexErrMsgTxt("There must be one output argument");
  
  int m,n;
  double *input;
  double *output;
  
  // get size of input matrix
  input = mxGetPr(prhs[0]);
  m = mxGetM(prhs[0]);
  n = mxGetN(prhs[0]);
  
  // add up elements
  double s = 0;
  for (int i = 0; i<(m*n); i++)
      s += input[i];
  
  // output the data
  plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
  output = mxGetPr(plhs[0]);
  output[0] = s;
} 