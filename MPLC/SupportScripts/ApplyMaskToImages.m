function output = ApplyMaskToImages(images, mask, spaceProp, waveForward, propForward)
    % Require different cases:
    % waveForward: for if the wave is travelling forward from input
    % propForward: for if the wave is being propagated forward or back

    if nargin < 4
        waveForward = 1; 
    end
    
    if nargin < 5
        propForward = 1;
    end

    if size(mask, 3) > 1
        error("Mask must be 2D array");
    end
        
    % Invert masks if wave is going in the opposite direction
    % Will be undone later if the wave is backwards, in reverse
    if ~waveForward
        mask = -mask;
        spaceProp = conj(spaceProp);
    end
    
    % If wave direction and direction to prop are the same, mask first
    % If wave is travelling backwards, already inverted
    if (waveForward == propForward) % Mask first
        output = images .*  repmat(exp(1i .* mask), 1, 1, size(images, 3));
        output = ApplyFreeSpace(output, spaceProp);
    % For else, if wave is travelling forward, but moving moving back, inv
    % If backward wave (i.e. output) moving forward, inversion is undone
    else
        output = ApplyFreeSpace(images, conj(spaceProp));
        output = output .*  repmat(exp(1i .* -mask), 1, 1, size(images, 3));
    end
end