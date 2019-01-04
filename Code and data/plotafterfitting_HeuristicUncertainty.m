clear all; close all;
load('Summary_Semus_sym.mat')
data = Summary_Semus_sym 
load estimates_13122017SymSD_FINALk
% 
% load('summaryNew.mat')
% load estimates_19122017Pos_k % estimates_SD_pos_FINALK
% 
% load summary_Neg
% load estimates_SD_neg_FINALK %estimates_TestcaseSD2_neg_k

subjvec = unique(data.subjid);
subjvec = setdiff(subjvec, [1007 1012 1019 4025 4027 4028 4039 4041 5001 5005 5020 50202]); 

%% Plots

moneyvec  = [0 1];
socialvec = [0 1];
m = 2;
T = 25;
recipvec = unique(data.recip);
lapse_est = 0;

[mean_nsamp_data_subj mean_nsamp_model_subj] = deal(NaN(length(moneyvec), length(socialvec), length(subjvec), length(recipvec)));

nsims = 1000;
figure;
for subjidx = 1:length(subjvec)
    subjidx;
    for moneyidx = 1:length(moneyvec)
        money = moneyvec(moneyidx);
        
        for socialidx = 1:length(socialvec)
            social = socialvec(socialidx);
            
            idx = find(data.subjid == subjvec(subjidx) & data.money == money & data.social == social & (data.red + data.green < T));
            thisred    = data.red(idx);
            thisgreen  = data.green(idx);
            thistime   = thisred + thisgreen + 1;
            thischoice = data.choice(idx);
            thisrecip  = data.recip(idx);
            
            % Estimates
            beta1_est  = exp(pars_est(subjidx, 1));
            allk_est   = exp(([pars_est(subjidx, 2), pars_est(subjidx, 4); pars_est(subjidx, 3), pars_est(subjidx, 5)]));
            k_est      = allk_est(moneyidx, socialidx);
            alpha_0    = pars_est(subjidx, 6);
            beta_0     = pars_est(subjidx, 7);
   

            DeltaQ = computeUncertainty(T, m, k_est, alpha_0, beta_0);
            prob_sample = 1./(1+exp(- beta1_est * DeltaQ));
            
            for recipidx = 1:length(recipvec)
                recip = recipvec(recipidx);
                
                nsamp = NaN(nsims,1);
                for i = 1: nsims
                    decisionmade = 0;
                    ngreen = 0;
                    nred = 0;
                    while decisionmade == 0 & (ngreen + nred < T)
                        if rand < lapse_est
                            decidetosample = rand < 0.5;
                        else
                            decidetosample = rand < prob_sample(ngreen + 1, ngreen + nred + 1);
                        end
                        
                        if decidetosample == 0
                            decisionmade = 1;
                        else
                            samplegood   = rand < recip;
                            ngreen = ngreen + samplegood;
                            nred = nred + (1-samplegood);
                        end
                        
                    end
                    nsamp(i) = ngreen + nred;
                end
                
                mean_nsamp_model_subj(moneyidx, socialidx, subjidx, recipidx) = mean(nsamp);
            end
        end
    end
end

% Number of samples from the data
for subjidx = 1:length(subjvec)
    subject = subjvec(subjidx);
    for moneyidx = 1:length(moneyvec)
        money = moneyvec(moneyidx);
        
        for socialidx = 1:length(socialvec)
            social = socialvec(socialidx);
            for recipidx = 1:length(recipvec)
                recip = recipvec(recipidx);
                idx = find(data.subjid == subject & data.money == money & data.social == social & data.recip == recip & (data.time <= T));
                trialstarttimes = [find(data.time(idx)==1); length(idx) + 1];
                mean_nsamp_data_subj(moneyidx, socialidx, subjidx, recipidx) = mean(diff(trialstarttimes)-1);
            end
        end
    end
end
mean_nsamp_data = squeeze(mean(mean_nsamp_data_subj, 3));
sem_nsamp_data = squeeze(std(mean_nsamp_data_subj,[],3))/sqrt(length(subjvec));

mean_nsamp_model = squeeze(mean(mean_nsamp_model_subj, 3));
sem_nsamp_model = squeeze(std(mean_nsamp_model_subj,[],3))/sqrt(length(subjvec));

% Plot number of samples as a function of reciprocation probability per
% cost condition.  Line and errorbar is data. Shaded regions is model fit.
colors = [0, 0.2, 0.5; 0.3, 0.4, 1; 0, 0.5, 0; 0, 0.9, 0.2]; 
social_labels = {'Trustee not informed', 'Trustee informed'};
    
for socialidx = 1:length(socialvec)
    subplot(1, length(socialvec), socialidx);
    set(gcf,'color','w');
    hold on;
    xlabel('Reciprocation probability'); ylabel('Number of samples');
    axis([-0.1 1.1 0 20]);
    title(social_labels(socialidx));
    set(gca,'xtick', recipvec);
    set(gca,'ytick', 0:5:20);
    
    social = socialvec(socialidx);
    thingsWithALegend = [];
    
    for moneyidx = 1:length(moneyvec)
        money = moneyvec(moneyidx);
        data_mean = squeeze(mean_nsamp_data(moneyidx, socialidx,:));
        data_sem = squeeze(sem_nsamp_data(moneyidx, socialidx,:));
        model_mean = squeeze(mean_nsamp_model(moneyidx, socialidx,:));
        model_sem = squeeze(sem_nsamp_model(moneyidx, socialidx,:));
        set(gca,'FontSize',10)
        X = [recipvec; flipud(recipvec)];
        Y = [data_mean + data_sem; flipud(data_mean - data_sem)];
        Y = [model_mean + model_sem; flipud(model_mean - model_sem)];
        thingsWithALegend = [thingsWithALegend, fill(X,Y, colors(2 * moneyidx, :), 'FaceAlpha', 0.6, 'EdgeAlpha', 0)]; %colors and transparency
        ebar = errorbar(recipvec, data_mean, data_sem, '-', 'LineWidth', 2);
        ebar.Color = 0.8 * colors(2 * moneyidx, :);

        grid off
    end
    legend(thingsWithALegend, {'No cost', 'Cost'}, 'Location', 'southwest','FontSize',8);
    legend('boxoff');
end
