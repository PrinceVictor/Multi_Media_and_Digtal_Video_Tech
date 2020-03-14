%{
Name: Hongbin Zhou
Stu.ID: 3119305524
this is the MATLAB code for DCT Assignment 
of the Course Mulitmedia and Digtal Video Tech 
%}
% clear and close all
clear;close;clc;

% load the image, this image is from KITTI Dataset
source_image = imread("images/source_img.png");

% show source rgb image
% figure('name','source image')
% imshow(source_image);

% convert rgb into gray
gray_img = rgb2gray(source_image);
[rows, cols] = size(gray_img);

% resize to times of 8
rows = floor(rows/8)*8;
cols = floor(cols/8)*8;
gray_img = gray_img(1:rows ,1:cols) ;

% show resized gray image
% figure('name','resized gray image')
% imshow(gray_img);

% change uin8 into float and shit from -128~127
double_gray = double(gray_img) - 128;

% get the DCT 8x8 matrix 
%  dct_result = A*f(x,y)*A'
A_matrix = dct8x8_matrix(8);

% define and get the DCT transform batch 8x8 result
% get dct batch size = (rows/8) * (cols/8)
dct_batch_result = zeros( 8, 8, rows/8, cols/8);
for index_row = 1:8:rows
    for index_col = 1:8:cols
        batch_img = double_gray(index_row: index_row+7, index_col:index_col+7);
        dct_batch_result( :, :, ceil(index_row/8), ceil(index_col/8)) = A_matrix*batch_img*A_matrix';
    end
end

% define and get quantization result matrix
% get the quantization table
quanti_table = quantization_table;

% define further quantization coefficients vector
% due to the source image with high resolution, so I selected some large
% coefficients to make the differences visualisable
quanti_coef = [0.5, 1.0, 10.0, 25.0, 50.0, 100.0]';
quanti_coef_length = length(quanti_coef);
quantization_result = zeros( 8, 8, rows/8, cols/8, quanti_coef_length);

for index_coef = 1:quanti_coef_length
    coef_quanti = quanti_table*quanti_coef(index_coef);
    for index_row = 1:8:rows
        for index_col = 1:8:cols
            temp = dct_batch_result( :, :, ceil(index_row/8), ceil(index_col/8))./coef_quanti;
            quantization_result( :, :, ceil(index_row/8), ceil(index_col/8), index_coef) = round(temp);
        end
    end
end

% Attention here the 5 dimension matrix " quantization_result " storage
% the quantization result with size 8x8x(rows/8)x(cols/8)xsizeof(quanti coeffient)

% create recovered dct matrix correspoding to coefficient
recovered_dct = zeros(8, 8, rows/8, cols/8, quanti_coef_length);
recovered_img = uint8( zeros(rows, cols, quanti_coef_length));

% revovery by inverse DCT transform
% get the inverse of A_matrix
A_inverse = inv(A_matrix);
A_inverse_trans = inv(A_matrix');
for index_coef = 1:quanti_coef_length
    coef_quanti = quanti_table*quanti_coef(index_coef);
    for index_row = 1:8:rows
        for index_col = 1:8:cols
            temp = quantization_result( :, :, ceil(index_row/8), ceil(index_col/8), index_coef).*coef_quanti;
            recovered_dct( :, :, ceil(index_row/8), ceil(index_col/8), index_coef) = temp;
            
%             batch_img = A_inverse*temp*A_inverse_trans + 128;
            batch_img = A_matrix\temp/A_matrix' + 128;
            recovered_img(index_row: index_row+7, index_col:index_col+7, index_coef) = ...
                uint8(batch_img);
        end
    end
end

% Show result 
% By default, I comment the imwrite function
figure('name', "quanti coef results");
for index_coef = 1:quanti_coef_length
    % our evaluation with RMSE
    difference = double(recovered_img(:, :, index_coef)) - double(gray_img);
    quanti_mse = sum(sum(difference.^2))/(rows*cols);
    quanti_rmse = sqrt(quanti_mse);
    % our evalution with Frobenius Nom
    fro_norm = norm(difference, 'fro');
    
    subplot(3, 2, index_coef, 'position', ...
        [(0.5*rem(index_coef-1, 2))+0.05, 0.33*(2 -floor((index_coef-1)/2)), 0.4, 0.3]);
    imshow(recovered_img(:, :, index_coef));
    title( "coef " +string(quanti_coef(index_coef))+ ...
        " rmse: " + string(quanti_rmse) + ...
        " norm: "+ string(fro_norm));
%     imwrite(recovered_img(:, :, index_coef), "images/quanti_coef_ " +string(quanti_coef(index_coef))+".png");
end

% Dircetly cope with DCT coefficients as below
% defince the range of DCT coef
dct_range = [1, 2, 4, 8]';
dct_range_length = length(dct_range);
dct_coef_matrix = zeros(8, 8,  rows/8, cols/8, dct_range_length);
dct_recoverd_img = uint8( zeros(rows, cols, dct_range_length));

for index_coef = 1:dct_range_length
    for index_row = 1:8:rows
        for index_col = 1:8:cols
            temp = dct_batch_result( :, :, ceil(index_row/8), ceil(index_col/8));
            temp_batch = zeros(8, 8);
            temp_batch(1:dct_range(index_coef), 1:dct_range(index_coef)) = ...
                temp(1:dct_range(index_coef), 1:dct_range(index_coef));
            
%             batch_img = A_inverse*temp*A_inverse_trans + 128;
            batch_img = A_matrix\temp_batch/A_matrix' + 128;
            dct_recoverd_img(index_row: index_row+7, index_col:index_col+7, index_coef) = ...
                uint8(batch_img);
        end
    end
end

% show the keep differet dct coefficients results
% evaluate the result by using rmse
figure('name', "dct coef result");
for index_coef = 1:dct_range_length
    % our evaluation with RMSE
    difference = double(dct_recoverd_img(:, :, index_coef)) - double(gray_img);
    dct_mse = sum(sum(difference.^2))/(rows*cols);
    dct_rmse = sqrt(dct_mse);
    % our evalution with Frobenius Nom
    fro_norm = norm(difference, 'fro');
    
    subplot(2, 2, index_coef, 'position', ...
        [(0.5*rem(index_coef-1, 2))+0.05, 0.5*( 1-floor((index_coef-1)/2))+0.05, 0.4, 0.4]);
    imshow(dct_recoverd_img(:, :, index_coef));
    title( "range: " +string(dct_range(index_coef))+"x"+string(dct_range(index_coef)) + ...
        " rmse: " + string(dct_rmse) + ...
        " norm: " + string(fro_norm));
%     imwrite(dct_recoverd_img(:, :, index_coef), "images/dct_range_ " +string(dct_range(index_coef))+".png");
end


