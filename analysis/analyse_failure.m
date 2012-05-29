%function analyse the failure modes for tracking a single signer

video_num = [22 47 59 61 62];
results_dir = '../../Saved_data/forest_results/single_signer/results/';
frames_dir = '../../Video_database/Signing/extracted_frames/single_signer/testing/frames/';
data_dir = '../../Video_database/Signing/Data/';
video_type = {'colourmodel_tomas','lab','silhouette','tomas'};
window_width = [31 51 71 91];
tree_depth = [8 16 32 64 128];
VN = 1;
VT = 1;
WW = 1;
TD = 4;
JOINT = 3;
BAD_THRESH = 5;
%load estimated joints and their distance (L2) from ground truth
results = load(sprintf('%s%s/video%d/pred_joints_width_%d_depth_%d.mat',...
    results_dir,video_type{VT},video_num(VN),window_width(WW),...
    tree_depth(TD)));

%locate bad joint estimates - we do this per joint
bad_idx = results.dist_frm_GT > BAD_THRESH;
bad_idx = find(bad_idx(:,JOINT));

%visuals frames with bad joint estimates
images = load(sprintf('%s%s/video%d/images.mat',frames_dir,video_type{VT},video_num(VN)));
images = images.images;

%load testing set idx
testingset = load(sprintf('%s%s/video%d/testingset.mat',frames_dir,video_type{VT},video_num(VN)));
testingset = testingset.opts.testingset;

%get Patricks GT joint location
load(sprintf('%sfeatMatSmoothed_videoNr%d',data_dir,video_num(VN)));
load(sprintf('%sheadMeanPosMat_videoNr%d',data_dir,video_num(VN)));
load(sprintf('%sshoulderPosMat_videoNr%d',data_dir,video_num(VN)));
load(sprintf('%soffset',data_dir));
opts.P=[headMeanPosMat(:,[2 1]) ...
featMatSmoothed(:,[4 3 6 5 8 7 10 9]) ...
shoulderPosMat(:,[2 1 4 3])]';
opts.P=reshape(opts.P,2,[],size(opts.P,2));
opts.P(1,:,:)=opts.P(1,:,:)*3+offset(1,video_num(VN));
opts.P(2,:,:)=opts.P(2,:,:)*3+offset(2,video_num(VN));
opts.P=double(opts.P);
opts.joints = round((opts.P-1)*0.5 + 1);
pgt = opts.joints(:,:,testingset);

%test to visualise all frame
handle = [];
handle2 = [];

opts1.clr = jet(9);
opts1.linewidth = 5;
opts1.jointsize = 10;

opts2.clr = ones(9,3);
opts2.linewidth = 3;
opts2.jointsize = 5;

if VT ~= 3
    img_handle = imagesc(images(:,:,:,1)); axis image
else
    img_handle = imagesc(images(:,:,1)); axis image
end

for i = 1:numel(bad_idx)
    if VT ~= 3
        set(img_handle,'cdata',images(:,:,:,bad_idx(i))); axis image
    else
        set(img_handle,'cdata',images(:,:,bad_idx(i))); axis image
    end
    hold on
    handle = plot_skeleton(results.pred_joints(:,:,bad_idx(i)),opts1,handle);
    handle2 = plot_skeleton(pgt(:,:,bad_idx(i)),opts2,handle2);
    drawnow
    pause(1);
end


