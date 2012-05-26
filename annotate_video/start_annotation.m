function start_annotation(src, event, handle, images)
    global andata;
    
    %if its a space bar press then start the annotation
    switch event.Key
        case 'space'
            jorder = [1 6 4 2 3 5 7];
            for j = 1:7
                [x,y] = ginput(1);
                andata.joints(:,jorder(j),andata.current) = [x;y];
                show_annotation(handle);
            end
            %go to next image
            button_next([],[],handle,images);
        case 'otherwise'
    end
end