function coeffs = CalculateImageCoeffs(modes, imageNames, modeSize, showFlag)

    modeCount = size(modes, 3);
    coeffs = zeros(modeCount, length(imageNames));
    for im = 1:length(imageNames)
        rawImage = double(imread(convertStringsToChars(imageNames(im)))) / 255;
        
        if size(rawImage, 3) == 3
            image = rgb2gray(rawImage);
        else
            image = rawImage;
        end
        
        image = imresize(image, modeSize);
        image = image / sqrt(sum(sum((image.* conj(image)))));
        
        for mode = 1:modeCount
            coeffs(mode, im) = sum(sum(modes(:, :, mode) .* image));
        end
        
        % Showing image
        if showFlag
            reconImage = zeros(size(image));
            for mode = 1:size(modes, 3)
                reconImage = reconImage + ...
                    modes(:, :, mode) * coeffs(mode, im);
            end
            figure; imshow(reconImage);
        end     
    end
end