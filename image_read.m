clear all;

%filename = input('Input a filename: ', 's');
filename = 'Tab_No_Lines.jpg';
image = imread(filename);

image_binary = rgb2gray(image);
image_edges = edge(image_binary, 'Prewitt');

%Find Horizontal edges
summed_horz = sum(image_edges, 2);
summed_horz = (summed_horz >= 0.5 * max(summed_horz)) .* summed_horz;

[horz_val, horz_line_loc] = findpeaks(summed_horz);

summed_vert = sum(image_edges, 1);
summed_vert = (summed_vert >= 0.5 * max(summed_vert)) .* summed_vert;
figure(1)
subplot(2, 1, 1); plot(summed_horz)
subplot(2, 1, 2); plot(summed_vert)

%image_edges(horz_line_loc, :) = 0;
%imshow(image_edges)

I = ocr(image_edges, 'CharacterSet', '0123456789');

Iocr = insertObjectAnnotation(image_binary, 'rectangle', I.WordBoundingBoxes, I.WordConfidences);
figure; imshow(Iocr)

% imshow(image_edges)
% [H, theta, rho] = hough(image_edges, 'Theta', -90:0.5:-85);
% 
% H_peaks = houghpeaks(H, 50, 'threshold', 0.5 .* max(H(:)));
% H_lines = houghlines(image_edges, theta, rho, H_peaks, 'FillGap', 1, 'MinLength', 1);
% 
% figure, imshow(image_edges), hold on
% max_len = 0;
% for k = 1:length(H_lines)
%     xy = [H_lines(k).point1; H_lines(k).point2];
%     plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
%     
%     plot(xy(1,1),xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
%     plot(xy(2,1),xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
% 
%     len = norm(H_lines(k).point1 - H_lines(k).point2);
%     if(len > max_len)
%         max_len = len;
%         xy_long = xy;
%     end
% end
% 
% plot(xy_long(:,1), xy_long(:,2), 'LineWidth', 2, 'Color', 'red');
