//= require jquery-3.3.1.js
//= require jquery_ujs
//= require jquery-ui
$(function(){


$(".gruppe_select").change(function(event) {
    event.preventDefault();
  
    var playerid = $(this).attr("playerid");
    var gruppennummer = $(this).val();
   // var currentgroup = $(this).data("currentgroup");
    
    //alert("Spieler " + playerid + " in die Gruppe " + gruppennummer );
    if ($(this).val() === '0') {
     //   alert("Spieler " + playerid + " aus der Gruppe " + gruppennummer + " raus");
        $.ajax({

            type: "POST",
            url: "/players/remove_group_from_player/" + playerid + "/" + gruppennummer,
            processData: false,
            error: function (data, textStatus, jqXHR) { notify(textStatus);  },
            success: function(msg) {
         
                    
                    }
                    ,
            data: 'authenticity_token=' + encodeURIComponent('<%= form_authenticity_token if protect_against_forgery? %>')         
    
        });     
    } else {
     //   alert("Spieler " + playerid + " in die Gruppe " + gruppennummer );
        $.ajax({

            type: "POST",
            url: "/players/add_player_to_group/" + playerid + "/" + gruppennummer,
            processData: false,
            error: function (data, textStatus, jqXHR) { notify(textStatus);  },
            success: function(msg) {
           
                 
                    }
                    ,
            data: 'authenticity_token=' + encodeURIComponent('<%= form_authenticity_token if protect_against_forgery? %>')         
    
        });  

   

    }
   
 });
 //$(".ball_select").change(function(event) {
 $(document).on("change", ".ball_select", function(event){
    event.preventDefault();
    
    var matchid =  $(this).data("matchid");
    var setnummer= $(this).data("set");
    var ballanzahl_vorzeichen = $(this).val()
    var ballanzahl = ballanzahl_vorzeichen;
    var gruppennummer = $('#einzelergebnisse').attr('gruppennummer');
 
    // alert(satz_plus);
   // console.log("ballanzahl: " + ballanzahl);

    // alert(matchid + "/" + setnummer + "/" + ballanzahl)
    
  
        $.ajax({

            type: "POST",
            url: "/players/update_set_in_match/" + matchid + "/" + setnummer + "/" + encodeURIComponent(ballanzahl),
            processData: false,
            error: function (data, textStatus, jqXHR) { notify(textStatus);  },
            success: function(msg) {
                
                var satz_plus = $('#satzverhaeltnis_' + matchid + "_plus").text();
                var satz_minus = $('#satzverhaeltnis_' + matchid + "_minus").text();
                 var next_set1 = setnummer + 1;
                 var next_set2 = next_set1 + 1;
          
                   if(satz_plus == "3" || satz_minus == "3"){
                   
                    $('#option_results_' + matchid + '_set' + next_set1).attr("disabled","disabled");
                    $('#option_results_' + matchid + '_set' + next_set2).attr("disabled","disabled");
                   }else{
                    $('#option_results_' + matchid + '_set' + next_set1).removeAttr("disabled");
                    $('#option_results_' + matchid + '_set' + next_set2).removeAttr("disabled");
                   }
                }
                    ,
            data: 'gruppennummer=' + gruppennummer + '&authenticity_token=' + encodeURIComponent('<%= form_authenticity_token if protect_against_forgery? %>')         
    
        });     
  
  
   
 });


 $(document).on("click", "#erzeuge_player", function(event){
    event.preventDefault();
    var player = $("#newplayer").val();
  
        $.ajax({

            type: "POST",
            url: "/players/erzeuge_player/" + player,
            processData: false,
            error: function (data, textStatus, jqXHR) { notify(textStatus);  },
            success: function(msg) {
             //   alert("added");
                    window.location.href="/players";
                  
                }
                    ,
            data: 'authenticity_token=' + encodeURIComponent('<%= form_authenticity_token if protect_against_forgery? %>')         
    
        });     
  
  
   
 });




});