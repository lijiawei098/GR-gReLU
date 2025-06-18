function [SR_BS] = GRBSReLU(m, m_c, sigma_m, C)
    m_translated = m + C;
    m_c_translated = m_c + C;
    

    m_translated = max(m_translated, eps);
    

    d1 = (log(m_translated / m_c_translated) + 0.5 * sigma_m^2) / sigma_m;
    d2 = d1 - sigma_m;
    

    d1 = max(min(d1, 37), -37);
    d2 = max(min(d2, 37), -37);
    

    SR_BS = (m_translated / sigma_m) .* normcdf(d1) - (m_c_translated / sigma_m) .* normcdf(d2);
end