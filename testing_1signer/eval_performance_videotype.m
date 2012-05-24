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

P = zeros(numel(testtype),numel(testdist));
T = zeros(numel(testtype),7);

for t = 1:numel(testtype)
    eval_opts.video_type = testtype{t};
    for d = 1:numel(testdist)
        eval_opts.thresh_dist = testdist(d);
        score = 0;
        for v = 1:numel(testvideo)
            eval_opts.video_num = testvideo(v);
            score = score + get_score(eval_opts);
        end
        P(t,d) = sum(score)/(numel(testvideo)*7);       
        if testdist(d)==5
            T(t,:) = score/numel(testvideo);
        end
    end
end

figure
clr = lines(numel(testtype));
plot_type = {'b-^','b-*','b--','b-s'};
leg_str = 'legend(';
for t = 1:numel(testtype)
    plot(testdist,P(t,:)*100,plot_type{t},'color',clr(t,:),'linewidth',3);
    hold on
    if t == numel(testtype)
        leg_str = sprintf('%s''%s''',leg_str,type_str{t});
    else
        leg_str = sprintf('%s''%s'',',leg_str,type_str{t});
    end
end
leg_str = sprintf('%s,''location'',''SouthEast'');',leg_str);
eval(leg_str)

%create table
table_str = '\\begin{tabular}{lc*{8}{@{\\hspace{10pt}}c}}\n\\hline\nMethod & Head & R wrist & L wrist & R elbow & L elbow & R shder & L shlder & Average\\\\\n\\hline\n';

T = cat(2,T,mean(T,2));
for tt = 1:numel(testtype)
    t = reorder(tt);
    table_str = sprintf('%s%s',table_str,short_str{t});
    for j = 1:8
        if sum(T(t,j) <= T(:,j))==1
            table_str = sprintf('%s & \\\\textbf{%02.1f}',table_str,T(t,j)*100);
        else
            table_str = sprintf('%s & %02.1f',table_str,T(t,j)*100);
        end
    end
    table_str = sprintf('%s \\\\\\\\ \n',table_str);
end
table_str = sprintf('%s\\\\hline \n\\\\end{tabular}\n',table_str);
fprintf(table_str)
% CP        & 99.0 & 77.2 & 73.7 & 72.6 & 92.6 & 90.8 & 96.7 & 86.1\\\\\
% Seg+CP & 99.8 & 82.5 & 78.1 & 78.0 & 93.3 & 95.1 & 97.4 & 89.2 \\\\\\
% \hline
% \end{tabular}'

axis([0 20 0 100])
h = ylabel('Average accuracy (%)');
set(h,'fontsize',20)
h = xlabel('Number of trees');
set(h,'fontsize',20)
set(gca,'fontsize',20)
grid on

% pause
% export_fig(gcf,'tree_depth.pdf','-pdf','-a1','-transparent')



