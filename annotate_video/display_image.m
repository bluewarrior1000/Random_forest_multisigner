function display_image(andata,handle,images)
    set(handle.img,'cdata',images(:,:,:,andata.current));
    set(handle.title,'string',sprintf('frame %d of %d',andata.current,length(andata.completed)));
    show_annotation(handle);
end