function [results, bms_results] = fit_models(experiment,results,models)
    
    % Fit RL models using MFIT.
    %
    % USAGE: [results, bms_results] = fit_models(data)
    %
    % INPUTS:
    %   data - [S x 1] structure array of data for S subjects
    %
    % OUTPUTS:
    %   results - [M x 1] model fits
    %   bms_results - Bayesian model selection results
    %
    % Hayley Dorfman, 2026
    
    if experiment == 1 % Main experiment
        filename = 'df_behav_exp1.csv';
        likfuns = {'lik_unambigcounter_1LR_skip' 'lik_unambigcounter_bayesian_1prior_skip' 'lik_unambigcounter_bayesian_1prior' 'lik_unambigcounter_bayesian_3prior_skip' 'lik_unambigcounter_bayesian_3prior' 'lik_unambigcounter_2LR_skip' 'lik_unambigcounter_2LR_bias' 'lik_unambigcounter_2LR_skip_3Q' 'lik_unambigcounter_2LR_bias_3Q' 'lik_unambigcounter_confirm_2lr'}; 
   elseif experiment == 2 % Supplemental experiment
        filename = 'df_behav_exp2.csv';
        likfuns = {'lik_ambigcounter_1LR_skip' 'lik_ambigcounter_bayesian_1prior_skip' 'lik_ambigcounter_bayesian_1prior' 'lik_ambigcounter_bayesian_3prior_skip' 'lik_ambigcounter_bayesian_3prior' 'lik_ambigcounter_2LR_skip' 'lik_ambigcounter_2LR_bias' 'lik_ambigcounter_2LR_skip_3Q' 'lik_ambigcounter_2LR_bias_3Q'};
    end
    
    data = load_data(filename);
    
    if nargin < 3; models = 1:length(likfuns); end
    
    for mi = 1:length(models)
        m = models(mi);
        disp(['... fitting model ',num2str(m)]);
        
        switch likfuns{m}
            
        % versions for counterfactual feedback that is unambiguous 
           
            case 'lik_unambigcounter_1LR_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);

            case 'lik_unambigcounter_bayesian_1prior'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean','logpdf',@(x) 0,'lb',-100,'ub',100);

            case 'lik_unambigcounter_bayesian_1prior_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean','logpdf',@(x) 0,'lb',-100,'ub',100);

            case 'lik_unambigcounter_bayesian_3prior'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean1','logpdf',@(x) 0,'lb',-100,'ub',100);
                param(5) = struct('name','prior_mean2','logpdf',@(x) 0,'lb',-100,'ub',100); 
                param(6) = struct('name','prior_mean3','logpdf',@(x) 0,'lb',-100,'ub',100);

            case 'lik_unambigcounter_bayesian_3prior_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean1','logpdf',@(x) 0,'lb',-100,'ub',100);
                param(5) = struct('name','prior_mean2','logpdf',@(x) 0,'lb',-100,'ub',100); 
                param(6) = struct('name','prior_mean3','logpdf',@(x) 0,'lb',-100,'ub',100);                   
                                
           case 'lik_unambigcounter_2LR_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                
           case 'lik_unambigcounter_2LR_skip_3Q'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(5) = struct('name','q_poor','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(6) = struct('name','q_rich','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(7) = struct('name','q_neutral','logpdf',@(x) 0,'lb',-15,'ub',15);            
                
            case 'lik_unambigcounter_2LR_bias'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(5) = struct('name','bias','logpdf',@(x) 0,'lb',-1,'ub',1);
             
            case 'lik_unambigcounter_2LR_bias_3Q'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(5) = struct('name','bias','logpdf',@(x) 0,'lb',-1,'ub',1);
                param(6) = struct('name','q_poor','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(7) = struct('name','q_rich','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(8) = struct('name','q_neutral','logpdf',@(x) 0,'lb',-15,'ub',15);
                
            case 'lik_unambigcounter_confirm_2lr'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_confirm','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_disconfirm','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
           
    % versions for counterfactual feedback that is ambiguous  
            
            case 'lik_ambigcounter_1LR_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);

            case 'lik_ambigcounter_bayesian_1prior'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean','logpdf',@(x) 0,'lb',-100,'ub',100);

            case 'lik_ambigcounter_bayesian_1prior_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean','logpdf',@(x) 0,'lb',-100,'ub',100);

            case 'lik_ambigcounter_bayesian_3prior'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean1','logpdf',@(x) 0,'lb',-100,'ub',100);
                param(5) = struct('name','prior_mean2','logpdf',@(x) 0,'lb',-100,'ub',100); 
                param(6) = struct('name','prior_mean3','logpdf',@(x) 0,'lb',-100,'ub',100);

            case 'lik_ambigcounter_bayesian_3prior_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(3) = struct('name','prior_sd','logpdf',@(x) 0,'lb',0.1,'ub',100);
                param(4) = struct('name','prior_mean1','logpdf',@(x) 0,'lb',-100,'ub',100);
                param(5) = struct('name','prior_mean2','logpdf',@(x) 0,'lb',-100,'ub',100); 
                param(6) = struct('name','prior_mean3','logpdf',@(x) 0,'lb',-100,'ub',100);                         
                                
           case 'lik_ambigcounter_2LR_skip'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                
           case 'lik_ambigcounter_2LR_skip_3Q'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(5) = struct('name','q_poor','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(6) = struct('name','q_rich','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(7) = struct('name','q_neutral','logpdf',@(x) 0,'lb',-15,'ub',15);        
                
            case 'lik_ambigcounter_2LR_bias'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(5) = struct('name','bias','logpdf',@(x) 0,'lb',-1,'ub',1);
                
            case 'lik_ambigcounter_2LR_bias_3Q'
                param(1) = struct('name','invtemp','logpdf',@(x) log(gampdf(x,4.82,0.88)),'lb',1e-3,'ub',20);
                param(2) = struct('name','lr_pos','logpdf',@(x) 0,'lb',0,'ub',1);
                param(3) = struct('name','lr_neg','logpdf',@(x) 0,'lb',0,'ub',1);
                param(4) = struct('name','sticky','logpdf',@(x) 0,'lb',-10,'ub',10);
                param(5) = struct('name','bias','logpdf',@(x) 0,'lb',-1,'ub',1);
                param(6) = struct('name','q_poor','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(7) = struct('name','q_rich','logpdf',@(x) 0,'lb',-15,'ub',15);
                param(8) = struct('name','q_neutral','logpdf',@(x) 0,'lb',-15,'ub',15); 
                
        end

        fun = str2func(likfuns{m});
        results(m) = mfit_optimize(fun,param,data);
        clear param
    end
    
    % Bayesian model selection
    if nargout > 1
        bms_results = mfit_bms_aic(results,1);  % uses AIC to calculate PXP (can use mfit_bms.m if you want to use BIC)
    end