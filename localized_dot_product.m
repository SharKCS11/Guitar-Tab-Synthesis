
function [localized_region, local_dot] = localized_dot_product(image_binary, feature_binary, image_edges, string_loc)
%{
LOCALIZED_DOT_PRODUCT - takes a binarized version of the original guitar
tab image and feature image, the original guitar tab image after the
function "edge" has been called on it, and a vector of horizontal string
locations. Returns localized and normalized cross-correlation outputs for
every feature centered about every string.

Preconditions: Requires the aforementioned image formats. May be called
independently of driver.m. 

The localized_region output is not used in the system, but is used for data
visualization purposes.

%}

    %Get size of image sizes
    [row_num, col_num] = size(image_binary);
    [feature_rows, feature_cols] = size(feature_binary);
    
    %Declare matrices that store the value of the local convolution and localized region
    %localized_region - the image around each string used for convolution.
    %Allow for some tolerance in terms of height, in case the digit is not
    %perfectly centered about the string index.
    localized_region = zeros(feature_rows + 4, col_num, length(string_loc));
    local_dot = [];
    
    %Find normalization factor, which is the theoretical maximum value of
    %the cross-correlation. This is the number of 1s in the feature image.
    norm_factor = sum(sum(feature_binary));

    %Iterate through every string location
    for i = 1:length(string_loc)
        first_ind = string_loc(i) - floor(feature_rows / 2) - 2;
        second_ind = string_loc(i) + ceil(feature_rows / 2) + 1;
        
        %Create localized region from test image centered about each
        %string location with vertical tolerances for alignment correction
        if(string_loc(i) < floor(feature_rows / 2))
            localized_region(:, :, i) = image_binary(1:feature_rows + 4, :);
        elseif(string_loc(i) > row_num - floor(feature_rows / 2))
            localized_region(:, :, i) = image_binary(row_num - feature_rows - 3:row_num, :);
        else
            localized_region(:, :, i) = image_binary(first_ind : second_ind, :);
        end
        
        %Perform cross-correlation horizontally then vertically. Store the
        %maximum value of the vertical cross-correlation as the result of
        %the output of the horizontal cross-correlation.
        local_dot_temp = zeros(1, col_num - feature_cols - 1);
        for j = 1:col_num - feature_cols - 1
            dot_vert = [];
            for k = 1:4
                local_area = localized_region(k:k+feature_rows - 1, j:j+feature_cols - 1, i);
                dot_vert(k) = sum(dot(local_area, feature_binary));
            end
            local_dot_temp(j) = max(dot_vert);            
        end
        
        %Normalize the results of the cross-correlation by the
        %normalization factor found earlier. Filter out values less than
        %70% similar (less than 0.7. This value was chosen as a result of
        %trial and error.
        local_dot_temp = local_dot_temp ./ norm_factor;
        local_dot_temp = (local_dot_temp > 0.7) .* local_dot_temp;           
        local_dot = [local_dot; local_dot_temp];
    end
    
    %Deletes localized area about the locations of the vertical lines.
    local_dot = clear_vert_lines(image_edges, length(string_loc), local_dot, feature_rows);
end

function local_dot = clear_vert_lines(image_edges, num_strings, local_dot, feature_rows)
%{
CLEAR_VERT_LINES - takes the number of the strings, the result of the
cross-correlations, the number of rows in the feature image, and the
image_edges image and deletes non-zero values found at locations of
vertical lines.

%Preconditions: do not call outside of localized_dot_product.m, as it
requires the results of the cross-correlation to function.

%}
    [row_num, col_num] = size(image_edges);
    
    %Calculate the number of string groups
    num_groups = num_strings / 6;
    vert_loc = cell(1, num_groups);
    
    %Iterate over all groups of strings
    for i = 1:num_groups
        %Divide the image into a fraction corresponding to the number of
        %groups. For example, if there are 3 string groups, divide the
        %image in to thirds. 
        temp_range = floor((((i - 1) * row_num) / num_groups) + 1) : floor(i * row_num / num_groups);
        image_region = image_edges(temp_range, :);
        
        %Sum over each portion of the image and find indices of significant
        %output. 
        summed_vert = sum(image_region, 1);
        summed_vert = (summed_vert > (0.33 * length(temp_range))) .* summed_vert;
        vert_inds = find(summed_vert > 0);
        
        %Group vertical indices that are relatively close together as one
        %location.
        vert_loc = [];
        while(~isempty(vert_inds))
            temp = vert_inds((vert_inds > vert_inds(1) - floor(0.05 .* row_num)) & (vert_inds < vert_inds(1) + floor(0.05 .* row_num)));
            vert_loc = [vert_loc, floor(mean(temp))];
            vert_inds = vert_inds(vert_inds > max(temp));
        end
        
        %Loop through all vertical locations and set the local_dot values
        %to 0.
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
