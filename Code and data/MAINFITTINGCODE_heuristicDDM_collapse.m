% FITTING
clear all; close all
% 
% %Symmetric
% load('Summary_Semus_sym.mat')
% data = Summary_Semus_sym 

% %positive
% load summaryNew

%negative
 load summary_Neg

numinit = 100; % Number of starting points for parameter fitting

subjvec = unique(data.subjid);
subjvec = setdiff(subjvec, [1007 1012 1019 4025 4027 4039 4041 5001 5005 5020 50202]); 

for subjidx = 1:length(subjvec)
    subjidx
    idx = find(data.subjid == subjvec(subjidx));
    datasubj.money  = data.money(idx);
    datasubj.social = data.social(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    
    myNLL = @(pars) mymodelHeuristicDDM_collapse(pars, datasubj);
    
    init         = NaN(numinit, 6);
    init(:,1)    = log(rand(numinit,1)); %beta softmax
    init(:,2:5)  = randi(25, numinit,4) - 1; %4 criteria
    init(:,6)    = -rand(numinit,1);
    
    lowK = 0;
    highK = inf;
    lowLimits = [-inf lowK lowK lowK lowK -inf];
    highLimits = [inf highK highK highK highK 0];
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
    
    myNLL = @(pars) mymodelHeuristicDDM_collapse(pars, datasubj);
end

allbestNLL
pars_est

save estimates_DDM_collapse pars_est allbestNLL

