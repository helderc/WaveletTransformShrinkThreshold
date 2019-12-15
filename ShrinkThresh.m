function [ img ] = ShrinkThresh(img, t, factor)
    % Shrink-Thresholding
    % x = -2:0.01:2;
    % y = ShrinkThresh(x, 1, 0.5);
    % plot(x,y)
    
    for i = 1:1:length(img)
        v = abs(img(i));
        if (v < t)
            img(i) = img(i) * factor;
        end
    end
end

