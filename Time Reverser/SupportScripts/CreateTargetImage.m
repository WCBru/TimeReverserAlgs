function output = CreateTargetImage(imSize, template, coeffs, vertStart, horistart, numModes)
    output = zeros(imSize);
    tSize = size(template);
    dotCapacity = floor((size(output) - [vertStart, horistart]) ./ tSize);
    for im = 1:min(size(coeffs, 2), dotCapacity(2))
        for m = 1:numModes
            % These long statements are to obtain the interval for the dot
            output((vertStart + tSize(1) * m):(vertStart + tSize(1) * (m + 1) - 1), ...
                (horistart + tSize(2) * im):(horistart + (tSize(2) * (im + 1) - 1))) = ...
                template * coeffs(m, im); % This statement sets the dot
        end
    end
    
    output = output / sqrt(sum(sum((output .* conj(output)))));
end