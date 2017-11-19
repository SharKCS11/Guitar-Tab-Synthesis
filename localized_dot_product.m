%Inputs: original image, feature_image, horz. string locations 
%Outputs: localized regions, local convolutions

function [localized_region, local_conv] = localized_dot_product(image_binary, feature_binary, string_loc)

    [row_num, col_num] = size(image_binary);
    [feature_rows, feature_cols] = size(feature_binary);

    %Declare matrices that store the value of the local convolution and localized region
    %localized_region - the image around each string used for convolution. Same
    %height as test image, centered about a string location.
    localized_region = zeros(feature_rows, col_num, length(string_loc));
    local_conv = zeros(1, col_num - feature_cols - 1, length(string_loc));
    
    for i = 1:length(string_loc)
        first_ind = string_loc(i) - floor(feature_rows / 2);
        second_ind = string_loc(i) + ceil(feature_rows / 2) - 1;
        %Create a region of same height as test image centered about each
        %string location
        localized_region(:, :, i) = image_binary(first_ind : second_ind, :);

        %Perform "convolution". Instead of flip and shift, just shift test
        %image across the created localized_region and sum the product
        for j = 1:col_num - feature_cols - 1
            local_area = localized_region(:, j:j+feature_cols-1, i);
            local_conv(1, j, i) = sum(dot(local_area, feature_binary));
        end

        %The convolution yields positive values for locations that are not 0s.
        %Filter out these locations by only considereing locations that have
        %convolution values larger than 0.75 the maximum value of the
        %convolution. 0.75 is arbitrary, works well. 0.5 yielded some false
        %positives.
        max_conv_val = max(local_conv(:, :, i));
        local_conv(:, :, i) = (local_conv(:, :, i) > 0.75 * max_conv_val) .* local_conv(:, :, i);
    end
end