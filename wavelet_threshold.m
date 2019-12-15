function [ t ] = wavelet_threshold(img, method)

t = -1;

switch method
    % Assumindo ruído Gaussiano, o VisuShrink deve ser o suficiente.
    % Portanto %sqrt(var(img(:)))
    % livro do Mallat, pag 454 (Choice of Threshold)
    case 'visushrink'
        t = sqrt(2*log(length(img(:)'))) * sqrt(var(img(:)));
        fprintf('D: VisuShrink: %.4f\n', t);
        
    case 'sure'
        t = thselect(img, 'rigrsure');
        fprintf('D: SURE: %.4f\n', t);
        
    case 'fundamental'
        t = thselect(img, 'sqtwolog');
        fprintf('D: Fundamental: %.4f\n', t);
        
    case 'sure+fundamental'
        t = thselect(img, 'heursure');
        fprintf('D: SURE+Fundamental: %.4f\n', t);
        
    case 'minimaxi'
        t = thselect(img, 'minimaxi');
        fprintf('D: Minimaxi: %.4f\n', t);
        
    % Median Absolute Deviation (MAD) gives an estimation
    % of the noise standard deviation: MAD = MED(| w1 |)/0.6745
    case 'mad'
        t = median(abs(img(:))) / 0.6745;
        fprintf('D: MAD: %.4f\n', t);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Casos de teste:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'otsu'
        t = graythresh(img);
        fprintf('D: Otsu: %.4f\n', t);

    otherwise
        fprintf('The selected method has not found!');
end


end

