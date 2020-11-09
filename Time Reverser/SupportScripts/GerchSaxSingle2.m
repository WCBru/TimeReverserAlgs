function [output] = GerchSaxSingle2(src, dest, rowRange, colRange, portion)
    if ~ismatrix(src) || ~ismatrix(dest)
        error('Both images must be 2D');
    end

    % FFT to far field
    output = fftshift(fft2(src));
    output = output / sqrt(sum(sum(output .* conj(output)))); % normalise
   
    % Scale discard region and add desired region
    output = output * (1 - portion);
    output(rowRange, colRange) = portion * dest(rowRange, colRange);
    
    output = ifft2(ifftshift(output));
    %output = output / sqrt(sum(sum(output .* conj(output)))); % normalise
end
