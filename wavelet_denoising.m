function [ img_out ] = wavelet_denoising(img, factor)

    wave_name = 'db4';
    nivel_dec = 5;
    anscombe = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ANSCOMBE -> FORWARD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (anscombe == 1)
        img_2_proc = Anscombe_forward(img);
    else
        img_2_proc = img;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Wavelet Forward
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % X% da dose
    [cA_X, cH_X, cV_X, cD_X, tams_X] = wavelet_dec(img_2_proc, nivel_dec, wave_name);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THRESHOLDING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        % factor = 0.7;

        for iR = 1:1:C
            for iC = 1:1:R

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
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reconstruction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img = wavelet_rec(cA_X, cH_X, cV_X, cD_X, ...
                    nivel_dec, wave_name, tams_X);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ANSCOMBE <- INVERSE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if anscombe == 1,
        img = Anscombe_inverse_exact_unbiased(img);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Recortes onde existem microcalcificacoes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img_out = img;
end