function [lik,latents] = lik_ambigcounter_bayesian_3prior_skip(x,data)
    
    % Likelihood function for Bayesian learning model on two-armed bandit with
    % ambiguously valenced feedback & counterfactual feedback.
    % NOTE: CHOSEN option feedback is AMBIGUOUS; COUNTERFACTUAL feedback is
    % AMBIGUOUS. AMBIGUOUS outcomes are SKIPPED.
    
    % 3-prior Bayesian Model
    
    % 6 free parameters (inverse temp, sticky, prior variance, prior mean for each of 3 conditions)
    %
    % USAGE: lik = rllik2(x,data)
    %
    % INPUTS:
    %   x - parameters:
    %       x(1) - inverse temperature
    %       x(2) - stickiness
    %       x(3) - prior variance
    %       x(4:6) = prior means
    %   data - structure with the following fields
    %          .c - [N x 1] choices
    %          .r - [N x 1] rewards
    %          ...
    %
    % OUTPUTS:
    %   lik - log-likelihood
    %
    % Rahul Bhui & Hayley Dorfman 2021
    
    % parameters
    b = x(1);           % inverse temperature
    sticky = x(2);      % stickiness
    prior_sd = x(3);
    prior_mean = x(4:6);

    
    % initialization
    lik = 0;            % log-likelihood
    
    for n = 1:data.N
        
        if n==1 || data.block(n)~=data.block(n-1)
            v = zeros(1,2) + prior_mean(data.cond(n));  % initial values [v1 v2]
            u = zeros(1,2); % stickiness indicator [u1 u2]
            t = 0; % trial number
            sigma_t = zeros(1,2) + prior_sd^2; %variance for each arm [var1 var2]
        end
        
        t = t + 1;
        c = data.c(n); % chosen option (1 = left, 2 = right); scalar
        uc = 3 - c; % unchosen option (1 = left, 2 = right)
        r = data.r(n,:); %[reward1 reward2]
        belief_gold = data.latent_guess(n); %subj belief about rocks (0) or gold (1); scalar
        noise = zeros(1,2) + data.sd(n)^2; %[noise1 noise2]
        q = b*v + sticky*u; %[q1 q2]
        u = zeros(1,2); u(c) = 1; %[u1 u2]
        lik = lik + q(c) - logsumexp(q,2); %likelihood; scalar
        if isnan(lik); keyboard; end

        
        if data.ambig(n) == 0 %if the trial is unambiguous
            p_hat = NaN;
            p_belief = .99*(r(c) > 0) + 0.01*(r(c) < 0); % believed probability that chosen outcome is positive = true probability (bounded between 1%-99%)
            r_hat = r; % [believed_reward1 believed_reward2] = [reward1 reward2]
            rpe = r_hat-v; % [believed_rpe1 believed_rpe2] = [believed_reward1 believed_reward2] - [value_estimate1 value_estimate2]
            lr = sigma_t./(noise + sigma_t); % [lr1 lr2] = [var1 var2]/[noise1+var1 noise2+var2]
            v = v + lr.*rpe; % [value_estimate1 value_estimate2] = [value_estimate1+lr1*believed_rpe1 value_estimate2+lr2*believed_rpe2]
            sigma_t = (1 - lr).*sigma_t; % sigma is the variance not SD! [var1 var2] = [(1-lr1)*var1 (1-lr2)*var2]
        
        elseif data.ambig(n)== 1 %if the trial is ambiguous
            p_hat = normpdf(abs(r(c)), v(c), sqrt(noise(c)))/(normpdf(abs(r(c)), v(c), sqrt(noise(c))) + normpdf(-abs(r(c)), v(c), sqrt(noise(c)))); % believed probability that ambiguous outcome is positive
            p_hat = bound(p_hat, .01, .99); % bound p_hat between 1% and 99%
            p_belief = p_hat;
            r_hat = r; % [believed_reward1 believed_reward2] = [reward1 reward2] (will be amended in next line)
            r_hat(c) = 2*abs(r(c))*(p_hat-.5); % believed_reward(chosen) = E(believed reward)
            rpe = r_hat-v; % [believed_rpe1 believed_rpe2] = [believed_reward1 believed_reward2] - [value_estimate1 value_estimate2]
            sigma_r_hat = noise; % [imputed_reward_noise1 imputed_reward_noise2] = [noise1 noise2] (will be amended in next line)
            sigma_r_hat(c) = noise(c) + 4*abs(r(c))^2 * p_hat * (1-p_hat); % imputed_reward_noise(chosen) = noise(chosen) + ambiguity(chosen)
            lr = sigma_t./(sigma_r_hat + sigma_t); % [lr1 lr2] = [var1 var2]/[noise1+var1 noise2+var2]
            lr(c) = 0; % lr(chosen) = 0; ambiguous outcome is skipped
            lr(uc) = 0; % lr(unchosen) = 0; ambiguous outcome is skipped 
            v = v + lr.*rpe; % [value_estimate1 value_estimate2] = [value_estimate1+lr1*believed_rpe1 value_estimate2+lr2*believed_rpe2]
            sigma_t = (1 - lr).*sigma_t; % sigma is the variance not SD!
        end

    lik = lik + belief_gold*log(p_belief)+(1-belief_gold)*log(1-p_belief);
        
            latents.choiceprob(n,:) = exp(q)./sum(exp(q));
            latents.v(n,:) = v;
            latents.lr(n,:) = lr;
            latents.rpe(n,:) = rpe;
            latents.p_hat(n,1) = p_hat;
            latents.better_choice(n,1) = data.better_choice(n);
            latents.belief_gold(n,1) = belief_gold;
            latents.p_belief(n,1) = p_belief;


    end