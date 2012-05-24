%function to get the clean slate
function mask = get_slate(opts)

    video_path = sprintf('%s/video%d/%s',opts.video_dir,opts.video_num,opts.video_filename);
    mean_img = zeros(opts.stdimgheight,opts.stdimgwidth);
    for i = 1:length(opts.trainingset)
        I=mre_avifile(video_path,opts.trainingset(i)-1);
        I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
        mean_img = mean_img + mean(I,3);
    end
    mean_img = mean_img/length(opts.trainingset);

    %get variance
    var_img = zeros(opts.stdimgheight,opts.stdimgwidth);
    for i = 1:length(opts.trainingset)
        I=mre_avifile(video_path,opts.trainingset(i)-1);
        I=mre_resizebilinear(I,opts.stdimgheight,opts.stdimgwidth,true);
        var_img = var_img + (mean_img - mean(I,3)).^2;
    end
    var_img = var_img/length(opts.trainingset);
    mask = var_img<10;
