function button_prev(src, event,handle,images)
    global andata;
    andata.completed(andata.current) = 1;
    %save data
    save(andata.data_filename,'andata');
    andata.current = andata.current - 1;
    display_image(andata,handle,images);   

end