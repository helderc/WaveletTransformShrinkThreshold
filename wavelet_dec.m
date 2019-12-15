% ------------------------------------------------------------------------------
%
% Author: Helder C. R. Oliveira 
%
% Copyright (c) Helder Oliveira, 2015
% Email: heldercro@gmail.com
%
% ------------------------------------------------------------------------------

function [cA, cH, cV, cD, tams] = wavelet_dec(img, levels, wavename)

    % Approximation
    cA = cell(1, levels);
    
    % Horizontal
    cH = cell(1, levels);
    
    % Vertical
    cV = cell(1, levels);
    
    % Diagonal
    cD = cell(1, levels);

    image_ini = img;
    
    % Guardando as Dimensoes
    tams = size(img);
    
    % Aplly the decompositions extracting the coefficients
    for level = 1:levels,  
        % Nao-decimada (estacionaria)
        [cA{level}, cH{level}, cV{level}, cD{level}] = swt2(image_ini, 1, wavename);
        % Decimada
        %[cA{level}, cH{level}, cV{level}, cD{level}] = idwt2(image_ini, wavename);
        tams = [tams; size(cH{level})];
        image_ini = cA{level};
    end
end