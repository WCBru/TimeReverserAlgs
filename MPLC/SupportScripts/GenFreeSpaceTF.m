function H = GenFreeSpaceTF(szX, szY, xLimits, yLimits, dist, lambda)
    if length(xLimits) ~= 2 || length(yLimits) ~= 2
        error("Limits must have two elements");
    end
    
    if numel(szX) ~= 1 || numel(szY) ~= 1 || ...
            numel(dist) ~= 1 || numel(lambda) ~= 1
        error("Sizes/Wavelength/Distance must be scalar");
    end

    % Generate spatial frequencies
    % Remember this is in freqeuncy domain
    % TODO: check if custom range is possible
    % Otherwise, replace diff with a pure range
    nuX = ( (-szX/2):(szX/2 - 1) ) /  abs(diff(xLimits));
    nuY = ( (-szY/2):(szY/2 - 1) ) /  abs(diff(yLimits));
    
    [nuMeshX, nuMeshY] = meshgrid(nuX, nuY);

    H = exp(-(1i * 2 * pi * dist) .* sqrt( ...
            lambda^(-2) - nuMeshX.^2 - nuMeshY.^2 ...
        ));
end