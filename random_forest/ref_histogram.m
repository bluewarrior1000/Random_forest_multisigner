%learn signer colour model
%v2 - uses presegmented image to train and outputs histograms for
%torso/background/skin
function colour_hist = ref_histogram(opts)
    colour_hist = cell(2,1);
    %load reference image
    I = imread(sprintf('%svideo%d/%s',opts.video_dir,opts.video_num,opts.colourhist.ref_image_filename));
    S = imread(sprintf('%svideo%d/%s',opts.video_dir,opts.video_num,opts.colourhist.ref_seg_filename));

    Mskin=(S(:,:,1)==255&S(:,:,2)==0&S(:,:,3)==0) | ...
        (S(:,:,1)==0&S(:,:,2)==255&S(:,:,3)==0) ;
    Mbody=(S(:,:,1)==0&S(:,:,2)==0&S(:,:,3)==255);

    colour_hist{1} = smooth_normalise_hist(opts,mre_rgbhistogram(I,opts.colourhist.bits,Mskin));
    colour_hist{2} = smooth_normalise_hist(opts,mre_rgbhistogram(I,opts.colourhist.bits ,Mbody));
        