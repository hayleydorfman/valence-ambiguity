function [lik,latents] = lik_ambigcounter_1LR_skip(x,data)
    
    % Likelihood function for Q-learning on two-armed bandit with single
    % learning rate.
    % NOTE: CHOSEN option feedback is AMBIGUOUS; COUNTERFACTUAL feedback is
    % AMBIGUOUS. AMBIGUOUS outcomes are SKIPPED.
    %
    % USAGE: lik = lik_1LR_sticky(x,data)
    %
    % INPUTS:
    %   x - parameters:
    %       x(1) - inverse temperature
    %       x(2) - learning rates
    %       x(3) - stickiness
    %   data - structure with the following fields
    %          .c - [N x 1] choices
    %          .r - [N x 1] rewards
    %
    % OUTPUTS:
    %   lik - log-likelihood
    %
    % Rahul Bhui & Hayley Dorfman 2021
    
    % parameters
    b = x(1);           % inverse temperature
    lr = x(2);  % learning rate 
    sticky = x(3);      % stickiness

    
    % initialization
    lik = 0;             % log-likelihood

    
    for n = 1:data.N
        
        if n==1 || data.block(n)~=data.block(n-1)
            v = zeros(1,2);  % initial values
            u = zeros(1,2);
        end
        
        c = data.c(n); % chosen option (1 = left, 2 = right)
        uc = 3 - c; % unchosen option (1 = left, 2 = right)
        r = data.r(n,:);
        belief_gold = data.latent_guess(n); %subj belief about rocks (0) or gold (1)
        q = b*v + sticky*u;
        u = zeros(1,2); u(c) = 1;
        lik = lik + q(c) - logsumexp(q,2);
        rpe = r-v;
        v(c) = v(c) + (1-data.ambig(n))*lr*rpe(c); %doesn't update on ambiguous trials
        v(uc) = v(uc) + (1-data.ambig(n))*lr*rpe(uc); %doesn't update on ambiguous trials
        p_belief = (1-data.ambig(n))*(.99*(r(c) > 0) + 0.01*(r(c) < 0)) + (data.ambig(n)*0.5);
        lik = lik + belief_gold*log(p_belief)+(1-belief_gold)*log(1-p_belief);

            latents.lr(n,1) = lr;
            latents.v(n,:) = v;
            latents.v_chosen(n,1) = v(c);
            latents.r(n,:) = r;
            latents.rpe(n,:) = rpe;
            latents.chosen(n,1) = c;
            latents.choiceprob(n,:) = exp(q)./sum(exp(q));
            latents.better_choice(n,1) = data.better_choice(n);
            latents.belief_gold(n,1) = belief_gold;
            latents.p_belief(n,1) = p_belief;

        
    end