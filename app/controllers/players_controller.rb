class PlayersController < ActionController::Base
    def index
        puts "def index..."
        @players = Player.all.reverse_order
        @players_in_gruppe1_with_results = Hash.new
        @players_in_gruppe2_with_results = Hash.new
        @players_in_gruppe3_with_results = Hash.new
        @players_in_gruppe4_with_results = Hash.new

        @players_in_gruppe1_with_results = berechne_gruppen_ranking("1")
        @players_in_gruppe2_with_results = berechne_gruppen_ranking("2")
        @players_in_gruppe3_with_results = berechne_gruppen_ranking("3")
        @players_in_gruppe4_with_results = berechne_gruppen_ranking("4")



        #p @players_in_gruppe3_with_results
    end

    def update_set_in_match
        require 'uri'

        puts "update_set_in_match..."
        puts "matchid: #{params[:matchid]}"
        puts "set: #{params[:setnummer]}"
        puts "ballanzahl: #{params[:ballanzahl]}"
        puts "gruppennummer: #{params[:gruppennummer]}"
        
        if !params[:ballanzahl].blank?
            ballanzahl = URI.escape(params[:ballanzahl])
            puts "ballanzahl: " + ballanzahl
        else
            ballanzahl = nil
            puts "keine Ballanzahl"
        end
        
        match = Match.where(:id => params[:matchid])
        if params[:setnummer] == "1"
            match.update(:set1 => ballanzahl)
        elsif params[:setnummer] == "2"
            match.update(:set2 => ballanzahl)
        elsif params[:setnummer] == "3"
            match.update(:set3 => ballanzahl)
        elsif params[:setnummer] == "4"
            match.update(:set4 => ballanzahl)
        elsif params[:setnummer] == "5"
            match.update(:set5 => ballanzahl)
        end
      

        match = Match.where(:id => params[:matchid]).first
       
        
        @ballverhaeltnis = berechne_ballverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
        @satzverhaeltnis = berechne_satzverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
        puts "satzverhaeltnis: #{@satzverhaeltnis.inspect}"
        ########################################################
        if @satzverhaeltnis.to_s =~ /3/ # ein abgeschlossenes Spiel #
            @players_in_gruppe_with_results = Hash.new
            @players_in_gruppe_with_results = berechne_gruppen_ranking(params[:gruppennummer])   #
        end                                                    # 
        #########################################################
        
        respond_to do |format|
            format.js
        end
    end

    def berechne_gruppen_ranking(gruppennummer) # dann in die index-Action hinzufügen
        puts "berechne_gruppen_ranking neu... in Gruppe #{gruppennummer}"
        @players_in_group = Player.where(:gruppennummer => gruppennummer)
        @players_h = Hash.new
     
        @players_id_a = []
        @players_in_group.each do |player| 
            @players_id_a << player.id
            @players_h[player.id.to_s] = player.name 
        end
        puts @players_id_a.inspect
        # für jeden Spieler in der Tabelle matches (Spalten player1_id player2_id) seine Einzelergebnisse nachschlagen und zusammenzählen.
        # Dann das Ranking erstellen und rendern.
        players_results_h = Hash.new
     
        #  Das Gruppenranking wird nur berechnet, wenn mehr als 1 Spieler in der Gruppe ist.
       
        if @players_id_a.size > 1 
            @players_id_a.each do | pl_id |
                puts "kuck for pl_id  #{pl_id} (a)"
                match_plus = 0
                match_minus = 0
                puts "pl_id: #{pl_id}"
                matches_player1 = Match.where(:player1_id => pl_id) 
                p matches_player1
                matches_player1.each do | match |
                puts "match.id: " + match.id.to_s
                    ballverhaeltnis = berechne_ballverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
                    satzverhaeltnis = berechne_satzverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
                    

                    if !players_results_h.has_key?(pl_id)
                        if (satzverhaeltnis[0] > satzverhaeltnis[1])
                            match_plus  = match_plus + 1
                        elsif (satzverhaeltnis[0] < satzverhaeltnis[1])

                            match_minus = match_minus + 1
                        end
                        
                        players_results_h[pl_id] = ["match_plus" => match_plus, "match_minus" => match_minus , "name" =>  @players_h[pl_id.to_s], "player_id" => pl_id,  "ball_plus" => ballverhaeltnis[0], "ball_minus" => ballverhaeltnis[1], "satz_plus" => satzverhaeltnis[0], "satz_minus" => satzverhaeltnis[1], "gruppennummer" => gruppennummer ]
                    else
                        players_results_h[pl_id][0]["ball_plus"] = players_results_h[pl_id][0]["ball_plus"] + ballverhaeltnis[0]
                        players_results_h[pl_id][0]["satz_plus"] = players_results_h[pl_id][0]["satz_plus"] + satzverhaeltnis[0]
                        players_results_h[pl_id][0]["ball_minus"] = players_results_h[pl_id][0]["ball_minus"] + ballverhaeltnis[1]
                        players_results_h[pl_id][0]["satz_minus"] = players_results_h[pl_id][0]["satz_minus"] + satzverhaeltnis[1]
                        if (satzverhaeltnis[0] > satzverhaeltnis[1])
                            players_results_h[pl_id][0]["match_plus"] = players_results_h[pl_id][0]["match_plus"] + 1
                        elsif (satzverhaeltnis[0] < satzverhaeltnis[1])
                            players_results_h[pl_id][0]["match_minus"] = players_results_h[pl_id][0]["match_minus"] + 1
                        end
                    end
                end
            
            end

            @players_id_a.each do | pl_id |
                puts "kuck for pl_id  #{pl_id} (b)"
                p players_results_h.inspect
                if !players_results_h[pl_id].nil?
                    match_plus = players_results_h[pl_id][0]["match_plus"]
                    match_minus = players_results_h[pl_id][0]["match_minus"]
                else
                    match_plus = 0
                    match_minus = 0
                end

                matches_player2 = Match.where(:player2_id => pl_id) 
                matches_player2.each do | match |
                    p match
                    ballverhaeltnis = berechne_ballverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
                    satzverhaeltnis = berechne_satzverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
                    if (satzverhaeltnis[0] > satzverhaeltnis[1])
                        match_minus = match_minus + 1
                    elsif (satzverhaeltnis[0] < satzverhaeltnis[1])
                        match_plus = match_plus  + 1
                    end

                    
                    if !players_results_h.has_key?(pl_id)
                        players_results_h[pl_id] = ["match_plus" => match_plus, "match_minus" => match_minus , "name" =>  @players_h[pl_id.to_s], "ball_plus" => ballverhaeltnis[1], "ball_minus" => ballverhaeltnis[0], "satz_plus" => satzverhaeltnis[1], "satz_minus" => satzverhaeltnis[0], "gruppennummer" => gruppennummer ]
                    else
                        players_results_h[pl_id][0]["ball_plus"] = players_results_h[pl_id][0]["ball_plus"] + ballverhaeltnis[1]
                        players_results_h[pl_id][0]["satz_plus"] = players_results_h[pl_id][0]["satz_plus"] + satzverhaeltnis[1]
                        players_results_h[pl_id][0]["ball_minus"] = players_results_h[pl_id][0]["ball_minus"] + ballverhaeltnis[0]
                        players_results_h[pl_id][0]["satz_minus"] = players_results_h[pl_id][0]["satz_minus"] + satzverhaeltnis[0]
                        
                        if (satzverhaeltnis[0] > satzverhaeltnis[1])
                            players_results_h[pl_id][0]["match_minus"] = players_results_h[pl_id][0]["match_minus"] + 1
                        elsif (satzverhaeltnis[0] < satzverhaeltnis[1])
                            players_results_h[pl_id][0]["match_plus"] = players_results_h[pl_id][0]["match_plus"] + 1
                        
                        end
                    
                    end
                end
            end
        else # wenn 0 oder 1 Spieler in der Gruppe, dann wird das Ranking nicht berechnet
            # bei 0 Spieler: nichts machen
            # bei 1 Spieler: Diesen Spieler mit Nullwerten rendern.
            if @players_id_a.size == 1
                player_id = @players_id_a[0]
                players_results_h[player_id] = ["match_plus" => 0, "match_minus" => 0 , "name" =>  @players_h[player_id.to_s], "ball_plus" => 0, "ball_minus" => 0, "satz_plus" => 0, "satz_minus" => 0, "gruppennummer" => gruppennummer ]
                  
            else # 0 Spieler
                # nichts machen
            end
        end

       # Dieser Code verwendet sort_by um den Hash zu sortieren. 
       # Wir sortieren zuerst nach "satz_plus" absteigend (daher das negative Vorzeichen)
       # und dann nach "satz_minus" aufsteigend. 
       # Das Ergebnis wird dann in einen Hash zurückgewandelt, 
       # um die ursprüngliche Struktur beizubehalten.

      #  players_results_sorted_satz_h = Hash[players_results_h.sort_by { |key, value| value.first["satz_plus"] }.to_a].reverse_each
         players_results_sorted_h  = players_results_h.sort_by { |key, value| [-value[0]['satz_plus'], value[0]['satz_minus'], -value[0]['ball_plus'], value[0]['ball_minus'] ] }.to_h
        # players_results_h = {18=>[{"match_plus"=>0, "match_minus"=>3, "name"=>"Peter", "matches"=>"1", "ball_plus"=>51, "ball_minus"=>104, "satz_plus"=>0, "satz_minus"=>9, "gruppennummer"=>"2"}], 
        # 22=>[{"match_plus"=>1, "match_minus"=>2, "name"=>"Winfried", "ball_plus"=>105, "ball_minus"=>106, "satz_plus"=>5, "satz_minus"=>6, "gruppennummer"=>"2"}], 
        # 17=>[{"match_plus"=>2, "match_minus"=>1, "name"=>"Manfred", "matches"=>"1", "ball_plus"=>89, "ball_minus"=>88, "satz_plus"=>7, "satz_minus"=>3, "gruppennummer"=>"2"}], 
        # 9=>[{"match_plus"=>3, "match_minus"=>0, "name"=>"Birgit", "matches"=>"1", "ball_plus"=>121, "ball_minus"=>68, "satz_plus"=>9, "satz_minus"=>3, "gruppennummer"=>"2"}]}
        puts "neuberechnung Gruppe satz fertig: #{players_results_sorted_h.inspect}"
        
        players_results_sorted_h

    end

    def anlegen_matches(gruppennummer)
        @players_in_group = Player.where(:gruppennummer => gruppennummer)
        @players_in_group_a = []
        @players_h = Hash.new
        @players_in_group.each do | player |
            @players_in_group_a << player.id
            @players_h[player.id.to_s] = player.name 
        end
        puts " @players_in_group: #{@players_in_group_a.inspect}"

        # Alle Match-Kombinationen berechnen:
        matches_a = []
        @players_in_group_a.each_with_index do |player1, index1|
            @players_in_group_a.each_with_index do |player2, index2|
              next if index1 >= index2
              matches_a << [player1, player2]
            end
          end
          
          puts "Begegnungen:"
          matches_a.each do |match|
            puts "#{match[0]} vs. #{match[1]}"
          end
           # Alle Match-Kombinationen aus der db (Tabelle matches) abfragen oder in der db speichern, falls noch nicht vorhanden
       # checken ob die Begegnung schon in der db gespeichert ist.
        @matches_in_group_h = Hash.new
        matches_a.each do |player|
            puts "#{player[0]} vs. #{player[1]}"
            if Match.exists?(player1_id: player[0], player2_id: player[1])
                puts "in der db"
                @matches = Match.where(:player1_id => player[0], :player2_id => player[1] )
                matches(@matches)
                
            elsif  Match.exists?(player1_id: player[1], player2_id: player[0])
                puts "in der db"
                @matches = Match.where(:player1_id => player[1], :player2_id => player[0] )
                matches(@matches)
            else
                puts "Spieler " + player[0].to_s  + " vs Spieler " + player[1].to_s + " noch nicht in der db."
                # match in der Tabelle anlegen
                Match.create(:player1_id => player[0], :player2_id => player[1])
                @matches = Match.where(:player1_id => player[0], :player2_id => player[1] )
                matches(@matches)
            end
        end
    end


    def show_results_in_group
        puts "show results in group  #{params[:gruppennummer]}"
        
        anlegen_matches(params[:gruppennummer])

        respond_to do |format|
            format.js
        end
    end

    def sum(a,b)
        sum = a + b;
      
        return sum;
    end

    def matches(matches)
        matches.each do | match |
            ballverhaeltnis = berechne_ballverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
            satzverhaeltnis = berechne_satzverhaeltnis(match.set1, match.set2, match.set3, match.set4, match.set5)
            puts "name #{@players_h[match.player1_id]}"
            if satzverhaeltnis[0] == 3 or satzverhaeltnis[1] == 3
                if sum(satzverhaeltnis[0], satzverhaeltnis[1]) == 4 
                 disabled5 = "disabled"
                elsif sum(satzverhaeltnis[0], satzverhaeltnis[1]) == 5 
                    disabled5 = ""
                    disabled4 = ""
                else # == 3
                    disabled5 = "disabled"
                    disabled4 = "disabled"
                end
            else
                disabled = ""
            end
            @matches_in_group_h[match.id] = [ "player1" => @players_h[match.player1_id], "player2" => @players_h[match.player2_id], "player1_id" => match.player1_id, "player2_id" => match.player2_id, "set1" => match.set1 , "set2" => match.set2, "set3" => match.set3, "set4" => match.set4, "set5" => match.set5, "ball_plus" => ballverhaeltnis[0]  , "ball_minus" => ballverhaeltnis[1] , "satz_plus" => satzverhaeltnis[0], "satz_minus" => satzverhaeltnis[1], "disabled5" => disabled5, "disabled4" => disabled4 ]
        end
      #  p @matches_in_group_h
    end

    def berechne_ballverhaeltnis(set1, set2, set3, set4, set5)
        # berechne ballverhaeltnis
        set_ergebnisse_a = [set1, set2, set3, set4, set5]
        positiv = 0
        negativ = 0
        set_ergebnisse_a.each do | set |
            if !set.nil?
                if set =~ /\+/
                    zahl = set.sub("+","").to_i
                    negativ = negativ + zahl
                    if zahl < 10
                        positiv = positiv + 11
                    else
                        positiv = positiv + zahl + 2
                    end
                else
                   zahl = set.sub("-","").to_i
                   positiv = positiv + zahl
                   if zahl < 10
                        negativ = negativ  + 11
                   else
                        negativ = negativ + zahl  + 2
                   end
                end
            end
        end

        return [positiv, negativ]
    end

    def berechne_satzverhaeltnis(set1, set2, set3, set4, set5)
        set_ergebnisse_a = [set1, set2, set3, set4, set5]
        positiv = 0
        negativ = 0
        set_ergebnisse_a.each do | set |
            if !set.nil?
                if set =~ /\+/
                    
                  positiv = positiv  + 1
                else
                   
                   negativ = negativ + 1
                end
            end
        end

        return [positiv, negativ]
    end


    def remove_group_from_player

        puts "remove group #{params[:gruppennummer]} from player-id: #{params[:id]}"
        @player = Player.find(params[:id])
        @player.update(:gruppennummer => nil)
        delete_all_matches_for_player(params[:id])
       # redirect_to "/players"
       @players = Player.all#.reverse_order
       @players_in_gruppe1_with_results = Hash.new
       @players_in_gruppe2_with_results = Hash.new
       @players_in_gruppe3_with_results = Hash.new
       @players_in_gruppe4_with_results = Hash.new

       @players_in_gruppe1_with_results = berechne_gruppen_ranking("1")
       @players_in_gruppe2_with_results = berechne_gruppen_ranking("2")
       @players_in_gruppe3_with_results = berechne_gruppen_ranking("3")
       @players_in_gruppe4_with_results = berechne_gruppen_ranking("4")
        respond_to do |format|
            format.js
        end
    
    end

    def add_player_to_group

        puts "add player  #{params[:id]} to group  #{params[:gruppennummer]}"
        @player = Player.find(params[:id])
        @player_id = @player.id
        @player.update(:gruppennummer => params[:gruppennummer])

        # alle Spieler finden, die schon in der selben Gruppe sind. 
        # Diese kompletten Gruppe rendern/aktualisieren
        
        @players_group = Player.where(:gruppennummer => params[:gruppennummer])
 

        # Ready: weil ein User eventuell einen Spieler aus einer Gruppe in eine andere schiebt
        # und er hat vlt. schon gespielt, müssen seine matches beim Verschieben gelöscht werden.
        delete_all_matches_for_player(params[:id])

        # Ready: die Matches-Erzeugung der Gruppe hier durchführen, 
        # damit beim Reloaden der Seite der verschobene Spieler in der Gruppe erscheint
        # Es erscheinen nämlich beim Reloaden der Seite (siehe action index) nur die Spieler,
        # deren Matches schon angelegt sind. 
        anlegen_matches(params[:gruppennummer])

        respond_to do |format|
            format.js
        end
    
    end

    def erzeuge_player
        #     @player = Player.new(player_params)
             puts "create player #{params[:player]}"       
             Player.create(:name => params[:player], :gruppennummer => "")
             player = Player.where(:name => params[:player])
          #   @players_group = Player.where(:gruppennummer => params[:gruppennummer])
            if player.exists?
                respond_to do |format|
                    format.js
                  
                end
            end
             
               

    end
    
    def create # wird nicht benutzt
           
                @player = Player.new(player_params)
                   
                puts "create #{params[:id]}"

                if @player.save
                  redirect_to "/"
             
                else
                  # This line overrides the default rendering behavior, which
                  # would have been to render the "create" view.
                  render "new"
                end
         

    
    end

    def show # wird nicht benutzt
        if !params[:id].blank?
            @player = Player.find(params[:id])
     
        end
      
    end

    def new # wird nicht benutzt
        
            @player = Player.new
        
    end

    def update 
        @player = Player.find(params[:id])

        if @player.update(player_params)
            redirect_to "/"
          else
            render 'edit'
          end
      
    end

    def delete_all_matches_for_player(pl_id)
         matches = Match.where(:player1_id => pl_id)
         matches.each do | match |
            match.destroy
         end
         matches = Match.where(:player2_id => pl_id)
         matches.each do | match |
            match.destroy
         end

    end

    def destroy
        @player = Player.find(params[:id])
        @player.destroy
        delete_all_matches_for_player(params[:id])
        redirect_to "/"

    end

    def edit
        @player = Player.find(params[:id])
      end
    


    private

    def player_params
       params.require(:player).permit(:name, :gruppennummer)
        
      end
  


end
