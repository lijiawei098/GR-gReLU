function [y] = GRAEReLU(x, BETA)
    y = zeros(size(x));
    for i = 1:length(x)
        if x(i) <= 0
            y(i) = exp(x(i)) / (1 + BETA);
        else
            y(i) = x(i) + exp(-1 * BETA * x(i)) / (1 + BETA);
        end
    end
end