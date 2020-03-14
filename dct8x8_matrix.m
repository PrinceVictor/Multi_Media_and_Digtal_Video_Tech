function A_Matrix = dct8x8_matrix(dimension)
%DCT8_MATRIX 此处显示有关此函数的摘要
%   此处显示详细说明
pi = 3.1415926;

A_Matrix = zeros(dimension);

for rows = 1:dimension
    for cols = 1:dimension
        
% define C(u)
        if rows == 1
            coefficient = 1/sqrt(2);
        else
            coefficient = 1;
        end
        
        temp = 2*(cols-1)+1;
        temp = temp*(rows-1)*pi/(dimension*2);
        
        A_Matrix(rows, cols) = cos(temp) * coefficient;
    end
    
end
end

