function [y] = model_3(x)
    y = zeros(size(x));
    for i = 1:length(x)
        if x(i) <= 1
            y(i) = exp(x(i) - 1);
        else
            y(i) = x(i);
        end
    end
end