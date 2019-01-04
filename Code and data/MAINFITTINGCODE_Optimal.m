% FITTING
clear all; close all

%symmetric (no bias)
load('Summary_Semus_sym.mat')
data = Summary_Semus_sym;
subjvec = 4001:max(data.subjid);
subjvec = setdiff(subjvec, [4025 4027 4028 4039 4041]); %exclude in sym (include 4028 in analysis but not plot)

%%positive bias
% load('summaryNew.mat')
% subjvec = 1001:max(data.subjid);
% subjvec = setdiff(subjvec, [1007 1012 1019]); %exclude in asym pos

%negative bias
% load('summary_Neg.mat')
% subjvec = unique(data.subjid);
%subjvec = setdiff(subjvec, [5001 5005 5020 50202]); %exclude in asym pos

numinit = 100; % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.money  = data.money(idx);
    datasubj.social = data.social(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Optimal(pars, datasubj);
    
    init        = NaN(numinit, 9); 
    init(:,1)   = rand(numinit,1) * -1;  %beta0
    init(:,2)   = rand(numinit,1) * 4 - 2; %k
    init(:,3:6) = rand(numinit,4) * 2 - 1; %costs
    init(:,7)   = rand(numinit,1) * 2 - 0; % risk
     init(:,8)   = randn(numinit,1) * 5 + 1; %Alphaprior
     init(:,9)   = randn(numinit,1) * 5 + 1; %Betaprior
    
    for runidx = 1:numinit
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf 0 0 0 0 0 -inf .1 .1],[10 inf inf inf inf inf inf 25 25], [], optimset('Display', 'off'));
    end
    NLL
    [~, bestrun] = min(NLL);
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf 0 0 0 0 0 -inf .1 .1],[10 inf inf inf inf inf inf 25 25], [], optimset('Display', 'off'));
    pars_est(subjidx,:) = fittedpars;
    allbestNLL(subjidx) = bestNLL;
    
end

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.money  = data.money(idx);
    datasubj.social = data.social(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodel_Optimal(pars, datasubj);
end

allbestNLL = [subjvec, allbestNLL']
pars_est = [subjvec, pars_est]

save estimates_optimal pars_est allbestNLL

