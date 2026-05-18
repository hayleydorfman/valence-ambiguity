function [lik,latents] = lik_ambigcounter_2LR_bias_3Q(x,data)
% Likelihood: Q-learning on 2-armed bandit with asymmetric learning rates.
% NOTE: CHOSEN option feedback can be AMBIGUOUS; COUNTERFACTUAL feedback is
% AMBIGUOUS.
%
% For UNAMBIGUOUS: Two learning rates (picked by the RPE sign).
% For AMBIGUOUS: Push the chosen Q in the direction set by a bias parameter
% using only the magnitude of the observed outcome.
%
% Adds p_belief calculation: on ambiguous trials, p_belief is derived from
% the free 'bias' parameter (mapped from [-1,1] to [0.01,0.99]) and is used
% in the belief-report likelihood term.
%
% PARAMETERS (x):
%   x(1) = inverse temperature (beta)
%   x(2) = learning rate for positive RPEs
%   x(3) = learning rate for negative RPEs
%   x(4) = stickiness
%   x(5) = ambiguity valence bias in [-1,+1]  (drives p_belief on ambiguous)
%   x(6) = q_poor     (initial Q for poor condition)
%   x(7) = q_rich     (initial Q for rich condition)
%   x(8) = q_neutral  (initial Q for neutral condition)
%
% Required fields in data: .N, .block, .c, .r, .ambig, .latent_guess, .cond

% ---------------- PARAMETERS ----------------
b        = x(1);
lr_pos   = x(2);
lr_neg   = x(3);
sticky   = x(4);
bias     = x(5);     % in [-1, +1]
q_poor   = x(6);
q_rich   = x(7);
q_neutral= x(8);

% Map bias in [-1,1] to probability in [0.01,0.99] for p_belief on ambiguous
bias_as_p = max(0.01, min(0.99, 0.5*(bias + 1)));

% ---------------- INITIALIZE ----------------
lik = 0;
pick_alpha = @(delta) (delta>0).*lr_pos + (delta<0).*lr_neg; % LR by RPE sign

for n = 1:data.N

    % Reset per block with condition-specific Q inits
    if n==1 || data.block(n) ~= data.block(n-1)
        v0 = 0;
        if isfield(data,'cond')
            ci = data.cond(n);  % 1=poor, 2=rich, 3=neutral
            if     ci==1, v0 = q_poor;
            elseif ci==2, v0 = q_rich;
            else           v0 = q_neutral;
            end
        end
        v = [v0 v0];   % Q-values
        u = [0 0];     % stickiness indicator
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
        % ambiguous chosen: magnitude * bias (same as your original rule)
        delta_ambig = bias * abs(r(c));
        v(c) = v(c) + lr_pos * delta_ambig;

        % p_belief from bias parameter (mapped to probability)
        p_belief = bias_as_p;
    end
    
    % Unchosen (counterfactual): follow same unambig/ambig rules as chosen
    if ~data.ambig(n)   % unambiguous trial -> standard 2LR update
        a_uc  = pick_alpha(rpe(uc));
        v(uc) = v(uc) + a_uc * rpe(uc);
    else                % ambiguous trial -> bias-by-magnitude update
        delta_ambig_uc = bias * abs(r(uc));
        v(uc) = v(uc) + lr_pos * delta_ambig_uc;
    end

    % ---------- BELIEF-REPORT LIKELIHOOD ----------
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

    % store the condition-specific inits for reference
    latents.q_poor(n,1)    = q_poor;
    latents.q_rich(n,1)    = q_rich;
    latents.q_neutral(n,1) = q_neutral;

end
end
