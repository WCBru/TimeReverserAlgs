function im = CreateInputPlane(targetImage)
    [~, inpY] = meshgrid(linspace(-1, 1, size(targetImage, 2)), ...
    linspace(-1, 1, size(targetImage, 1)));
    im = exp(-0.5*(inpY/0.3).^2);
    im = im / sqrt(sum(sum(im .* conj(im))));
  end