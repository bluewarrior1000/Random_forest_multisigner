%function analyse the failure modes for tracking a single signer

video_num = [22 47 59 60 61];
results_dir = '../../Saved_data/forest_results/single_signer/results/';
frames_dir = '../../Video_database/Signing/extracted_frames/single_signer/testing/frames/';
video_type = {'colourmodel_tomas','lab','silhouette','tomas'};
window_width = [31 51 71 91];
tree_depth = [8 16 32 64 128];
VN = 1;
VT = 1;
WW = 4;
TD = 4;
BAD_THRESH = 10;
%load estimated joints and their distance (L2) from ground truth
load(sprintf('%s%s/video%d/pred_joints_width_%d_depth_%d.mat',...
    results_dir,video_type{VT},video_num(VN),window_width(WW),...
    tree_depth(TD)));

%locate bad joint estimates - we do this per joint
bad_idx = dist_frm_GT > BAD_THRESH;

%visuals frames with bad joint estimates
load(sprintf('%s%s/video%d/images.mat',frames_dir,video_num(VN));



