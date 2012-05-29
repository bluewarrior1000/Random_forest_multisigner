function show_annotation(handle)
    global andata
    for j = 1:7
        set(handle.plotj{j},'xdata',andata.joints(1,j,andata.current),...
            'ydata',andata.joints(2,j,andata.current));
    end
    
    jorder = [1 6 4 2 3 5 7];
    ldata = zeros(2,2,4);
    if andata.joints(1,4,andata.current)==0
        ldata(:,1,1) = [andata.joints(1,6,andata.current); andata.joints(2,6,andata.current)];
        ldata(:,2,1) = [andata.joints(1,6,andata.current); andata.joints(2,6,andata.current)];
    else
        ldata(:,:,1) = [andata.joints(1,[6,4],andata.current); andata.joints(2,[6,4],andata.current)];
    end
    
    if andata.joints(1,2,andata.current)==0
        ldata(:,1,2) = [andata.joints(1,4,andata.current); andata.joints(2,4,andata.current)];
        ldata(:,2,2) = [andata.joints(1,4,andata.current); andata.joints(2,4,andata.current)];
    else
        ldata(:,:,2) = [andata.joints(1,[4,2],andata.current); andata.joints(2,[4,2],andata.current)];
    end
    
    if andata.joints(1,5,andata.current)==0
        ldata(:,1,3) = [andata.joints(1,3,andata.current); andata.joints(2,3,andata.current)];
        ldata(:,2,3) = [andata.joints(1,3,andata.current); andata.joints(2,3,andata.current)];
    else        
        ldata(:,:,3) = [andata.joints(1,[3,5],andata.current); andata.joints(2,[3,5],andata.current)];
    end
    
    if andata.joints(1,7,andata.current)==0
        ldata(:,1,4) = [andata.joints(1,5,andata.current); andata.joints(2,5,andata.current)];
        ldata(:,2,4) = [andata.joints(1,5,andata.current); andata.joints(2,5,andata.current)];
    else
        ldata(:,:,4) = [andata.joints(1,[5,7],andata.current); andata.joints(2,[5,7],andata.current)];
    end
    
    for l = 1:4
        set(handle.line{l},'xdata',ldata(1,:,l),'ydata',ldata(2,:,l))
    end
    
    %show patricks output if toggled
    if andata.pat.toggled == true
        plot_skeleton(andata.pat.joints(:,:,andata.frameidx(andata.current)),handle.pat.opts,handle.pat.plot_handle);
    else
        plot_skeleton(zeros(2,7),handle.pat.opts,handle.pat.plot_handle);
    end
end