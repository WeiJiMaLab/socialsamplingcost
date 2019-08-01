load Estimates_Optimalfull_Sym_decreasing_r_exponential_30April2019.mat
load summary_invest
load invest_decreasesym_4mei2019 softmax_pars_est softmax_bestNLL

scatterBins = 5;
bins = 10;

[sctCenters, sctData, sctModel] = plotInvestVarBinsdeterminedbinsize_Decrease(data, pars_est, softmax_pars_est, scatterBins);
[binCenters, binData, binModel] = plotInvestVarBinsdeterminedbinsize_Decrease(data, pars_est, softmax_pars_est, bins);

figure;
hold on;

%Scatter plot
legendHandles = plotInvestCreateScatterPlot(sctCenters, sctData, sctModel, true, false);

% Rotated ellipses
%plotInvestCreateEllipsePlot(binCenters, binData, binModel);

% SEM ellipses
%legendHandles = plotInvestCreateSemEllipsePlot(binCenters, binData, binModel);


plot([0 1], [0 1], 'k--', 'LineWidth', 2);
Titles = {'No cost, covert', 'Costly, covert', 'No cost, overt','Costly, overt'};

legend(legendHandles, Titles, 'Location', 'northwest');
legend boxoff;
%set(gca,'XLim', ([0 1]), 'box', 'off', 'FontSize',20);