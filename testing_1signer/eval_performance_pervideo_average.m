%script to evaluate the performance of the single signer forests
testtype = {'colourmodel_tomas','silhouette','tomas','lab'};
type_str = {'Color Posterior','Silhouette','Seg + Color Posterior','LAB'};
short_str = {'CP','S','Seg + CP','LAB'};

reorder = [4 1 2 3];

testvideo = [22 47 59 61 62];
eval_opts.thresh_dist = 6;
eval_opts.numtrees = [];

%fixed parameters
eval_opts.results_dir = './results/';
eval_opts.treedepth = 128;
eval_opts.windowwidth = 91;

T = zeros(numel(testvideo),7);
eval_opts.video_type = testtype{4};

for v = 1:numel(testvideo)
    eval_opts.video_num = testvideo(v);
    T(v,:) =  get_score(eval_opts);
end

T = cat(2,T,mean(T,2));



%create table
table_str = '\\begin{tabular}{lc*{8}{@{\\hspace{10pt}}c}}\n\\hline\n & Head & R wrist & L wrist & R elbow & L elbow & R shder & L shlder & Average\\\\\n\\hline\n';

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






