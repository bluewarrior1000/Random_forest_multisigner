%script to evaluate the performance of the single signer forests
testwidth = [31 51 71 91];
testtype = {'colourmodel_tomas','silhouette','tomas','lab'};
testvideo = [22 47 59 61 62];

%fixed parameters
eval_opts.results_dir = './results/';
eval_opts.thresh_dist = 6;
eval_opts.treedepth = 64;
eval_opts.numtrees = [];

P = zeros(numel(testwidth),numel(testtype));
for t = 1:numel(testtype)
    eval_opts.video_type = testtype{t};
    for w = 1:numel(testwidth)
        eval_opts.windowwidth = testwidth(w);
        score = 0;
        for v = 1:numel(testvideo)
            eval_opts.video_num = testvideo(v);
            score = score + get_score(eval_opts);
        end
        P(w,t) = sum(score)/(numel(testvideo)*7);        
    end
end
clr = lines(4);
plot_type = {'b-^','b-*','b--','b-s'};
figure

% LAB = rand(numel(testwidth),1)/5 + P(:,1) + P(:,2) + P(:,3) -0.1;
% P = cat(2,P,LAB/3);
for t = 1:4
    plot(testwidth,P(:,t)*100,plot_type{t},'linewidth',3,'markersize',10,'color',clr(t,:));
    hold on
end
AX=legend('CP','S','Seg+CP','LAB','location','SouthEast');
LEG = findobj(AX,'type','text');
set(LEG,'FontSize',25)
fontsize = 30;
axis([31 91  0 100])
h = ylabel('Average accuracy (%)');
set(h,'fontsize',fontsize)
h = xlabel('(a) Window width');
set(h,'fontsize',fontsize)
set(gca,'fontsize',fontsize)
grid on
set(gcf,'outerposition',[0,0,500,600])
set(gca,'xtick',[31 51 71 91])
% set(gca,'xticklabel',1:32:128);
% export_fig(gcf,'D:\Shared\Dropbox\BMVC_2012\images\window_width.pdf','-pdf','-a1','-transparent')



