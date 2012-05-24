%script to produce two plots showing performance of predicted joints

%set option parameters
init_options;

%make sure a forest is loaded
if isempty(whos('forest'))
    error('load in a forest');
end

%get performance measure for first threshold
thresh = 0:1:20;
[score, dist_frm_GT, pred_joints] = eval_joints(opts,thresh(1),[],forest);
performance = zeros(length(thresh),opts.numclasses-1);
performance(1,:) = mean(score);
%now cmpute performance curve
for i = 2:length(thresh)
    score = eval_joints(opts, thresh(i), pred_joints);
    performance(i,:) = mean(score);
end
%plot curves
figure
joint_name = {'head','right wrist','left wrist','right elbow','left elbow','right shldr','left shldr'};
for c = 1:(opts.numclasses-1)
    subplot(3,3,c)
    plot(thresh,performance(:,c))
    xlabel('Distance from GT location');
    ylabel('Percentage correct');
    title(joint_name{c});
    grid on
end

%plot histograms of distances from GT joints
dist_frm_GT = permute(dist_frm_GT,[3 2 1]);
figure
joint_name = {'head','right wrist','left wrist','right elbow','left elbow','right shldr','left shldr'};
for c = 1:(opts.numclasses-1)
    subplot(3,3,c)
    H = hist(dist_frm_GT(:,c),0:20);
    H = H./sum(H(:));
    bar(0:20,H);
    xlabel('Distance from GT location');
    ylabel('Percentage');
    title(joint_name{c});
    grid on
end

