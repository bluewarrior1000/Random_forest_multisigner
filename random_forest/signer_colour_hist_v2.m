%learn signer colour model
%v2 - uses presegmented image to train and outputs histograms for
%torso/background/skin
function colour_posterior = signer_colour_hist_v2(opts)
    colour_posterior = cell(3,1);
    %load reference image
    I = imread(sprintf('%s%s',opts.video_dir,opts.colourhist.ref_image_filename));
    S = imread(sprintf('%s%s',opts.video_dir,opts.colourhist.ref_seg_filename));

    Mskin=(S(:,:,1)==255&S(:,:,2)==0&S(:,:,3)==0);
    Mbody=(S(:,:,1)==0&S(:,:,2)==0&S(:,:,3)==255);
    Mbg=all(S==0,3);

    colour_posterior{1} = smooth_normalise_hist(opts,mre_rgbhistogram(I,opts.colourhist.bits,Mskin));
    colour_posterior{2} = smooth_normalise_hist(opts,mre_rgbhistogram(I,opts.colourhist.bits ,Mbody));
    colour_posterior{3} = smooth_normalise_hist(opts,mre_rgbhistogram(I,opts.colourhist.bits ,Mbg));
    
    for i = 1:3
        colour_posterior{i} = colour_posterior{i}./sum(cat(4,colour_posterior{:}),4);
    end
    
    %smooth and normalise histogram
    function histogram = smooth_normalise_hist(opts, histogram)
        histogram=histogram+1;
        histogram = gauss3d(histogram,opts.colourhist.smoothvariance,0);
        histogram=histogram/sum(histogram(:));
        