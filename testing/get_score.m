%function to return the score of forests
function score = get_score(eval_opts)

   switch eval_opts.video_num
       case 22
           trainvids = [47 59 61 62];
       case 47
           trainvids = [59 61 62 22];
       case 59
           trainvids = [61 62 22 47];
       case 61
           trainvids = [62 22 47 59];
       case 62
           trainvids = [22 47 59 61];
   end
       
   load(sprintf('%s%s/forest_%d.%d.%d.%d/pred_joints_depth_%d.mat',...
                eval_opts.results_dir, eval_opts.video_type, ...
                trainvids(1),trainvids(2),trainvids(3),trainvids(4), eval_opts.treedepth));
    score = accuracy(eval_opts.thresh_dist+1,:);
end