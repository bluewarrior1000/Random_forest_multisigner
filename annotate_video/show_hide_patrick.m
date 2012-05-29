function show_hide_patrick(src, event, handle)
    global andata;
    
    %toggle visibility of patricks output
    if andata.pat.toggled 
        andata.pat.toggled = false;
    else
        andata.pat.toggled = true;
    end
    
    show_annotation(handle);
end