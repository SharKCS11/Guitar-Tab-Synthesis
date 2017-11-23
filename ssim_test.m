
disp('Start');
%{
for(i=1:1:9)
    ref{i} = imread(sprintf('Reference_Images/%d.jpg',i-1));
    testOut = pc_resize(ref{i},32,24);
    imwrite(testOut,sprintf('Reference_Images/%d_rs.jpg',i-1));
end
%}


for(i=1:1:9)
    ref_rs{i} = imread(sprintf('Reference_Images/%d_rs.jpg',i-1));
end



%imresize
function imOut = pc_resize(im,height,width)
    % change width and height
    diff_left = floor((width - size(im,2))/2);
    diff_right = ceil((width-size(im,2))/2);
    diff_top = floor((height - size(im,1))/2);
    diff_bottom = ceil((height - size(im,1))/2);
    for(i=1:1:3)
        imTemp = im(:,:,i);
        fprintf('Cells %d\n',i);
        if((diff_left+diff_right)>0) %image is smaller: pad array
            fprintf('Growing width\n');
            imTemp =  padarray(imTemp,[0 diff_left],255,'pre');
            imTemp =  padarray(imTemp,[0 diff_right],255,'post');
        elseif((diff_left+diff_right)<0)
            fprintf('Shrinking width\n');
            beg = 1-diff_left;
            endidx = size(im,2)+diff_right;
            imTemp = imTemp(:,beg:1:endidx); 
        end
        if(diff_top+diff_bottom>0) %image is smaller: pad array
            fprintf('Growing height\n');
            size(imTemp)
            imTemp = padarray(imTemp,[diff_top 0],255,'pre');
            imTemp = padarray(imTemp,[diff_bottom 0],255,'post');
        elseif(diff_top+diff_bottom<0) %
            fprintf('Shrinking height\n');
            beg = 1-diff_top;
            endidx = size(im,1)+diff_bottom;
            imTemp = imTemp(beg:1:endidx,:); 
        end
        imOut(:,:,i)=imTemp;
    end
end