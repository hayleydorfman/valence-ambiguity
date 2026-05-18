function [lik,latents] = lik_ambigcounter_bayesian_3prior(x,data)

% Likelihood function for Bayesian learning model on two-armed bandit with
% ambiguously valenced feedback & counterfactual feedback.
% NOTE: CHOSEN option feedback is AMBIGUOUS; COUNTERFACTUAL feedback is
% AMBIGUOUS
%
% 3-prior Bayesian Model
%
% Rahul Bhui & Hayley Dorfman 2021

% parameters
b = x(1);           % inverse temperature
sticky = x(2);      % stickiness
prior_sd = x(3);
prior_mean = x(4:6);  % prior mean per condition (1..3)

% initialization
lik = 0;            % log-likelihood

for n = 1:data.N

    if n==1 || data.block(n)~=data.block(n-1)
        v = zeros(1,2) + prior_mean(data.cond(n));  % initial values [v1 v2]
        u = zeros(1,2);                             % stickiness indicator
        t = 0;
        sigma_t = zeros(1,2) + prior_sd^2;          % variance per arm
    end

    t = t + 1;
    c  = data.c(n);             % chosen option (1 or 2)
    uc = 3 - c;                 % unchosen option (1 or 2)
    r  = data.r(n,:);           % [reward1 reward2]
    belief_gold = data.latent_guess(n);
    noise = zeros(1,2) + data.sd(n)^2;

    q = b*v + sticky*u;
    u = zeros(1,2); u(c) = 1;
    lik = lik + q(c) - logsumexp(q,2);
    if isnan(lik); keyboard; end

    if data.ambig(n) == 0
        % ---------- UNAMBIGUOUS TRIAL: standard Bayesian/Kalman update both arms ----------
        p_hat = NaN; % ensure defined for latents
        p_belief = .99*(r(c) > 0) + 0.01*(r(c) < 0);

        r_hat = r;
        rpe   = r_hat - v;
        lr    = sigma_t ./ (noise + sigma_t);

        v       = v + lr .* rpe;
        sigma_t = (1 - lr) .* sigma_t;

    elseif data.ambig(n) == 1
        % ---------- AMBIGUOUS TRIAL: treat BOTH chosen + unchosen as ambiguous ----------
        r_hat       = r;      % will overwrite for c and uc
        sigma_r_hat = noise;  % will overwrite for c and uc

        p_hat_all = nan(1,2);

        for a = [c uc]
            denom = normpdf(abs(r(a)), v(a), sqrt(noise(a))) + ...
                    normpdf(-abs(r(a)), v(a), sqrt(noise(a)));
            p_hat_a = normpdf(abs(r(a)), v(a), sqrt(noise(a))) / denom;
            p_hat_a = bound(p_hat_a, .01, .99);

            p_hat_all(a) = p_hat_a;

            % imputed mean (expected signed outcome)
            r_hat(a) = 2 * abs(r(a)) * (p_hat_a - .5);

            % imputed variance includes ambiguity term
            sigma_r_hat(a) = noise(a) + 4 * abs(r(a))^2 * p_hat_a * (1 - p_hat_a);
        end

        % belief-report likelihood based on CHOSEN outcome
        p_belief = p_hat_all(c);

        rpe = r_hat - v;
        lr  = sigma_t ./ (sigma_r_hat + sigma_t);

        v       = v + lr .* rpe;
        sigma_t = (1 - lr) .* sigma_t;

        % store chosen p_hat
        p_hat = p_hat_all(c);
    end

    lik = lik + belief_gold*log(p_belief) + (1-belief_gold)*log(1-p_belief);

    latents.choiceprob(n,:) = exp(q)./sum(exp(q));
    latents.lr(n,:)         = lr;
    latents.rpe(n,:)        = rpe;
    latents.v(n,:)          = v;
    latents.p_hat(n,1)      = p_hat;
    latents.better_choice(n,1) = data.better_choice(n);
    latents.belief_gold(n,1)   = belief_gold;
    latents.p_belief(n,1)      = p_belief;

end
end
