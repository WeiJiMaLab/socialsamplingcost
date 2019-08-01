%nBins = 10
% 
% load Estimates_Optimalfull_Sym_decreasing_r_exponential_17April2019.mat
% load summary_invest
% load invest_decreasesym_4mei2019 softmax_pars_est softmax_bestNLL

function [binCentersPp, binProportionsPp, pInvestsFromModel] = plotInvestVarBinsdeterminedbinsize_Decrease(data, pars_est, softmax_pars_est, nBins)
    if ~isfield(data, 'rawChoice')
        disp('data does not have the rawChoice field. Can''t plot data');
        return;
    end
    exclude = [4025 4039 4027 4028 4041  5001 5005 5013 5020 5039 50202 1007 1012 1019];
    % Manually exclude 4001 from estimated things
    pars_est = pars_est(1:end, :);
    softmax_pars_est = softmax_pars_est(1:end, :);

    subjects = setdiff(unique(data.subjid), exclude)
    nSubjects = size(pars_est, 1) - 2
    T = 25;
    m = 2;
    nConditions = 4;
    % We sort the actually occuring deltaUs from the data and cut them up in
    % the required amount of bins, then compute the centers
    binCentersPp = NaN(nSubjects, nBins, nConditions);
    % The proportion of invest choices for a given bin
    binProportionsPp = NaN(nSubjects, nBins, nConditions);
    pInvestsFromModel = NaN(nSubjects, nBins, nConditions);
    % Each subject has their own priors and risk aversion, so to interpret the data we have to go subject by subject
    for subjIdx = 1:nSubjects
        %!!!!!!!!!! Collect subbject information DIFFERENT PARS FOR HEURISTIC AND OPTIMAL
        subjectNr = subjects(subjIdx);
        alld = pars_est(subjIdx, 6:7);
        risk = pars_est(subjIdx, 8);
        alpha_prior = pars_est(subjIdx, 9);
        beta_prior = pars_est(subjIdx, 10);

        b0s = softmax_pars_est(subjIdx, 1);
        b1s = softmax_pars_est(subjIdx, 2);

        for money = 0:1
            for social = 0:1
                if social
                    DeltaUtable = computeDeltaUtable_decreased_r(T, m, alld(1 + money), alpha_prior, beta_prior, risk);
                else
                    DeltaUtable = computeDeltaUtable_decreased_r(T, m, 1, alpha_prior, beta_prior, risk);
                end
                conditionNr = 1 + money + 2 * social;
                choiceIdx = data.rawChoice ~= 0 & data.subjid == subjectNr & data.money == money & data.social == social;
                nGoods = data.green(choiceIdx);
                nOpens = nGoods + data.red(choiceIdx);
                dus = DeltaUtable(sub2ind(size(DeltaUtable), nGoods + 1, nOpens + 1));
                choices = data.rawChoice(choiceIdx);
                invests = 0.5 * (choices + 1);
                % Put the invest data in a table with accompanying deltaU
                investTable = [dus invests];
                % Sort them on delta u
                investTable = sortrows(investTable, 1);
                % fill the center- and proportions table
                binSize = ceil(size(investTable, 1) / nBins);
                for binNr = 1:nBins
                    first = (binNr - 1) * binSize + 1;
                    last = min(binNr * binSize, size(investTable, 1));
                    binCentersPp(subjIdx, binNr, conditionNr) = mean(investTable(first:last, 1));
                    binProportionsPp(subjIdx, binNr, conditionNr) = mean(investTable(first:last, 2));
                    pInvestsFromModel(subjIdx, binNr, conditionNr) = mean(1 ./ (1 + exp(-b0s - b1s * investTable(first:last, 1))));
                end
            end
        end
    end
    %plotInvestCreate4in1plot(binCentersPp, binProportionsPp, pInvestsFromModel);
    %plotInvestCreate4plots(binCentersPp, binProportionsPp, pInvestsFromModel);
    %plotInvestCreateScatterPlot(binCentersPp, binProportionsPp, pInvestsFromModel);
end
