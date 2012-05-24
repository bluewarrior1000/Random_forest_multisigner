%compute posteriors of an image given colour histograms
function posterior = compute_posterior(opts,I, colour_hist)
    %compute histogram for background
    Mbg = true(size(I,1),size(I,2));
    Mbg(33:end,200:end) = false;
    
    %use clean slate
    Mbg(opts.seg.slate) = true;
    
    colour_hist{3} = smooth_normalise_hist(opts, mre_rgbhistogram(I,opts.colourhist.bits,Mbg));
    posterior = zeros(size(I));
    N = sum(cat(4,colour_hist{:}),4);
    for i = 1:3
        colour_hist{i} = colour_hist{i}./N;
        posterior(:,:,i) = mre_rgblookup(I, colour_hist{i});
    end   
end