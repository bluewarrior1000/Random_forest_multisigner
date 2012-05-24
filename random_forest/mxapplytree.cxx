#include "mex.h"

// Q = mxapplytree(num_channels,x,y,boxwidth,boxheight,tree,data)
// data is an n by m by num_channels matrix
// Q is an n by m by num_classes matrix
// where n,m is the width and height of the input image, data
// x,y,boxwidth,boxheight specifies the box in the image to classify. 
typedef unsigned __int32 uint32_t;

struct NODE
{
	int		offset1[2];
    int     offset2[2];
	int   	thresh;
    int     channel;
    int     funcType;
	NODE*   left;
    NODE*   right;
	double* distribution;
};

NODE* MakeTree(const mxArray *apTree, int index) {
    float left_index;
    float right_index;
    double* test_val;
    int leaf = (int)mxGetScalar(mxGetField(apTree, index, "leaf"));
    NODE* node = new NODE();
    
    if (leaf == 0) {
        test_val = (double *)mxGetData(mxGetField(apTree, index, "test"));
        node->offset1[0] = test_val[0];
        node->offset1[1] = test_val[1];
        node->offset2[0] = test_val[2];
        node->offset2[1] = test_val[3];
        node->funcType = test_val[4];
        node->thresh = test_val[5];
        node->channel = test_val[6];
        left_index = (float)mxGetScalar(mxGetField(apTree,index,"left"))-1;
        right_index = (float)mxGetScalar(mxGetField(apTree,index,"right"))-1;
        node->left = MakeTree(apTree, left_index);
        node->right = MakeTree(apTree, right_index);
        node->distribution = NULL;
    } else {
        node->offset1[0] = 0;
        node->offset1[1] = 0;
        node->offset2[0] = 0;
        node->offset2[1] = 0;
        node->funcType = 0;
        node->thresh = 0;
        node->channel = 0;
        node->left = NULL;
        node->right = NULL;
        node->distribution = (double*) mxGetPr(mxGetField(apTree, index, "distribution"));
    }
    return node;
}

void DeleteTree(NODE* node)
{
    if (node->left) {
        DeleteTree(node->left);
        DeleteTree(node->right);
    }
    delete node;
}

double* ApplyTree(const NODE* node, double* data, int m, int n, int index)
{
    int     offset1[2];
    int     offset2[2];
	int   	thresh;
    int     channel;
    uint32_t     idx_off1;
    uint32_t     idx_off2;
    int     feature;
    double* distribution;
    
    offset1[0] = node->offset1[0];
    offset1[1] = node->offset1[1];
    offset2[0] = node->offset2[0];
    offset2[1] = node->offset2[1];
    thresh  = node->thresh;
    channel = node->channel;
    distribution = node->distribution;
    
    idx_off1 = index + (m*n)*(channel-1) + offset1[0]*m + offset1[1];
    idx_off2 = index + (m*n)*(channel-1) + offset2[0]*m + offset2[1];
    
    if (node->left) {
        switch (node->funcType) {
            case 1:
                feature = data[idx_off1];
                break;
            case 2:
                feature = data[idx_off1] - data[idx_off2];
                break;
            case 3:
                if (data[idx_off1]<= data[idx_off2])
                    feature = data[idx_off2] - data[idx_off1];
                else
                    feature = data[idx_off1] - data[idx_off2];
                break;
            case 4:
                    feature = data[idx_off1] + data[idx_off2];
                break;
        }

        if (feature <= thresh)
            distribution = ApplyTree(node->left, data, m, n, index);
        else
            distribution = ApplyTree(node->right, data, m, n, index);
    } 
    return distribution;
}

// Q = mxapplytree(num_channels,x,y,boxwidth,boxheight,tree,data)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int m,n,img_index;
    const mxArray* apNumChannels = prhs[0];
    const mxArray* apBx = prhs[1];
    const mxArray* apBy = prhs[2];
    const mxArray* apBwidth = prhs[3];
    const mxArray* apBheight = prhs[4];
    const mxArray* apTree = prhs[5];
    const mxArray* apData = prhs[6];
    double* data = mxGetPr(apData);
    const mxArray* apNumClasses = prhs[7];
    
    //create tree structure
    NODE *tree = MakeTree(apTree,0);
    
    //pass through each image pixel within the classification box
    m = mxGetM(apData);
    n = mxGetN(apData)/mxGetScalar(apNumChannels);
    int box_width = (int)mxGetScalar(apBwidth);
    int box_height = (int)mxGetScalar(apBheight);
    int num_classes = (int)mxGetScalar(apNumClasses);
    
    plhs[0] = mxCreateDoubleMatrix(num_classes,box_width*box_height,mxREAL);
    double* output = mxGetPr(plhs[0]);
    double* distribution;
    
    img_index = ((int)mxGetScalar(apBx)-1)*m -2 + (int)mxGetScalar(apBy);
    for (int i = 0; i<(box_width*box_height); i++) {
        // convert box index i into image index
        if ( ((i % box_height) == 0) && (i!=0)) {
            img_index += (m-box_height+1);
        } else {
            img_index += 1;
        }
        
        // get distribution associated with current pixel
        distribution = ApplyTree(tree,data,m,n,img_index);
        
        // populate output array
        for (int c = 0; c<num_classes; c++) {
            output[i*num_classes + c] = distribution[c];
        }
    }
    DeleteTree(tree);
}
