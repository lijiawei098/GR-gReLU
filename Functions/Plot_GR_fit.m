function Plot_GR_fit(res, CCFMD, m_c, sigma_m, Model)
    m_values = res.mi;
    y_values = res.CCFMD;  
    y_values_log = log10(y_values);

    figure;
    plot(m_values, y_values_log, 'o', 'MarkerFaceColor', [0.128, 0.535, 0.825], 'MarkerEdgeColor', 'none', 'DisplayName', 'Catalog data');  
    hold on;
    

   modelName = Model;  

   plot(m_values, CCFMD, ...
            'r-', 'LineWidth', 2, 'DisplayName', modelName);


    y_limits = ylim;

    xline(m_c, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5, 'DisplayName', sprintf('$m_\\mathrm{c}^{\\mathrm{pred}} = %.2f$', m_c));


    fill([m_c - sigma_m, m_c - sigma_m, m_c + sigma_m, m_c + sigma_m], ...
     [y_limits(1), y_limits(2), y_limits(2), y_limits(1)], ...
     [0.5, 0.5, 0.5], 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
     'DisplayName', '$m_{\mathrm{c}}^{\mathrm{pred}} \pm \sigma_{m_{\mathrm{c}}}^{\mathrm{pred}}$');

    ylim([0 inf]) 
    xlim([0 inf])

    xlabel('Magnitude', 'FontSize', 18);
    ylabel('$\log_{10}$CCFMD($m$)', 'FontSize', 18, 'Interpreter', 'latex');

%     title('CCFMD(m) fitting results');
    legend('show', 'Interpreter', 'latex', 'FontSize', 12); 
    grid on;
    hold off;
end

