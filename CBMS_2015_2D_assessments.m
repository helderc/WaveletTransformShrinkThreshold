clear all;
close all;
clc;

folder_list = {'50perc/', ...
               '70perc/', ... 
               '85perc/', ... 
               '100perc/'};
            
dose_list = {50, 70, 85, 100};
rls_list = {1, 2, 3, 4, 5};

% Esse esquema eh bom para pegar uma realizacao de uma determinada projecao %%%%%%%%%%%%%
% folder_list = {'Dose 85 Percent (Anthro)/'};
%             
% dose_list = {85};
% rls_list = {1};
%%%%%%%%%%%%%%%

tipo = 'Raw';
salvar_raw = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COORDENADAS (Observar o cluster a ser usado!):
%
% 1a maiores: (2709:3108, 117:516)
% 2a maiores: (2123:2634, 141:652) (512x512)
%
% Mama inteira: (380:3628, 13:1029)
%
% do [r]ecorte: (r_i_l:r_f_l, r_i_c:r_f_c)
r_i_l = 2123; r_f_l = 2634;
r_i_c = 141; r_f_c = 652;


% Medida p/ equipamento Hologic
offset_eqp = 43;
% ajuste dos niveis de cinza de uma imagem
% IDEAL - O fator eh baseado na dose
% ajuste = @(img, dose) (((img - offset_hologic) * (100/dose)) + offset_hologic);
% GAMBI - O fator eh baseado na media das duas imagens, GT e IMG
ajuste = @(img, fator) (((img - offset_eqp) * (fator)) + offset_eqp);


% o grountruth é sempre o mesmo para todos, 
% entao pode ser carregado antes
img_gt = double(imread('SPIE2015_2D_GT.tif'));

% Loop nas pastas de cada 'dose'
for i = 1:length(dose_list),
    % Nome fixo que ficara no inicio de todo arquivo
    canonical_name = sprintf('SPIE2015_2D_%dperc', dose_list{i});
    
    % folder = 'Full Dose (Anthro)/';
    folder = folder_list{i};
    
    % Salvando info da 'dose' e 'realizacao'
    r = [dose_list{i}];
    dlmwrite('assessments.csv', r, '-append', 'delimiter', ';');
    
    % Loop na lista de 'realizacoes' (rls)
    for j = 1:length(rls_list),
        % valor da j-esima realizacao
        rls = rls_list{j};
        
        % Nome do arquivo
        % ex: SPIE2015_2D_85perc_rls01_Raw.dcm
        file_name = sprintf('%s_rls%02d_%s.dcm', canonical_name, rls, tipo);
            
        % montagem do path completo
        % ex: 50perc/SPIE2015_2D_50perc_rls01_Raw.dcm
        path = sprintf('%s%s', folder, file_name);
            
        % leitura da:
        %           j-esima realizacao da,
        %           i-esima dose
        img = double(dicomread(path));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SALVANDO A IMAGEM COMO .tif
        %novo_nome = strcat(path(1:length(path)-3), 'tif');
        %imwrite(uint16(img), novo_nome);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Pega o recorte APENAS PARA AJUSTAR
        img_gt_rec = img_gt(r_i_l:r_f_l, r_i_c:r_f_c);
        img_rec = img(r_i_l:r_f_l, r_i_c:r_f_c);
        % AJUSTA ANTES!!!!!!!!!!!!!!!!
        % Ajuste dos niveis e compensacao da maquina
        % O ajuste deve ser feito apenas para imagens RAW, as PROC ja
        % estao ajustadas
        if (strcmp('Raw', tipo)),
            fator = mean(img_gt_rec(:)-offset_eqp) / mean(img_rec(:)-offset_eqp);
            img = ajuste(img, fator);  
        end
        
        % Só processa o recorte
        img_gt_rec = img_gt(r_i_l:r_f_l, r_i_c:r_f_c);
        img_rec = img(r_i_l:r_f_l, r_i_c:r_f_c);

            
        fprintf('[Dose: %d; Rls: %02d; Media: %f] >> %s\n', dose_list{i}, rls, mean(img_rec(:)), file_name);
        
        [~, r] = evaluation6(img_rec, img_gt_rec);

        % salvando no csv
        dlmwrite('assessments.csv', r, '-append', 'precision', '%f', 'delimiter', ';');
    end
end
    
fprintf('\n\nFinished!\n');