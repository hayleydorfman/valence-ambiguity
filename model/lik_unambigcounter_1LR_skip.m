function [lik, latents] = lik_unambigcounter_1LR_skip(x, data)
% Likelihood function for Q-learning on two-armed bandit with a single
% learning rate.
%
% NOTE: CHOSEN option feedback is AMBIGUOUS; COUNTERFACTUAL feedback is
% UNAMBIGUOUS. AMBIGUOUS outcomes are SKIPPED (no chosen-arm update).
%
% USAGE: [lik, latents] = lik_unambigcounter_1LR_skip(x, data)
%
% INPUTS:
%   x - parameters:
%       x(1) - inverse temperature (beta)
%       x(2) - learning rate (lr)
%       x(3) - stickiness
%   data - struct with fields:
%       .N            - number of trials
%       .block        - [N x 1] block index
%       .c            - [N x 1] choices (1=left, 2=right)
%       .r            - [N x 2] rewards [r_left, r_right]
%       .ambig        - [N x 1] 1 if chosen outcome ambiguous, else 0
%       .latent_guess - [N x 1] subject belief (1=gold, 0=rocks)
%       .better_choice- [N x 1] ground-truth better option
%
% OUTPUTS:
%   lik     - log-likelihood
%   latents - struct of trial-wise latent variables
%
% Rahul Bhui & Hayley Dorfman, 2021

% ---- parameters ------------------------------------------------------------
b      = x(1);   % inverse temperature
lr     = x(2);   % learning rate
sticky = x(3);   % stickiness

% ---- initialise ------------------------------------------------------------
lik = 0;

for n = 1:data.N

    if n == 1 || data.block(n) ~= data.block(n-1)
        v = zeros(1, 2);   % Q-values [left, right]
        u = zeros(1, 2);   % stickiness indicator
    end

    c   = data.c(n);                  % chosen (1 or 2)
    uc  = 3 - c;                      % unchosen
    r   = data.r(n, :);               % [r_left, r_right]
    belief_gold = data.latent_guess(n); % 1=gold, 0=rocks

    % ---- choice likelihood -------------------------------------------------
    q = b * v + sticky * u;
    u = zeros(1, 2); u(c) = 1;
    lik = lik + q(c) - logsumexp(q, 2);

    % ---- value updates -----------------------------------------------------
    rpe = r - v;

    % Chosen: skip update on ambiguous trials
    v(c)  = v(c)  + (1 - data.ambig(n)) * lr * rpe(c);
    % Unchosen (counterfactual): always unambiguous, always update
    v(uc) = v(uc) + lr * rpe(uc);

    % ---- belief likelihood -------------------------------------------------
    p_belief = (1 - data.ambig(n)) * (0.99 * (r(c) > 0) + 0.01 * (r(c) < 0)) ...
               + data.ambig(n) * 0.5;
    lik = lik + belief_gold * log(p_belief) + (1 - belief_gold) * log(1 - p_belief);

    % ---- store latents -----------------------------------------------------
    latents.lr(n, 1)          = lr;
    latents.v(n, :)           = v;
    latents.v_chosen(n, 1)    = v(c);
    latents.r(n, :)           = r;
    latents.rpe(n, :)         = rpe;
    latents.chosen(n, 1)      = c;
    latents.choiceprob(n, :)  = exp(q) ./ sum(exp(q));
    latents.better_choice(n, 1) = data.better_choice(n);
    latents.belief_gold(n, 1) = belief_gold;
    latents.p_belief(n, 1)    = p_belief;

end
end
