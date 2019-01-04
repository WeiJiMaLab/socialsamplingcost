clear; close all
load('summary_invest.mat');

subjvec = unique(data.subjid);
subjvec = setdiff(subjvec, [4025 4027 4028 4041 5001 5005 5013 5020 5039 50202 1007 1012 1019]);
nSubjects = length(subjvec);

nParameters = 2;
numinit = 100; % Number of starting points for parameter fitting
softmax_pars_per_run = NaN(nSubjects, numinit, 2);
NLL = NaN(1, numinit);
softmax_pars_est = NaN(nSubjects, nParameters);
softmax_bestNLL = NaN(nSubjects, 1);

for subjidx = 1:nSubjects
    subjectNr = subjvec(subjidx);
    [subjidx, subjectNr]
    
    % Select only the data for the current subject
    datasubj = subjectData(subjectNr, data);
    
    myNLL = @(pars) investDDMSoftmaxNLL(datasubj, pars);
    
    init        = NaN(numinit, 1); %
    init(:,1)   = rand(numinit,1) * 2 - 1; %softmax intercept
    init(:,2)   = rand(numinit,1) * 10; %beta softmax (comment for null model)
    
    for runidx = 1:numinit
       [softmax_pars_per_run(subjidx, runidx, :), NLL(runidx)] = fmincon(myNLL, init(runidx,:),[],[],[],[], [-inf -inf],[inf inf], [], optimset('Display', 'off')); 
    end
    [~, bestrun] = min(NLL); 
    [fittedpars, bestNLL] = fmincon(myNLL, init(bestrun,:),[],[],[],[], [-inf -inf],[inf inf], [], optimset('Display', 'off'));
    fittedpars
    
    softmax_pars_est(subjidx,:) = fittedpars;
    softmax_bestNLL(subjidx) = bestNLL;
end

softmax_bestNLL
softmax_pars_est

save invest_Nll_sym_DDM softmax_pars_est softmax_bestNLL

