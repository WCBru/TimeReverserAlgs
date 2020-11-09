function [mdlDB, insertDB, transfer] = LossCalculation(ideal, meas)
    if ~all(size(ideal) == size(meas))
        error("Ideal and measured modes must be the same size");
    end
    
    % Normalise ideal and meas, then calculate coupling matrix
    % Assume same number of modes
    transfer = NaN(size(ideal, 3));
    for mode = 1:size(ideal, 3)
        idealMode = ideal(:, :, mode);
        ideal(:, :, mode) = idealMode / ...
            sqrt(sum(sum(idealMode .* conj(idealMode))));
        measMode = meas(:, :, mode);
        meas(:, :, mode) = measMode / ...
            sqrt(sum(sum(measMode .* conj(measMode))));
    end
    
    for mode = 1:size(ideal, 3)
        for mode2  = 1:size(ideal, 3)
            transfer(mode, mode2) = sum(sum(...
                conj(meas(:, :, mode)) .* ideal(:, :, mode2)));
        end
    end
    
    [~, S, ~] = svd(transfer);
    Sdiag = diag(S) .^2;
    mdlDB = 10*log10(Sdiag(end) / Sdiag(1));
    insertDB = 10*log10(mean(Sdiag));
end