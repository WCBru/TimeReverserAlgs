function output = ApplyFreeSpace(inp, freeSpace)
    output = zeros(size(inp));

    % Possible tweak needed
    for dim = 1:size(inp, 3)
        output(:, :, dim) = fftshift(ifft2(fftshift( ...
            fftshift(fft2(fftshift(inp(:, :, dim)))) .* freeSpace)));
    end
end