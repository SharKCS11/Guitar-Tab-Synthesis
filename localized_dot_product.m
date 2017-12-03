%Inputs: image_binary (binarized version of guitar tab), feature_image 
%(number to search for), image_edges (guitar image after calling function
%'edges' on image -> used to find string/vertical line locations)

%Outputs: localized_region, local_dot

function [localized_region, local_dot] = localized_dot_product(image_binary, feature_binary, image_edges, string_loc)

    [row_num, col_num] = size(image_binary);
    
    %Find horizontal line locations for strings
    %Since the edges function returns a binary image, summing horizontally should 
    %and finding the peaks should yield the locations of the horizontal
    %lines. 
    %Throw out noisy peaks to obtain only horizontal line locations
%     summed_horz = sum(image_edges, 2);
%     summed_horz = (summed_horz >= 0.5 * max(summed_horz)) .* summed_horz; 
% 
%     %Horizontal lines occur in peaks of 2. Reshape the matrix to represent
%     %each line, then average the position of the peaks to get a singular
%     %value for horizontal line location
%     [horz_val, horz_line_loc] = findpeaks(summed_horz);
%     horz_line_loc = reshape(horz_line_loc, 2, []);
%     string_loc = floor(mean(horz_line_loc));
    
%     %Find vertical line locations. Throw out noisy peaks by only
%     %considering vertical lines that are greater than half the height of
%     %the total image
%     summed_vert = sum(image_edges, 1);
%     summed_vert = (summed_vert >= 0.5 * row_num) .* summed_vert;
%     vert_loc = find(summed_vert > 0);

    %Get size of feature size
    [feature_rows, feature_cols] = size(feature_binary);
    
    %Declare matrices that store the value of the local convolution and localized region
    %localized_region - the image around each string used for convolution. Same
    %height as test image, centered about a string location.
    localized_region = zeros(feature_rows + 4, col_num, length(string_loc));
    local_dot = [];
    norm_factor = sum(sum(feature_binary));

    for i = 1:length(string_loc)
        first_ind = string_loc(i) - floor(feature_rows / 2) - 2;
        second_ind = string_loc(i) + ceil(feature_rows / 2) + 1;
        
        %Create a region of same height as test image centered about each
        %string location
        if(string_loc(i) < floor(feature_rows / 2))
            localized_region(:, :, i) = image_binary(1:feature_rows + 4, :);
        elseif(string_loc(i) > row_num - floor(feature_rows / 2))
            localized_region(:, :, i) = image_binary(row_num - feature_rows - 3:row_num, :);
        else
            localized_region(:, :, i) = image_binary(first_ind : second_ind, :);
        end
        
        %Perform "convolution". Instead of flip and shift, just shift test
        %image across the created localized_region and sum the product
        local_dot_temp = zeros(1, col_num - feature_cols - 1);
        for j = 1:col_num - feature_cols - 1
            dot_vert = [];
            for k = 1:4
                local_area = localized_region(k:k+feature_rows - 1, j:j+feature_cols - 1, i);
                dot_vert(k) = sum(dot(local_area, feature_binary));
            end
            local_dot_temp(j) = max(dot_vert);            
        end
        
        %The convolution yields positive values for locations that are not 0s.
        %Normalize the dot products by dividing by the largest possible dot
        %product value, which is the number of 1s in the feature image.
        %Then take values larger than 0.7 (Arbitrary value)
     
        local_dot_temp = local_dot_temp ./ norm_factor;
        local_dot_temp = (local_dot_temp > 0.7) .* local_dot_temp;           
        local_dot = [local_dot; local_dot_temp];
    end
    
    %ONLY WORKS IF VERTICAL LINES ARE ALIGNED
    %Deletes localized area about the locations of the vertical lines.
    local_dot = clear_vert_lines(image_edges, length(string_loc), local_dot, feature_rows);
end

function local_dot = clear_vert_lines(image_edges, num_strings, local_dot, feature_rows)
    [row_num, col_num] = size(image_edges);
    
    num_groups = num_strings / 6;
    vert_loc = cell(1, num_groups);
    
    for i = 1:num_groups
        temp_range = ((((i - 1) * row_num) / num_groups) + 1) : (i * row_num / num_groups);
        image_region = image_edges(temp_range, :);
        
        summed_vert = sum(image_region, 1);
        summed_vert = (summed_vert > (0.33 * length(temp_range))) .* summed_vert;
        
        vert_inds = find(summed_vert > 0);
        vert_loc = [];
        while(~isempty(vert_inds))
            temp = vert_inds((vert_inds > vert_inds(1) - 0.1 .* row_num) & (vert_inds < vert_inds(1) + 0.1 .* row_num));
            vert_loc = [vert_loc, floor(mean(temp))];
            vert_inds = vert_inds(vert_inds > max(temp));
        end
        for j = 1:length(vert_loc)
            if (vert_loc(j) < feature_rows)
                local_dot(:, 1:feature_rows) = 0;
            else
                vert_range = vert_loc(j) - floor(feature_rows) : vert_loc(j) + floor(feature_rows);
                local_dot(:, vert_range) = 0;
            end
        end
    end
end
