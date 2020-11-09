function imageOut = ComplexImage(image)
    image = squeeze(image);
    imageOut = angle(image) / (2 * pi) + 0.5; % 0 to 1 hsv
    imageOut(:, :, 2) = ones(size(image));
    if all(abs(image) == 0)
        imageOut(:, :, 3) = zeros(size(image));
    else
        imageOut(:, :, 3) = abs(image) / max(max(abs(image)));
    end
    
    imageOut = hsv2rgb(imageOut);
end  