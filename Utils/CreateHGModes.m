function modes = CreateHGModes(modeVector, imageDim, beamWidth)
    if size(modeVector, 1) == 0
        error('No modes specified');
    end
        
    if size(modeVector, 2) ~= 2 || ~ismatrix(modeVector)
        error('Expected Nx2 Matrix');
    end
    
    if length(imageDim) ~= 2
        error('Expected Image Size array of length 2');
    end
    
    modes = zeros([imageDim, size(modeVector, 1)]);
    domainX = linspace(-1, 1, imageDim(2));
    domainY = linspace(-1, 1, imageDim(1));
    [x, y] = meshgrid(domainX, domainY);
    
    hermiteScale = sqrt(2) / beamWidth;
    xdegrees = unique(modeVector(:, 1)); % Get all polys needed
    ydegrees = unique(modeVector(:, 2));
    degrees = unique([xdegrees; ydegrees]);
    syms p; hermitePolys = hermiteH(degrees, p);
    
    % Calculate x-axis Hermite Poly values (for all degrees)
    xData = zeros(length(xdegrees), length(domainX));
    for m = 1:length(xdegrees)
        xData(m, :) = subs(hermitePolys(find(degrees == xdegrees(m), 1)), ...
            hermiteScale * domainX);
    end
    
    % Calculate y-axis Hermite Poly values (for all degrees)
    yData = zeros(length(ydegrees), length(domainY));
    for m = 1:length(ydegrees)
        yData(m, :) = subs(hermitePolys(find(degrees == ydegrees(m), 1)), ...
            hermiteScale * domainY);
    end
    
    gaussBase = exp( -((x.^2 + y.^2)/beamWidth.^2) );
    for m = 1:size(modeVector, 1)
        modes(:, :, m) = gaussBase(:, :);
        [xMesh, yMesh] = meshgrid( xData(find(xdegrees == modeVector(m, 1), 1) , :), ...
            yData(find(ydegrees == modeVector(m, 2), 1), :));
        modes(:, :, m) = modes(:, :, m) .* xMesh .* yMesh;
        modes(:, :, m) = modes(:, :, m) / ...
            sqrt(sum(sum(modes(:, :, m) .* conj(modes(:, :, m)))));
    end
end