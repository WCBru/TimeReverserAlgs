function modes = CreateModeIndices(lowerIndex, upperIndex)
    triangNumber = upperIndex - lowerIndex + 2;
    modes = zeros(triangNumber * (triangNumber + 1) / 2, 2);
    index = 1;
    for m = lowerIndex:upperIndex
        for n = 0:floor(m / 2)
            modes(index, :) = [m - n, n];
            index = index + 1;
        end
    end
    modes(index:(2 * index - 2), :) = flip(modes(1:(index - 1), :), 2);
    modes = unique(modes, 'rows');
end