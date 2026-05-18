function [lik,latents] = lik_ambigcounter_2LR_skip(x,data)

% Likelihood: Q-learning on 2-armed bandit with asymmetric learning rates.
% NOTE: CHOSEN option feedback can be AMBIGUOUS; COUNTERFACTUAL feedback is
% AMBIGUOUS. AMBIGUOUS chosen outcomes are SKIPPED (no value update).
%
% USAGE: [lik,latents] = lik_unambigcounter_2LR_skip(x,data)
%
% INPUTS:
%   x - parameters:
%       x(1) - inverse temperature (beta)
%       x(2) - learning rate for positive RPEs 
%       x(3) - learning rate for negative RPEs 
%       x(4) - stickiness
%   data - structure with fields:
%          .N              - number of trials
%          .block [N x 1]  - block index per trial
%          .c     [N x 1]  - choices (1=left, 2=right)
%          .r     [N x 2]  - rewards [r_left, r_right]
%          .ambig [N x 1]  - 1 if chosen outcome ambiguous, 0 otherwise
%          .latent_guess [N x 1] - subj belief about gold (1) vs rocks (0)
%          .better_choice [N x 1] - indicator for ground-truth better option 
%
% OUTPUTS:
%   lik     - log-likelihood 
%   latents - struct with trial-wise latent variables
%
% Rahul Bhui & Hayley Dorfman 2025

% ---------------- PARAMETERS ----------------
b = x(1);              % inverse temperature
lr_pos = x(2);              % learning rate for positive RPE
lr_neg = x(3);              % learning rate for negative RPE
sticky  = x(4);              % stickiness

% ---------------- INITIALIZE ----------------
lik = 0;

% pick LR by RPE sign
pick_alpha = @(delta) (delta>0).*lr_pos + (delta<0).*lr_neg;

for n = 1:data.N

    % Reset values at block starts
    if n==1 || data.block(n) ~= data.block(n-1)
        v = zeros(1,2);  % action values [left,right]
        u = zeros(1,2);  % last-choice indicator for stickiness
    end

    c   = data.c(n);                % chosen (1 or 2)
    uc  = 3 - c;                    % unchosen
    r   = data.r(n,:);              % [r_left, r_right]
    belief_gold = data.latent_guess(n); % subjective belief gold (1) vs rocks (0)

    % ---------- CHOICE LIKELIHOOD ----------
    q = b*v + sticky*u;             % decision variable with stickiness
    u = zeros(1,2); u(c) = 1;       % update last choice
    lik = lik + q(c) - logsumexp(q,2);

    % ---------- VALUE UPDATES ----------
    rpe = r - v;                    % vector RPEs for both options

    % Chosen option: update only if NOT ambiguous
    if ~data.ambig(n)
        a_c   = pick_alpha(rpe(c)); % select alpha by sign of chosen RPE
        v(c)  = v(c) + a_c * rpe(c);
    end

    % Unchosen (counterfactual) option:
    a_uc  = pick_alpha(rpe(uc));
    v(uc) = v(uc) + (1-data.ambig(n))*a_uc*rpe(uc); %doesn't update on ambiguous trials

    p_belief = (1-data.ambig(n))*(.99*(r(c) > 0) + 0.01*(r(c) < 0)) + (data.ambig(n)*0.5);
    lik = lik + belief_gold*log(p_belief)+(1-belief_gold)*log(1-p_belief);
    
    % ---------- STORE LATENTS ----------
    latents.lr_pos(n,1)   = lr_pos;
    latents.lr_neg(n,1)   = lr_neg;
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
    latents.p_belief(n,1) = p_belief;


end
end
