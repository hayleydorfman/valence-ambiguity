function [lik,latents] = lik_unambigcounter_confirm_2lr(x,data)
    
    % Likelihood function for confirmation/disconfirmation model with forgone outcomes
    % Updates values using both chosen and forgone (unchosen) outcomes
    % Confirmatory evidence (positive chosen, negative forgone) uses lr_confirm
    % Disconfirmatory evidence (negative chosen, positive forgone) uses lr_disconfirm
    %
    % USAGE: lik = lik_unambigcounter_confirm_2lr(x,data)
    %
    % INPUTS:
    %   x - parameters:
    %       x(1) - inverse temperature
    %       x(2) - learning rate for confirmatory evidence (lr_confirm)
    %       x(3) - learning rate for disconfirmatory evidence (lr_disconfirm)
    %       x(4) - stickiness
    %   data - structure with the following fields
    %          .c - [N x 1] choices
    %          .r - [N x 2] rewards (both chosen and forgone)
    %          .ambig - [N x 1] ambiguity flags
    %          .latent_guess - [N x 1] subject belief
    %
    % OUTPUTS:
    %   lik - log-likelihood
    %
    % Hayley Dorfman 2026
    
    % parameters
    b = x(1);              % inverse temperature
    lr_confirm = x(2);     % learning rate for confirmatory evidence
    lr_disconfirm = x(3);  % learning rate for disconfirmatory evidence
    sticky = x(4);         % stickiness
    
    % initialization
    lik = 0;
    
    for n = 1:data.N
        
        if n==1 || data.block(n)~=data.block(n-1)
            v = zeros(1,2);  % initial values
            u = zeros(1,2);
        end
        
        c = data.c(n);   % chosen option
        uc = 3 - c;      % unchosen option
        r = data.r(n,:); % both outcomes
        r_chosen = r(c);
        r_forgone = r(uc);
        
        belief_gold = data.latent_guess(n);
        
        % Choice likelihood
        q = b*v + sticky*u;
        u = zeros(1,2); u(c) = 1;
        lik = lik + q(c) - logsumexp(q,2);
        
        % Update chosen option (skip if ambiguous)
        if ~data.ambig(n)
            rpe_c = r_chosen - v(c);
            if r_chosen > 0
                % Positive chosen outcome = confirmatory
                v(c) = v(c) + lr_confirm * rpe_c;
            else
                % Negative chosen outcome = disconfirmatory
                v(c) = v(c) + lr_disconfirm * rpe_c;
            end
        end
        
        % Update unchosen option (always unambiguous)
        rpe_uc = r_forgone - v(uc);
        if r_forgone < 0
            % Negative forgone = confirmatory (I avoided a bad outcome)
            v(uc) = v(uc) + lr_confirm * rpe_uc;
        else
            % Positive forgone = disconfirmatory (I missed a good outcome)
            v(uc) = v(uc) + lr_disconfirm * rpe_uc;
        end
        
        % Belief likelihood
        p_belief = (1-data.ambig(n))*(.99*(r_chosen > 0) + 0.01*(r_chosen < 0)) + (data.ambig(n)*0.5);
        lik = lik + belief_gold*log(p_belief)+(1-belief_gold)*log(1-p_belief);
        
        % Latents
        latents.lr_confirm(n,1) = lr_confirm;
        latents.lr_disconfirm(n,1) = lr_disconfirm;
        latents.v(n,:) = v;
        latents.v_chosen(n,1) = v(c);
        latents.r(n,:) = r;
        latents.rpe_chosen(n,1) = r_chosen - v(c);
        latents.rpe_forgone(n,1) = r_forgone - v(uc);
        latents.chosen(n,1) = c;
        latents.choiceprob(n,:) = exp(q)./sum(exp(q));
        latents.better_choice(n,1) = data.better_choice(n);
        latents.belief_gold(n,1) = belief_gold;
        latents.p_belief(n,1) = p_belief;
    end
end