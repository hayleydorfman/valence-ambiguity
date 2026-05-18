function data = load_data(fname)
    
  
    f = fopen(fname); y = regexp(fgetl(f),',','split');
    fclose(f);
    
    x = csvread(fname,1);
    
    for i = 1:length(y)
        try
            D.(y{i}) = x(:,i);
        end
    end
    
    subs = unique(D.subj_num);
    
    for s = 1:length(subs)
        ix = D.subj_num==subs(s);
        data(s).sub = subs(s);
        data(s).c = D.subj_choice(ix);
        data(s).r_shown = D.feedback(ix); % when feedback is provided only for chosen arm
        data(s).r = [D.feedback_left(ix) D.feedback_right(ix)]; % when feedback is provided for both arms
        data(s).cond = D.condition_num(ix);
        data(s).block = D.block(ix);
        data(s).ambig = D.ambiguity(ix);
        data(s).guess_acc = D.guess_accuracy(ix);
        data(s).choice_acc = D.choice_accuracy(ix);
        data(s).latent_guess = D.guess_num(ix);
        data(s).better_choice = D.better_choice(ix);
        data(s).sd = D.sd(ix);
        data(s).N = length(data(s).c);

    end
