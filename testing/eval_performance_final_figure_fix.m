%script to evaluate the performance of the single signer forests
testtype = {'colourmodel_tomas','silhouette','tomas','lab'};
type_str = {'Color Posterior','Silhouette','Seg + Color Posterior','LAB'};
short_str = {'CP','S','Seg + CP','LAB'};

reorder = [4 1 2 3];

testvideo = [22 47 59 61 62];
testdist = 0:20;

%fixed parameters
eval_opts.results_dir = './results/';
eval_opts.treedepth = 64;
eval_opts.windowwidth = 91;
eval_opts.numtrees = [];

P = zeros(numel(testdist),7);
eval_opts.video_type = testtype{3};

for d = 1:numel(testdist)
    eval_opts.thresh_dist = testdist(d);
    score = 0;
    for v = 1:numel(testvideo)
        eval_opts.video_num = testvideo(v);
        score = score + get_score(eval_opts);
    end
    P(d,:) = score/numel(testvideo);
end


%fixed parameters
eval_opts.results_dir = '../testing_1signer/results/';
eval_opts.treedepth = 64;
eval_opts.windowwidth = 91;
eval_opts.numtrees = [];

Ps = zeros(numel(testdist),7);
eval_opts.video_type = testtype{3};

for d = 1:numel(testdist)
    eval_opts.thresh_dist = testdist(d);
    score = 0;
    for v = 1:numel(testvideo)
        eval_opts.video_num = testvideo(v);
        score = score + get_score_single_signer(eval_opts);
    end
    Ps(d,:) = score/numel(testvideo);
end
Ps(:,8) = mean(Ps,2);
P(:,8) = mean(P,2);

Ps = [Ps(:,1), mean(Ps(:,2:3),2), mean(Ps(:,4:5),2), mean(Ps(:,6:7),2), Ps(:,8)];
P = [P(:,1), mean(P(:,2:3),2), mean(P(:,4:5),2), mean(P(:,6:7),2), P(:,8)];
title_str = {'Head','Wrists','Elbows','Shoulders','Average'};
for f = 2:5
    figure
    plot(testdist,P(:,f),'b-','linewidth',4);
    hold on
    plot(testdist,Ps(:,f),'r--','linewidth',4);
    grid on
    tidx = find(P(:,f)>=0.8,1,'first');
    set(gca,'xtick',[0 10 20]);
    if ~isempty(tidx)
        plot([testdist(tidx),testdist(tidx)],[0, P(tidx,f)],'b--','linewidth',3);
        xtick = get(gca,'xtick');
        set(gca,'xtick',unique([xtick,testdist(tidx)]));
    end
    
    tidx = find(Ps(:,f)>=0.8,1,'first');
    if ~isempty(tidx)
        plot([testdist(tidx),testdist(tidx)],[0, Ps(tidx,f)],'r--','linewidth',3);
        xtick = get(gca,'xtick');
        set(gca,'xtick',unique([xtick,testdist(tidx)]));
    end
    tt = title(title_str{f});
    set(gca,'fontsize',30)
    set(tt,'fontsize',30)
    set(gcf,'position',[0 0 400 400]);
    export_fig(gcf,sprintf('D:\\Shared\\Dropbox\\BMVC_2012\\images\\video22_seg_fig%d',f),'-pdf','-a1','-transparent')
end


