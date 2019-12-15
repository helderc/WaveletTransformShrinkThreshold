function img = wavelet_rec(cA, cH, cV, cD, levels, wavename, tams)

    % Get the LAST aproximation
    img = cA{levels};
    
    for l = levels:-1:1,
        a = size(cA{l});
        b = size(cH{l});
        c = size(cV{l});
        d = size(cD{l});
        e = size(img);
        %fprintf('img: [%d,%d] ~ ', e(1), e(2));
        %fprintf('[%d,%d] [%d,%d] [%d,%d] [%d,%d]', a(1), a(2), b(1), b(2), c(1), c(2), d(1), d(2));
        % Decimada
        %img = idwt2(img, cH{l}, cV{l}, cD{l}, wavename, tams(l,:));
        % Nao-Decimada (Estacionaria)
        img = iswt2(img, cH{l}, cV{l}, cD{l}, wavename);
        %disp(l);
    end
end