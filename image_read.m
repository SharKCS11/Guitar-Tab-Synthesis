clear all;
filename = 'Training1.jpg';
image = imread(filename);

%Create grayscale image
image_gray = rgb2gray(image);

%Create inverse binary image. 1 corresponds to a nonwhite pixel. Inverse
%binary better for convolutions
image_binary = 1 - imbinarize(image_gray);
[row_num, col_num] = size(image_binary);

%Get image edges to determine positions of horizontal lines
image_edges = edge(image_gray, 'Canny');

%Find horizontal line locations for strings
    %Since the edges returns a binary image, summing horizontally should 
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

%Plot horizontal and vertical line locations
figure(1)
subplot(2, 1, 1); plot(summed_horz, 1:length(summed_horz))
subplot(2, 1, 2); plot(summed_vert)


%Import pictures of numbers to serve as the ground truth for convolution
true_0 = 1 - imbinarize(rgb2gray(imread('0.jpg')));
% true_1 = imread('1.jpg');
% true_2 = imread('2.jpg');
% true_3 = imread('3.jpg');
% true_4 = imread('4.jpg');
% true_5 = imread('5.jpg');
% true_6 = imread('6.jpg');
% true_7 = imread('7.jpg');
% true_8 = imread('8.jpg');
% true_9 = imread('9.jpg');

%Get size of the true_0 image.
[true0_rows, true0_cols] = size(true_0);

%Declare matrices that store the value of the local convolution and
%localized region
%localized_region - the image around each string used for convolution. Same
%height as test image, centered about a string location.
localized_region = zeros(true0_rows, col_num, length(string_loc));
local_conv = zeros(1, col_num - true0_cols - 1, length(string_loc));


for i = 1:length(string_loc)
    first_ind = string_loc(i) - floor(true0_rows / 2);
    second_ind = string_loc(i) + ceil(true0_rows / 2) - 1;
    %Create a region of same height as test image centered about each
    %string location
    localized_region(:, :, i) = image_binary(first_ind : second_ind, :);
    
    %Perform "convolution". Instead of flip and shift, just shift test
    %image across the created localized_region and sum the product
    for j = 1:col_num - true0_cols - 1
        local_area = localized_region(:, j:j+true0_cols-1, i);
        local_conv(1, j, i) = sum(sum(local_area .* true_0));
    end
    
    %The convolution yields positive values for locations that are not 0s.
    %Filter out these locations by only considereing locations that have
    %convolution values larger than 0.75 the maximum value of the
    %convolution. 0.75 is arbitrary, works well. 0.5 yielded some false
    %positives.
    max_conv_val = max(local_conv(:, :, i));
    local_conv(:, :, i) = (local_conv(:, :, i) > 0.75 * max_conv_val);
end



