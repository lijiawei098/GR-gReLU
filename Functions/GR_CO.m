function Parameters = GR_CO(Magnitude)
%GR_CO Estimate augmented GR_CO model parameters with bootstrap uncertainty.
%   Parameters = GR_CO(Magnitude)
%   Input:
%       Magnitude : N-by-1 (or 1-by-N) vector of earthquake magnitudes.
%   Output (struct):
%       .names        : {'a','b','mc','sigma_mc'}
%       .estimate     : point estimate from full sample [1x4]
%       .std          : bootstrap standard deviation [1x4]
%       .ci95         : percentile 95% CI [4x2]
%       .bounds       : struct with lower/upper bounds used in inversion
%       .bootstrap    : successful bootstrap parameter samples [Kx4]
%       .n_bootstrap  : number of successful bootstrap inversions
%
%   Ref.
%   [1] Wang, X., Li, J., Feng, A., Sornette, D. (2025). Estimating magnitude 
%               completeness in earthquake catalogs: A comparative study of 
%               catalog-based methods. Journal of Geophysical Research: Solid Earth, 
%               130(9), e2025JB031441.
%   [2] Li, J., Wang, X., Sornette, D. (2026). Unifying the Gutenberg-Richter 
%               law with probabilistic catalog completeness. Seismological Research 
%               Letters (to be published) or https://doi.org/10.48550/arXiv.2506.16849.
%
%   Dr. Jiawei Li & Ms. Xinyi Wang
%   Version 2.1: May 1, 2026.

    if nargin < 1
        error('GR_CO:MissingInput', 'Magnitude input is required.');
    end

    Magnitude = Magnitude(:);
    Magnitude = Magnitude(isfinite(Magnitude));

    if numel(Magnitude) < 30
        error('GR_CO:TooFewSamples', ...
            'At least 30 valid magnitudes are recommended. Current N=%d.', numel(Magnitude));
    end

    mbin = 0.1;
    res = local_Cal_fmd(Magnitude, mbin, 1);
    m = res.mi(:);
    y = res.CCFMD(:);

    positive_y = y(y > 0);
    if isempty(positive_y)
        error('GR_CO:InvalidCCFMD', 'CCFMD is all zeros; cannot fit model.');
    end
    y(y <= 0) = min(positive_y);
    ylog = log10(y);

    mc0 = local_maxc(Magnitude, mbin);
    m_min = min(Magnitude);
    m_max = max(Magnitude);
    m_rng = max(m_max - m_min, 0.5);

    b_lb = 0.2;
    b_ub = 2.5;
    mc_lb = max(m_min - 0.3, mc0 - 1.2);
    mc_ub = min(m_max + 0.3, mc0 + 1.8);
    sigma_lb = 0.05;
    sigma_ub = min(2.5, max(0.35, 0.8 * m_rng));

    a_ref = log10(numel(Magnitude)) + b_lb * mc_lb;
    a_lb = max(-2, a_ref - 6);
    a_ub = a_ref + 8;

    lb = [a_lb, b_lb, mc_lb, sigma_lb];
    ub = [a_ub, b_ub, mc_ub, sigma_ub];

    a0 = log10(max(y(1), 1));
    b0 = 1.0;
    sigma0 = max(0.2, min(0.6, 0.25 * m_rng));
    p0 = [a0, b0, mc0, sigma0];
    p0 = max(lb, min(ub, p0));

    model = @(p, mm) local_GRLUE_CO(mm, p(1), p(2), p(3), p(4));

    weights = sqrt(max(y, 1));
    weights = weights ./ max(weights);

    residual = @(p, mm, yy, ww) (model(p, mm) - yy) .* ww;

    opts = optimoptions('lsqnonlin', ...
        'Display', 'off', ...
        'MaxIterations', 3000, ...
        'MaxFunctionEvaluations', 20000, ...
        'FunctionTolerance', 1e-8, ...
        'StepTolerance', 1e-8);

    p_hat = local_multistart_fit(p0, lb, ub, m, ylog, weights, residual, opts, 12);

    n_boot = 200;
    n = numel(Magnitude);
    boot_params = nan(n_boot, 4);

    rng('shuffle');
    for i = 1:n_boot
        idx = randi(n, [n, 1]);
        mag_b = Magnitude(idx);

        res_b = local_Cal_fmd(mag_b, mbin, 1);
        mb = res_b.mi(:);
        yb = res_b.CCFMD(:);

        yb_pos = yb(yb > 0);
        if isempty(yb_pos)
            continue;
        end

        yb(yb <= 0) = min(yb_pos);
        yb_log = log10(yb);

        wb = sqrt(max(yb, 1));
        wb = wb ./ max(wb);

        p_init = p_hat .* (1 + 0.08 * randn(1, 4));
        p_init = max(lb, min(ub, p_init));

        try
            p_b = local_multistart_fit(p_init, lb, ub, mb, yb_log, wb, residual, opts, 4);
            if all(isfinite(p_b))
                boot_params(i, :) = p_b;
            end
        catch
        end
    end

    boot_params = boot_params(all(isfinite(boot_params), 2), :);
    if isempty(boot_params)
        error('GR_CO:BootstrapFailed', 'All bootstrap inversions failed.');
    end

    Parameters = struct();
    Parameters.names = {'a', 'b', 'mc', 'sigma_mc'};
    Parameters.estimate = p_hat;
    Parameters.std = std(boot_params, 0, 1);
    Parameters.ci95 = prctile(boot_params, [2.5 97.5])';
    Parameters.bounds = struct('lower', lb, 'upper', ub);
    Parameters.bootstrap = boot_params;
    Parameters.n_bootstrap = size(boot_params, 1);
end

function p_best = local_multistart_fit(p0, lb, ub, m, ylog, w, residual_fun, opts, n_starts)
    best_res = inf;
    p_best = p0;

    for k = 1:n_starts
        p_try = p0 .* (1 + 0.10 * (rand(1, numel(p0)) - 0.5));
        p_try = max(lb, min(ub, p_try));

        [p_tmp, resnorm] = lsqnonlin(@(p) residual_fun(p, m, ylog, w), p_try, lb, ub, opts);

        if isfinite(resnorm) && resnorm < best_res
            best_res = resnorm;
            p_best = p_tmp;
        end
    end
end

function GR_values = local_GRLUE_CO(m, a, b, m_c, sigma_m)
    activation_value = local_GRCO((m - m_c) ./ sigma_m);
    GR_values = a - b * m_c - b * sigma_m * activation_value;
end

function y = local_GRCO(x)
    y = zeros(size(x));
    idx1 = x <= 1;
    idx2 = ~idx1;
    y(idx1) = exp(x(idx1) - 1);
    y(idx2) = x(idx2);
end

function Mc = local_maxc(mag, mbin)
    res = local_Cal_fmd(mag, mbin, 1);
    [~, idx] = max(res.FMD);
    Mc = res.mi(idx);
end

function res = local_Cal_fmd(mag, mbin, flag)
    if ~exist('flag', 'var')
        flag = 0;
    end

    if flag == 1
        mincr = -10:mbin:max(round(mag/mbin)*mbin);
    else
        mincr = min(round(mag/mbin)*mbin):mbin:max(round(mag/mbin)*mbin);
    end

    nbm = length(mincr);
    cumnbmag = zeros(nbm, 1);

    for n = 1:nbm
        cumnbmag(n, 1) = length(find(mag > mincr(n) - mbin/2));
    end

    cumnbmagtmp = [cumnbmag; 0];
    nbmag = abs(diff(cumnbmagtmp));

    res.CCFMD = cumnbmag';
    res.FMD = nbmag';
    res.mi = mincr;
end
