function NLL = mymodel_Optimal(pars, data)
k = pars(1);
beta1 = pars(2);
allc = [pars(3) pars(5);
       pars(4) pars(6)];
risk = pars(7); 
alphaPrior = pars(8);
betaPrior = pars(9); 

NLL = 0;
m = 2;
T = 25;

moneyvec  = [0 1];
socialvec = [0 1];

for moneyidx = 1:length(moneyvec)
    money = moneyvec(moneyidx);
    
    for socialidx = 1:length(socialvec)
        social = socialvec(socialidx);
        
        c = allc(moneyidx, socialidx);
        DeltaQ = computeDeltaQ_Optimal(T, m, c, alphaPrior, betaPrior, risk);
        
        trialidx   = find(data.money == money & data.social == social & data.red + data.green < T);
        
        thistime   = data.red(trialidx) + data.green(trialidx) + 1;
        thischoice = data.choice(trialidx);
        
        linearidx           = sub2ind(size(DeltaQ), data.green(trialidx) + 1, thistime);
        DeltaQ_vectorized   = DeltaQ(:);
        
        % Log likelihood
        prediction = 1./(1+exp(- thischoice .* (beta1 * (DeltaQ_vectorized(linearidx) - k)))); 
        NLL = NLL - sum(log(prediction));
    end
end