clear all;
close all;
clc;

folder_list = {'../SPIE2015_Mammo2D/50perc/', ...
               '../SPIE2015_Mammo2D/70perc/', ... 
               '../SPIE2015_Mammo2D/85perc/', ... 
               '../SPIE2015_Mammo2D/100perc/'};
            
dose_list = {50, 70, 85};
rls_list = {1, 2, 3, 4, 5};

factor_list = {0.62, 0.83, 0.93};

% Esse esquema eh bom para pegar uma realizacao de uma determinada projecao %%%%%%%%%%%%%
% folder_list = {'../SPIE2015_Mammo2D/85perc/'};
%             
% dose_list = {85};
% rls_list = {1, 2, 3, 4, 5};
% factor_list = {0.93};
%%%%%%%%%%%%%%%

nps2d = cell(length(dose_list), 1);
nnps1d = cell(length(dose_list), 1);
f = cell(length(dose_list), 1);

tipo = 'Raw';
salvar_rec_antes = 0;
salvar_rec_proc = 0;

delete('assessments.csv');

% o grountruth é sempre o mesmo para todos, 
% entao pode ser carregado antes
img_gt = double(imread('../SPIE2015_Mammo2D/SPIE2015_2D_GT.tif'));

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
        
        % Só processa o recorte
        img_gt_rec = img_gt(2709:3108, 117:516);
        img_rec = img(2709:3108, 117:516);
                                    
        % Ajuste dos niveis e compensacao da maquina
        img_rec = ajuste_offset_equipamento_dose(img_rec, img_gt_rec, dose_list{i});
            
        fprintf('[Dose: %d; Rls: %02d; Media: %f] >> %s\n', dose_list{i}, rls, mean(img_rec(:)), file_name);
        
        [~, r] = evaluation5(img_rec, img_gt_rec);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Denoising
        img_rec_proc = wavelet_denoising(img_rec, factor_list{i});
        
        if (salvar_rec_proc == 1)
            novo_nome = path(1:length(path)-4);
            imwrite(uint16(img_rec_proc), sprintf('%s_Rec_Wavelet.tif', novo_nome));
        end
        
        if (salvar_rec_antes == 1)
            novo_nome = path(1:length(path)-4);
            imwrite(uint16(img_rec), sprintf('%s_Rec_Antes.tif', novo_nome));
        end
        
        [~, r] = evaluation5(img_rec_proc, img_gt_rec);
%         [nps2d{i}, nnps1d{i}, f{i}] = NPS_Lucas3(img_rec_proc, 0, 64, 0.07);

        % salvando no csv
        dlmwrite('assessments.csv', r, '-append', 'precision', '%f', 'delimiter', ';');
    end
end
    
% img_100 = double(dicomread('../SPIE2015_Mammo2D/100perc/SPIE2015_2D_100perc_rls01_Raw.dcm'));
% img_100_rec = img_100(2709:3108, 117:516);
% [nps2d{4}, nnps1d{4}, f{4}] = NPS_Lucas3(img_100_rec, 0, 64, 0.07);
% 
% % PLOT
% inicio = 64/2+1;
% fim = 64;
% semilogy(f{1}(inicio:fim), nnps1d{1}, '*-b', ... 
%         f{2}(inicio:fim), nnps1d{2}, '*-g', ...
%         f{3}(inicio:fim), nnps1d{3}, '*-r', ...
%         f{4}(inicio:fim), nnps1d{4}, '*-k'),
% xlim([1 8]),
% ylim([.8e-6 0.00002]),
% legend('50%', '70%', '85%', '100%');
        
fprintf('\n\nFinished!\n');