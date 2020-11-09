function masks = MPLC_Generate(numMasks, passes, inputImages, outputImages, freeSpaceTF, offset, masks)
    % If offset is NaN, Otsu will be used
    if any(size(inputImages) ~= size(outputImages))
        error("Input/Output sizes must match");
    end
    
    if ~exist('masks', 'var')
        masks = zeros(size(inputImages, 1), size(inputImages, 2), numMasks);
    end
        
    currIn = inputImages(:, :, :);
    currOut = ApplyFreeSpace(outputImages(:, :, :), conj(freeSpaceTF));
    w = 0;
    
    % Transform output image to first mask
    for m = (numMasks - 1):-1:1
        currOut = ApplyMaskToImages(currOut, masks(:, :, m + 1), freeSpaceTF, 0, 0);
    end
    
    for x = 1:passes
        % Forward
        for m = 1:numMasks            
            
            currCorr = sum(conj(currIn) .* (currOut), 3);
            
            if isnan(offset)
                thresh = graythresh(abs(currCorr)/max(max(abs(currCorr)))) * max(max(abs(currCorr)));
                currCorr(abs(currCorr) < thresh) = 0;
            else
                currCorr = currCorr + offset;
            end
            
            masks(:, :, m) = w * masks(:, :, m) + (1-w) * angle(currCorr);

            if m < numMasks % Prop forward, except at last mask
                currIn = ApplyMaskToImages(currIn, masks(:, :, m), freeSpaceTF, 1, 1);
                currOut = ApplyMaskToImages(currOut, masks(:, :, m + 1), freeSpaceTF, 0, 1);
            end
        end
        
        % At this point, input is before last mask, output is after last

        % Back - start at 1 back, since it would dupe the last mask
        for m = (numMasks - 1):-1:1
            currIn = ApplyMaskToImages(currIn, masks(:, :, m), freeSpaceTF, 1, 0);
            currOut = ApplyMaskToImages(currOut, masks(:, :, m + 1), freeSpaceTF, 0, 0);

            currCorr = sum(conj(currIn) .* (currOut), 3);
            
            % Update
            if isnan(offset)
                thresh = graythresh(abs(currCorr)/max(max(abs(currCorr)))) * max(max(abs(currCorr)));
                currCorr(abs(currCorr) < thresh) = 0;
            else
                currCorr = currCorr + offset;
            end
            
            masks(:, :, m) = w * masks(:, :, m) + (1-w) * angle(currCorr);
        end
        
        if isnan(offset)
            outputs = inputImages(:, :, :);
            for m = 1:numMasks
                outputs = ApplyMaskToImages(outputs, masks(:, :, m), freeSpaceTF, 1, 1);
            end

            for i = 1:size(outputs, 3)
                outputs(:, :, i) = outputs(:, :, i) / sqrt(sum(sum(abs(outputs(:, :, i)).^2)));
            end
            w = abs(sum(sum(sum(outputs .* conj(outputImages))))) / size(outputImages, 3);
        end
    end
end
