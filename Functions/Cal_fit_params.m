function params_fit = Cal_fit_params(mag, Model)
    % Data preprocessing
    res = Cal_fmd(mag, 0.1,1);
    m_values_fitted = res.mi;
    y_values_fitted = res.CCFMD;
    m_values_fitted = m_values_fitted(:);
    % Zero value processing
    min_nonzero = min(y_values_fitted(y_values_fitted > 0));
    y_values_fitted(y_values_fitted <= 0) = min_nonzero;
    y_values_log = log10(y_values_fitted(:)); 
    
    % Initial parameter estimation
    fMc = maxc(mag, 0.1);

    % Weight calculation (weighted by frequency square root)
    weights = sqrt(y_values_log);
    weights = weights / max(weights);
    weights = weights(:); 


    valid_idx = find(y_values_fitted > 0, 1, 'first');
    if ~isempty(valid_idx)
        a_init = log10(y_values_fitted(valid_idx)) + 1 * m_values_fitted(valid_idx);
    else
        a_init = 3;
    end
    
    % Parameter configuration
    switch Model
        case 'GR-SSReLU'
            params0 = [a_init, 1, fMc, 0.5]; % [a, b, mc, sigma]
            lb = [0.1, 0.1, fMc-0.3, 0.1];
            ub = [ 12, 2.0, fMc+3.0, 3  ];
            model_predict = @(p, m) GRLUE(m, p(1), p(2), p(3), p(4), 0, Model);
        case 'GR-BSReLU'
            params0 = [a_init, 1, fMc, 0.5, 0]; % [a, b, mc_fit, sigma, C]
            lb = [0.1, 0.1, fMc-0.3, 0.1, 0];
            ub = [ 12, 2.0, fMc+3.0,   3, 0.1];  % C must be sufficiently large to ensure that m + C > 0
            model_predict = @(p, m) GRLUE(m, p(1), p(2), p(3), p(4), p(5), Model);
        case 'GR-COReLU'
            params0 = [a_init, 1, fMc, 0.5]; % [a, b, mc, sigma]
            lb = [0.1, 0.1, fMc-0.3, 0.1];
            ub = [ 12, 2.0, fMc+3.0, 3  ];
            model_predict = @(p, m) GRLUE(m, p(1), p(2), p(3), p(4), 0, Model);
        case 'GR-AEReLU'
            params0 = [a_init, 1, fMc, 0.5, 1]; % [a, b, mc, sigma, beta]
            lb = [0.1, 0.1, fMc-0.3, 0.1, 0.01];
            ub = [ 12, 2.0, fMc+3.0,   3, 3   ];
            model_predict = @(p, m) GRLUE(m, p(1), p(2), p(3), p(4), p(5), Model);
    end
    
    residuals = @(p) (model_predict(p, m_values_fitted) - y_values_log) .* weights;

    options = optimoptions('lsqnonlin',...
        'Display', 'off',...
        'MaxIterations', 2000,...
        'FunctionTolerance', 1e-6,...
        'StepTolerance', 1e-6);

    num_starts = 5;
    best_resnorm = inf;
    params_fit = params0;
    
    for i = 1:num_starts
        current_params0 = params0 .* (1 + 0.1*(rand(size(params0))-0.5)); % 均匀扰动
        current_params0 = max(lb, min(ub, current_params0));
        
        [temp_params, resnorm] = lsqnonlin(...
            residuals, current_params0,...
            lb, ub, options);
        

        if resnorm < best_resnorm
            params_fit = temp_params;
            best_resnorm = resnorm;
        end
    end
    if length(params_fit) == 4
        params_fit = [params_fit, 0];
    end
end