%smooth and normalise histogram
function histogram = smooth_normalise_hist(opts, histogram)
    histogram=histogram+1;
    histogram = gauss3d(histogram,opts.colourhist.smoothvariance,0);
    histogram=histogram/sum(histogram(:));