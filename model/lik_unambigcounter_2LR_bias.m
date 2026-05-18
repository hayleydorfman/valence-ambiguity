function [lik,latents] = lik_unambigcounter_2LR_bias(x,data)
% Likelihood: Q-learning on 2-armed bandit with asymmetric learning rates.
% NOTE: CHOSEN option feedback can be AMBIGUOUS; COUNTERFACTUAL feedback is
% UNAMBIGUOUS.
%
% For UNAMBIGUOUS: Two learning rates (picked by the RPE sign).
% For AMBIGUOUS: Push the chosen Q in the direction set by a bias parameter
% using only the magnitude of the observed outcome.
%
% Adds p_belief calculation: on ambiguous trials, p_belief is derived from
% the free 'bias' parameter (mapped from [-1,1] to [0.01,0.99]) and is used
% in the belief-report likelihood term.

% ---------------- PARAMETERS ----------------
b      = x(1);   % inverse temperature
lr_pos = x(2);   % learning rate for positive RPE
lr_neg = x(3);   % learning rate for negative RPE
sticky = x(4);   % stickiness
bias   = x(5);   % ambiguity valence bias in [-1,+1]

% Map bias in [-1,1] to probability in [0.01,0.99] for use in p_belief
% calculation
bias_as_p = max(0.01, min(0.99, 0.5*(bias + 1)));

% ---------------- INITIALIZE ----------------
lik = 0;
pick_alpha = @(delta) (delta>0).*lr_pos + (delta<0).*lr_neg; % LR by RPE sign

for n = 1:data.N

    if n==1 || data.block(n) ~= data.block(n-1)
        v = [0 0];         % Q-values
        u = [0 0];         % stickiness indicator
    end

    c   = data.c(n);
    uc  = 3 - c;
    r   = data.r(n,:);                 % [r_left, r_right]
    belief_gold = data.latent_guess(n);% 1=gold, 0=rocks

    % ---------- CHOICE LIKELIHOOD ----------
    q = b*v + sticky*u;
    u = [0 0]; u(c) = 1;
    lik = lik + q(c) - logsumexp(q,2);

    % ---------- VALUE UPDATES ----------
    rpe = r - v;

    if ~data.ambig(n) % unambiguous chosen
        a_c  = pick_alpha(rpe(c));
        v(c) = v(c) + a_c * rpe(c);
        % p_belief from sign of unambiguous outcome
        p_belief = 0.99*(r(c)>0) + 0.01*(r(c)<0);
    else
        % ambiguous chosen: magnitude * bias
        delta_ambig = bias * abs(r(c));
        v(c) = v(c) + lr_pos * delta_ambig;

        % p_belief from bias parameter (mapped to probability)
        p_belief = bias_as_p;
    end

    % Unchosen (counterfactual)
    a_uc  = pick_alpha(rpe(uc));
    v(uc) = v(uc) + a_uc * rpe(uc);

    % ---------- BELIEF-REPORT LIKELIHOOD ----------
    % likelihood for belief
    lik = lik + belief_gold*log(p_belief) + (1-belief_gold)*log(1 - p_belief);

    % ---------- STORE LATENTS ----------
    latents.lr_pos(n,1)      = lr_pos;
    latents.lr_neg(n,1)      = lr_neg;
    latents.bias(n,1)        = bias;
    latents.p_belief(n,1)    = p_belief;
    latents.v(n,:)           = v;
    latents.v_chosen(n,1)    = v(c);
    latents.r(n,:)           = r;
    latents.rpe(n,:)         = rpe;
    latents.chosen(n,1)      = c;
    latents.choiceprob(n,:)  = exp(q)./sum(exp(q));
    if isfield(data,'better_choice')
        latents.better_choice(n,1) = data.better_choice(n);
    end
    latents.belief_gold(n,1) = belief_gold;

end
end
