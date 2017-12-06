function ordered_notes = image_read(filename) 
%{
IMAGE_READ - takes in the name of the guitar tab image and returns a cell
array ordered_notes which contains the note order for every group of 6
horizontal guitar strings. 

Preconditions: None. May be called independently of "driver.m".
%}
    disp("Reading image.");
    image = imread(filename);

    %Create grayscale image, then create inverse binary image. 
    %1 = non-white pixel in original image
    %0 = white pixel in original image
    image_gray = rgb2gray(image);
    image_binary = 1 - imbinarize(image_gray);
    
    [row_num, col_num] = size(image_binary);

    %Get image edges to determine positions of horizontal and vertical
    %lines
    image_edges = edge(image_gray, 'Canny');

    %Import pictures of numbers to serve as the ground truth for convolution
    num_images = 10;
    true = cell(1,num_images);
    for(i=0:1:num_images - 1)
       true{i+1} =  1 - imbinarize(rgb2gray(imread(sprintf('%d_rs.jpg',i))));
    end

    %Get size of the feature images.
    true_rows = zeros(1,num_images); true_cols=zeros(1,num_images);
    for(i=1:1:num_images)
       [true_rows(i),true_cols(i)] = size(true{i}); 
    end
    
    %Find the horizontal guitar string location in the image
    string_loc = find_horz_string_loc(image_edges);

    %Call localized_dot_product on each feature image to retrieve localized
    %and normalized cross-correlation output
    locations=cell(num_images,1);
    feature_widths = true_cols;
    for i=0:1:num_images - 1
        fprintf('    Finding localized regions of %d\n',i);
        [localized_region,locations{i+1}] = localized_dot_product(image_binary, true{i+1}, image_edges, string_loc);
    end
    
    %Find the correct ordering of the notes by calling find_note_order
    ordered_notes = find_note_order(locations, feature_widths);
end


function string_loc = find_horz_string_loc(image_edges)
%{
FIND_HORZ_STRING_LOC - takes in the guitar tab image after calling the
function "edge" on the original guitar tab image. Returns a vector
containing the vertical indices of the the horizontal string locations

Preconditions: "edge" has been called on the guitar tab image.

%}
    [row_num, col_num] = size(image_edges);
    
    %Sum image_edges horizontally and consider only locations where the
    %value is greater than 0.5 times the maximum value of the sum output.
    summed_horz = sum(image_edges, 2);
    summed_horz = (summed_horz > 0.5 * max(summed_horz)) .* summed_horz;
    
    %Find indices where summed_horz has nonzero values
    horz_inds = find(summed_horz > 0);
    
    %Group horizontal indices found in relatively close locations together
    %as a single horizontal string.
    string_loc = [];
    while(~isempty(horz_inds))
        temp = horz_inds((horz_inds > horz_inds(1) - 5) & (horz_inds < horz_inds(1) + 5));
        string_loc = [string_loc, floor(mean(temp))];
        horz_inds = horz_inds(horz_inds > max(temp));
    end
end


