%options for annotation
opts.stdimgwidth        = 720;          %standard width of input images (already scaled)
opts.stdimgheight       = 405;          %standard height of input images (already scaled)
opts.video_filename     = 'x.avs';
opts.video_num          = 62;
opts.video_dir          = '../../Video_database/Signing/Videos/';
opts.data_dir           = '../../Video_database/Signing/Data/';
opts.frames_dir         = '../../Video_database/Signing/extracted_frames/single_signer/testing/frames/tomas/';
opts.scale              = 1;
%if a testing set has been created then load it, if not then create one
if exist(sprintf('%svideo%d/testingset.mat',opts.frames_dir,opts.video_num),'file')
    loaded_data = load(sprintf('%svideo%d/testingset.mat',opts.frames_dir,opts.video_num));
    opts.testingset = loaded_data.opts.testingset;
else
    opts.valid_frames       = load(sprintf('%svalid_frames_videoNr%d.mat',opts.data_dir,opts.video_num),'valid_frames');
    opts.valid_frames       = opts.valid_frames.valid_frames;
    opts.testingsetstepsize = 2;
    opts.testingset         = opts.valid_frames((floor(length(opts.valid_frames)*0.6)+1):opts.testingsetstepsize:end); 
end
opts.numclusters        = 200; %number of clusters to cluster pose space when sampling images

%% load body joint coordinates
load(sprintf('%sfeatMatSmoothed_videoNr%d',opts.data_dir,opts.video_num));
load(sprintf('%sheadMeanPosMat_videoNr%d',opts.data_dir,opts.video_num));
load(sprintf('%sshoulderPosMat_videoNr%d',opts.data_dir,opts.video_num));
load(sprintf('%soffset',opts.data_dir));
opts.P=[headMeanPosMat(:,[2 1]) ...
featMatSmoothed(:,[4 3 6 5 8 7 10 9]) ...
shoulderPosMat(:,[2 1 4 3])]';
opts.P=reshape(opts.P,2,[],size(opts.P,2));
opts.P(1,:,:)=opts.P(1,:,:)*3+offset(1,opts.video_num);
opts.P(2,:,:)=opts.P(2,:,:)*3+offset(2,opts.video_num);
opts.P=double(opts.P);
opts.joints = round((opts.P-1)*opts.scale + 1);