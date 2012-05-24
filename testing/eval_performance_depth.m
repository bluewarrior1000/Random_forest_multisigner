%script to evaluate the performance of the single signer forests
testtype = {'colourmodel_tomas','silhouette','tomas','lab'};
type_str = {'Color Posterior','Silhouette','Seg + Color Posterior','LAB'};
testvideo = [22 47 59 61 62];
testdepth = [8 16 32 64 128];

%fixed parameters
eval_opts.results_dir = './results/';
eval_opts.windowwidth = 91;
eval_opts.thresh_dist = 6;
eval_opts.numtrees = [];

P = zeros(numel(testtype),numel(testdepth));
for t = 1:numel(testtype)
    eval_opts.video_type = testtype{t};
    for d = 1:numel(testdepth)
        eval_opts.treedepth = testdepth(d);
        score = 0;
        for v = 1:numel(testvideo)
            eval_opts.video_num = testvideo(v);
            score = score + get_score(eval_opts);
        end
        P(t,d) = sum(score)/(numel(testvideo)*7);        
    end
end

figure
fontsize = 30;
clr = lines(numel(testtype));
plot_type = {'b-^','b-*','b--','b-s'};
leg_str = 'legend(';
for t = 1:numel(testtype)
    plot(testdepth,P(t,:)*100,plot_type{t},'color',clr(t,:),'linewidth',3,'markersize',10);
    hold on
    if t == numel(testtype)
        leg_str = sprintf('%s''%s''',leg_str,type_str{t});
    else
        leg_str = sprintf('%s''%s'',',leg_str,type_str{t});
    end
end
leg_str = sprintf('%s,''location'',''SouthEast'');',leg_str);
% eval(leg_str)

axis([8 128 2 70])
h = ylabel('Average accuracy (%)');
set(h,'fontsize',fontsize)
h = xlabel('(c) Depth of trees');
set(h,'fontsize',fontsize)
set(gca,'fontsize',fontsize)
grid on

set(gca,'xtick',[8 32 64 96 128])
set(gcf,'outerposition',[0,0,500,600])

% set(gca,'xticklabel',1:32:128);

% export_fig(gcf,'D:\Shared\Dropbox\BMVC_2012\images\tree_depth_multi.pdf','-pdf','-a1','-transparent')




