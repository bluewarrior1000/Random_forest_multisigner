%script to show predicted joints
clear
clc
addpath('../random_forest_1signer/')
init_options_multisigner_fold1;
forest = cell(8,1);
forest_str = {'a','b','c','d'};
countf = 1;
%compile forest of 8 trees
for f_id = 1:4
    temp_F = load(sprintf('%sforest_%d.%d.%d.%d/forest_fold1%s.mat',...
        opts.forest_dir, opts.video_num(1), opts.video_num(2), opts.video_num(3), ...
        opts.video_num(4),forest_str{f_id}),'forest','data');
    %append forest
    for f = 1:2
        forest{countf} = temp_F.forest{f};
        countf = countf+1;
    end        
end

init_options_colourmodel_62;
opts.testingsetstepsize = 2;
opts.testingset         = opts.valid_frames((floor(length(opts.valid_frames)*0.6)+1):opts.testingsetstepsize:end); 
show_pred_joints_colourmodel(opts,forest,1)