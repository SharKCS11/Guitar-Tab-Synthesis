clear all; close all;
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
%subplot(2, 1, 1); 
plot(summed_horz)
title('Horizontal Line Detection')
xlabel('Vertical position of string lines in image')
%subplot(2, 1, 2); plot(summed_vert)


%Import pictures of numbers to serve as the ground truth for convolution
true_0 = 1 - imbinarize(rgb2gray(imread('0.jpg')));
true_1 = 1 - imbinarize(rgb2gray(imread('1.jpg')));
true_2 = 1 - imbinarize(rgb2gray(imread('2.jpg')));
% true_3 = imread('3.jpg');
% true_4 = imread('4.jpg');
% true_5 = imread('5.jpg');
% true_6 = imread('6.jpg');
% true_7 = imread('7.jpg');
% true_8 = imread('8.jpg');
% true_9 = imread('9.jpg');

%Get size of the true_0 image.
[true0_rows, true0_cols] = size(true_0);

%Call localized_dot_product to retrieve location of 0s for each localized
%region
[localized_region0, locations0] = localized_dot_product(image_binary, true_0, string_loc);
[localized_region1, locations1] = localized_dot_product(image_binary, true_1, string_loc);
[localized_region2, locations2] = localized_dot_product(image_binary, true_2, string_loc);


