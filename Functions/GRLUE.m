function [GR_values] = GRLUE(m, a, b, m_c, sigma_m, beta, Model)
    switch Model
        case 'GR-SSReLU'
            activation_value = GRSSReLU((m - m_c) / sigma_m);
            GR_values = a - b * m_c - b * sigma_m * activation_value;
        case 'GR-BSReLU'
%         activation_value = GR-BSReLU((m - m_c) / sigma_m, m_c, sigma_m);
        activation_value = GRBSReLU(m, m_c, sigma_m, beta);
        GR_values = a - b * (m_c + beta) - b * sigma_m * activation_value;
        % 调整传入的m_c为mc_new = m_c + C，需确保与model_2中的C一致
%         a_m_c = m_c + beta;
%         activation_value = model_2((m - m_c) / sigma_m, m_c, sigma_m);
        case 'GR-COReLU'
            activation_value = GRCOReLU((m - m_c) / sigma_m); 
            GR_values = a - b * m_c - b * sigma_m * activation_value;
        case 'GR-AEReLU'
            activation_value = GRAEReLU((m - m_c) / sigma_m, beta); 
            GR_values = a - b * m_c - b * sigma_m * activation_value;
    end
   
end