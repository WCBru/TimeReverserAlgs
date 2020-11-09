function dots = CreateDotStrip(imageSize, dotWidth, numDots)
    actualWidth = dotWidth; % Change if reference coords are used
    xCenter = 0;
    ySpace = 2 / (numDots + 3);
    
    dots = zeros([imageSize, numDots]);
    [X, Y] = meshgrid(linspace(-1, 1, imageSize(2)), ...
        linspace(-1, 1, imageSize(1)));
    
    for mode = 2:(numDots + 1)
        yCenter = mode * ySpace - 1;
        dots(:, :, mode - 1) = exp(-0.5 / actualWidth^2 * (...
            (X-xCenter).^2 + (Y-yCenter).^2)); 
        % Normalise
        dots(:, :, mode - 1) = dots(:, :, mode - 1) / ...
            sqrt(sum(sum(dots(:, :, mode - 1) .* ...
            conj(dots(:, :, mode - 1)))));
    end
end