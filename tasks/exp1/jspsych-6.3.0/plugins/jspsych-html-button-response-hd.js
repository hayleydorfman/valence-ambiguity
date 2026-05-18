/**
 * jspsych-html-button-response
 * Josh de Leeuw
 *
 * plugin for displaying a stimulus and getting a button response
 *
 * documentation: docs.jspsych.org
 *
 **/

jsPsych.plugins["html-button-response-hd"] = (function() {

  var plugin = {};

  plugin.info = {
    name: 'html-button-response-hd',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'Stimulus',
        default: undefined,
        description: 'The HTML string to be displayed'
      },
      choices: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Choices',
        default: undefined,
        array: true,
        description: 'The labels for the buttons.'
      },
      button_html: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Button HTML',
        default: '<button class="jspsych-btn">%choice%</button>',
        array: true,
        description: 'The html of the button. Can create own style.'
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'Any content here will be displayed under the button.'
      },
      stimulus_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Stimulus duration',
        default: null,
        description: 'How long to hide the stimulus.'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: null,
        description: 'How long to show the trial.'
      },
      margin_vertical: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Margin vertical',
        default: '0px',
        description: 'The vertical margin of the button.'
      },
      margin_horizontal: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Margin horizontal',
        default: '8px',
        description: 'The horizontal margin of the button.'
      },
      response_ends_trial: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Response ends trial',
        default: true,
        description: 'If true, then trial will end when user responds.'
      },
      gold_image: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'Positive feedback image',
        default: null,
        description: 'Positive feedback.'
      },
      rock_image: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name: 'Negative feedback image',
        default: null,
        description: 'Negative feedback.'
      },
      dirty_image: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Ambiguous feedback image',
        default: null,
        description: 'Ambiguous feedback.'
      },
      latent_intervention: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'latent intervention',
        default: null,
        description: 'Whether the feedback should be ambiguous or not.'
      },
      true_feedback_L: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'True feedback',
        default: null,
        description: 'Whether the true feedback was positive or negative.'
      },
      magnitude_L: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Magnitude',
        default: null,
        description: 'Reward Magnitude.'
      },
      true_feedback_R: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'True feedback',
        default: null,
        description: 'Whether the true feedback was positive or negative.'
      },
      magnitude_R: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Magnitude',
        default: null,
        description: 'Reward Magnitude.'
      },
    }
  }

  plugin.trial = function(display_element, trial) {

    var prev_choice = jsPsych.data.get().last(1).filter({task_component: 'choice'}).select('response').values
    //console.log('prev_choice is '+ prev_choice)


    // display choice stimulus
    var html = '<div id="jspsych-html-button-response-hd-stimulus">'+trial.stimulus+'</div>';


//if trial.true_feedback_L == -1, rocks on left, if trial.true_feedback_L == 1, gold on left


    // display feedback stimulus
    if(prev_choice == 0){ //if the prev choice was the left mine
      if(trial.true_feedback_L == -1 && trial.true_feedback_R == -1 && trial.latent_intervention == 0){ //if feedback on L should be rocks and latent should be known & feedback on R is rocks
      html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-left:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate left choice
      html += '<img src="'+trial.rock_image+'" class ="fb_position_left"></hr>'; //rocks on left
      html += '<p class = "valence_position_left"> - </p>';
      html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of loss
      html += '<img src="'+trial.rock_image+'" class ="fb_position_right">'; //rocks
      html += '<p class = "valence_position_right"> - </p>';
      html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of loss

      //console.log('trial.magnitude_L ' + trial.magnitude_L)

      var trial_feedback = trial.magnitude_L;
      var trial_ambiguity = 0;
      var trial_valence = 0; //neg is 0, pos is 1, ambig is 2
      var trial_valence_string = 'Rocks';

      //save feedback as 0
      //save ambiguity as 0
      //save valence as neg
      // if(trial.true_feedback_R == -1){ //if feedback should be rocks and latent should be known
      //   html += '<img src="'+trial.rock_image+'" class ="fb_position_right">'; //rocks
      //   html += '<p class = "valence_position_right"> - </p>';
      //   html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of loss
      // }
      }

       else if(trial.true_feedback_L == 1 && trial.true_feedback_R == 1 && trial.latent_intervention == 0){ //if feedback should be gold and latent is known
      html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-left:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate left choice
      html += '<img src="'+trial.gold_image+'" class ="fb_position_left">'; //gold
      html += '<p class = "valence_position_left"> + </p>';
      html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win
      html += '<img src="'+trial.gold_image+'" class ="fb_position_right">'; //gold
      html += '<p class = "valence_position_right"> + </p>';
      html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win

      var trial_feedback = trial.magnitude_L;
      var trial_ambiguity = 0;
      var trial_valence = 1;
      var trial_valence_string = 'Gold';

      //save feedback as 1
      //save ambiguity as 0
      //save valence as pos

      }
             else if(trial.true_feedback_L == -1 && trial.true_feedback_R == 1 && trial.latent_intervention == 0){
            html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-left:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate left choice
            html += '<img src="'+trial.rock_image+'" class ="fb_position_left">'; //gold
            html += '<p class = "valence_position_left"> - </p>';
            html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win
            html += '<img src="'+trial.gold_image+'" class ="fb_position_right">'; //gold
            html += '<p class = "valence_position_right"> + </p>';
            html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win

            var trial_feedback = trial.magnitude_L;
            var trial_ambiguity = 0;
            var trial_valence = 0;
            var trial_valence_string = 'Rocks';

            //save feedback as 0
            //save ambiguity as 0
            //save valence as neg
          }

          else if(trial.true_feedback_L == 1 && trial.true_feedback_R == -1 && trial.latent_intervention == 0){
         html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-left:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate left choice
         html += '<img src="'+trial.gold_image+'" class ="fb_position_left">'; //gold
         html += '<p class = "valence_position_left"> + </p>';
         html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win
         html += '<img src="'+trial.rock_image+'" class ="fb_position_right">'; //gold
         html += '<p class = "valence_position_right"> - </p>';
         html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win

         var trial_feedback = trial.magnitude_L;
         var trial_ambiguity = 0;
         var trial_valence = 1;
         var trial_valence_string = 'Gold';

         //save feedback as 1
         //save ambiguity as 0
         //save valence as pos
       }

        else if(trial.latent_intervention == 1 && trial.true_feedback_R == -1){ //if R feedback is rocks and latent is unknown
        html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-left:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate left choice
        html += '<img src="'+trial.dirty_image+'" class ="fb_position_left">'; //dirty
        html += '<p class = "valence_position_left"> ? </p>';
        html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of loss
        html += '<img src="'+trial.rock_image+'" class ="fb_position_right">'; //gold
        html += '<p class = "valence_position_right"> - </p>';
        html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win

        var trial_feedback = trial.magnitude_L;
        var trial_ambiguity = 1;
        var trial_valence = 2;
        var trial_valence_string = 'Dirty';

        //save feedback as 0
        //save ambiguity as 1
        //save valence as ambig
        }
        else if(trial.latent_intervention == 1 && trial.true_feedback_R == 1){ //if R feedback is gold and latent is unknown
        html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-left:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate left choice
        html += '<img src="'+trial.dirty_image+'" class ="fb_position_left">'; //dirty
        html += '<p class = "valence_position_left"> ? </p>';
        html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win
        html += '<img src="'+trial.gold_image+'" class ="fb_position_right">'; //gold
        html += '<p class = "valence_position_right"> + </p>';
        html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win

        var trial_feedback = trial.magnitude_L;
        var trial_ambiguity = 1;
        var trial_valence = 2;
        var trial_valence_string = 'Dirty';

        //save feedback as 1
        //save ambiguity as 1
        //save valence as ambig
      }
    }
      else if (prev_choice == 1){
        if(trial.true_feedback_R == -1 && trial.true_feedback_L == -1 && trial.latent_intervention == 0){ //if feedback should be rocks and latent should be known
          html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-right:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate right choice
          html += '<img src="'+trial.rock_image+'" class ="fb_position_right">'; //rocks
          html += '<p class = "valence_position_right"> - </p>';
          html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of loss
          html += '<img src="'+trial.rock_image+'" class ="fb_position_left">'; //gold
          html += '<p class = "valence_position_left"> - </p>';
          html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win

          var trial_feedback = trial.magnitude_R;
          var trial_ambiguity = 0;
          var trial_valence = 0;
          var trial_valence_string = 'Rocks';

          //save feedback as 0
          //save ambiguity as 0
          //save valence as neg
          }
          else if(trial.true_feedback_R == 1 && trial.true_feedback_L == 1 && trial.latent_intervention == 0){ //if feedback should be gold and latent is known
          html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-right:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate right choice
          html += '<img src="'+trial.gold_image+'" class ="fb_position_right">'; //gold
          html += '<p class = "valence_position_right"> + </p>';
          html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win
          html += '<img src="'+trial.gold_image+'" class ="fb_position_left">'; //gold
          html += '<p class = "valence_position_left"> + </p>';
          html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win

          var trial_feedback = trial.magnitude_R;
          var trial_ambiguity = 0;
          var trial_valence = 1;
          var trial_valence_string = 'Gold';

          //save feedback as 1
          //save ambiguity as 0
          //save valence as pos

          }
          else if(trial.true_feedback_R == 1 && trial.true_feedback_L == -1 && trial.latent_intervention == 0){ //if feedback should be gold and latent is known
          html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-right:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate right choice
          html += '<img src="'+trial.gold_image+'" class ="fb_position_right">'; //gold
          html += '<p class = "valence_position_right"> + </p>';
          html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win
          html += '<img src="'+trial.rock_image+'" class ="fb_position_left">'; //gold
          html += '<p class = "valence_position_left"> - </p>';
          html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win

          var trial_feedback = trial.magnitude_R;
          var trial_ambiguity = 0;
          var trial_valence = 1;
          var trial_valence_string = 'Gold';

          //save feedback as 1
          //save ambiguity as 0
          //save valence as pos

          }
          else if(trial.true_feedback_R == -1 && trial.true_feedback_L == 1 && trial.latent_intervention == 0){ //if feedback should be gold and latent is known
          html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-right:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate right choice
          html += '<img src="'+trial.rock_image+'" class ="fb_position_right">'; //gold
          html += '<p class = "valence_position_right"> - </p>';
          html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win
          html += '<img src="'+trial.gold_image+'" class ="fb_position_left">'; //gold
          html += '<p class = "valence_position_left"> + </p>';
          html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win

          var trial_feedback = trial.magnitude_R;
          var trial_ambiguity = 0;
          var trial_valence = 0;
          var trial_valence_string = 'Rocks';

          //save feedback as 1
          //save ambiguity as 0
          //save valence as pos

          }
            else if(trial.latent_intervention == 1 && trial.true_feedback_L == -1){ //if L feedback is rocks and latent is unknown
            html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-right:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate right choice
            html += '<img src="'+trial.dirty_image+'" class ="fb_position_right">'; //dirty
            html += '<p class = "valence_position_right"> ? </p>';
            html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of loss
            html += '<img src="'+trial.rock_image+'" class ="fb_position_left">'; //gold
            html += '<p class = "valence_position_left"> - </p>';
            html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win

            var trial_feedback = trial.magnitude_R;
            var trial_ambiguity = 1;
            var trial_valence = 2;
            var trial_valence_string = 'Dirty';

            //save feedback as 0
            //save ambiguity as 1
            //save valence as ambig
            }
            else if(trial.latent_intervention == 1 && trial.true_feedback_L == 1){ //if L feedback is gold and latent is unknown
            html += '<hr style="height:15px;background-color:MediumAquaMarine;margin-right:0%;width:50%; margin-top:0%;margin-bottom:5%">', //indicate right choice
            html += '<img src="'+trial.dirty_image+'" class ="fb_position_right">'; //dirty
            html += '<p class = "valence_position_right"> ? </p>';
            html += '<p class = "magnitude_position_right">'+Math.abs(trial.magnitude_R)+'</p>'; //magnitude of win
            html += '<img src="'+trial.gold_image+'" class ="fb_position_left">'; //gold
            html += '<p class = "valence_position_left"> + </p>';
            html += '<p class = "magnitude_position_left">'+Math.abs(trial.magnitude_L)+'</p>'; //magnitude of win

            var trial_feedback = trial.magnitude_R;
            var trial_ambiguity = 1;
            var trial_valence = 2;
            var trial_valence_string = 'Dirty';

            //save feedback as 1
            //save ambiguity as 1
            //save valence as ambig

            }
          }

          display_element.innerHTML = html;


    //display buttons
    var buttons = [];
    if (Array.isArray(trial.button_html)) {
      if (trial.button_html.length == trial.choices.length) {
        buttons = trial.button_html;
      } else {
        console.error('Error in html-button-response plugin. The length of the button_html array does not equal the length of the choices array');
      }
    } else {
      for (var i = 0; i < trial.choices.length; i++) {
        buttons.push(trial.button_html);
      }
    }
    html += '<div id="jspsych-html-button-response-hd-btngroup">';
    for (var i = 0; i < trial.choices.length; i++) {
      var str = buttons[i].replace(/%choice%/g, trial.choices[i]);
      html += '<div class="jspsych-html-button-response-hd-button" style="display: inline-block; margin:'+trial.margin_vertical+' '+trial.margin_horizontal+'" id="jspsych-html-button-response-hd-button-' + i +'" data-choice="'+i+'">'+str+'</div>';
    }
    html += '</div>';

    //show prompt if there is one
    if (trial.prompt !== null) {
      html += trial.prompt;
    }
    display_element.innerHTML = html;

    // start time
    var start_time = performance.now();

    // add event listeners to buttons
    for (var i = 0; i < trial.choices.length; i++) {
      display_element.querySelector('#jspsych-html-button-response-hd-button-' + i).addEventListener('click', function(e){
        var choice = e.currentTarget.getAttribute('data-choice'); // don't use dataset for jsdom compatibility
        after_response(choice);
      });
    }

    // store response
    var response = {
      rt: null,
      button: null
    };


    // function to handle responses by the subject
    function after_response(choice) {

      // measure rt
      var end_time = performance.now();
      var rt = end_time - start_time;
      response.button = parseInt(choice);
      response.rt = rt;
//console.log('jspsych-html-button-response-hd-stimulus' + display_element.querySelector('#jspsych-html-button-response-hd-stimulus'))
      // after a valid response, the stimulus will have the CSS class 'responded'
      // which can be used to provide visual feedback that a response was recorded
      display_element.querySelector('#jspsych-html-button-response-hd-stimulus').className += ' responded';

      // disable all the buttons after a response
      var btns = document.querySelectorAll('.jspsych-html-button-response-hd-button button');
      for(var i=0; i<btns.length; i++){
        //btns[i].removeEventListener('click');
        btns[i].setAttribute('disabled', 'disabled');
      }

      if (trial.response_ends_trial) {
        end_trial();
      }
    };

    // function to end trial when it is time
    function end_trial() {

      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // gather the data to store for the trial
      var trial_data = {
        rt: response.rt,
        stimulus: trial.stimulus,
        response: response.button,
        feedback: trial_feedback,
        feedback_image: trial_valence_string,
        ambiguity: trial_ambiguity,
        valence: trial_valence,
        guess: trial.choices[response.button],
        feedback_left: trial.magnitude_L,
        feedback_right: trial.magnitude_R,

      };

      // clear the display
      display_element.innerHTML = '';

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };

    // hide image if timing is set
    if (trial.stimulus_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        display_element.querySelector('#jspsych-html-button-response-hd-stimulus').style.visibility = 'hidden';
      }, trial.stimulus_duration);
    }

    // end trial if time limit is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.trial_duration);
    }

  };

  return plugin;
})();
