clear; clc; close all;
% ======================================================================= %
% ----------- The augmented Gutenberg–Richter (GR) model used ----------- %
% Model:
%   GR-SSReLU
%   GR-BSReLU
%   GR-COReLU
%   GR-AEReLU
Model      = 'GR-SSReLU';
% ---------------------------- Study region ----------------------------- %
% Region: 
%   Beijing-Tianjin-Hebei, 
%   Southeastern coastal, 
%   Sichuan-Yunnan,
%   Northern Xinjiang, 
%   California, 
%   New Zealand
Region     = 'California';
% --------------------------- Project path ------------------------------ %
PATH       = './GR-gReLU/';
% ======================================================================= %

%% Main part

% Add function folder to the MATLAB search path
addpath(fullfile(PATH, 'Functions'));

% Read data
Mag = readmatrix([PATH, 'Example/', Region, '.xlsx']);

% Compute frequency–magnitude distribution (FMD) and complementary
%   cumulative frequency–magnitude distribution (CCFMD)
mbin = 0.1;      % Bin size of magnitude
res  = Cal_fmd(Mag, mbin,1);

% Model parameter fitting
switch Model
    case 'GR-SSReLU'
        params = Cal_fit_params(Mag, Model);
        CCFMD = GRLUE(res.mi, params(1), params(2), params(3), params(4), 0, Model);
        Plot_GR_fit(res, CCFMD, params(3), params(4), Model);
    case 'GR-BSReLU'
        params = Cal_fit_params(Mag, Model);
        CCFMD = GRLUE(res.mi, params(1), params(2), params(3), params(4), params(5), Model);
        Plot_GR_fit(res, CCFMD, params(3)-params(5), params(4), Model);
    case 'GR-COReLU'
        params = Cal_fit_params(Mag, Model);
        CCFMD = GRLUE(res.mi, params(1), params(2), params(3), params(4), 0, Model);
        Plot_GR_fit(res, CCFMD, params(3), params(4), Model);
    case 'GR-AEReLU'
        params = Cal_fit_params(Mag, Model);
        CCFMD = GRLUE(res.mi, params(1), params(2), params(3), params(4), params(5), Model);
        Plot_GR_fit(res, CCFMD, params(3), params(4), Model);
end

% Save figures and results
% Figure
figFilename = fullfile(fullfile(PATH, 'Output'), [Region, '.jpg']);
saveas(gcf, figFilename);  % 或使用 exportgraphics(gcf, figFilename)（若为 R2020a+）
% Results
matFilename = fullfile(fullfile(PATH, 'Output'), [Region, '.mat']);
save(matFilename, 'params', 'Model', 'CCFMD', 'Region', 'res');

% Remove function folder to the MATLAB search path
rmpath(fullfile(PATH, 'Functions'));