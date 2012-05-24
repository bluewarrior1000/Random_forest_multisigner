%script to visualise the result

exp_str = {'lab','colourmodel','colourmodel_tomas','tomas','silhouette'};

for e_num = 3%:numel(exp_str)
    A = 0;
    for fold = 1:5
        opts_load_string = sprintf('init_options_multisigner_fold%d',fold);
        eval(opts_load_string);
        

        %compile results
        a = load(sprintf('./results/%s/forest_%d.%d.%d.%d/pred_joints_depth_32.mat',...
                exp_str{e_num}, opts.video_num(1), opts.video_num(2), opts.video_num(3), ...
                opts.video_num(4)),'accuracy');
        A = A + a.accuracy;   
        
        %plot graph of fold accuracy
        plot_graph(a.accuracy,0.9,sprintf('fold: %d\n%s',fold,exp_str{e_num}));
    end
    A = A/5;
    %plot graph of average accuracy
    plot_graph(A,0.9,sprintf('Av\n%s',exp_str{e_num}));    
end