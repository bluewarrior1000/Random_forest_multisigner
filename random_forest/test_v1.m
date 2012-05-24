 %% 1
idxp = idxp1; image_set = image_set1; 
im = reshape(idxp,opts.boundingbox(4)+1,opts.boundingbox(3)+1,size(image_set,4));
        for i = 1:size(image_set,4)
            subplot(121)
            img = image_set(:,:,:,i);
            data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4));
           data_x = (opts.boundingbox(1):(opts.boundingbox(1)+opts.boundingbox(3)));
           box_img = img(data_y,data_x,:);
            imagesc(uint8(box_img)); axis image;
            subplot(122)
            imagesc(uint8(box_img)); axis image;
            hold on
            
            alpha = im(:,:,i)~=8;
            color_im = ind2rgb(im(:,:,i),jet(8));
            im_handle = imagesc(color_im); 
            set(im_handle,'alphadata',alpha*0.8);
            title(['frame: ' num2str(i)]);
            drawnow
            pause(0.04);
        end
        %% 2
        idxp = idxp2; image_set = image_set2; 
im = reshape(idxp,opts.boundingbox(4)+1,opts.boundingbox(3)+1,size(image_set,4));
        for i = 1:size(image_set,4)
            subplot(121)
            img = image_set(:,:,:,i);
            data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4));
           data_x = (opts.boundingbox(1):(opts.boundingbox(1)+opts.boundingbox(3)));
           box_img = img(data_y,data_x,:);
            imagesc(uint8(box_img)); axis image;
            subplot(122)
            imagesc(uint8(box_img)); axis image;
            hold on
            
            alpha = im(:,:,i)~=8;
            color_im = ind2rgb(im(:,:,i),jet(8));
            im_handle = imagesc(color_im); 
            set(im_handle,'alphadata',alpha*0.8);
            title(['frame: ' num2str(i)]);
            drawnow
            pause(0.04);
        end
        %% 3
        idxp = idxp3; image_set = image_set3; 
im = reshape(idxp,opts.boundingbox(4)+1,opts.boundingbox(3)+1,size(image_set,4));
        for i = 1:size(image_set,4)
            subplot(121)
            img = image_set(:,:,:,i);
            data_y = opts.boundingbox(2):(opts.boundingbox(2) + opts.boundingbox(4));
           data_x = (opts.boundingbox(1):(opts.boundingbox(1)+opts.boundingbox(3)));
           box_img = img(data_y,data_x,:);
            imagesc(uint8(box_img)); axis image;
            subplot(122)
            imagesc(uint8(box_img)); axis image;
            hold on
            
            alpha = im(:,:,i)~=8;
            color_im = ind2rgb(im(:,:,i),jet(8));
            im_handle = imagesc(color_im); 
            set(im_handle,'alphadata',alpha*0.8);
            title(['frame: ' num2str(i)]);
            drawnow
            pause;
        end