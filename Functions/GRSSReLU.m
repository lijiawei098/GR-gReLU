% 定义激活函数
function [y] = model_1(x)
    y = log(1 + exp(x));
end