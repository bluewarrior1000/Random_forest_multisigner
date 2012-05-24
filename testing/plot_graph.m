%function to plot a graph of joint prediction accuracies given accuracy
%matrix A. 
function plot_graph(A,thresh,title_str)
    figure
    T = 0:20;
    joint_name = {'head','right wrist','left wrist','right elbow',...
        'left elbow','right shldr','left shldr','average'};
    A(:,end+1) = sum(A,2)/7;
    for j = 1:8
        subplot(2,4,j)
        plot(T,A(:,j),'b-','linewidth',2);
        %plot vertical line where more than thresh
        idxT = find(A(:,j)>=thresh,1,'first');
        if ~isempty(idxT)
            hold on
            plot([T(idxT),T(idxT)],[0,A(idxT,j)],'r.-','linewidth',3)
            xtick = get(gca,'xtick');
            xtick = unique([xtick, T(idxT)]);
            set(gca,'xtick',xtick);
        end
        axis([0 20 0 1]);
        grid on;
        title(sprintf('%s: %s',title_str,joint_name{j}))
    end
end