%Inputs: image_binary (binarized version of guitar tab), feature_image 
%(number to search for), image_edges (guitar image after calling function
%'edges' on image -> used to find string/vertical line locations)

%Outputs: localized_region, local_dot

function [localized_region, local_dot, local_sum] = localized_dot_product(image_binary, feature_binary, image_edges)
    
    %Find horizontal line locations for strings
    %Since the edges function returns a binary image, summing horizontally should 
    %and finding the peaks should yield the locations of the horizontal
    %lines. 
    %Throw out noisy peaks to obtain only horizontal line locations
    summed_horz = sum(image_edges, 2);
    summed_horz = (summed_horz >= 0.5 * max(summed_horz)) .* summed_horz; 

    %Horizontal lines occur in peaks of 2. Reshape the matrix to represent
    %each line, then average the position of the peaks to get a singular
    %value for horizontal line location
    [horz_val, horz_line_loc] = findpeaks(summed_horz);
    horz_line_loc = reshape(horz_line_loc, 2, []);
    string_loc = floor(mean(horz_line_loc));


    %Find vertical line locations - Not really used
    summed_vert = sum(image_edges, 1);
    summed_vert = (summed_vert >= 0.5 * max(summed_vert)) .* summed_vert;
    vert_loc = find(summed_vert > 0);

    col_num = size(image_binary, 2);
    [feature_rows, feature_cols] = size(feature_binary);
    
    %Declare matrices that store the value of the local convolution and localized region
    %localized_region - the image around each string used for convolution. Same
    %height as test image, centered about a string location.
    localized_region = zeros(feature_rows + 4, col_num, length(string_loc));
    local_dot = [];
    local_sum = [];
    
    for i = 1:length(string_loc)
        first_ind = string_loc(i) - floor(feature_rows / 2) - 2;
        second_ind = string_loc(i) + ceil(feature_rows / 2) + 1;
        
        %Create a region of same height as test image centered about each
        %string location
        localized_region(:, :, i) = image_binary(first_ind : second_ind, :);
        
        %Perform "convolution". Instead of flip and shift, just shift test
        %image across the created localized_region and sum the product
        local_dot_temp = zeros(1, col_num - feature_cols - 1);
        local_sum_temp = zeros(1, col_num - feature_cols - 1);
        for j = 1:col_num - feature_cols - 1
            dot_vert = [];
            sum_temp = [];
            for k = 1:4
                local_area = localized_region(k:k+feature_rows - 1, j:j+feature_cols-1, i);
                dot_vert(k) = sum(dot(local_area, feature_binary));
                sum_temp(k) = sum(sum(local_area));
            end
            local_dot_temp(j) = max(dot_vert);
            local_sum_temp(j) = abs(max(sum_temp) - sum(sum(feature_binary)));
        end
        
        %The convolution yields positive values for locations that are not 0s.
        %Filter out these locations by only considereing locations that have
        %convolution values larger than 0.75 the maximum value of the
        %convolution. 0.75 is arbitrary, works well. 0.5 yielded some false
        %positives.

        %Normalize the convolutions for comparisons later
        max_conv_val = max(local_dot_temp);
        %local_dot_temp = ((local_dot_temp > 0.8 * max_conv_val) .* local_dot_temp) ./ sum(sum(feature_binary));
        local_dot_temp = local_dot_temp ./ sum(sum(feature_binary));
        local_dot_temp = (local_dot_temp > 0.7) .* local_dot_temp;
        
        local_dot = [local_dot; local_dot_temp];
        local_sum = [local_sum; local_sum_temp];
    end
    
    
    for m = 1:length(vert_loc)
        vert_range = vert_loc(m) - feature_cols : vert_loc(m) + feature_cols;
        local_dot(:, vert_range) = 0;
    end
end