clc;
clear all;
close all;

wave_name = 'db1';
nivel_dec = 5;
nivel_analise = 5;
anscombe = 1;

plot_coeff = 0;
plot_meand_std = 0;

base_folder = 'SPIE2015_Mammo2D/';
folder_list = {'50perc/', ...
               '70perc/', ... 
               '85perc/', ... 
               '100perc/'};
           
dose_list = {50, 70, 85, 100};
rls_list = {1, 2, 3, 4, 5};
           
img_100 = double(imread('projMarcelo50perc_100%_NoNoise_r1.tif'));
img_25 = double(imread('projMarcelo50perc_25%_Noise_quarterDose_r1.tif'));
img_50 = double(imread('projMarcelo50perc_50%_Noise_halfDose_r1.tif'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ajustes de Offset e Dose
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img_25 = ajuste_offset_equipamento_dose(img_25, img_100, 25);
img_50 = ajuste_offset_equipamento_dose(img_50, img_100, 50);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotando média e desvio padrão
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (plot_meand_std == 1)
    plot_mean_std(img_25, '25%', ...
                  img_50, '50%', ...
                  img_100, '100%');
end
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% figure, imshow(1-mat2gray(img_25), []), title('Noisy');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANSCOMBE -> FORWARD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if anscombe == 1,
    img_25 = Anscombe_forward(img_25);
    img_100 = Anscombe_forward(img_100);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wavelet Forward
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% X% da dose
%[c25, s25] = wavedec2(img25, nivel_dec, wave_name);
[cA_X, cH_X, cV_X, cD_X, tams_X] = wavelet_dec(img_25, nivel_dec, wave_name);

% Ground
%[cGround, sGround] = wavedec2(imgGround, nivel_dec, wave_name);
[cA_Ground, cH_Ground, cV_Ground, cD_Ground, tams_Ground] = wavelet_dec(img_100, nivel_dec, wave_name);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotando os COEFICIENTES ---> ANTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (plot_coeff == 1)
    wavelet_plot_coef_2d('25% (Antes)', ...
                  abs(cA_X{nivel_analise}), ...
                  abs(cH_X{nivel_analise}), ...
                  abs(cV_X{nivel_analise}), ...
                  abs(cD_X{nivel_analise}), ...
                  'Ground (Antes)', ... 
                  abs(cA_Ground{nivel_analise}), ...
                  abs(cH_Ground{nivel_analise}), ...
                  abs(cV_Ground{nivel_analise}), ...
                  abs(cD_Ground{nivel_analise}), ...
                  0,0,0);
end



 for nivel = 1:1:nivel_dec,
    fprintf('\n-> Nivel: %d\n', nivel);
     
    % k == 3, citado no livro do Starck
    % |w| <= k*sigma  <--- threshold 
    k = 1.5;
    
    % Threshold local, na sub-banda
    t_h = wavelet_threshold(cH_X{nivel}, 'visushrink') * k;
    t_v = wavelet_threshold(cV_X{nivel}, 'visushrink') * k;
    t_d = wavelet_threshold(cD_X{nivel}, 'visushrink') * k;

    % H-Threshold
    % Escala os coeficientes dentro do intervalo de threshold: [-t, t]
    [R, C] = size(cH_X{nivel});
    
    % Fator de Shrinkage dos coeficientes
    factor = 0.4;
    
    for iR = 1:1:R
        for iC = 1:1:C
            
            v1 = abs(cH_X{nivel}(iC, iR));
            v2 = abs(cV_X{nivel}(iC, iR));
            v3 = abs(cD_X{nivel}(iC, iR));
            
            if (v1 < t_h)
                cH_X{nivel}(iC, iR) = (cH_X{nivel}(iC, iR)) * factor;
            end
            if (v2 < t_v)
                cV_X{nivel}(iC, iR) = (cV_X{nivel}(iC, iR)) * (factor);
            end
            if (v3 < t_d)
                cD_X{nivel}(iC, iR) = (cD_X{nivel}(iC, iR)) * factor;
            end
            
        end
    end

%     cH25{nivel} = wthresh(cH25{nivel}, 's', t1);
%     cV25{nivel} = wthresh(cV25{nivel}, 's', t2);
%     cD25{nivel} = wthresh(cD25{nivel}, 's', t3);
end



% figure, plot(reshape(cH25{nivel_analise}, 1, [])), title('25% (H)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotando os COEFICIENTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (plot_coeff == 1)
    wavelet_plot_coef_2d('25%', ...
                      abs(cA_X{nivel_analise}), ... 
                      abs(cH_X{nivel_analise}), ...
                      abs(cV_X{nivel_analise}), ...
                      abs(cD_X{nivel_analise}), ...
                      'Ground Truth', ... 
                      abs(cA_Ground{nivel_analise}), ...
                      abs(cH_Ground{nivel_analise}), ...
                      abs(cV_Ground{nivel_analise}), ...
                      abs(cD_Ground{nivel_analise}), ...
                      t_h, t_v, t_d);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

img = wavelet_rec(cA_X, cH_X, cV_X, cD_X, ...
                nivel_dec, wave_name, tams_X);
            
img_100 = wavelet_rec(cA_Ground, cH_Ground, cV_Ground, cD_Ground, ...
                        nivel_dec, wave_name, tams_Ground);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANSCOMBE <- INVERSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if anscombe == 1,
    img = Anscombe_inverse_exact_unbiased(img);
    img_25 = Anscombe_inverse_exact_unbiased(img_25);
    img_100 = Anscombe_inverse_exact_unbiased(img_100);
end


% img100 = double(imread('projMarcelo50perc_100%_Noise_r1.tif'));
% h = fspecial('average');
% imgAVG = imfilter(img_25,h);
% figure, imshow(1-mat2gray(imgAVG), []), title('AVG');




figure, imshow(1-mat2gray(img)), title('Denoised');
figure, imshow(1-mat2gray(img_25), []), title('Noisy');
figure, imshow(1-mat2gray(img_100), []), title('100%');

% fprintf('Diference: %.10f\n', max(max(abs(img-img25))))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recortes onde existem microcalcificacoes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img25Rec = img_25(50:129, 85:164);
imgRec = img(50:129, 85:164);
imgGroundRec = img_100(50:129, 85:164);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluation (ANTIGO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L = max(img100(:));
fprintf('\nRecortes: Noisy vs Ground\n');
evaluation5(img25Rec, imgGroundRec);
% 
fprintf('\nRecortes: Restored vs Ground\n');
evaluation5(imgRec, imgGroundRec);
% 
% imgAVGRec = imgAVG(50:129, 85:164);
% evaluation4(imgAVGRec, imgGroundRec);

% fprintf('\nRestored vs 25%%\n');
% evaluation3(img, img25, L);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotando média e desvio padrão
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (plot_meand_std == 1)
    plot_mean_std(img_25, '25%', ...
                  img, '25% Depois', ...
                  img_100, '100%');
end

%figure,
%subplot(2,2,1); imshow(cA25{nivel_analise}, []), title('Aproximacao');
%subplot(2,2,2); imshow(cH25{nivel_analise}, []), title('Horizontal');
%subplot(2,2,3); imshow(cV25{nivel_analise}, []), title('Vertical');
%subplot(2,2,4); imshow(cD25{nivel_analise}, []), title('Diagonal');