% FITTING
clear all; close all

%Symmetric
% load('Summary_Semus_sym.mat')
% data = Summary_Semus_sym
% subjvec = 4001:max(data.subjid);

%positive bias
load('summaryNew.mat')
subjvec = 1001:max(data.subjid);
 
% %negative bias
% load('summary_Neg.mat')
% subjvec = unique(data.subjid);

subjvec = setdiff(subjvec, [1007 1012 1019 4025 4027 4039 4041 5001 5005 5020 50202])
numinit = 100; % Number of starting points for parameter fitting

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.money  = data.money(idx);
    datasubj.social = data.social(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelHeuristicUncertainty(pars, datasubj);
    
    init         = NaN(numinit, 7); % 5 parameters without priors
    init(:,1)    = log(rand(numinit,1) * 4); %beta softmax
    init(:,2:5)  = log(rand(numinit,4)); %4 costs
    init(:,6)    = rand(numinit,1) + 1; %Alphaprior
    init(:,7)    = rand(numinit,1) + 1; %Betaprior
    
    lowK = log(0.0000001);
    highK = log(1);
% %     without priors:
%     lowLimits = [-inf lowK lowK lowK lowK];
%     highLimits = [inf highK highK highK highK];
%     with priors:
    lowLimits = [-inf lowK lowK lowK lowK 1 1];
    highLimits = [inf highK highK highK highK inf inf];
    for runidx = 1:numinit
        [pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    end
    NLL
    [~, bestrun] = min(NLL); 
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], lowLimits, highLimits, [], optimset('Display', 'off'));
    
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
    
    myNLL = @(pars) mymodelHeuristicUncertainty(pars, datasubj);
end

allbestNLL = [subjvec', allbestNLL']
pars_est = [subjvec', pars_est]

save estimates_heuristicUncertainty pars_est allbestNLL

