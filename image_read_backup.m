function ordered_notes = image_read(filename) 
    disp("Reading image.");
    image = imread(filename);

    %Create grayscale image
    image_gray = rgb2gray(image);

    %Create inverse binary image. 1 corresponds to a nonwhite pixel. Inverse
    %binary better for convolutions
    image_binary = 1 - imbinarize(image_gray);
    [row_num, col_num] = size(image_binary);

    %Get image edges to determine positions of horizontal lines
    image_edges = edge(image_gray, 'Canny');

    %Import pictures of numbers to serve as the ground truth for convolution
    %{
    true = cell(1,9);
    for(i=0:1:8)
       true{i+1} =  1 - imbinarize(rgb2gray(imread(sprintf('%d_rs.jpg',i))));
    end
    %}
    
    true_0 = 1 - imbinarize(rgb2gray(imread('0_rs.jpg')));
    true_1 = 1 - imbinarize(rgb2gray(imread('1_rs.jpg')));
    true_2 = 1 - imbinarize(rgb2gray(imread('2_rs.jpg')));
    true_3 = 1 - imbinarize(rgb2gray(imread('3_rs.jpg')));
    true_4 = 1 - imbinarize(rgb2gray(imread('4_rs.jpg')));
    true_5 = 1 - imbinarize(rgb2gray(imread('5_rs.jpg')));
    true_6 = 1 - imbinarize(rgb2gray(imread('6_rs.jpg')));
    true_7 = 1 - imbinarize(rgb2gray(imread('7_rs.jpg')));
    true_8 = 1 - imbinarize(rgb2gray(imread('8_rs.jpg')));


    %Get size of the true_0 image.
    %{ 
    true_rows = zeros(1,9); true_cols=zeros(1,9);
    for(i=1:1:9)
       [true_rows(i),true_cols(i)] = size(true{i}); 
    end
    %}
    [true0_rows, true0_cols] = size(true_0);
    [true1_rows, true1_cols] = size(true_1);
    [true2_rows, true2_cols] = size(true_2);
    [true3_rows, true3_cols] = size(true_3);
    [true4_rows, true4_cols] = size(true_4);
    [true5_rows, true5_cols] = size(true_5);
    [true6_rows, true6_cols] = size(true_6);
    [true7_rows, true7_cols] = size(true_7);
    [true8_rows, true8_cols] = size(true_8);
    
    
    %Call localized_dot_product to retrieve location of 0s for each localized
    %{
    %region
    locations=cell(1,9);
    feature_widths=zeros(1,9);
    for(i=0:1:8)
        fprintf('    Finding localized regions of %d\n',i);
        [localized_region,locations{i+1}] = localized_dot_product(image_binary, true{i+1}, image_edges);
        feature_widths = true_cols;
    end
    %}
    
    fprintf('Finding LDP for 0\n');
    [localized_region0, locations0] = localized_dot_product(image_binary, true_0, image_edges);
    fprintf('Finding LDP for 1\n');
    [localized_region1, locations1] = localized_dot_product(image_binary, true_1, image_edges);
    [localized_region2, locations2] = localized_dot_product(image_binary, true_2, image_edges);
    [localized_region3, locations3] = localized_dot_product(image_binary, true_3, image_edges);
    [localized_region4, locations4] = localized_dot_product(image_binary, true_4, image_edges);
    [localized_region5, locations5] = localized_dot_product(image_binary, true_5, image_edges);
    fprintf('Finding LDP for 6\n');
    [localized_region6, locations6] = localized_dot_product(image_binary, true_6, image_edges);
    [localized_region7, locations7] = localized_dot_product(image_binary, true_7, image_edges);
    fprintf('Finding LDP for 8\n');
    [localized_region8, locations8] = localized_dot_product(image_binary, true_8, image_edges);

    
    locations = {locations0; locations1; locations2; locations3; locations4; locations5; locations6; locations7; locations8};
    feature_widths = [true0_cols, true1_cols, true2_cols, true3_cols, true4_cols, true5_cols, true6_cols, true7_cols, true8_cols];
    
    
    ordered_notes = find_note_order(locations, feature_widths);
end




